import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_playerhq/firebase_api.dart';
import 'package:mobile_playerhq/models/game.dart';
import 'package:mobile_playerhq/provider/user.dart';
import 'package:provider/provider.dart';

class GameDetailPage extends StatefulWidget {
  final Game game;

  const GameDetailPage({super.key, required this.game});

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final fcmToken = await FirebaseApi().getToken();
    setState(() {
      _fcmToken = fcmToken;
    });
  }

  Future<void> _buyGame(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data is unavailable')),
      );
      return;
    }

    final transactionData = {
      'game_api_id': widget.game.id,
      'amount': widget.game.price,
      'user_id': user.userId,
      "fcmToken": _fcmToken ?? "",
      "game": widget.game.name
    };

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/api/transaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transactionData),
      );

      if (response.statusCode == 200) {
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create transaction')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Text(
              'Are you sure you want to buy "${widget.game.name}" for Rp. ${NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp. ',
            decimalDigits: 0,
          ).format(widget.game.price)}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _buyGame(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(widget.game.backgroundImage, fit: BoxFit.cover),
                const SizedBox(height: 16),

                // Title and Details
                Text(
                  widget.game.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Release Date: ${widget.game.released}'),
                const SizedBox(height: 8),
                Text(
                    'Rating: ${widget.game.rating} (${widget.game.ratingsCount} ratings)'),
                const SizedBox(height: 8),
                if (widget.game.metacritic != null)
                  Text('Metacritic Score: ${widget.game.metacritic}'),

                // Platforms
                const SizedBox(height: 16),
                Text('Available Platforms:',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: widget.game.platforms
                      .map((platform) => Chip(label: Text(platform.name)))
                      .toList(),
                ),

                // Genres
                const SizedBox(height: 16),
                Text('Genres:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: widget.game.genres
                      .map((genre) => Chip(label: Text(genre.name)))
                      .toList(),
                ),

                // Stores
                const SizedBox(height: 16),
                Text('Available on Stores:',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: widget.game.stores
                      .map((store) => Chip(label: Text(store.store.name)))
                      .toList(),
                ),

                // ESRB Rating
                const SizedBox(height: 16),
                Text('ESRB Rating: ${widget.game.esrbRating.name}'),
                const SizedBox(height: 16),

                // Ratings Chart
                Text('Ratings Distribution:',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                _buildRatingChart(),
                const SizedBox(height: 16),
                _buildLegend(),

                // Screenshots
                const SizedBox(height: 16),
                Text('Screenshots:',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.game.shortScreenshots
                        .map((screenshot) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.network(
                                screenshot.image,
                                width: 200,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // Sticky Buy Button
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: widget.game.price != null && widget.game.price != '-'
                ? ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.black,
                    ),
                    child: Text(
                      'Buy ${widget.game.name} - ${NumberFormat.currency(
                        locale: 'id_ID', // Indonesian locale
                        symbol: 'Rp. ', // Currency symbol
                        decimalDigits: 0, // No decimal places
                      ).format(widget.game.price)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChart() {
    final sections = widget.game.ratings
        .map((rating) => PieChartSectionData(
              value: rating.percent,
              title: '${rating.percent.toStringAsFixed(1)}%',
              color: _getColorForRating(rating.title),
              radius: 50,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ))
        .toList();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.game.ratings.map((rating) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: _getColorForRating(rating.title),
              ),
              const SizedBox(width: 8),
              Text(
                '${rating.title} (${rating.percent.toStringAsFixed(1)}%)',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForRating(String title) {
    switch (title.toLowerCase()) {
      case 'exceptional':
        return Colors.green;
      case 'recommended':
        return Colors.blue;
      case 'meh':
        return Colors.orange;
      case 'skip':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
