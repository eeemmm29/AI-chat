# Task 1 Fixes: Frontend Login UI and Google Sign-In Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Address Code Quality Reviewer feedback for the frontend authentication implementation.

**Architecture:** Refine the `LoginButton` component with better UX (loading states, error handling), improve type safety in `AuthContext`, and organize icon assets.

**Tech Stack:** React (Next.js), Firebase Auth, HeroUI (Tailwind).

---

### Task 1: Organize Google Icon

**Files:**
- Modify: `AI-chat-frontend/components/icons.tsx`
- Modify: `AI-chat-frontend/components/login-button.tsx`

- [ ] **Step 1: Export GoogleIcon from icons.tsx**
Add the `GoogleIcon` component to `AI-chat-frontend/components/icons.tsx`.

```typescript
export const GoogleIcon: React.FC<IconSvgProps> = ({
  size = 24,
  width,
  height,
  ...props
}) => {
  return (
    <svg
      height={size || height}
      viewBox="0 0 24 24"
      width={size || width}
      {...props}
    >
      <path
        fill="currentColor"
        d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
      />
      <path
        fill="currentColor"
        d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-1 .67-2.28 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
      />
      <path
        fill="currentColor"
        d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
      />
      <path
        fill="currentColor"
        d="M12 5.38c1.62 0 3.06.56 4.21 1.66l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
      />
    </svg>
  );
};
```

- [ ] **Step 2: Use GoogleIcon in LoginButton**
Remove the inline SVG and use the new `GoogleIcon` component in `AI-chat-frontend/components/login-button.tsx`.

```typescript
import { GoogleIcon } from "@/components/icons";
// ... in return:
<GoogleIcon size={16} />
```

- [ ] **Step 3: Commit**
```bash
git add AI-chat-frontend/components/icons.tsx AI-chat-frontend/components/login-button.tsx
git commit -m "refactor: move Google icon to central icons file"
```

### Task 2: Improve Auth Type Safety

**Files:**
- Modify: `AI-chat-frontend/context/auth-context.tsx`

- [ ] **Step 1: Update AuthContextType signature**
Import `UserCredential` and update the `signInWithGoogle` return type.

```typescript
import { onAuthStateChanged, User, GoogleAuthProvider, signInWithPopup, signOut, UserCredential } from "firebase/auth";

interface AuthContextType {
  user: User | null;
  loading: boolean;
  signInWithGoogle: () => Promise<UserCredential>;
  logout: () => Promise<void>;
}
```

- [ ] **Step 2: Verify with tsc**
Run: `pnpm --filter AI-chat-frontend tsc --noEmit`
Expected: SUCCESS

- [ ] **Step 3: Commit**
```bash
git add AI-chat-frontend/context/auth-context.tsx
git commit -m "fix: improve type safety for signInWithGoogle"
```

### Task 3: Add Loading State and Error Handling to LoginButton

**Files:**
- Modify: `AI-chat-frontend/components/login-button.tsx`

- [ ] **Step 1: Implement isLoading state and try/catch**
Add local loading state and wrap auth calls in try/catch.

```typescript
"use client";

import { useState } from "react";
import { Button } from "@heroui/react";
import { useAuth } from "@/context/auth-context";
import { GoogleIcon } from "@/components/icons";

export const LoginButton = () => {
  const { user, signInWithGoogle, logout } = useAuth();
  const [isActionLoading, setIsActionLoading] = useState(false);

  const handleSignIn = async () => {
    setIsActionLoading(true);
    try {
      await signInWithGoogle();
    } catch (error) {
      console.error("Sign-in failed:", error);
      // Optional: alert("Failed to sign in. Please try again.");
    } finally {
      setIsActionLoading(false);
    }
  };

  const handleLogout = async () => {
    setIsActionLoading(true);
    try {
      await logout();
    } catch (error) {
      console.error("Logout failed:", error);
    } finally {
      setIsActionLoading(false);
    }
  };

  if (user) {
    return (
      <Button 
        variant="secondary" 
        onPress={handleLogout}
        isLoading={isActionLoading}
      >
        Logout
      </Button>
    );
  }

  return (
    <Button 
      variant="primary" 
      onPress={handleSignIn}
      className="flex items-center gap-2"
      isLoading={isActionLoading}
    >
      {!isActionLoading && <GoogleIcon size={16} />}
      Sign in with Google
    </Button>
  );
};
```

- [ ] **Step 2: Verify with tsc**
Run: `pnpm --filter AI-chat-frontend tsc --noEmit`
Expected: SUCCESS

- [ ] **Step 3: Commit**
```bash
git add AI-chat-frontend/components/login-button.tsx
git commit -m "fix: add loading states and error handling to LoginButton"
```
