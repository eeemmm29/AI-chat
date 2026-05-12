# Backend User Sync and REST Security Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix issues identified by Code Quality Reviewer: remove redundant endpoint, fix timestamp data loss in messages, and improve email/username fallback logic.

**Architecture:** Surgical updates to FastAPI endpoints and Pydantic schemas.

**Tech Stack:** FastAPI, Pydantic, SQLAlchemy, Firebase Admin SDK.

---

### Task 1: Remove Redundant /users/register Endpoint

**Files:**
- Modify: `AI-chat-backend/main.py`
- Modify: `AI-chat-backend/test_main.py`

- [ ] **Step 1: Remove register_user endpoint in main.py**

```python
<<<<
@fastapi_app.post("/users/register", response_model=schemas.User)
def register_user(user: schemas.UserCreate, db: Session = Depends(database.get_db)):
    db_user = models.User(username=user.username)
    try:
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="Username already registered")
====
>>>>
```

- [ ] **Step 2: Remove related tests in test_main.py**
Remove `test_register_user` and update other tests that use `/users/register` (e.g., `test_get_users`, `test_search_users`) to use a direct DB insert or `/users/sync` if applicable. Since those tests are for testing list/search, I will change them to use direct DB inserts for setup.

- [ ] **Step 3: Run tests to verify removal**
Run: `uv run pytest AI-chat-backend/test_main.py`
Expected: Tests should pass (after updating them).

### Task 2: Fix Message Timestamp Data Loss

**Files:**
- Modify: `AI-chat-backend/schemas.py`

- [ ] **Step 1: Add timestamp field to MessageCreate schema**

```python
class MessageCreate(BaseModel):
    sender: str
    recipient: str
    content: str
    timestamp: str  # Add this field
```

- [ ] **Step 2: Run existing socketio test to verify it still works**
Run: `uv run pytest AI-chat-backend/test_main.py::test_socketio_send_message`
Expected: PASS. The test already sends a timestamp.

### Task 3: Improve Email/Username Fallback in sync_user

**Files:**
- Modify: `AI-chat-backend/main.py`

- [ ] **Step 1: Update sync_user logic for fallbacks**

```python
@fastapi_app.post("/users/sync", response_model=schemas.User)
async def sync_user(current_user: dict = Depends(get_current_user), db: Session = Depends(database.get_db)):
    email = current_user.get("email")
    name = current_user.get("name")
    uid = current_user["uid"]
    
    # Fallback logic
    if not name:
        if email:
            name = email.split("@")[0]
        else:
            name = f"user_{uid[:8]}"
            
    db_user = db.query(models.User).filter(models.User.firebase_uid == uid).first()
    if db_user:
        db_user.email = email
        db_user.username = name
        db.commit()
        db.refresh(db_user)
        return db_user
    
    new_user = models.User(
        username=name,
        firebase_uid=uid,
        email=email
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user
```

- [ ] **Step 2: Add test case for missing email/name in sync_user**
Add `test_sync_user_no_email_no_name` to `test_main.py`.

- [ ] **Step 3: Run all tests**
Run: `uv run pytest AI-chat-backend/test_main.py`
Expected: ALL PASS.

### Task 4: Final Verification and Commit

- [ ] **Step 1: Run all tests one last time**
Run: `uv run pytest AI-chat-backend/test_main.py`

- [ ] **Step 2: Commit changes**
Run: `git add . && git commit -m "fix: remove redundant register endpoint and fix message schema timestamps"` (In AI-chat-backend)
