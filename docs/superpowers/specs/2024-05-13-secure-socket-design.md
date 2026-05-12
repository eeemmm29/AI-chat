# Design Doc: Secure Socket.io Connection

## Goal
Secure the Socket.io connection by requiring a Firebase ID token during the handshake and verifying it on the backend. Ensure message integrity by using the authenticated UID from the socket session.

## Architecture

### Backend (FastAPI + python-socketio)
- **Handshake Verification**: The `connect` event handler will be updated to accept an `auth` argument. It will expect a `token` field containing a Firebase ID token.
- **Session Management**: Upon successful verification, the user's decoded token (including `uid`) will be stored in the socket session using `sio.save_session`.
- **Message Integrity**: The message event handler (renamed to `message` for frontend alignment) will retrieve the `uid` from the session and use it to set the `sender` field, ignoring any sender info provided in the client payload.

### Frontend (Next.js + socket.io-client)
- **Token Retrieval**: The frontend will use the Firebase SDK (`user.getIdToken()`) to get a fresh token before establishing the socket connection.
- **Secure Handshake**: The token will be passed in the `auth` object during the `io()` call.
- **Event Alignment**: Socket events and payloads will be updated to match the backend expectations (using `message` event and `content`/`recipient` fields).

## Data Flow
1. Client calls `user.getIdToken()`.
2. Client calls `io(url, { auth: { token } })`.
3. Backend `connect` handler receives `auth`, calls `auth.verify_id_token(token)`.
4. If valid, backend saves user to session and accepts connection.
5. Client emits `message` with `{ content, recipient, timestamp }`.
6. Backend `message` handler gets `uid` from session, adds `sender: uid` to payload, and saves to DB.
7. Backend broadcasts `receive_message` to all clients.

## Error Handling
- **Missing/Invalid Token**: Backend returns `False` in `connect` handler, causing the client to receive a connection error.
- **Expired Token**: Client should ideally refresh the token, but for this task, a reconnection attempt with a fresh token will be triggered if the user object changes.

## Testing Plan
- **Backend**: 
    - Mock `firebase_admin.auth.verify_id_token`.
    - Test `connect` with valid token.
    - Test `connect` with invalid/missing token.
    - Test `message` event ensures `sender` matches session UID.
- **Frontend**: 
    - Verify that `io` is called with the correct `auth` object.
    - Verify that messages are sent with the updated payload structure.
