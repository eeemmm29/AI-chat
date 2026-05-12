# Design: Backend User Sync and REST Security

## Goal
Synchronize Firebase users with the local database and secure REST endpoints to ensure users can only access their own data.

## 1. Data Model Updates (`models.py`)
Update the `User` model to include fields for Firebase integration:
- `firebase_uid`: String, unique, index (Primary key for sync)
- `email`: String, index

## 2. Schemas (`schemas.py`)
- Add `UserSync` schema (if needed, though token contains data).
- Update `User` schema to include `firebase_uid` and `email`.

## 3. User Sync Endpoint (`main.py`)
`POST /users/sync`
- Authentication: `Depends(get_current_user)`
- Logic:
  1. Extract `uid`, `email`, and `name` from the decoded token.
  2. Query `User` by `firebase_uid`.
  3. If found: Update `email` and `username` (if changed).
  4. If not found: Create a new `User` with `firebase_uid`, `email`, and `username` (using `name` or email prefix).
  5. Return the `User`.

## 4. REST Security (`main.py`)
Secure the following endpoints with `Depends(get_current_user)` and ownership checks:
- `GET /messages`: Return only messages where `sender` or `recipient` is the `current_user`'s UID or ID.
- `GET /messages/history/{user_id}`: Validate that `{user_id}` matches the `current_user`'s UID or ID.
- `GET /messages/conversation/{user1_id}/{user2_id}`: Validate that one of the IDs matches the `current_user`.
- `GET /messages/search`: Filter results to only include messages involving the `current_user`.

## 5. Verification Plan
- Run existing tests to ensure no regressions.
- Add new tests for:
  - User sync (new user and existing user update).
  - Unauthorized access to other users' messages.
  - Authorized access to own messages.
