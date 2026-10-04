
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.tickets_route import router as tickets_router


app = FastAPI(
    title="Support Ticket Dashboard API",
    description="API for creating, searching and managing support tickets.",
    version="1.0.0",
)


# Development configuration for Flutter Web.
# Restrict allowed origins before production deployment.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(tickets_router)


# @app.get("/")
# def root():
#     return {
#         "message": "Support Ticket Dashboard API is running."
#     }


# @app.get("/health")
# def health_check():
#     return {"status": "ok"}