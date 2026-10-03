import 'package:assigned_task_quantek/models/ticket.dart';
import 'package:flutter/material.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key, required this.summary});

  final TicketSummary summary;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

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

    final columns = isMobile
        ? 1
        : isTablet
        ? 2
        : 4;

    const spacing = 12.0;

    final horizontalPadding = isMobile ? 0.0 : 0.0;
    final availableWidth = screenWidth - horizontalPadding;
    final cardWidth =
        (availableWidth - ((columns - 1) * spacing)) / columns;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final card in cards)
          SizedBox(
            width: cardWidth,
            child: card,
          ),
      ],
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
    final screenWidth = MediaQuery.sizeOf(context).width;

    final isMobile = screenWidth < 600;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: colors.primary,
              size: isMobile ? 22 : 24,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
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