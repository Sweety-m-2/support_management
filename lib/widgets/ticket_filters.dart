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
    final screenWidth = MediaQuery.sizeOf(context).width;

    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;

    if (isMobile) {
      return _buildMobileFilters();
    }

    if (isTablet) {
      return _buildTabletFilters();
    }

    return _buildDesktopFilters();
  }

  Widget _buildMobileFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchField(),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: _buildStatusDropdown()),
            const SizedBox(width: 12),
            Expanded(child: _buildPriorityDropdown()),
          ],
        ),

        const SizedBox(height: 12),

        _buildSortDropdown(),
      ],
    );
  }

  Widget _buildTabletFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchField(),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: _buildStatusDropdown()),
            const SizedBox(width: 12),
            Expanded(child: _buildPriorityDropdown()),
            const SizedBox(width: 12),
            Expanded(child: _buildSortDropdown()),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildSearchField()),

        const SizedBox(width: 12),

        SizedBox(width: 170, child: _buildStatusDropdown()),

        const SizedBox(width: 12),

        SizedBox(width: 170, child: _buildPriorityDropdown()),

        const SizedBox(width: 12),

        SizedBox(width: 170, child: _buildSortDropdown()),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      // key: const ValueKey('ticket-search-field'),
      controller: _searchController,
      onChanged: widget.onSearchChanged,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        labelText: 'Search',
        hintText: 'Search by title or customer email',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String?>(
      key: ValueKey('status-${widget.status}'),
      initialValue: widget.status,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('All')),
        DropdownMenuItem(value: 'Open', child: Text('Open')),
        DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
        DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
      ],
      onChanged: widget.onStatusChanged,
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<String?>(
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
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButtonFormField<String>(
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
        if (value != null) {
          widget.onSortChanged(value);
        }
      },
    );
  }
}
