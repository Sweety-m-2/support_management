# Support Ticket Dashboard

A full-stack Support Ticket Dashboard built as part of the Full-stack Web Application Developer assignment.

The project contains:

* Flutter frontend for the UI
* FastAPI backend for REST APIs
* SQLAlchemy for database access
* Alembic for database migrations
* SQLite for local development
* PostgreSQL for the deployed environment
* Search, filtering, sorting, pagination
* Ticket creation and updates
* Dataset-wide summary counts

---

## Quick Start

The fastest way to run the application locally is to use the default SQLite database.

### Prerequisites

Install the following:

* Python 3.10+
* Flutter SDK
* Git
* pip

PostgreSQL is **not required for local development**, because the application uses SQLite by default.

### 1. Clone the repository

```bash
git clone https://github.com/Sweety-m-2/support_management.git
cd support_management
```

### 2. Start the backend

Open a terminal:

```bash
cd backend
```

Create and activate a virtual environment.

#### Windows PowerShell

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

#### macOS/Linux

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install the backend dependencies:

```bash
pip install -r requirements.txt
```

Run the database migration:

```bash
alembic upgrade head
```

Optional: populate the local database with sample tickets:

```bash
python seed.py
```

Start the FastAPI server:

```bash
uvicorn app.main:app --reload
```

The backend will normally be available at:

```text
http://localhost:8000
```

FastAPI Swagger documentation:

```text
http://localhost:8000/docs
```

ReDoc documentation:

```text
http://localhost:8000/redoc
```

### 3. Start the Flutter frontend

Open a **second terminal** from the project root:

```bash
cd frontend
```

Install Flutter dependencies:

```bash
flutter pub get
```

Check the Flutter environment:

```bash
flutter doctor
```

Run the application:

```bash
flutter run
```

The Flutter application will use the local backend:

```text
http://localhost:8000
```

### 4. Run against the deployed backend

The deployed FastAPI backend is:

```text
https://support-management-9jfs.onrender.com
```

From the `frontend/` directory, run:

```bash
flutter run --dart-define=API_BASE_URL=https://support-management-9jfs.onrender.com
```

The frontend automatically adds `/api/tickets` to the configured base URL.

Do **not** include `/api/tickets` in `API_BASE_URL`.

### Quick Start Summary

```text
Terminal 1 - Backend

cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
alembic upgrade head
python seed.py
uvicorn app.main:app --reload
```

```text
Terminal 2 - Frontend

cd frontend
flutter pub get
flutter run
```

After starting both services, the Flutter application can be used to create, search, filter, sort, paginate, and update tickets.

---

# Features

## Ticket Creation

* Create a support ticket
* Required title
* Title maximum length of 120 characters
* Required description
* Customer email validation
* Priority:

  * Low
  * Medium
  * High
* Status:

  * Open
  * In Progress
  * Resolved
* New tickets default to `Open`
* `created_at` and `updated_at` are generated automatically
* Validation is performed by the backend and supported by the frontend

## Ticket Listing

* Search by ticket title or customer email
* Filter by status
* Filter by priority
* Combine search and filters
* Sort by creation time:

  * Newest
  * Oldest
* Server-side pagination
* 10 tickets per page by default

## Ticket Details and Updates

* View complete ticket details
* Update ticket status
* Update ticket priority
* Changes are persisted in the database

## Summary

The ticket listing API also returns summary counts for the entire dataset, independent of the current search, filter, or pagination state.

Summary values include:

* Total tickets
* Open tickets
* In Progress tickets
* Resolved tickets

---

# Technology Stack

## Frontend

* Flutter
* Dart
* `http`
* Flutter BLoC/Cubit for state management

## Backend

* Python
* FastAPI
* Uvicorn
* SQLAlchemy
* Pydantic
* Alembic

## Database

* SQLite for local development
* PostgreSQL for the deployed environment

## Deployment

* Render Web Service for FastAPI
* Render PostgreSQL for persistent storage

---

# Project Structure

```text
support_management/
│
├── frontend/                         # Flutter application
│   ├── lib/
│   │   ├── main.dart
│   │   │
│   │   ├── config/
│   │   │   └── api_config.dart       # API base URL configuration
│   │   │
│   │   ├── models/
│   │   │   └── ticket.dart            # Ticket models / JSON mapping
│   │   │
│   │   ├── services/
│   │   │   ├── api_client.dart
│   │   │   └── ticket_api_service.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── ticket_list_screen.dart
│   │   │   ├── create_ticket_screen.dart
│   │   │   └── ticket_detail_screen.dart
│   │   │
│   │   └── widgets/
│   │       ├── ticket_card.dart
│   │       ├── summary_cards.dart
│   │       └── ticket_filters.dart
│   │
│   └── pubspec.yaml
│
├── backend/                          # FastAPI application
│   ├── app/
│   │   ├── main.py                   # FastAPI application entry point
│   │   ├── database.py               # SQLAlchemy engine/session setup
│   │   │
│   │   ├── models/
│   │   │   └── ticket_model.py       # SQLAlchemy Ticket model
│   │   │
│   │   ├── schemas/
│   │   │   └── ticket_schema.py      # Pydantic request/response schemas
│   │   │
│   │   ├── routes/
│   │   │   └── tickets_route.py      # Ticket API routes
│   │   │
│   │   └── services/
│   │       └── ticket_service.py     # Business/database operations
│   │
│   ├── alembic/
│   │   ├── versions/
│   │   │   └── create_001_tickets.py # Ticket table migration
│   │   ├── env.py
│   │   └── script.py.mako
│   │
│   ├── alembic.ini
│   ├── seed.py                       # Inserts sample tickets
│   └── requirements.txt
│
├── .gitignore
├── README.md
└── SUBMISSION_NOTES.md
```

The exact Flutter file list may vary slightly as the UI evolves.

The backend follows a layered structure separating routes, schemas, models, services, and database configuration.

---

# Backend Setup

## Prerequisites

Install:

* Python 3.10+
* pip
* Git
* Flutter SDK

PostgreSQL is only required if you want to run the backend against PostgreSQL locally.

The default local configuration uses SQLite, so PostgreSQL is not required for basic local development.

## Create a Python Virtual Environment

From the `backend/` directory:

### Windows PowerShell

```powershell
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
```

### macOS/Linux

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
```

## Install Backend Dependencies

```bash
pip install -r requirements.txt
```

---

# Backend Environment Variables

The backend supports the following environment variable:

## `DATABASE_URL`

### Local Development

If `DATABASE_URL` is not provided, the application uses:

```text
sqlite:///./support_tickets.db
```

No PostgreSQL installation is required for local development.

### PostgreSQL / Render

For the deployed environment, configure:

```text
DATABASE_URL=<PostgreSQL connection URL>
```

For example:

```powershell
$env:DATABASE_URL="postgresql://username:password@host/database"
```

Use the actual database connection string for the environment being configured.

Never commit database credentials to Git.

---

# Database Migrations

Alembic is used to manage database schema changes.

## Apply Existing Migrations

From `backend/`:

```bash
alembic upgrade head
```

This creates the required database schema, including the tickets table.

## Create a New Migration

After changing SQLAlchemy models:

```bash
alembic revision --autogenerate -m "describe your change"
```

Review the generated migration before applying it.

Then run:

```bash
alembic upgrade head
```

---

# Seed Test Data

The project includes `backend/seed.py` for creating sample support tickets.

After applying the migrations:

```bash
python seed.py
```

The seed script currently inserts sample tickets for demonstrating:

* Pagination
* Search
* Filtering
* Sorting
* Summary counts

Avoid running the seed script repeatedly unless the script has duplicate protection.

---

# Run the FastAPI Backend Locally

From `backend/`:

```bash
uvicorn app.main:app --reload
```

The API will normally be available at:

```text
http://localhost:8000
```

Swagger:

```text
http://localhost:8000/docs
```

ReDoc:

```text
http://localhost:8000/redoc
```

For Render, the service uses:

```bash
uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

---

# API Endpoints

The project uses three main ticket API endpoints.

## 1. Create Ticket

```http
POST /api/tickets
```

Example request:

```json
{
  "title": "Payment failed",
  "description": "The customer could not complete the payment.",
  "customer_email": "customer@example.com",
  "priority": "High"
}
```

A newly created ticket defaults to:

```text
status = Open
```

## 2. List Tickets

```http
GET /api/tickets
```

Supported query parameters:

| Parameter  | Description                 | Example             |
| ---------- | --------------------------- | ------------------- |
| `search`   | Search title/customer email | `payment`           |
| `status`   | Filter by status            | `Open`              |
| `priority` | Filter by priority          | `High`              |
| `sort`     | Creation order              | `newest` / `oldest` |
| `page`     | Page number                 | `1`                 |
| `limit`    | Items per page              | `10`                |

Example:

```text
GET /api/tickets?search=payment&status=Open&priority=High&sort=newest&page=1&limit=10
```

The response contains:

* Current page tickets
* Filtered total used for pagination
* Page number
* Page size
* Total pages
* Dataset-wide summary counts

Example response shape:

```json
{
  "items": [],
  "total": 25,
  "page": 1,
  "limit": 10,
  "total_pages": 3,
  "summary": {
    "total": 25,
    "open": 10,
    "in_progress": 8,
    "resolved": 7
  }
}
```

The summary values are calculated across the complete ticket dataset rather than only the current filtered page.

## 3. Update Ticket

```http
PATCH /api/tickets/{ticket_id}
```

Example:

```json
{
  "status": "Resolved",
  "priority": "High"
}
```

Only status and priority are updateable through this endpoint.

---

# Frontend Setup

Go to the Flutter project:

```bash
cd frontend
```

Install dependencies:

```bash
flutter pub get
```

Check the Flutter environment:

```bash
flutter doctor
```

---

# Flutter API Configuration

The frontend uses `String.fromEnvironment` to configure the API base URL.

The default local configuration is:

```dart
static const baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);
```

## Run Flutter Against Local FastAPI

First start the backend:

```bash
cd backend
uvicorn app.main:app --reload
```

Then, from another terminal:

```bash
cd frontend
flutter run
```

The Flutter application will use:

```text
http://localhost:8000
```

## Run Flutter Against the Deployed FastAPI API

The deployed backend URL is:

```text
https://support-management-9jfs.onrender.com
```

Run:

```bash
flutter run --dart-define=API_BASE_URL=https://support-management-9jfs.onrender.com
```

The frontend service automatically adds `/api/tickets` to the base URL.

For example:

```text
Base URL:
https://support-management-9jfs.onrender.com

API:
https://support-management-9jfs.onrender.com/api/tickets
```

Do not include `/api/tickets` in `API_BASE_URL`.

---

# Running Tests

## Flutter Tests

From `frontend/`:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/example_test.dart
```

If additional Flutter tests are added, they should be placed under:

```text
frontend/test/
```

## Backend Tests

The backend can be tested with `pytest`.

If pytest is not already included in the backend dependencies:

```bash
pip install pytest
```

Run:

```bash
pytest
```

For a more verbose test run:

```bash
pytest -v
```

Backend tests should be placed under:

```text
backend/tests/
```

Example:

```text
backend/
└── tests/
    ├── test_tickets.py
    └── ...
```

---

# Deployment

## Backend Deployment

Only the FastAPI backend is deployed to Render.

The repository is a monorepo containing both Flutter and FastAPI:

```text
repository/
├── frontend/
└── backend/
```

The Render Web Service uses:

```text
Root Directory: backend
```

Therefore, the Flutter frontend is not deployed as part of the Render backend service.

## Render Web Service

Build command:

```bash
pip install -r requirements.txt
```

Start command:

```bash
uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

## Render PostgreSQL

The PostgreSQL database is configured separately on Render.

The FastAPI Web Service receives:

```text
DATABASE_URL
```

through Render Environment Variables.

For a Render service and PostgreSQL database in the same region, the PostgreSQL Internal Database URL can be used for the web service connection.

---

# Deployed API

Current deployed backend:

```text
https://support-management-9jfs.onrender.com
```

Swagger documentation:

```text
https://support-management-9jfs.onrender.com/docs
```

The Render Free Web Service may spin down after inactivity, so the first request after a period without traffic can take longer.

The Render Free PostgreSQL plan is intended for testing/prototyping and has a limited lifetime. For long-term production deployment, an appropriate paid database/service plan should be used.

---

# Security and Git

The following should never be committed:

```text
.env
*.db
.venv/
**/__pycache__/**
*.pyc
```

In particular, never commit:

```text
DATABASE_URL
```

when it contains a real PostgreSQL username or password.

If database credentials are accidentally exposed, rotate/regenerate the credentials and update the corresponding Render environment variable.

---

# Development Workflow

A typical local development workflow is:

```text
1. Start backend
       ↓
2. Run Alembic migrations
       ↓
3. Seed test data if needed
       ↓
4. Open FastAPI /docs
       ↓
5. Start Flutter
       ↓
6. Test ticket creation
       ↓
7. Test search/filter/sort
       ↓
8. Test pagination
       ↓
9. Test ticket update
       ↓
10. Run automated tests
```

## Backend

```bash
cd backend

# Activate virtual environment
.venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt

# Apply migrations
alembic upgrade head

# Optional sample data
python seed.py

# Start API
uvicorn app.main:app --reload
```

## Frontend

In another terminal:

```bash
cd frontend
flutter pub get
flutter run
```

---

# Assignment Requirements Mapping

| Requirement               | Implementation                           |
| ------------------------- | ---------------------------------------- |
| Create ticket             | `POST /api/tickets`                      |
| Title max 120 characters  | Pydantic validation                      |
| Required description      | Pydantic validation                      |
| Customer email validation | Pydantic `EmailStr`                      |
| Priority                  | Low / Medium / High                      |
| Status                    | Open / In Progress / Resolved            |
| Default status            | Open                                     |
| Automatic timestamps      | SQLAlchemy model                         |
| Search                    | `GET /api/tickets?search=...`            |
| Status filter             | `status` query parameter                 |
| Priority filter           | `priority` query parameter               |
| Combined search/filter    | Backend query conditions                 |
| Sorting                   | `sort` query parameter                   |
| Pagination                | `page` + `limit`                         |
| Ticket details            | Full ticket objects returned by list API |
| Update status/priority    | `PATCH /api/tickets/{ticket_id}`         |
| Persistent storage        | PostgreSQL on Render                     |
| Summary counts            | Included in ticket list response         |
| Database migrations       | Alembic                                  |
| Test/demo data            | `seed.py`                                |
| Frontend                  | Flutter                                  |
| Backend                   | FastAPI                                  |

---

# Architecture

```text
                         GitHub Repository
                                │
                 ┌──────────────┴──────────────┐
                 │                             │
             frontend/                     backend/
              Flutter                       FastAPI
                 │                             │
                 │ HTTP                        │
                 └──────────────► Render Web Service
                                             │
                                         SQLAlchemy
                                             │
                                             ▼
                                      Render PostgreSQL
```

The frontend and backend remain in the same repository, while only the `backend/` directory is deployed as the Render Web Service.

For local development, the backend can use SQLite instead of PostgreSQL.

---

# Submission Documentation

The repository also contains:

```text
SUBMISSION_NOTES.md
```

This document provides additional assignment-specific information, including:

* Technical choices
* Assumptions
* Known limitations
* Time spent
* How AI tools were used
* Development/prioritization notes

The assignment was completed within the requested time limit.

---

# Notes

* Local development uses SQLite by default.
* The deployed backend uses PostgreSQL through `DATABASE_URL`.
* Alembic manages database schema changes.
* `seed.py` provides sample/demo data.
* Search, filtering, sorting, and pagination are handled by the backend rather than only in Flutter.
* Summary counts represent the complete dataset and are not limited to the current page.
* The Flutter API base URL can be changed without modifying source code by using `--dart-define=API_BASE_URL=...`.
* The deployed backend is available through Render.
* The Flutter application can be run locally against either the local FastAPI backend or the deployed FastAPI backend.
