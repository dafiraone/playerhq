import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_playerhq/models/game.dart';

class UserGameList extends StatefulWidget {
  final int userId;

  const UserGameList({super.key, required this.userId});

  @override
  _UserGameListState createState() => _UserGameListState();
}

class _UserGameListState extends State<UserGameList> {
  List<Game> ownedGames = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOwnedGames();
  }

  Future<void> _fetchOwnedGames() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Fetch transactions for the user
      final transactionsResponse = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/transaction'),
      );

      if (transactionsResponse.statusCode != 200) {
        throw Exception(
            'Failed to load transactions: ${transactionsResponse.statusCode}');
      }

      final List<dynamic> transactions =
          jsonDecode(transactionsResponse.body) as List<dynamic>;

      // Filter transactions for the current user
      final userTransactions = transactions.where((transaction) {
        return transaction['user_id'] == widget.userId;
      }).toList();

      // Extract game_api_ids from user transactions
      final List<int> gameApiIds = userTransactions
          .map((transaction) => transaction['game_api_id'] as int)
          .toList();

      // Fetch game data
      final gamesResponse = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/test'),
      );

      if (gamesResponse.statusCode != 200) {
        throw Exception('Failed to load games: ${gamesResponse.statusCode}');
      }

      final List<dynamic> gamesData =
          jsonDecode(gamesResponse.body)['results'] as List<dynamic>;

      // Map the games API data to Game objects
      final allGames =
          gamesData.map((gameJson) => Game.fromJson(gameJson)).toList();

      // Filter the owned games using game_api_ids
      final filteredGames = allGames.where((game) {
        return gameApiIds.contains(game.id);
      }).toList();

      setState(() {
        ownedGames = filteredGames;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching data: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteGame(int gameId) async {
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['API_URL']}/api/transaction/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'game_api_id': gameId, // Add userId here
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Game Removed")),
        );

        await _fetchOwnedGames();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove game')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Games',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ownedGames.isEmpty
                  ? const Center(child: Text('You do not own any games yet.'))
                  : ListView.builder(
                      itemCount: ownedGames.length,
                      itemBuilder: (context, index) {
                        final game = ownedGames[index];
                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            leading: Image.network(
                              game.backgroundImage,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                            title: Text(game.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rating: ${game.rating}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.black),
                              onPressed: () {
                                _deleteGame(game.id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
