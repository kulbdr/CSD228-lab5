import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(PokemonBattleApp());
}

class PokemonBattleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokémon TCG Battle',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
      ),
      home: PokemonBattleScreen(),
    );
  }
}

class PokemonBattleScreen extends StatefulWidget {
  @override
  _PokemonBattleScreenState createState() => _PokemonBattleScreenState();
}

class _PokemonBattleScreenState extends State<PokemonBattleScreen> {
  String card1Image = '';
  String card2Image = '';
  int card1HP = 0;
  int card2HP = 0;
  String winnerMessage = 'Press the button to start the battle!';

  @override
  void initState() {
    super.initState();
    fetchRandomCards();
  }

  Future<void> fetchRandomCards() async {
    final response = await http.get(Uri.parse('https://api.pokemontcg.io/v2/cards'));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List cards = data['data'];

      if (cards.length < 2) return;

      Random random = Random();
      var randomCards = [
        cards[random.nextInt(cards.length)],
        cards[random.nextInt(cards.length)]
      ];

      setState(() {
        card1Image = randomCards[0]['images']['large'];
        card2Image = randomCards[1]['images']['large'];
        card1HP = int.tryParse(randomCards[0]['hp'] ?? '0') ?? 0;
        card2HP = int.tryParse(randomCards[1]['hp'] ?? '0') ?? 0;
        winnerMessage = determineWinner();
      });
    } else {
      setState(() {
        winnerMessage = 'Failed to load Pokémon cards. Try again!';
      });
    }
  }

  String determineWinner() {
    if (card1HP > card2HP) {
      return '🎉 Winner: Pokémon 1!';
    } else if (card2HP > card1HP) {
      return '🎉 Winner: Pokémon 2!';
    } else {
      return '⚔️ It\'s a Tie!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.yellow.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🔥 Pokémon TCG Battle 🔥',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 3, color: Colors.black)],
              ),
            ),
            SizedBox(height: 20),
            if (card1Image.isNotEmpty && card2Image.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCard('Pokémon 1', card1Image, card1HP),
                  _buildCard('Pokémon 2', card2Image, card2HP),
                ],
              ),
              SizedBox(height: 20),
              Text(
                winnerMessage,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                ),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchRandomCards,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                shadowColor: Colors.black,
                elevation: 8,
              ),
              child: Text('🔄 Load New Battle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String imageUrl, int hp) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      color: Colors.white,
      child: Container(
        width: 160,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 8),
            Image.network(imageUrl, height: 150),
            SizedBox(height: 8),
            Text(
              'HP: $hp',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
