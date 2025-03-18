import 'package:email_firebase_demo/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'models.dart';
import 'services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptionsDevelopment.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email Firebase Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const EmailSyncPage(),
    );
  }
}

class EmailSyncPage extends StatefulWidget {
  const EmailSyncPage({super.key});

  @override
  State<EmailSyncPage> createState() => _EmailSyncPageState();
}

class _EmailSyncPageState extends State<EmailSyncPage> {
  final EmailSyncService _service = EmailSyncService();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(
    text: 'alvin2phantomhive@gmail.com', // Default email for demo
  );

  String? _syncId;
  bool _isLoading = false;
  String _errorMessage = '';

  // Lists to store data
  SyncStatus? _syncStatus;
  List<EmailDocument> _emails = [];
  ScrollController _scrollController = ScrollController();
  bool _isFirstLoad = true;

  String _formatDateTime(String dateTimeStr) {
    final date = DateTime.parse(dateTimeStr);

    // Get month name
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final monthName = months[date.month - 1];

    // Format hour for 12-hour clock
    int hour = date.hour % 12;
    if (hour == 0) hour = 12; // 0 should be displayed as 12 in 12-hour format

    // Add leading zeros to minutes
    final minutes = date.minute.toString().padLeft(2, '0');

    // AM/PM indicator
    final period = date.hour < 12 ? 'am' : 'pm';

    return '${date.day} $monthName ${date.year} $hour:$minutes $period';
  }

  @override
  void initState() {
    super.initState();
    // You could load a saved token here if you have one
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _emailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Start the email sync process
  Future<void> _startSync() async {
    if (_tokenController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an authentication token';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _syncId = null;
      _syncStatus = null;
      _emails = [];
      _isFirstLoad = true;
    });

    try {
      // Set the auth token
      _service.setAuthToken(_tokenController.text);

      // Start the sync
      final response = await _service.startEmailSync(_emailController.text);

      setState(() {
        _syncId = response.id;
        _isLoading = false;
      });

      // Start listening to Firestore
      _listenToFirestore();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  // Listen to Firestore for updates
  void _listenToFirestore() {
    if (_syncId == null) return;

    // Listen to sync status
    _service.listenToSyncStatus(_syncId!).listen((status) {
      if (mounted) {
        setState(() {
          _syncStatus = status;
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Firestore error: ${error.toString()}';
        });
      }
    });

    // Listen to sync collection
    _service.listenToSyncCollection(_syncId!).listen((emails) {
      if (mounted) {
        _updateEmails(emails);
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Firestore error: ${error.toString()}';
        });
      }
    });
  }

  void _updateEmails(List<EmailDocument> newEmails) {
    setState(() {
      _emails = newEmails;

      // Only scroll to bottom on first load
      if (_isFirstLoad && _emails.isNotEmpty) {
        _isFirstLoad = false;
        // Use a post-frame callback to ensure the list has been built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Firebase Sync Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Authentication token input
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Authentication Token',
                hintText: 'Enter your Bearer token',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Email input
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter email to sync',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Sync button
            ElevatedButton(
              onPressed: _isLoading ? null : _startSync,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Start Email Sync'),
            ),

            // Error message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Sync ID
            if (_syncId != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Sync ID: $_syncId',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

            // Sync status
            if (_syncStatus != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sync Status',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        Text('Status: ${_syncStatus!.status}'),
                        Text('Completed: ${_syncStatus!.completed}'),
                        Text(
                            'Progress: ${(_syncStatus!.percentage * 100).toStringAsFixed(1)}%'),
                        LinearProgressIndicator(
                          value: _syncStatus!.percentage,
                        ),
                        const SizedBox(height: 8),
                        Text('Total Emails: ${_syncStatus!.totalEmails}'),
                        Text('Message: ${_syncStatus!.message}'),
                        Text('Collection: ${_syncStatus!.syncCollection}'),
                      ],
                    ),
                  ),
                ),
              ),

            // Email list
            if (_emails.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emails (${_emails.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          itemCount: _emails.length,
                          itemBuilder: (context, index) {
                            final email = _emails[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      email.data['email_date'] == null
                                          ? 'No Date'
                                          : _formatDateTime(
                                              email.data['email_date']),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                    ),
                                    Text(
                                      email.data['subject'] ?? 'No Subject',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const Divider(),
                                    ...email.data.entries.map((entry) {
                                      // Format the value based on its type
                                      String valueStr = '';
                                      if (entry.value == null) {
                                        valueStr = 'null';
                                      } else if (entry.value is Map) {
                                        // Pretty print the JSON
                                        final jsonMap =
                                            Map<String, dynamic>.from(
                                                entry.value as Map);
                                        valueStr =
                                            const JsonEncoder.withIndent('  ')
                                                .convert(jsonMap);
                                      } else if (entry.value is List) {
                                        // Pretty print the JSON
                                        final jsonList = List<dynamic>.from(
                                            entry.value as List);
                                        valueStr =
                                            const JsonEncoder.withIndent('  ')
                                                .convert(jsonList);
                                      } else {
                                        valueStr = entry.value.toString();
                                      }

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 150,
                                              child: Text(
                                                '${entry.key}:',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                valueStr,
                                                style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
