# Project Specification: Profile/Posting app

This small full-stack learning project includes user registration/login via Firebase Authentication, user profile storing in Firestore, backend API (Python) with token verification to create accounts, update profile, and create/view posts (title + description)

## 1. Tech Stack Summary

### Frontend
- React
- AuthContext
- Firebase Auth
- Firestore
- Fetch API

### Backend
- FastAPI
- Firebase Admin SDK
- Pydantic models
- Firestore Admin

## 2. System Overview

The system consists of two components:

### 1. React Frontend (Client)

- Handles Firebase Authentication
- Manages user session with AuthContext
- Writes Firestore for account creation
- Calls backend endpoints with Firebase ID token
- Displays dashboard of posts (with filter for current users posts)
- Allows username change in profile page

### 2. Backend API (Python)

- Verifies Firebase ID tokens using Firebase Admin SDK
- Handles creating and getting posts
- Handles username updates

## 3. Authentication Flow
### Registration

- User enters email, password, username
- Frontend calls createUserWithEmailAndPassword()
- Firebase Auth creates the user
- Frontend writes profile document:
```
/users/{uid}
{
  uid,
  username,
  email,
  created_at
}
```
### Login

- User enters email + password
- signInWithEmailAndPassword()
- Firebase returns logged-in user
- Frontend fetches user profile from backend
- AuthContext merges data into a global currentUser

### Backend Authentication

All backend calls require header "Authorization: Bearer \<Firebase ID token>"


Backend verifies token and extracts uid
and email, returning whatever requested.

## 4. Data Model Specification
### 4.1 User Data
### Stored in Firestore
```
/users/{uid}
  uid
  email
  username
  created_at
```

### Backend — Pydantic User Models
#### User (Firestore document)
```py
class User(BaseModel):
    uid: str
    email: Optional[str] = None
    username: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
```

#### UsernameUpdate (frontend → backend)

```py
class UsernameUpdate(BaseModel):
    username: str
```

### Frontend — TypeScript User Model
```ts
export interface User {
  uid: string;
  email: string;
  username: string;
  created_at: string;
}
```

### 4.2 Post Data

### Posts have:
```
id
user_id
username
title
description
created_at
```
Frontend gets posts from:
`/posts`

### Backend — Pydantic Post Models
#### Post stored in Firestore
```py
class Post(BaseModel):
    id: str
    user_id: str
    username: str
    title: str
    description: str
    created_at: datetime
```
#### PostCreate (frontend → backend)
```py 
class PostCreate(BaseModel):
    title: str
    description: str
```

#### PostListResponse
```py
class PostListResponse(BaseModel):
    posts: list[Post]
```

### Frontend — TypeScript Post Models
#### Post returned from backend
```ts
export interface Post {
  id: string;
  user_id: string;
  username: string;
  title: string;
  description: string;
  created_at: string;
}
```

#### PostCreate (what the frontend sends to backend)
```ts
export interface PostCreate {
  title: string;
  description: string;
}
```
#### PostListResponse (what the backend returns when /posts is called)
```ts
export interface PostListResponse {
  posts: Post[];
}
```

## 5. Frontend Architecture
### 5.1 AuthContext Responsibilities

- subscribe to onAuthStateChanged
- fetch user profile from the backend
- hold current user
- supplies:
  - register(email, password, username)
  - login(email, password)
  - logout()
  - updateUsername()
  - store loading state

## 6. Backend API Specification
POST /posts

Create new post <br>
Headers: Authorization: Bearer \<token> <br>
Body: PostCreate <br>
Response: Post

GET /posts

Return all posts <br>
Response: PostListResponse

PATCH /users/username

Update username
Headers: Authorization: Bearer \<token> <br>
Body: UsernameUpdate

## 7. Firestore Structure

```
users/
  {uid}/
    uid
    username
    email
    created_at

posts/
  {postId}/
    id
    user_id
    title
    description
    created_at
```

## 8. Security Rules (High-Level)
Users:
- Can read their own user profile
- Can update only their username field

Posts:
- Anyone can read posts
- Only authenticated users can create posts
- No one can edit posts (simple app)
