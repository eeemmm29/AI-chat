# Firebase Auth Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate Firebase Auth into the Next.js frontend by creating an AuthContext and wrapping the application with an AuthProvider.

**Architecture:** Use React Context to share authentication state. Listen to Firebase `onAuthStateChanged` to keep the state in sync.

**Tech Stack:** React 19, Next.js 16 (App Router), Firebase 12.

---

### Task 1: Create AuthContext

**Files:**
- Create: `AI-chat-frontend/context/auth-context.tsx`

- [ ] **Step 1: Create the AuthContext file**

```tsx
"use client";

import React, { createContext, useContext, useEffect, useState, ReactNode } from "react";
import { onAuthStateChanged, User } from "firebase/auth";
import { auth } from "@/config/firebase";

interface AuthContextType {
  user: User | null;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  return (
    <AuthContext.Provider value={{ user, loading }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};
```

- [ ] **Step 2: Commit**

```bash
git add AI-chat-frontend/context/auth-context.tsx
git commit -m "feat: add AuthContext and AuthProvider"
```

---

### Task 2: Wrap Application with AuthProvider

**Files:**
- Modify: `AI-chat-frontend/app/providers.tsx`

- [ ] **Step 1: Update Providers component**

```tsx
"use client";

import type { ThemeProviderProps } from "next-themes";

import * as React from "react";
import { ThemeProvider as NextThemesProvider } from "next-themes";
import { AuthProvider } from "@/context/auth-context";

export interface ProvidersProps {
  children: React.ReactNode;
  themeProps?: ThemeProviderProps;
}

export function Providers({ children, themeProps }: ProvidersProps) {
  return (
    <AuthProvider>
      <NextThemesProvider {...themeProps}>{children}</NextThemesProvider>
    </AuthProvider>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add AI-chat-frontend/app/providers.tsx
git commit -m "feat: wrap application with AuthProvider"
```

---

### Task 3: Verification

- [ ] **Step 1: Run type check**

Run: `pnpm tsc --noEmit` from `AI-chat-frontend` directory.
Expected: No errors.

- [ ] **Step 2: Final commit**

```bash
git add AI-chat-frontend/app/providers.tsx AI-chat-frontend/context/auth-context.tsx
git commit -m "chore: verify firebase auth integration"
```
