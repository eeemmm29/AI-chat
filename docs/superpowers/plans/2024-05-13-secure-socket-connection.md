# Secure Socket.io Connection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Secure the Socket.io connection using Firebase ID tokens and ensure sender integrity.

**Architecture:** Use the Socket.io `auth` handshake to verify Firebase ID tokens, store user info in the socket session, and use that session info to override the sender ID in incoming messages.

**Tech Stack:** Python (FastAPI, python-socketio, firebase-admin), TypeScript (Next.js, socket.io-client).

---

### Task 1: Backend Handshake Authentication

**Files:**
- Modify: `AI-chat-backend/main.py`
- Test: `AI-chat-backend/test_main.py`

- [ ] **Step 1: Update backend test to include auth handshake**

In `AI-chat-backend/test_main.py`, update `test_socketio_send_message` and `test_socketio_typing` to mock Firebase verification and pass a token.

```python
# Modify test_socketio_send_message in AI-chat-backend/test_main.py
@pytest.mark.asyncio
async def test_socketio_send_message(server):
    sio = socketio.AsyncClient()
    messages = []
    
    @sio.on('receive_message')
    async def on_receive_message(data):
        messages.append(data)
        
    # Mocking firebase_admin.auth.verify_id_token
    mock_user = {"uid": "user1", "email": "user1@example.com"}
    with patch("firebase_admin.auth.verify_id_token", return_value=mock_user):
        await sio.connect('http://127.0.0.1:8000', auth={'token': 'valid_token'})
        await sio.emit('send_message', {'sender': 'user1', 'recipient': 'user2', 'content': 'hello ws', 'timestamp': '2023-01-01T10:00:00'})
        await asyncio.sleep(0.1)
    
    assert len(messages) == 1
    # ...
```

- [ ] **Step 2: Run tests to verify they fail (due to missing auth logic in main.py)**

Run: `pytest AI-chat-backend/test_main.py`
Expected: Failures in socket tests because they now expect `auth` but `main.py` doesn't enforce it yet (or might fail if we change `connect` signature).

- [ ] **Step 3: Implement handshake verification in `main.py`**

```python
# Modify AI-chat-backend/main.py

@sio.event
async def connect(sid, environ, auth):
    if not auth or 'token' not in auth:
        print(f"connect {sid} rejected: No token")
        return False
    try:
        decoded_token = auth.verify_id_token(auth['token'])
        await sio.save_session(sid, {'user': decoded_token})
        print(f"connect {sid} (user: {decoded_token['uid']})")
    except Exception as e:
        print(f"connect {sid} rejected: {e}")
        return False
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `pytest AI-chat-backend/test_main.py`

- [ ] **Step 5: Commit**

```bash
git add AI-chat-backend/main.py AI-chat-backend/test_main.py
git commit -m "feat: secure socket.io handshake with firebase tokens"
```

---

### Task 2: Backend Message Handling Security & Alignment

**Files:**
- Modify: `AI-chat-backend/main.py`
- Modify: `AI-chat-backend/test_main.py`

- [ ] **Step 1: Rename `send_message` to `message` and use session UID**

```python
# Modify AI-chat-backend/main.py

@sio.on("message")
async def handle_message(sid, data):
    session = await sio.get_session(sid)
    user = session.get("user")
    if not user:
        return

    # Security: Override sender with UID from session
    data['sender'] = user['uid']
    
    # Handle frontend field names if necessary
    if 'text' in data and 'content' not in data:
        data['content'] = data['text']
    if 'recipient' not in data:
        data['recipient'] = 'general'

    try:
        msg = schemas.MessageCreate(**data)
    except ValidationError as e:
        print(f"Validation error: {e}")
        return

    db = database.SessionLocal()
    # ... rest of the existing logic ...
```

- [ ] **Step 2: Update tests to match the new event name and security**

```python
# Modify test_socketio_send_message in AI-chat-backend/test_main.py
    # ...
    # Use 'message' instead of 'send_message'
    await sio.emit('message', {'recipient': 'user2', 'content': 'hello ws', 'timestamp': '2023-01-01T10:00:00'})
    # ...
```

- [ ] **Step 3: Run tests**

Run: `pytest AI-chat-backend/test_main.py`

- [ ] **Step 4: Commit**

```bash
git add AI-chat-backend/main.py AI-chat-backend/test_main.py
git commit -m "feat: secure message event and align with frontend"
```

---

### Task 3: Frontend Token Handshake & Alignment

**Files:**
- Modify: `AI-chat-frontend/app/page.tsx`

- [ ] **Step 1: Update socket initialization in `page.tsx`**

```typescript
// Modify AI-chat-frontend/app/page.tsx

  useEffect(() => {
    if (!currentUser || !user) return;

    let socketInstance: Socket;

    const initSocket = async () => {
      try {
        const token = await user.getIdToken();
        const socketUrl = process.env.NEXT_PUBLIC_SOCKET_URL || "http://localhost:8000";
        socketInstance = io(socketUrl, {
          auth: { token }
        });
        setSocket(socketInstance);

        socketInstance.on("connect", () => {
          console.log("Connected to server");
        });

        socketInstance.on("message", (message: Message) => {
          setMessages((prev) => [...prev, message]);
        });
        
        socketInstance.on("receive_message", (data: any) => {
          // Map backend receive_message to frontend Message structure
          const formattedMsg: Message = {
            id: data.id.toString(),
            text: data.content,
            senderId: data.sender,
            senderName: data.sender, // We might need to fetch names later
            timestamp: new Date(data.timestamp).getTime(),
          };
          setMessages((prev) => [...prev, formattedMsg]);
        });

        socketInstance.on("typing", (data: { sender: string, is_typing: boolean }) => {
          if (data.sender !== currentUser.id) {
            setIsTyping(data.is_typing ? data.sender : null);
          }
        });
      } catch (error) {
        console.error("Failed to initialize socket:", error);
      }
    };

    initSocket();

    return () => {
      if (socketInstance) socketInstance.close();
      if (typingTimeoutRef.current) clearTimeout(typingTimeoutRef.current);
    };
  }, [currentUser?.id, user]);
```

- [ ] **Step 2: Update `sendMessage` and `handleInputChange` to match backend**

```typescript
  const sendMessage = () => {
    if (!inputText.trim() || !socket || !currentUser) return;

    const payload = {
      content: inputText.trim(),
      recipient: "general",
      timestamp: new Date().toISOString(),
    };

    socket.emit("message", payload);
    setInputText("");

    // Stop typing indicator
    if (typingTimeoutRef.current) clearTimeout(typingTimeoutRef.current);
    socket.emit("typing", { sender: currentUser.id, is_typing: false, recipient: "general" });
  };
```

- [ ] **Step 3: Verify frontend build**

Run: `cd AI-chat-frontend && pnpm build` (or `npm run build`)

- [ ] **Step 4: Commit**

```bash
git add AI-chat-frontend/app/page.tsx
git commit -m "feat: frontend socket security and alignment"
```

---

### Task 4: Final Verification

- [ ] **Step 1: Run all backend tests**
- [ ] **Step 2: Check GEMINI.md for any necessary updates**
