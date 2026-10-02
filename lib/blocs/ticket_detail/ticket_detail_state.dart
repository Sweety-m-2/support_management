import 'package:assigned_task_quantek/models/ticket.dart';

sealed class TicketDetailState {
  const TicketDetailState();
}

class TicketDetailInitial extends TicketDetailState {
  const TicketDetailInitial();
}

class TicketDetailSaving extends TicketDetailState {
  const TicketDetailSaving();
}

class TicketDetailSaved extends TicketDetailState {
  const TicketDetailSaved(this.ticket);

  final Ticket ticket;
}

class TicketDetailError extends TicketDetailState {
  const TicketDetailError(this.message);

  final String message;
}
