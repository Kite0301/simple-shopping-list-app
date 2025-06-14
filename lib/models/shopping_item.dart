class ShoppingItem {
  final String id;
  String title;
  String memo;
  bool isPurchased;
  DateTime createdAt;
  int sortOrder;
  DateTime? completedAt;

  ShoppingItem({
    required this.id,
    required this.title,
    this.memo = '',
    this.isPurchased = false,
    DateTime? createdAt,
    int? sortOrder,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       sortOrder = sortOrder ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'memo': memo,
      'isPurchased': isPurchased,
      'createdAt': createdAt.toIso8601String(),
      'sortOrder': sortOrder,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      title: json['title'],
      memo: json['memo'] ?? '',
      isPurchased: json['isPurchased'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      sortOrder: json['sortOrder'] ?? DateTime.parse(json['createdAt']).millisecondsSinceEpoch,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  ShoppingItem copyWith({
    String? title,
    String? memo,
    bool? isPurchased,
    int? sortOrder,
    DateTime? completedAt,
  }) {
    return ShoppingItem(
      id: id,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      isPurchased: isPurchased ?? this.isPurchased,
      createdAt: createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}