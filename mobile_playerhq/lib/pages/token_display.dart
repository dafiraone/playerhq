import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_playerhq/firebase_api.dart'; // Import for Clipboard

class TokenDisplayPage extends StatefulWidget {
  const TokenDisplayPage({super.key});

  @override
  State<TokenDisplayPage> createState() => _TokenDisplayPageState();
}

class _TokenDisplayPageState extends State<TokenDisplayPage> {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  // Load token using FirebaseApi
  Future<void> _loadToken() async {
    // Assume you fetch the token here (e.g., from Firebase API)
    final fcmToken = await FirebaseApi().getToken();
    setState(() {
      _fcmToken = fcmToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FCM Token")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "FCM Token:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _fcmToken == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black))
                : TextField(
                    controller: TextEditingController(text: _fcmToken),
                    readOnly: true, // Make it readonly for copying
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          if (_fcmToken != null && _fcmToken!.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: _fcmToken!));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Token copied!")));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("No token available")));
                          }
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
