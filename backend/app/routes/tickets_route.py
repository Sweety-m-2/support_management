from typing import Literal

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.ticket_schema import (
    TicketCreate,
    TicketListResponse,
    TicketPriority,
    TicketStatus,
    TicketResponse,
    TicketUpdate,
)
from app.services import ticket_service


router = APIRouter(
    prefix="/api/tickets",
    tags=["Tickets"],
)


# API 1: Create a ticket.
@router.post(
    "",
    response_model=TicketResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_ticket(
    ticket_data: TicketCreate,
    db: Session = Depends(get_db),
):
    return ticket_service.create_ticket(db, ticket_data)


# API 2: Search, filter, sort, paginate tickets
# and return overall summary counts.
@router.get(
    "",
    response_model=TicketListResponse,
)
def list_tickets(
    search: str | None = Query(
        default=None,
        max_length=120,
    ),
    status_filter: TicketStatus | None = Query(
        default=None,
        alias="status",
    ),
    priority: TicketPriority | None = Query(
        default=None,
    ),
    sort: Literal["newest", "oldest"] = "newest",
    page: int = Query(
        default=1,
        ge=1,
    ),
    limit: int = Query(
        default=10,
        ge=1,
        le=100,
    ),
    db: Session = Depends(get_db),
):
    return ticket_service.get_tickets(
        db=db,
        search=search,
        status=status_filter,
        priority=priority,
        sort=sort,
        page=page,
        limit=limit,
    )


# API 3: Update status and/or priority.
@router.patch(
    "/{ticket_id}",
    response_model=TicketResponse,
)
def update_ticket(
    ticket_id: int,
    ticket_data: TicketUpdate,
    db: Session = Depends(get_db),
):
    return ticket_service.update_ticket(
        db,
        ticket_id,
        ticket_data,
    )