// Models for the email sync demo

// Model for the sync status document
class SyncStatus {
  final String userId;
  final String emailAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String status;
  final bool completed;
  final double percentage;
  final int totalEmails;
  final String message;
  final String syncCollection;

  SyncStatus({
    required this.userId,
    required this.emailAddress,
    this.createdAt,
    this.updatedAt,
    required this.status,
    required this.completed,
    required this.percentage,
    required this.totalEmails,
    required this.message,
    required this.syncCollection,
  });

  factory SyncStatus.fromMap(Map<String, dynamic> map) {
    return SyncStatus(
      userId: map['user_id'] ?? '',
      emailAddress: map['email_address'] ?? '',
      createdAt: map['created_at'] != null 
          ? (map['created_at'] as dynamic).toDate() 
          : null,
      updatedAt: map['updated_at'] != null 
          ? (map['updated_at'] as dynamic).toDate() 
          : null,
      status: map['status'] ?? 'unknown',
      completed: map['completed'] ?? false,
      percentage: (map['percentage'] ?? 0.0).toDouble(),
      totalEmails: map['total_emails'] ?? 0,
      message: map['message'] ?? '',
      syncCollection: map['sync_collection'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'email_address': emailAddress,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'status': status,
      'completed': completed,
      'percentage': percentage,
      'total_emails': totalEmails,
      'message': message,
      'sync_collection': syncCollection,
    };
  }
}

// Model for the sync response from the API
class SyncResponse {
  final String id;
  final String status;
  final double percentage;
  final String message;

  SyncResponse({
    required this.id,
    required this.status,
    required this.percentage,
    required this.message,
  });

  factory SyncResponse.fromMap(Map<String, dynamic> map) {
    return SyncResponse(
      id: map['id'] ?? '',
      status: map['status'] ?? '',
      percentage: (map['percentage'] ?? 0.0).toDouble(),
      message: map['message'] ?? '',
    );
  }
}

// Model for email documents in the sync collection
class EmailDocument {
  final Map<String, dynamic> data;

  EmailDocument({required this.data});

  factory EmailDocument.fromMap(Map<String, dynamic> map) {
    return EmailDocument(data: map);
  }
}
