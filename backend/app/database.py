import os

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker


# Use DATABASE_URL from the environment when available.
# Otherwise, use the local SQLite database.
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "sqlite:///./support_tickets.db",
)


# SQLite needs this option when used with FastAPI requests.
connect_args = {}

if DATABASE_URL.startswith("sqlite"):
    connect_args = {
        "check_same_thread": False,
    }


# Create the database engine.
engine = create_engine(
    DATABASE_URL,
    connect_args=connect_args,
)


# Creates database sessions.
SessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    autocommit=False,
)


# Parent class for SQLAlchemy models.
class Base(DeclarativeBase):
    pass


# Provides a database session to each API request.
def get_db():
    db: Session = SessionLocal()

    try:
        yield db
    finally:
        db.close()