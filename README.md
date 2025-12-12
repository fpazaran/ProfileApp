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

### 3. Backend API (Python)

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
#### UserProfile (Firestore document)
```py
class UserProfile(BaseModel):
    uid: str
    email: Optional[str] = None
    username: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
```

#### UserPublic (returned to frontend)

```py
class UserPublic(BaseModel):
    uid: str
    username: str
```

#### UsernameUpdate (frontend → backend)

```py
class UsernameUpdate(BaseModel):
    username: str
```

### Frontend — TypeScript User Models
#### Firebase user

```ts
export interface FirebaseUser {
  uid: string;
  email?: string | null;
  displayName?: string | null;
}
```

#### Firestore profile

```ts
export interface UserProfile {
  uid: string;
  username: string;
  created_at: string;
}
```

#### Combined AppUser

```ts
export interface AppUser {
  uid: string;
  email?: string | null;
  username: string;
}
```

### 4.2 Post Data

Posts have:

id

user_id

title

description

created_at

Stored at:

/posts/{postId}

Backend — Pydantic Post Models
Post stored in Firestore
class Post(BaseModel):
    id: str
    user_id: str
    title: str
    description: str
    created_at: datetime

PostCreate (frontend → backend)
class PostCreate(BaseModel):
    title: str
    description: str

PostListResponse
class PostListResponse(BaseModel):
    posts: list[Post]

Frontend — TypeScript Post Models
Post returned from backend
export interface Post {
  id: string;
  user_id: string;
  title: string;
  description: string;
  created_at: string;
}

PostCreate
export interface PostCreate {
  title: string;
  description: string;
}

PostListResponse
export interface PostListResponse {
  posts: Post[];
}

## 5. Frontend Architecture
### 5.1 AuthContext Responsibilities

subscribe to onAuthStateChanged

fetch Firestore user profile

expose unified currentUser

supply:

register(email, password, username)

login(email, password)

logout()

updateUsername()

store loading state

## 6. Backend API Specification

Assume FastAPI:

POST /posts

Create new post
Headers: Authorization: Bearer <token>
Body: PostCreate

Response: Post

GET /posts

Return all posts
Headers: Authorization: Bearer <token> (optional if public)

Response: PostListResponse

PATCH /users/me/username

Update username
Headers: token
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

Can read their own user profile

Can update only their username field

Posts:

Anyone logged in can read posts

Only authenticated users can create posts

No one can edit posts (simple app)
