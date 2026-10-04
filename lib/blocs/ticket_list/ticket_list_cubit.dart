import 'package:assigned_task_quantek/blocs/ticket_list/ticket_list_state.dart';
import 'package:assigned_task_quantek/models/ticket.dart';
import 'package:assigned_task_quantek/services/ticket_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketListCubit extends Cubit<TicketListState> {
  TicketListCubit(this._apiService) : super(const TicketListInitial());

  final TicketApiService _apiService;
  TicketListResponse? _lastResponse;

  String search = '';
  String? status;
  String? priority;
  String sort = 'newest';
  int page = 1;
  final int pageLimit = 10;

  bool get hasActiveFilters =>
      search.isNotEmpty ||
      status != null ||
      priority != null ||
      sort != 'newest';

  Future<void> loadTickets({bool refresh = false}) async {
    if (refresh && _lastResponse != null) {
      emit(TicketListLoaded(_lastResponse!, isRefreshing: true));
    } else {
      emit(const TicketListLoading());
    }

    try {
      final response = await _apiService.getTickets(
        search: search,
        status: status,
        priority: priority,
        sort: sort,
        page: page,
        limit: pageLimit,
      );
      _lastResponse = response;
      if (response.items.isEmpty) {
        emit(TicketListEmpty(response));
      } else {
        emit(TicketListLoaded(response));
      }
    } on TicketApiException catch (error) {
      emit(TicketListError(error.message));
    } catch (_) {
      emit(const TicketListError('Unable to load tickets. Please try again.'));
    }
  }

  Future<void> refreshTickets() => loadTickets(refresh: true);

  Future<void> searchTickets(String value) {
    search = value;
    page = 1;
    return loadTickets(refresh: true);
  }

  Future<void> changeStatusFilter(String? value) {
    status = value;
    page = 1;
    return loadTickets();
  }

  Future<void> changePriorityFilter(String? value) {
    priority = value;
    page = 1;
    return loadTickets();
  }

  Future<void> changeSort(String value) {
    sort = value;
    page = 1;
    return loadTickets();
  }

  Future<void> changePage(int value) {
    if (value < 1 ||
        (_lastResponse != null && value > _lastResponse!.totalPages)) {
      return Future.value();
    }
    page = value;
    return loadTickets();
  }

  Future<void> clearFilters() {
    search = '';
    status = null;
    priority = null;
    sort = 'newest';
    page = 1;
    return loadTickets();
  }
}
