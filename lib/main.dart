import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voltic Scores',
      home: ScorePage(),
    );
  }
}

class ScorePage extends StatefulWidget {
  @override
  _ScorePageState createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  Future<List<Score>> _fetchScores() async {
    final url = 'https://script.google.com/macros/s/AKfycby2qnZEDskOlihXxg2079QD0nVoR4mmk5GUEo5kIZndd5vVfnEVFx-eorzFgEb3RUaN/exec';

    try {
      final response = await http.get(Uri.parse(url));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Score> scores = data.map((item) => Score.fromJson(item)).where((score) => score.highScore > 0).toList();
        return scores;
      } else {
        throw Exception('Failed to load Voltic scores');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load Voltic scores temporarily. Please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voltic Scores'),
      ),
      body: FutureBuilder<List<Score>>(
        future: _fetchScores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No scores available'));
          } else {
            return ListView(
              children: snapshot.data!.map((score) => ListTile(
                title: Text(score.scenario),
                subtitle: Text(score.highScore > 0 ? 'High Score: ${score.highScore}' : 'No high score available'),
              )).toList(),
            );
          }
        },
      ),
    );
  }
}

class Score {
  final String scenario;
  final int highScore;

  Score({required this.scenario, required this.highScore});

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      scenario: json['Scenario'],
      highScore: int.tryParse(json['High Score'].toString()) ?? -1,
    );
  }
}
