class CreditTopupRequest {
  final String id;
  final int requestedCredits;
  final String paymentMethod;
  final String referenceNote;
  final String status; // pending | approved | rejected
  final DateTime createdAt;

  CreditTopupRequest({
    required this.id,
    required this.requestedCredits,
    required this.paymentMethod,
    required this.referenceNote,
    required this.status,
    required this.createdAt,
  });

  factory CreditTopupRequest.fromJson(Map<String, dynamic> j) {
    return CreditTopupRequest(
      id: j['id'] as String,
      requestedCredits: j['requested_credits'] as int,
      paymentMethod: j['payment_method'] as String? ?? '',
      referenceNote: j['reference_note'] as String? ?? '',
      status: j['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
    );
  }
}
