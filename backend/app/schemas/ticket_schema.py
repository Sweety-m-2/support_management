from datetime import datetime
from enum import Enum

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class TicketPriority(str, Enum):
    LOW = "Low"
    MEDIUM = "Medium"
    HIGH = "High"


class TicketStatus(str, Enum):
    OPEN = "Open"
    IN_PROGRESS = "In Progress"
    RESOLVED = "Resolved"


# Used when creating a new ticket
class TicketCreate(BaseModel):
    title: str = Field(min_length=1, max_length=120)
    description: str = Field(min_length=1)
    customer_email: EmailStr
    priority: TicketPriority
    status: TicketStatus = TicketStatus.OPEN


# Used when updating an existing ticket
class TicketUpdate(BaseModel):
    status: TicketStatus | None = None
    priority: TicketPriority | None = None


# Used for an individual ticket
class TicketResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    description: str
    customer_email: EmailStr
    priority: TicketPriority
    status: TicketStatus
    created_at: datetime
    updated_at: datetime


# Summary counts for the complete dataset
class TicketSummary(BaseModel):
    total: int
    open: int
    in_progress: int
    resolved: int


# Response of GET /api/tickets
class TicketListResponse(BaseModel):
    items: list[TicketResponse]

    # Pagination information
    total: int
    page: int
    limit: int
    total_pages: int

    # Overall summary, independent of search/filter/pagination
    summary: TicketSummary

