import 'package:assigned_task_quantek/blocs/ticket_list/ticket_list_cubit.dart';
import 'package:assigned_task_quantek/blocs/ticket_list/ticket_list_state.dart';
import 'package:assigned_task_quantek/models/ticket.dart';
import 'package:assigned_task_quantek/screens/create_ticket_screen.dart';
import 'package:assigned_task_quantek/screens/ticket_detail_screen.dart';
import 'package:assigned_task_quantek/services/ticket_api_service.dart';
import 'package:assigned_task_quantek/widgets/summary_cards.dart';
import 'package:assigned_task_quantek/widgets/ticket_card.dart';
import 'package:assigned_task_quantek/widgets/ticket_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key, required this.apiService});

  final TicketApiService apiService;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TicketListCubit(apiService)..loadTickets(),
      child: _TicketListView(apiService: apiService),
    );
  }
}

class _TicketListView extends StatelessWidget {
  const _TicketListView({required this.apiService});

  final TicketApiService apiService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xA20C8004),
        title: const Text('Support Ticket'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.sizeOf(context).width;
                final isMobile = screenWidth < 600;

                return isMobile
                    ? IconButton(
                        tooltip: 'Create Ticket',
                        icon: const Icon(Icons.add),
                        onPressed: () => _openCreateTicket(context),
                      )
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create Ticket'),
                        onPressed: () => _openCreateTicket(context),
                      );
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<TicketListCubit, TicketListState>(
        builder: (context, state) {
          if (state is TicketListInitial || state is TicketListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TicketListError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<TicketListCubit>().loadTickets(),
            );
          }
          final response = switch (state) {
            TicketListLoaded(:final response) => response,
            TicketListEmpty(:final response) => response,
            _ => null,
          };
          if (response == null) return const SizedBox.shrink();
          return _DashboardContent(
            apiService: apiService,
            response: response,
            isRefreshing: state is TicketListLoaded && state.isRefreshing,
            isEmpty: state is TicketListEmpty,
          );
        },
      ),
    );
  }

  Future<void> _openCreateTicket(BuildContext context) async {
    final cubit = context.read<TicketListCubit>();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateTicketScreen(apiService: apiService),
      ),
    );
    if (!context.mounted || result != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ticket created successfully.')),
    );
    await cubit.refreshTickets();
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.apiService,
    required this.response,
    required this.isRefreshing,
    required this.isEmpty,
  });

  final TicketApiService apiService;
  final TicketListResponse response;
  final bool isRefreshing;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    final cubit = context.read<TicketListCubit>();

    return RefreshIndicator(
      onRefresh: cubit.refreshTickets,
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: isMobile ? 12 : 24,
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isRefreshing) const LinearProgressIndicator(),

                  if (isRefreshing) const SizedBox(height: 12),

                  SummaryCards(summary: response.summary),

                  const SizedBox(height: 24),

                  TicketFilters(
                    search: cubit.search,
                    status: cubit.status,
                    priority: cubit.priority,
                    sort: cubit.sort,
                    //     onSearchChanged: (String value) {
                    //   cubit.searchTickets(value);
                    // },
                    onSearchChanged: cubit.searchTickets,
                    onStatusChanged: cubit.changeStatusFilter,
                    onPriorityChanged: cubit.changePriorityFilter,
                    onSortChanged: cubit.changeSort,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    '${response.total} matching ticket'
                    '${response.total == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 12),

                  if (isEmpty)
                    _EmptyView(
                      filtered: cubit.hasActiveFilters,
                      onClear: cubit.clearFilters,
                    )
                  else
                    for (final ticket in response.items)
                      TicketCard(
                        ticket: ticket,
                        onTap: () => _openTicket(context, ticket),
                      ),

                  const SizedBox(height: 8),

                  _Pagination(response: response),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTicket(BuildContext context, Ticket ticket) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            TicketDetailScreen(ticket: ticket, apiService: apiService),
      ),
    );
    if (!context.mounted || result != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ticket updated successfully.')),
    );
    await context.read<TicketListCubit>().refreshTickets();
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({required this.response});

  final TicketListResponse response;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TicketListCubit>();
    final displayPage = response.totalPages == 0 ? 0 : response.page;
    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: response.page > 1
                ? () => cubit.changePage(response.page - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
          ),
          Text('Page $displayPage of ${response.totalPages}'),
          OutlinedButton.icon(
            onPressed: response.page < response.totalPages
                ? () => cubit.changePage(response.page + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.filtered, required this.onClear});

  final bool filtered;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              filtered
                  ? 'No tickets match your current search or filters.'
                  : 'No tickets found.',
            ),
            if (filtered) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear search and filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
