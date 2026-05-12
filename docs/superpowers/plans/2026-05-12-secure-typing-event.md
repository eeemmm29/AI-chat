# Secure Typing Event Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Secure the `typing` Socket.io event by overriding the `sender` field with the verified UID from the session, preventing users from spoofing their identity.

**Architecture:** Modify the `typing` event handler in the backend to retrieve the user's UID from the Socket.io session and inject it into the event data before broadcasting.

**Tech Stack:** Python, FastAPI, python-socketio, pytest

---

### Task 1: Reproduce Security Flaw with Failing Test

**Files:**
- Modify: `AI-chat-backend/test_main.py`

- [ ] **Step 1: Write a failing test for `typing` spoofing**

```python
# In AI-chat-backend/test_main.py

@pytest.mark.asyncio
async def test_socketio_typing_spoofing(server):
    sio1 = socketio.AsyncClient()
    sio2 = socketio.AsyncClient()
    
    events = []
    @sio2.on('typing')
    async def on_typing(data):
        events.append(data)
    
    mock_user1 = {"uid": "real_user1", "email": "user1@example.com"}
    mock_user2 = {"uid": "user2", "email": "user2@example.com"}
    
    with patch("firebase_admin.auth.verify_id_token") as mock_verify:
        mock_verify.side_effect = [mock_user1, mock_user2]
        await sio1.connect('http://127.0.0.1:8000', auth={'token': 'token1'})
        await sio2.connect('http://127.0.0.1:8000', auth={'token': 'token2'})
    
    # User 1 attempts to spoof User 3
    await sio1.emit('typing', {'sender': 'spoofed_user3', 'recipient': 'user2'})
    await asyncio.sleep(0.1)
    
    assert len(events) == 1
    # This should FAIL initially because the backend currently just broadcasts the raw data
    assert events[0]['sender'] == 'real_user1' 
    
    await sio1.disconnect()
    await sio2.disconnect()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `uv run pytest AI-chat-backend/test_main.py::test_socketio_typing_spoofing`
Expected: FAIL (AssertionError: 'spoofed_user3' == 'real_user1')

### Task 2: Implement Fix in Backend

**Files:**
- Modify: `AI-chat-backend/main.py`

- [ ] **Step 1: Update `typing` handler to use session UID**

```python
# In AI-chat-backend/main.py

@sio.event
async def typing(sid, data):
    session = await sio.get_session(sid)
    user = session.get("user")
    if not user:
        return
    
    # Security: Override sender with UID from session
    data['sender'] = user['uid']
    await sio.emit('typing', data, skip_sid=sid)
```

- [ ] **Step 2: Run test to verify it passes**

Run: `uv run pytest AI-chat-backend/test_main.py::test_socketio_typing_spoofing`
Expected: PASS

- [ ] **Step 3: Run all backend tests**

Run: `uv run pytest AI-chat-backend/`
Expected: All tests pass

### Task 3: Finalize and Commit

- [ ] **Step 1: Remove the added test case from `test_main.py` or keep it as a regression test** (Prefer keeping it, but maybe clean up `test_socketio_typing` if it's redundant).

- [ ] **Step 2: Commit backend changes**

```bash
cd AI-chat-backend
git add main.py test_main.py
git commit -m "feat: secure typing event and socket messages with verified session uid"
```

- [ ] **Step 3: Commit frontend changes (as requested in task description, even if already done or if any adjustments are needed)**
*Note: The task description says "Commit the changes in both submodules", and gives a frontend message "feat: pass firebase id token in socket handshake". I should check if there are any pending frontend changes.*

```bash
cd AI-chat-frontend
git add .
git commit -m "feat: pass firebase id token in socket handshake"
```
