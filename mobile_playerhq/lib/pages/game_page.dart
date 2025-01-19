import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mobile_playerhq/models/game.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_playerhq/pages/game/game_detail.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Future<List<Game>> gamesFuture;

  @override
  void initState() {
    super.initState();
    gamesFuture = fetchGames();
  }

  Future<List<Game>> fetchGames() async {
    log("${dotenv.env['RAWG_API']}");
    final gameResponse = await http.get(Uri.parse("${dotenv.env['RAWG_API']}"));
    final List<dynamic> gameList = jsonDecode(gameResponse.body)["results"];

    List<Game> games =
        gameList.map((gameJson) => Game.fromJson(gameJson)).toList();

    // Fetch prices for each game asynchronously
    for (var game in games) {
      final priceResponse = await http.get(Uri.parse(
          '${dotenv.env['CHEAPSHARK_API']}/games?title=${game.name}'));

      // Decode the response as a List<dynamic>
      final List<dynamic> priceList = jsonDecode(priceResponse.body);

      // Check if the list is not empty
      if (priceList.isNotEmpty) {
        // Assuming the first element contains the required price info
        final firstPriceItem = priceList[0];
        if (firstPriceItem.containsKey('cheapest')) {
          // Multiply the price by 16,000 to convert to IDR
          game.price =
              double.tryParse(firstPriceItem['cheapest'].toString())! * 16000;
        }
      }
    }

    return games;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Game>>(
        future: gamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final games = snapshot.data!;
            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final price = game.price ?? '-';

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 1, // Simple shadow
                  child: InkWell(
                    onTap: () {
                      // Navigate to the game detail page when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDetailPage(game: game),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(8)),
                          child: Image.network(game.backgroundImage,
                              fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                game.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        fontSize: 16, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rating: ${game.rating}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                price != "-"
                                    ? 'Price: ${NumberFormat.currency(
                                        locale: 'id_ID',
                                        symbol: 'Rp. ',
                                        decimalDigits: 0,
                                      ).format(price)}'
                                    : "-",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No games available.'));
          }
        },
      ),
    );
  }
}
