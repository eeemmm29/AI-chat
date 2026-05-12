# Full Firebase Auth & Session Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement full user authentication and session management using Firebase, securing both REST and Socket.io communication.

**Architecture:**
- **Frontend:** Use Firebase Web SDK for Google Sign-In. Manage session in `AuthContext`. Secure Socket.io connection by passing the ID token in the `auth` handshake.
- **Backend:** Verify tokens in REST dependencies and Socket.io `connect` events. Map Firebase `uid` to local `User` records for message history.

**Tech Stack:** Next.js, HeroUI, Firebase SDK, FastAPI, Python-Socketio, SQLAlchemy.

---

### Task 1: Frontend Login UI and Google Sign-In

**Files:**
- Modify: `AI-chat-frontend/context/auth-context.tsx`
- Create: `AI-chat-frontend/components/login-button.tsx`
- Modify: `AI-chat-frontend/app/page.tsx`

- [ ] **Step 1: Add Sign-In Logic to AuthContext**
Add `signInWithGoogle` and `logout` functions to `AuthContext`.
```typescript
import { GoogleAuthProvider, signInWithPopup, signOut } from "firebase/auth";
// ...
const signInWithGoogle = () => {
  const provider = new GoogleAuthProvider();
  return signInWithPopup(auth, provider);
};
const logout = () => signOut(auth);
// Expose in context
```

- [ ] **Step 2: Create Login Button Component**
Create a button using HeroUI to trigger sign-in.

- [ ] **Step 3: Guard the Main Page**
Update `app/page.tsx` to show the Login Button if `user` is null, otherwise show the Chat UI.

- [ ] **Step 4: Commit**
```bash
git add AI-chat-frontend/
git commit -m "feat: add google sign-in and auth guarding to frontend"
```

### Task 2: Backend User Sync and REST Security

**Files:**
- Modify: `AI-chat-backend/models.py`
- Modify: `AI-chat-backend/schemas.py`
- Modify: `AI-chat-backend/main.py`

- [ ] **Step 1: Update User Model**
Add `firebase_uid` (String, unique) and `email` to `models.py`.

- [ ] **Step 2: Implement User Sync Endpoint**
Create `POST /users/sync`. This endpoint verifies the ID token and creates a local user if the `firebase_uid` doesn't exist.
```python
@fastapi_app.post("/users/sync")
async def sync_user(current_user = Depends(get_current_user), db: Session = Depends(get_db)):
    # Check if user exists by current_user['uid']
    # If not, create
```

- [ ] **Step 3: Secure Message Endpoints**
Ensure `GET /messages/*` endpoints use `get_current_user` to restrict access or identify the caller.

- [ ] **Step 4: Commit**
```bash
git add AI-chat-backend/
git commit -m "feat: implement user sync and secure rest endpoints"
```

### Task 3: Secure Socket.io Connection

**Files:**
- Modify: `AI-chat-backend/main.py`
- Modify: `AI-chat-frontend/app/page.tsx`

- [ ] **Step 1: Authenticate Socket Handshake**
In `AI-chat-backend/main.py`, update the `connect` event to verify the token passed in `auth`.
```python
@sio.on("connect")
async def connect(sid, environ, auth):
    token = auth.get("token")
    try:
        decoded_token = auth_verify.verify_id_token(token)
        await sio.save_session(sid, {"user": decoded_token})
    except:
        return False # Reject connection
```

- [ ] **Step 2: Pass Token from Frontend**
Update `AI-chat-frontend/app/page.tsx` to pass the Firebase ID token during socket initialization.
```typescript
const token = await user.getIdToken();
const newSocket = io(URL, { auth: { token } });
```

- [ ] **Step 3: Update send_message Event**
Use the `uid` from the socket session instead of trusting the payload's `sender` field.

- [ ] **Step 4: Commit**
```bash
git add .
git commit -m "feat: secure socket.io connection with firebase tokens"
```
