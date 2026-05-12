# AI Chat Application

A modern, real-time AI chat application featuring a robust backend API and a highly responsive frontend user interface.

## 🔗 Links
- **Live Website:** [Insert Live Website Link Here]
- **YouTube Demo:** [Insert YouTube Demo Video Link Here]

## ✨ Features
- Real-time messaging capabilities
- Modern, responsive, and accessible user interface
- Fast and reliable backend API
- Efficient package and environment management

## 🛠️ Tech Stack
- **Backend:** Python FastAPI, PostgreSQL / SQLite, Socket.io, uv (for Python environment management)
- **Frontend:** Next.js App Router, HeroUI v3, PNPM (Package Manager)

## 🚀 How to Run Locally

### Prerequisites
- [uv](https://docs.astral.sh/uv/) - Python package and environment manager
- [Node.js](https://nodejs.org/) and [PNPM](https://pnpm.io/) - JavaScript runtime and package manager

### 1. Backend Setup
Navigate to the backend directory, install dependencies, and start the development server using `uv`:

```bash
cd AI-chat-backend
uv run uvicorn main:app --reload
```
*The backend API will be available at `http://localhost:8000`.*

### 2. Frontend Setup
Open a new terminal window, navigate to the frontend directory, install dependencies, and start the development server:

```bash
cd AI-chat-frontend
pnpm install
pnpm dev
```
*The frontend application will be available at `http://localhost:3000`.*
