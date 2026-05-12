# Backend User Sync and REST Security Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Synchronize Firebase users with the local database and secure REST endpoints.

**Architecture:** Use SQLAlchemy for database models, Pydantic for schemas, and FastAPI for endpoints. Authentication is handled via Firebase ID tokens. Authorization checks ensure users only access their own data.

**Tech Stack:** FastAPI, SQLAlchemy, Pydantic, Firebase Admin SDK.

---

### Task 1: Update Models and Schemas

**Files:**
- Modify: `AI-chat-backend/models.py`
- Modify: `AI-chat-backend/schemas.py`

- [ ] **Step 1: Update `User` model in `models.py`**

```python
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    firebase_uid = Column(String, unique=True, index=True)
    email = Column(String, index=True)
```

- [ ] **Step 2: Update `User` schemas in `schemas.py`**

```python
class UserBase(BaseModel):
    username: str
    firebase_uid: str | None = None
    email: str | None = None

class UserCreate(UserBase):
    pass

class User(UserBase):
    id: int

    model_config = ConfigDict(from_attributes=True)
```

- [ ] **Step 3: Commit**

```bash
git add AI-chat-backend/models.py AI-chat-backend/schemas.py
git commit -m "feat: update user models and schemas for firebase sync"
```

### Task 2: Implement User Sync Endpoint

**Files:**
- Modify: `AI-chat-backend/main.py`
- Test: `AI-chat-backend/test_main.py`

- [ ] **Step 1: Write tests for `/users/sync`**

```python
def test_sync_new_user(client):
    # Mock firebase token decode
    # POST /users/sync
    # Assert 200, check db for new user
```

- [ ] **Step 2: Implement `POST /users/sync` in `main.py`**

```python
@fastapi_app.post("/users/sync", response_model=schemas.User)
def sync_user(current_user: dict = Depends(get_current_user), db: Session = Depends(database.get_db)):
    uid = current_user.get("uid")
    email = current_user.get("email")
    name = current_user.get("name") or email.split("@")[0]
    
    db_user = db.query(models.User).filter(models.User.firebase_uid == uid).first()
    if db_user:
        db_user.email = email
        db_user.username = name
    else:
        db_user = models.User(firebase_uid=uid, email=email, username=name)
        db.add(db_user)
    
    db.commit()
    db.refresh(db_user)
    return db_user
```

- [ ] **Step 3: Run tests and verify**

Run: `uv run pytest AI-chat-backend/test_main.py`

- [ ] **Step 4: Commit**

```bash
git add AI-chat-backend/main.py AI-chat-backend/test_main.py
git commit -m "feat: implement user sync endpoint"
```

### Task 3: Secure Message Endpoints

**Files:**
- Modify: `AI-chat-backend/main.py`
- Test: `AI-chat-backend/test_main.py`

- [ ] **Step 1: Update message endpoints to use `get_current_user` and ownership checks**

Modify `get_messages_history`, `get_messages_conversation`, etc.

- [ ] **Step 2: Write tests for unauthorized access**

- [ ] **Step 3: Run all tests**

- [ ] **Step 4: Commit**

```bash
git add AI-chat-backend/main.py AI-chat-backend/test_main.py
git commit -m "feat: secure message endpoints"
```
