class TransactionItem {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final String method;
  final String status;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
      'status': status,
    };
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
      method: (json['method'] as String?) ?? 'QR',
      status: (json['status'] as String?) ?? 'Completado',
    );
  }
}