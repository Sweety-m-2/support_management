from math import ceil

from fastapi import HTTPException
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.ticket_model import Ticket
from app.schemas.ticket_schema import (
    TicketCreate,
    TicketPriority,
    TicketStatus,
    TicketUpdate,
)


def create_ticket(db: Session, ticket_data: TicketCreate) -> Ticket:
    """Create and save a new ticket."""

    ticket = Ticket(
        title=ticket_data.title.strip(),
        description=ticket_data.description.strip(),
        customer_email=str(ticket_data.customer_email),
        priority=ticket_data.priority.value,
        status=ticket_data.status.value,
    )

    db.add(ticket)
    db.commit()
    db.refresh(ticket)

    return ticket


def get_tickets(
    db: Session,
    search: str | None = None,
    status: TicketStatus | None = None,
    priority: TicketPriority | None = None,
    sort: str = "newest",
    page: int = 1,
    limit: int = 10,
) -> dict:
    """Search, filter, sort and paginate tickets.

    Also returns summary counts for the entire dataset.
    """

    conditions = []

    # Search the fields users can use to identify a ticket.
    if search and search.strip():
        search_term = f"%{search.strip()}%"
        conditions.append(
            or_(
                Ticket.title.ilike(search_term),
                Ticket.description.ilike(search_term),
                Ticket.customer_email.ilike(search_term),
            )
        )

    # Apply optional status filter.
    if status is not None:
        conditions.append(Ticket.status == status.value)

    # Apply optional priority filter.
    if priority is not None:
        conditions.append(Ticket.priority == priority.value)

    # Count tickets matching the current search/filter.
    # This is used for pagination.
    count_query = select(func.count()).select_from(Ticket)

    if conditions:
        count_query = count_query.where(*conditions)

    total = db.scalar(count_query) or 0

    # Sort by creation date, using ID as a tie-breaker.
    if sort == "oldest":
        ordering = (
            Ticket.created_at.asc(),
            Ticket.id.asc(),
        )
    else:
        ordering = (
            Ticket.created_at.desc(),
            Ticket.id.desc(),
        )

    # Fetch only the requested page.
    ticket_query = select(Ticket)

    if conditions:
        ticket_query = ticket_query.where(*conditions)

    ticket_query = (
        ticket_query
        .order_by(*ordering)
        .offset((page - 1) * limit)
        .limit(limit)
    )

    tickets = db.scalars(ticket_query).all()

    # Get summary counts from the entire dataset.
    summary = get_ticket_summary(db)

    return {
        "items": tickets,
        "total": total,
        "page": page,
        "limit": limit,
        "total_pages": ceil(total / limit) if total else 0,
        "summary": summary,
    }


def get_ticket(db: Session, ticket_id: int) -> Ticket:
    """Find one ticket by its ID."""

    ticket = db.get(Ticket, ticket_id)

    if ticket is None:
        raise HTTPException(
            status_code=404,
            detail=f"Ticket with ID {ticket_id} was not found.",
        )

    return ticket


def update_ticket(
    db: Session,
    ticket_id: int,
    ticket_data: TicketUpdate,
) -> Ticket:
    """Update a ticket's status and/or priority."""

    ticket = get_ticket(db, ticket_id)

    changes = ticket_data.model_dump(exclude_unset=True)

    if not changes:
        raise HTTPException(
            status_code=422,
            detail="Provide at least one field to update.",
        )

    for field, value in changes.items():
        if value is None:
            raise HTTPException(
                status_code=422,
                detail=f"{field} cannot be null.",
            )

        setattr(
            ticket,
            field,
            value.value,
        )

    db.commit()
    db.refresh(ticket)

    return ticket


def get_ticket_summary(db: Session) -> dict:
    """Count tickets across the entire dataset."""

    total = db.scalar(
        select(func.count()).select_from(Ticket)
    ) or 0

    status_counts = db.execute(
        select(Ticket.status, func.count())
        .group_by(Ticket.status)
    ).all()

    counts = {
        status: count
        for status, count in status_counts
    }

    return {
        "total": total,
        "open": counts.get("Open", 0),
        "in_progress": counts.get("In Progress", 0),
        "resolved": counts.get("Resolved", 0),
    }
