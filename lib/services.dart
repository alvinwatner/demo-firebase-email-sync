import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class EmailSyncService {
  // API URL
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Your authentication token
  String? _authToken;
  
  // Set the auth token
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  // Get the auth token
  String? get authToken => _authToken;
  
  // Start email sync
  Future<SyncResponse> startEmailSync(String emailAddress) async {
    if (_authToken == null) {
      throw Exception('Authentication token not set');
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/emails/sync'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken',
      },
      body: jsonEncode({
        'email_address': emailAddress,
      }),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return SyncResponse.fromMap(data);
    } else {
      throw Exception('Failed to start email sync: ${response.statusCode} ${response.body}');
    }
  }
  
  // Listen to sync status document
  Stream<SyncStatus?> listenToSyncStatus(String syncId) {
    return _firestore
        .collection('email_sync_status')
        .doc(syncId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return SyncStatus.fromMap(snapshot.data()!);
      } else {
        return null;
      }
    });
  }
  
  // Listen to sync collection
  Stream<List<EmailDocument>> listenToSyncCollection(String syncId) {
    return _firestore
        .collection('new_emails_sync_$syncId')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EmailDocument.fromMap(doc.data()))
          .toList();
    });
  }
}
