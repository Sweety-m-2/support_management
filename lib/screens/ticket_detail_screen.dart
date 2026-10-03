import 'package:assigned_task_quantek/blocs/ticket_detail/ticket_detail_cubit.dart';
import 'package:assigned_task_quantek/blocs/ticket_detail/ticket_detail_state.dart';
import 'package:assigned_task_quantek/models/ticket.dart';
import 'package:assigned_task_quantek/services/ticket_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({
    super.key,
    required this.ticket,
    required this.apiService,
  });

  final Ticket ticket;
  final TicketApiService apiService;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TicketDetailCubit(apiService),
      child: _TicketDetailView(ticket: ticket),
    );
  }
}

class _TicketDetailView extends StatefulWidget {
  const _TicketDetailView({required this.ticket});

  final Ticket ticket;

  @override
  State<_TicketDetailView> createState() => _TicketDetailViewState();
}

class _TicketDetailViewState extends State<_TicketDetailView> {
  late String _priority = widget.ticket.priority;
  late String _status = widget.ticket.status;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket #${widget.ticket.id}'),
        backgroundColor: Color(0xA20C8004),
      ),
      body: BlocListener<TicketDetailCubit, TicketDetailState>(
        listener: (context, state) {
          if (state is TicketDetailSaved) {
            Navigator.of(context).pop(true);
          } else if (state is TicketDetailError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<TicketDetailCubit, TicketDetailState>(
          builder: (context, state) {
            final saving = state is TicketDetailSaving;

            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 32,
                      vertical: isMobile ? 16 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DetailField(
                          label: 'Title',
                          value: widget.ticket.title,
                        ),

                        _DetailField(
                          label: 'Description',
                          value: widget.ticket.description,
                        ),

                        _DetailField(
                          label: 'Customer email',
                          value: widget.ticket.customerEmail,
                        ),

                        _DetailField(
                          label: 'Created',
                          value: _formatDateTime(widget.ticket.createdAt),
                        ),

                        _DetailField(
                          label: 'Updated',
                          value: _formatDateTime(widget.ticket.updatedAt),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          initialValue: _priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Low', child: Text('Low')),
                            DropdownMenuItem(
                              value: 'Medium',
                              child: Text('Medium'),
                            ),
                            DropdownMenuItem(
                              value: 'High',
                              child: Text('High'),
                            ),
                          ],
                          onChanged: saving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() => _priority = value);
                                  }
                                },
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Open',
                              child: Text('Open'),
                            ),
                            DropdownMenuItem(
                              value: 'In Progress',
                              child: Text('In Progress'),
                            ),
                            DropdownMenuItem(
                              value: 'Resolved',
                              child: Text('Resolved'),
                            ),
                          ],
                          onChanged: saving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() => _status = value);
                                  }
                                },
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          height: isMobile ? 48 : 52,
                          child: FilledButton.icon(
                            onPressed: saving ? null : _save,
                            icon: saving
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(saving ? 'Saving...' : 'Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _save() {
    context.read<TicketDetailCubit>().updateTicket(
      ticketId: widget.ticket.id,
      status: _status,
      priority: _priority,
    );
  }

  String _formatDateTime(DateTime date) {
    final local = date.toLocal();
    final datePart =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final timePart =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$datePart $timePart';
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          SelectableText(value),
        ],
      ),
    );
  }
}
