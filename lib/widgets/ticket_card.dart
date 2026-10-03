import 'package:assigned_task_quantek/models/ticket.dart';
import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  final Ticket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ticket.title,
                      maxLines: isMobile ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                ticket.customerEmail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _TicketChip(
                    label: ticket.priority,
                    color: _priorityColor(ticket.priority),
                  ),
                  _TicketChip(
                    label: ticket.status,
                    color: _statusColor(ticket.status),
                  ),
                  Text(
                    'Created ${_formatDate(ticket.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _priorityColor(String priority) => switch (priority) {
        'High' => Colors.red,
        'Medium' => Colors.orange,
        _ => Colors.green,
      };

  static Color _statusColor(String status) => switch (status) {
        'Resolved' => Colors.green,
        'In Progress' => Colors.blue,
        _ => Colors.grey,
      };

  static String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}

class _TicketChip extends StatelessWidget {
  const _TicketChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Chip(
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
      ),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: isMobile ? 12 : 13,
      ),
      side: BorderSide(
        color: color.withValues(alpha: 0.45),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}