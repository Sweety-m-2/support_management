from alembic import op
import sqlalchemy as sa


revision = "001_create_tickets"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "tickets",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column(
            "title",
            sa.String(length=120),
            nullable=False,
        ),
        sa.Column(
            "description",
            sa.Text(),
            nullable=False,
        ),
        sa.Column(
            "customer_email",
            sa.String(length=254),
            nullable=False,
        ),
        sa.Column(
            "priority",
            sa.String(length=10),
            nullable=False,
        ),
        sa.Column(
            "status",
            sa.String(length=20),
            nullable=False,
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
        ),
    )

    op.create_index(
        "ix_tickets_id",
        "tickets",
        ["id"],
    )


def downgrade() -> None:
    op.drop_index(
        "ix_tickets_id",
        table_name="tickets",
    )

    op.drop_table("tickets")