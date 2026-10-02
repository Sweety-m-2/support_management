from app.database import SessionLocal
from app.models.ticket_model import Ticket


SEED_TICKETS = [
    {
        "title": "Login issue",
        "description": "Customer is unable to log in to the application.",
        "customer_email": "alice@example.com",
        "priority": "High",
        "status": "Open",
    },
    {
        "title": "Password reset request",
        "description": "Customer requested help resetting their password.",
        "customer_email": "bob@example.com",
        "priority": "Medium",
        "status": "In Progress",
    },
    {
        "title": "Payment failed",
        "description": "Payment transaction failed during checkout.",
        "customer_email": "charlie@example.com",
        "priority": "High",
        "status": "Resolved",
    },
    {
        "title": "Unable to update profile",
        "description": "Customer cannot save changes to their profile.",
        "customer_email": "david@example.com",
        "priority": "Low",
        "status": "Open",
    },
    {
        "title": "Invoice not received",
        "description": "Customer has not received the latest invoice.",
        "customer_email": "emma@example.com",
        "priority": "Medium",
        "status": "Resolved",
    },
    {
        "title": "Application is slow",
        "description": "Customer reports slow loading times on the dashboard.",
        "customer_email": "frank@example.com",
        "priority": "High",
        "status": "In Progress",
    },
    {
        "title": "Change email address",
        "description": "Customer wants to update their registered email address.",
        "customer_email": "grace@example.com",
        "priority": "Low",
        "status": "Open",
    },
    {
        "title": "Missing order confirmation",
        "description": "Customer placed an order but did not receive confirmation.",
        "customer_email": "henry@example.com",
        "priority": "Medium",
        "status": "Resolved",
    },
    {
        "title": "Unable to download report",
        "description": "Report download fails from the reports page.",
        "customer_email": "irene@example.com",
        "priority": "High",
        "status": "In Progress",
    },
    {
        "title": "Notification not working",
        "description": "Customer is not receiving application notifications.",
        "customer_email": "jack@example.com",
        "priority": "Medium",
        "status": "Open",
    },
    {
        "title": "Wrong account information",
        "description": "Customer sees incorrect information in their account.",
        "customer_email": "karen@example.com",
        "priority": "High",
        "status": "Resolved",
    },
    {
        "title": "Feature request",
        "description": "Customer requested an additional dashboard feature.",
        "customer_email": "leo@example.com",
        "priority": "Low",
        "status": "Open",
    },
    {
        "title": "Order status question",
        "description": "Customer wants an update about their order status.",
        "customer_email": "mia@example.com",
        "priority": "Medium",
        "status": "In Progress",
    },
    {
        "title": "Account locked",
        "description": "Customer account was locked after multiple failed attempts.",
        "customer_email": "noah@example.com",
        "priority": "High",
        "status": "Resolved",
    },
    {
        "title": "Incorrect billing amount",
        "description": "Customer reports an unexpected amount on their bill.",
        "customer_email": "olivia@example.com",
        "priority": "High",
        "status": "Open",
    },
    {
        "title": "Help with settings",
        "description": "Customer needs assistance configuring application settings.",
        "customer_email": "peter@example.com",
        "priority": "Low",
        "status": "Resolved",
    },
    {
        "title": "Search not working",
        "description": "Customer cannot find tickets using the search feature.",
        "customer_email": "quinn@example.com",
        "priority": "Medium",
        "status": "In Progress",
    },
    {
        "title": "Data export request",
        "description": "Customer wants to export their account data.",
        "customer_email": "rachel@example.com",
        "priority": "Low",
        "status": "Open",
    },
    {
        "title": "Duplicate transaction",
        "description": "Customer noticed what appears to be a duplicate transaction.",
        "customer_email": "sam@example.com",
        "priority": "High",
        "status": "In Progress",
    },
    {
        "title": "Unable to upload document",
        "description": "Customer receives an error while uploading a document.",
        "customer_email": "tina@example.com",
        "priority": "Medium",
        "status": "Resolved",
    },
    {
        "title": "Dashboard not loading",
        "description": "Customer reports that the dashboard page is not loading.",
        "customer_email": "uma@example.com",
        "priority": "High",
        "status": "Open",
    },
    {
        "title": "Request account deletion",
        "description": "Customer requested assistance with account deletion.",
        "customer_email": "victor@example.com",
        "priority": "Medium",
        "status": "Resolved",
    },
    {
        "title": "Mobile application issue",
        "description": "Customer reports an issue while using the mobile application.",
        "customer_email": "wendy@example.com",
        "priority": "High",
        "status": "In Progress",
    },
    {
        "title": "Update contact information",
        "description": "Customer wants to update their contact information.",
        "customer_email": "xavier@example.com",
        "priority": "Low",
        "status": "Open",
    },
    {
        "title": "Subscription question",
        "description": "Customer needs clarification about their subscription.",
        "customer_email": "yasmine@example.com",
        "priority": "Medium",
        "status": "Resolved",
    },
]

def seed_database():
    db = SessionLocal()

    try:
        existing_emails = {
            email
            for (email,) in db.query(Ticket.customer_email)
            .filter(
                Ticket.customer_email.in_(
                    ticket["customer_email"] for ticket in SEED_TICKETS
                )
            )
            .all()
        }

        new_seed_tickets = [
            Ticket(**ticket_data)
            for ticket_data in SEED_TICKETS
            if ticket_data["customer_email"] not in existing_emails
        ]

        if not new_seed_tickets:
            print("Seed data already exists. No new tickets were inserted.")
            return

        db.add_all(new_seed_tickets)
        db.commit()

        print(
            f"Successfully inserted {len(new_seed_tickets)} seed tickets."
        )

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


if __name__ == "__main__":
    seed_database()