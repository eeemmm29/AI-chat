# Firebase Auth & Minimal GCP Terraform Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Firebase Authentication and set up minimal GCP infrastructure using Terraform.

**Architecture:** Use Terraform to manage GCP Identity Platform (Firebase Auth equivalent) and Cloud Run for hosting. Update FastAPI to verify Firebase ID tokens and Next.js to use the Firebase Web SDK.

**Tech Stack:** Terraform (GCP Provider), Google Cloud Identity Platform, Firebase SDK, FastAPI, Next.js.

---

### Task 1: Minimal Terraform Infrastructure

**Files:**
- Create: `terraform/main.tf`
- Create: `terraform/variables.tf`
- Create: `terraform/outputs.tf`

- [ ] **Step 1: Define Variables**
Create `terraform/variables.tf` with project_id and region.
```hcl
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}
```

- [ ] **Step 2: Create Main Configuration**
Create `terraform/main.tf` to enable Identity Platform and Cloud Run APIs.
```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "identityplatform" {
  service = "identitytoolkit.googleapis.com"
}

resource "google_project_service" "cloudrun" {
  service = "run.googleapis.com"
}

resource "google_identity_platform_config" "default" {
  project = var.project_id
  depends_on = [google_project_service.identityplatform]
}
```

- [ ] **Step 3: Define Outputs**
Create `terraform/outputs.tf`.
```hcl
output "project_id" {
  value = var.project_id
}
```

- [ ] **Step 4: Commit**
```bash
git add terraform/*.tf
git commit -m "infra: add minimal terraform config for gcp and identity platform"
```

### Task 2: Firebase SDK Frontend Integration

**Files:**
- Modify: `AI-chat-frontend/package.json`
- Create: `AI-chat-frontend/config/firebase.ts`
- Modify: `AI-chat-frontend/app/providers.tsx`

- [ ] **Step 1: Install Firebase SDK**
Run: `cd AI-chat-frontend && pnpm add firebase`

- [ ] **Step 2: Initialize Firebase Client**
Create `AI-chat-frontend/config/firebase.ts`.
```typescript
import { initializeApp, getApps } from "firebase/app";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];
export const auth = getAuth(app);
```

- [ ] **Step 3: Update Providers for Auth State**
Wrap application in an Auth Provider (conceptually).

- [ ] **Step 4: Commit**
```bash
git add AI-chat-frontend/
git commit -m "feat: integrate firebase sdk on frontend"
```

### Task 3: Backend Firebase Token Verification

**Files:**
- Modify: `AI-chat-backend/pyproject.toml`
- Modify: `AI-chat-backend/main.py`

- [ ] **Step 1: Install Firebase Admin SDK**
Run: `cd AI-chat-backend && uv add firebase-admin`

- [ ] **Step 2: Implement Token Verification Middleware/Dependency**
In `AI-chat-backend/main.py`, add a dependency to verify the `Authorization: Bearer <token>` header.
```python
import firebase_admin
from firebase_admin import auth, credentials
from fastapi import Header, HTTPException

# Initialize Firebase Admin (using default credentials or project ID)
try:
    firebase_admin.get_app()
except ValueError:
    firebase_admin.initialize_app()

async def verify_firebase_token(authorization: str = Header(None)):
    if not authorization or not authorization.startsWith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid token")
    token = authorization.split(" ")[1]
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")
```

- [ ] **Step 3: Commit**
```bash
git add AI-chat-backend/
git commit -m "feat: add firebase token verification to backend"
```
