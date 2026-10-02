class Ticket {
  const Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.customerEmail,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String description;
  final String customerEmail;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      customerEmail: json['customer_email']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  static int _asInt(dynamic value) =>
      value is int ? value : int.tryParse('$value') ?? 0;

  static DateTime _asDateTime(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

class TicketSummary {
  const TicketSummary({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
  });

  final int total;
  final int open;
  final int inProgress;
  final int resolved;

  factory TicketSummary.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) =>
        value is int ? value : int.tryParse('$value') ?? 0;
    return TicketSummary(
      total: asInt(json['total']),
      open: asInt(json['open']),
      inProgress: asInt(json['in_progress']),
      resolved: asInt(json['resolved']),
    );
  }
}

class TicketListResponse {
  const TicketListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.summary,
  });

  final List<Ticket> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final TicketSummary summary;

  factory TicketListResponse.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) =>
        value is int ? value : int.tryParse('$value') ?? 0;
    final rawItems = json['items'];
    final rawSummary = json['summary'];
    return TicketListResponse(
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map((item) => Ticket.fromJson(Map<String, dynamic>.from(item)))
                .toList()
          : const [],
      total: asInt(json['total']),
      page: asInt(json['page']),
      limit: asInt(json['limit']),
      totalPages: asInt(json['total_pages']),
      summary: TicketSummary.fromJson(
        rawSummary is Map ? Map<String, dynamic>.from(rawSummary) : const {},
      ),
    );
  }
}
