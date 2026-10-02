import 'package:flutter/material.dart';

class TicketFilters extends StatefulWidget {
  const TicketFilters({
    super.key,
    required this.search,
    required this.status,
    required this.priority,
    required this.sort,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onSortChanged,
  });

  final String search;
  final String? status;
  final String? priority;
  final String sort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onPriorityChanged;
  final ValueChanged<String> onSortChanged;

  @override
  State<TicketFilters> createState() => _TicketFiltersState();
}

class _TicketFiltersState extends State<TicketFilters> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.search);
  }

  @override
  void didUpdateWidget(covariant TicketFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.search != _searchController.text) {
      _searchController.value = TextEditingValue(
        text: widget.search,
        selection: TextSelection.collapsed(offset: widget.search.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final selectWidth = wide ? 170.0 : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: wide
                  ? constraints.maxWidth - 3 * 182
                  : constraints.maxWidth,
              child: TextField(
                controller: _searchController,
                onChanged: widget.onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  hintText: 'Search by title or customer email',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: selectWidth,
              child: DropdownButtonFormField<String?>(
                key: ValueKey('status-${widget.status}'),
                initialValue: widget.status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: 'Open', child: Text('Open')),
                  DropdownMenuItem(
                    value: 'In Progress',
                    child: Text('In Progress'),
                  ),
                  DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
                ],
                onChanged: widget.onStatusChanged,
              ),
            ),
            SizedBox(
              width: selectWidth,
              child: DropdownButtonFormField<String?>(
                key: ValueKey('priority-${widget.priority}'),
                initialValue: widget.priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'High', child: Text('High')),
                ],
                onChanged: widget.onPriorityChanged,
              ),
            ),
            SizedBox(
              width: wide ? 170 : selectWidth,
              child: DropdownButtonFormField<String>(
                key: ValueKey('sort-${widget.sort}'),
                initialValue: widget.sort,
                decoration: const InputDecoration(
                  labelText: 'Sort',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'newest', child: Text('Newest')),
                  DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                ],
                onChanged: (value) {
                  if (value != null) widget.onSortChanged(value);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
