import 'package:assigned_task_quantek/blocs/create_ticket/create_ticket_cubit.dart';
import 'package:assigned_task_quantek/blocs/ticket_detail/ticket_detail_cubit.dart';
import 'package:assigned_task_quantek/blocs/ticket_detail/ticket_detail_state.dart';
import 'package:assigned_task_quantek/blocs/ticket_list/ticket_list_cubit.dart';
import 'package:assigned_task_quantek/blocs/ticket_list/ticket_list_state.dart';
import 'package:assigned_task_quantek/models/ticket.dart';
import 'package:assigned_task_quantek/services/ticket_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreateTicketCubit validation', () {
    test('rejects missing fields, an overlong title, and an invalid email', () {
      final emptyErrors = CreateTicketCubit.validate(
        title: '',
        description: '',
        customerEmail: 'not-an-email',
        priority: null,
      );
      expect(emptyErrors['title'], 'Title is required.');
      expect(emptyErrors['description'], 'Description is required.');
      expect(emptyErrors['customerEmail'], 'Enter a valid email address.');
      expect(emptyErrors['priority'], 'Please select a priority.');

      final longTitleErrors = CreateTicketCubit.validate(
        title: List.filled(121, 'a').join(),
        description: 'A description',
        customerEmail: 'customer@example.com',
        priority: 'Low',
      );
      expect(longTitleErrors['title'], 'Title must be 120 characters or less.');
    });
  });

  test('TicketListCubit sends and preserves backend query state', () async {
    final service = FakeTicketApiService();
    final cubit = TicketListCubit(service);
    final states = <TicketListState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.loadTickets();
    await cubit.changePage(3);
    await cubit.searchTickets('ticket2');
    await cubit.changeStatusFilter('Resolved');
    await cubit.changePriorityFilter('High');
    await cubit.changeSort('oldest');
    await Future<void>.delayed(Duration.zero);

    expect(cubit.search, 'ticket2');
    expect(cubit.status, 'Resolved');
    expect(cubit.priority, 'High');
    expect(cubit.sort, 'oldest');
    expect(cubit.page, 1, reason: 'Changing a filter resets pagination.');
    expect(service.queries.last, {
      'search': 'ticket2',
      'status': 'Resolved',
      'priority': 'High',
      'sort': 'oldest',
      'page': 1,
      'limit': 10,
    });
    expect(states.whereType<TicketListLoading>(), isNotEmpty);
    expect(states.whereType<TicketListLoaded>(), isNotEmpty);

    await subscription.cancel();
    await cubit.close();
  });

  test(
    'TicketDetailCubit sends updates and emits saved and error states',
    () async {
      final service = FakeTicketApiService();
      final cubit = TicketDetailCubit(service);
      final states = <TicketDetailState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.updateTicket(
        ticketId: 42,
        status: 'Resolved',
        priority: 'High',
      );
      await Future<void>.delayed(Duration.zero);
      expect(service.lastUpdate, {
        'ticketId': 42,
        'status': 'Resolved',
        'priority': 'High',
      });
      expect(states.whereType<TicketDetailSaved>(), isNotEmpty);

      service.failUpdates = true;
      await cubit.updateTicket(ticketId: 42, status: 'Open', priority: 'Low');
      await Future<void>.delayed(Duration.zero);
      expect(states.whereType<TicketDetailError>(), isNotEmpty);

      await subscription.cancel();
      await cubit.close();
    },
  );
}

class FakeTicketApiService extends TicketApiService {
  FakeTicketApiService() : super(baseUrl: 'http://example.test');

  final queries = <Map<String, Object?>>[];
  Map<String, Object?>? lastUpdate;
  bool failUpdates = false;

  @override
  Future<TicketListResponse> getTickets({
    String? search,
    String? status,
    String? priority,
    String sort = 'newest',
    int page = 1,
    int limit = 10,
  }) async {
    queries.add({
      'search': search,
      'status': status,
      'priority': priority,
      'sort': sort,
      'page': page,
      'limit': limit,
    });
    return TicketListResponse(
      items: [_ticket],
      total: 21,
      page: page,
      limit: limit,
      totalPages: 3,
      summary: const TicketSummary(
        total: 25,
        open: 10,
        inProgress: 8,
        resolved: 7,
      ),
    );
  }

  @override
  Future<Ticket> updateTicket({
    required int ticketId,
    required String status,
    required String priority,
  }) async {
    lastUpdate = {'ticketId': ticketId, 'status': status, 'priority': priority};
    if (failUpdates) throw const TicketApiException('Unable to update ticket.');
    return _ticket;
  }
}

final _ticket = Ticket(
  id: 42,
  title: 'Billing issue',
  description: 'An example ticket',
  customerEmail: 'customer@example.com',
  priority: 'High',
  status: 'Open',
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);
