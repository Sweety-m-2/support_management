import 'package:assigned_task_quantek/models/ticket.dart';

sealed class CreateTicketState {
  const CreateTicketState();
}

class CreateTicketInitial extends CreateTicketState {
  const CreateTicketInitial();
}

class CreateTicketSubmitting extends CreateTicketState {
  const CreateTicketSubmitting();
}

class CreateTicketSuccess extends CreateTicketState {
  const CreateTicketSuccess(this.ticket);

  final Ticket ticket;
}

class CreateTicketError extends CreateTicketState {
  const CreateTicketError(this.message, {this.validationErrors = const {}});

  final String message;
  final Map<String, String> validationErrors;
}
