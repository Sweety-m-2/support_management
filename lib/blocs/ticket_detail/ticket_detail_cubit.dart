import 'package:assigned_task_quantek/blocs/ticket_detail/ticket_detail_state.dart';
import 'package:assigned_task_quantek/services/ticket_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketDetailCubit extends Cubit<TicketDetailState> {
  TicketDetailCubit(this._apiService) : super(const TicketDetailInitial());

  final TicketApiService _apiService;

  Future<void> updateTicket({
    required int ticketId,
    required String status,
    required String priority,
  }) async {
    if (state is TicketDetailSaving) return;
    emit(const TicketDetailSaving());
    try {
      final ticket = await _apiService.updateTicket(
        ticketId: ticketId,
        status: status,
        priority: priority,
      );
      emit(TicketDetailSaved(ticket));
    } on TicketApiException catch (error) {
      emit(TicketDetailError(error.message));
    } catch (_) {
      emit(
        const TicketDetailError('Unable to update ticket. Please try again.'),
      );
    }
  }
}
