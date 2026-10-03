Support Ticket Dashboard

A full-stack Support Ticket Dashboard built as part of the Full-stack
Web Application Developer assignment.

The project contains:

Flutter frontend for the dashboard UI

FastAPI backend for REST APIs

SQLAlchemy for database access

Alembic for database migrations

PostgreSQL for deployed persistent storage

SQLite as the default local-development database

Search, filtering, sorting, pagination, ticket creation, ticket
updates, and dataset-wide summary counts

Features

Ticket creation

Create a support ticket

Required title with a maximum length of 120 characters

Required description

Customer email validation

Priority:

Low

Medium

High

Status:

Open

In Progress

Resolved

New tickets default to Open

created_at and updated_at are generated automatically

Validation is performed by the backend and supported by the frontend

Ticket listing

Search by ticket title or customer email

Filter by status

Filter by priority

Combine search and filters

Sort by creation time:

Newest

Oldest

Server-side pagination

10 tickets per page by default

Ticket details and updates

View complete ticket details

Update ticket status

Update ticket priority

Changes are persisted in the database

Summary

The ticket listing API also returns summary counts for the entire
dataset, independent of the current search/filter/pagination state:

Total tickets

Open tickets

In Progress tickets

Resolved tickets

Technology Stack

Frontend

Flutter

Dart

http package

Backend

Python

FastAPI

Uvicorn

SQLAlchemy

Pydantic

Alembic

Database

SQLite for local development

PostgreSQL for deployed production/demo environment

Deployment

Render Web Service for FastAPI

Render PostgreSQL for persistent database storage

Project Structure

assigned_task_quantek/
│
├── frontend/                         # Flutter application
│   ├── lib/
│   │   ├── main.dart
│   │   │
│   │   ├── config/
│   │   │   └── api_config.dart      # API base URL configuration
│   │   │
│   │   ├── models/
│   │   │   └── ticket.dart           # Ticket models / JSON mapping
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
│   ├── requirements.txt
│   ├── support_tickets.db            # Local only; ignored by Git
│   └── .venv/                        # Local only; ignored by Git
│
├── .gitignore
└── README.md

The exact Flutter file list may vary slightly as the UI evolves. The
backend follows a layered structure separating routes, schemas,
models, services, and database configuration.

Backend Setup

Prerequisites

Install:

Python 3.10+

pip

Git

PostgreSQL only if you want to run against PostgreSQL locally

Flutter SDK for the frontend

The backend can use SQLite locally, so a local PostgreSQL installation
is not required for basic development.

1. Clone the repository

git clone:git@github.com:Sweety-m-2/support_management.git
cd assigned_task_quantek

2. Create a Python virtual environment

From the backend directory:

Windows PowerShell

cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1

macOS/Linux

cd backend
python3 -m venv .venv
source .venv/bin/activate

3. Install backend dependencies

pip install -r requirements.txt

Backend Environment Variables

The backend supports a DATABASE_URL environment variable.

DATABASE_URL

Local development

If DATABASE_URL is not provided, the application uses the local SQLite
database:

sqlite:///./support_tickets.db

Render / PostgreSQL

On Render, configure:

DATABASE_URL=<Render PostgreSQL Internal Database URL>

Do not commit database credentials, passwords, or .env files to
Git.

PowerShell example

$env:DATABASE_URL="postgresql://username:password@host/database"

Use your actual database URL locally when running migrations or seed
commands. Never put real credentials into source code.

Database Migrations

Alembic manages database schema changes.

Apply migrations

From backend/:

alembic upgrade head

This creates the required database schema, including the tickets
table.

Create a new migration

After changing SQLAlchemy models:

alembic revision --autogenerate -m "describe your change"

Review the generated migration before applying it.

Then:

alembic upgrade head

Seed Test Data

The project includes backend/seed.py for creating sample support
tickets.

After the database schema has been migrated:

python seed.py

The seed script currently inserts 25 sample tickets for demonstrating:

Pagination

Search

Filtering

Sorting

Summary counts

Avoid running the seed script repeatedly unless the script has duplicate
protection.

Run the FastAPI Backend Locally

From backend/:

uvicorn app.main:app --reload

The API will normally be available at:

http://localhost:8000

Swagger documentation:

http://localhost:8000/docs

ReDoc:

http://localhost:8000/redoc

For Render, the service uses:

uvicorn app.main:app --host 0.0.0.0 --port $PORT

API Endpoints

The project uses three main ticket API endpoints.

1. Create ticket

POST /api/tickets

Example request:

{
  "title": "Payment failed",
  "description": "The customer could not complete the payment.",
  "customer_email": "customer@example.com",
  "priority": "High"
}

A newly created ticket defaults to:

status = Open

2. List tickets

GET /api/tickets

Supported query parameters:

Parameter    Description                   Example

search     Search title/customer email   payment
status     Filter by status              Open
priority   Filter by priority            High
sort       Creation order                newest / oldest
page       Page number                   1
limit      Items per page                10

Example:

GET /api/tickets?search=payment&status=Open&priority=High&sort=newest&page=1&limit=10

The response contains:

Current page tickets

Filtered total used for pagination

Page number

Page size

Total pages

Dataset-wide summary counts

Example response shape:

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

The summary values are calculated across the complete ticket dataset
rather than only the current filtered page.

3. Update ticket

PATCH /api/tickets/{ticket_id}

Example:

{
  "status": "Resolved",
  "priority": "High"
}

Only status and priority are updateable through this endpoint.

Frontend Setup

Go to the Flutter project:

cd frontend

Install dependencies:

flutter pub get

Check the Flutter environment:

flutter doctor

Flutter API Configuration

The frontend uses String.fromEnvironment to configure the API base
URL.

The default local configuration is:

static const baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

Run Flutter against local FastAPI

Start the backend first:

cd backend
uvicorn app.main:app --reload

Then from frontend/:

flutter run

The Flutter application will use:

http://localhost:8000

Run Flutter against the deployed FastAPI API

The deployed backend URL is:

https://support-management-9jfs.onrender.com

Run:

flutter run --dart-define=API_BASE_URL=https://support-management-9jfs.onrender.com

The frontend service automatically adds /api/tickets to the base URL.

For example:

Base URL:
https://support-management-9jfs.onrender.com

API:
https://support-management-9jfs.onrender.com/api/tickets

Do not include /api/tickets in API_BASE_URL.

Running Tests

Flutter tests

From frontend/:

flutter test

To run a specific test file:

flutter test test/example_test.dart

If no Flutter test files have been added yet, add tests under:

frontend/test/

Backend tests

The backend can be tested with pytest.

Install it if it is not already included in requirements.txt:

pip install pytest

Run:

pytest

For a more verbose test run:

pytest -v

Backend tests should be placed under:

backend/tests/

Example structure:

backend/
└── tests/
    ├── test_tickets.py
    └── ...

Deployment

Backend deployment

Only the FastAPI backend is deployed to Render.

The repository is a monorepo containing both Flutter and FastAPI:

repository/
├── frontend/
└── backend/

The Render Web Service uses:

Root Directory: backend

Therefore the Flutter frontend is not deployed as part of the Render
backend service.

Render Web Service

Build command:

pip install -r requirements.txt

Start command:

uvicorn app.main:app --host 0.0.0.0 --port $PORT

Render PostgreSQL

The PostgreSQL database is configured separately on Render.

The FastAPI Web Service receives:

DATABASE_URL

through Render Environment Variables.

For a Render service and PostgreSQL database in the same region, use the
PostgreSQL Internal Database URL for the web service connection.

Deployed API

Current deployed backend:

https://support-management-9jfs.onrender.com

Swagger:

https://support-management-9jfs.onrender.com/docs

The Render Free Web Service may spin down after inactivity, so the first
request after a period without traffic can take longer.

The Render Free PostgreSQL plan is intended for testing/prototyping and
has a limited lifetime. For a long-term production deployment, use an
appropriate paid database/service plan.

Security and Git

The following should never be committed:

.env
*.db
.venv/
__pycache__/
*.pyc

In particular, never commit:

DATABASE_URL

when it contains a real PostgreSQL username/password.

If database credentials are accidentally exposed, rotate/regenerate the
credentials and update the corresponding Render environment variable.

Development Workflow

A typical local development workflow is:

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

Commands:

# Backend
cd backend
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
alembic upgrade head
python seed.py
uvicorn app.main:app --reload

In another terminal:

# Frontend
cd frontend
flutter pub get
flutter run

Assignment Requirements Mapping

Requirement                 Implementation

Create ticket               POST /api/tickets
Title max 120 characters    Pydantic + database validation
Required description        Pydantic validation
Customer email validation   Pydantic EmailStr
Priority                    Low / Medium / High
Status                      Open / In Progress / Resolved
Default status              Open
Automatic timestamps        SQLAlchemy model
Search                      GET /api/tickets?search=...
Status filter               status query parameter
Priority filter             priority query parameter
Combined search/filter      Backend query conditions
Sorting                     sort query parameter
Pagination                  page + limit
Ticket details              Full ticket objects returned by list API
Update status/priority      PATCH /api/tickets/{ticket_id}
Persistent storage          PostgreSQL on Render
Summary counts              Included in ticket list response
Database migrations         Alembic
Test/demo data              seed.py
Frontend                    Flutter
Backend                     FastAPI

Architecture

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

The frontend and backend remain in the same repository, while only the
backend/ directory is deployed as the Render Web Service.

Notes

Local development uses SQLite by default.

The deployed backend uses PostgreSQL through DATABASE_URL.

Alembic manages schema changes; seed.py manages sample data.

Search, filtering, sorting, and pagination are handled by the
backend rather than only in Flutter.

Summary counts represent the complete dataset and are not limited to
the current page.

The Flutter API base URL can be changed without modifying source
code by using --dart-define=API_BASE_URL=....