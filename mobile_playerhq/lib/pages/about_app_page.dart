import 'dart:io'; // Add this import for using dart:io
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  // Helper function to launch a URL (Windows workaround)
  Future<void> _launchURL(String url) async {
    if (Platform.isWindows) {
      // For Windows, using dart:io to open the browser
      try {
        await Process.run('cmd', ['/c', 'start', url]);
      } catch (e) {
        throw 'Could not launch $url: $e';
      }
    } else {
      // For other platforms, use the url_launcher package
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0, // No elevation for a flat design
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PlayerHQ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gamer\'s Store & Social Media',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Text(
              'Proyek UAS IFB-355 Pemrograman Mobile',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kelompok:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('152022003 - Muhammad Daffa DJI',
                style: TextStyle(fontSize: 14)),
            const Text('152022012 - Katon Rinantomo',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 24),
            const Text(
              'APIs Used:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchURL('https://rawg.io/apidocs'),
              child: const Text(
                'RAWG API',
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchURL('https://apidocs.cheapshark.com/'),
              child: const Text(
                'CheapShark API',
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
