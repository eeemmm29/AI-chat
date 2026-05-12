# Chat Website Orchestration

This is the main orchestration repository for the Chat Website project.

## Architecture
- **Backend**: FastAPI with PostgreSQL and Socket.io for real-time messaging. Located in `/AI-chat-backend`.
- **Frontend**: Next.js App Router with HeroUI v3. Located in `/AI-chat-frontend`.
- **Infrastructure**: GCP (Cloud Run, Cloud SQL) configured via Terraform in `/terraform`.

## API Design & Events
For complete API and Socket.io definitions, see `/AI-chat-backend/GEMINI.md`.

## Workflow Guidelines
- Ensure any backend changes update the `/AI-chat-backend/GEMINI.md`.
- Ensure frontend adheres to HeroUI specifications.
- Ensure strict separation of concerns between frontend and backend submodules.
- **Commit Frequency**: Make frequent, small commits throughout the implementation process to maintain a clear and granular project history.