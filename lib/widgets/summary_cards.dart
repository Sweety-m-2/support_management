import 'package:assigned_task_quantek/models/ticket.dart';
import 'package:flutter/material.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key, required this.summary});

  final TicketSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        label: 'Total Tickets',
        value: summary.total,
        icon: Icons.confirmation_number_outlined,
      ),
      _SummaryCard(
        label: 'Open',
        value: summary.open,
        icon: Icons.mark_email_unread_outlined,
      ),
      _SummaryCard(
        label: 'In Progress',
        value: summary.inProgress,
        icon: Icons.pending_actions_outlined,
      ),
      _SummaryCard(
        label: 'Resolved',
        value: summary.resolved,
        icon: Icons.task_alt_outlined,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 920
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        const spacing = 12.0;
        final cardWidth =
            (constraints.maxWidth - (columns - 1) * spacing) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
