
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker


# Store the database file in the backend folder.
BASE_DIR = Path(__file__).resolve().parent.parent
DATABASE_URL = f"sqlite:///{(BASE_DIR / 'support_tickets.db').as_posix()}"


# SQLite needs this option when used with FastAPI requests.
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False},
)


# Creates database sessions.
SessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    autocommit=False,
)
# Parent class for our SQLAlchemy models.
class Base(DeclarativeBase):
    pass
# Provides a database session to each API request.
def get_db():
    db: Session = SessionLocal()
    try:
        yield db
    finally:
        db.close()