# Chat Website

**Role:** You are an expert Full-Stack Engineer and Architect.

**Project Goal:** Build a working chat website with a Python FastAPI backend in a single "speed-building" session. Success is evaluated on Al efficiency, speed, and product completeness.

**Architecture:**

1. **Main Repo:** Manages orchestration, global `README.md`, and the `terraform/` directory.
2. **Backend Submodule (`/backend`):** Python FastAPI. Must be testable and use **PostgreSQL** for all data storage (users, messages, history).

3. **Frontend Submodule (`/frontend`):** Next.js (App Router), TypeScript, PNPM. Use **HeroUI v3** for all UI components to ensure a "Clean basic design".

**Technical Specifications:**

* **Real-time:** Use `socketio` for real-time messaging (send/receive).

* **Database:** **PostgreSQL** is the source of truth for user management and message history.

* **Auth:** Implement a simple "Username-based" registration and session management.

**Infrastructure (GCP + Terraform):**

* Use Terraform to deploy the Backend to **Cloud Run** and the Frontend to **Cloud Run** or **Firebase Hosting**.

* Ensure resources (like Cloud SQL or a managed PostgreSQL instance) are configured to maximize the **GCP Free Tier** limits.

**Implementation Instructions:**

1. **GEMINI.md Strategy:** Before writing implementation code, create a `GEMINI.md` in each repository. Define the API endpoints for users/messages  and the Socket.io event list (e.g., `send_message`, `receive_message`).

2. **Feature Checklist:** You must implement all required features:

    * **User Management:** Add/register, search, and list users.

    * **Messaging:** Send/receive messages, chat history, search messages, and filter by user/conversation.

    * **Frontend UI:** Input box, user search, chat window, and clean design.

3. **Additional Features:** Once core features are stable, implement **Dark Mode** and **Typing Indicators**  using HeroUI's built-in states.

4. **Documentation (The Final Step):** Generate a professional `README.md` that includes:

    * Project title and description.

    * Full tech stack and features list.

    * Step-by-step "How to run locally" instructions.

    * Placeholders for the Live website link and YouTube demo video link.

**Step 1:** Start by initializing the project structure, submodules, and the `GEMINI.md` architecture files. Do not proceed to full code implementation until the structure is confirmed.
