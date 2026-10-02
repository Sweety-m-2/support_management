import 'package:assigned_task_quantek/blocs/create_ticket/create_ticket_state.dart';
import 'package:assigned_task_quantek/services/ticket_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateTicketCubit extends Cubit<CreateTicketState> {
  CreateTicketCubit(this._apiService) : super(const CreateTicketInitial());

  final TicketApiService _apiService;

  static Map<String, String> validate({
    required String title,
    required String description,
    required String customerEmail,
    required String? priority,
  }) {
    final errors = <String, String>{};
    if (title.trim().isEmpty) {
      errors['title'] = 'Title is required.';
    } else if (title.trim().length > 120) {
      errors['title'] = 'Title must be 120 characters or less.';
    }
    if (description.trim().isEmpty) {
      errors['description'] = 'Description is required.';
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(customerEmail.trim())) {
      errors['customerEmail'] = 'Enter a valid email address.';
    }
    if (priority == null || priority.isEmpty) {
      errors['priority'] = 'Please select a priority.';
    }
    return errors;
  }

  Future<void> createTicket({
    required String title,
    required String description,
    required String customerEmail,
    required String? priority,
  }) async {
    if (state is CreateTicketSubmitting) return;
    final validationErrors = validate(
      title: title,
      description: description,
      customerEmail: customerEmail,
      priority: priority,
    );
    if (validationErrors.isNotEmpty) {
      emit(
        CreateTicketError(
          'Please correct the highlighted fields.',
          validationErrors: validationErrors,
        ),
      );
      return;
    }

    emit(const CreateTicketSubmitting());
    try {
      final ticket = await _apiService.createTicket(
        title: title.trim(),
        description: description.trim(),
        customerEmail: customerEmail.trim(),
        priority: priority!,
      );
      emit(CreateTicketSuccess(ticket));
    } on TicketApiException catch (error) {
      emit(CreateTicketError(error.message));
    } catch (_) {
      emit(
        const CreateTicketError(
          'Unable to create ticket. Please check your information.',
        ),
      );
    }
  }
}
