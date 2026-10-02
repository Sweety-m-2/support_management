import 'package:assigned_task_quantek/models/ticket.dart';

sealed class TicketListState {
  const TicketListState();
}

class TicketListInitial extends TicketListState {
  const TicketListInitial();
}

class TicketListLoading extends TicketListState {
  const TicketListLoading();
}

class TicketListLoaded extends TicketListState {
  const TicketListLoaded(this.response, {this.isRefreshing = false});

  final TicketListResponse response;
  final bool isRefreshing;
}

class TicketListEmpty extends TicketListState {
  const TicketListEmpty(this.response);

  final TicketListResponse response;
}

class TicketListError extends TicketListState {
  const TicketListError(this.message);

  final String message;
}
