import 'package:agora_flutter_quickstart/main.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class WoD {
  final Map<String, String> description;
  final List<Map<String, dynamic>> round;
  final String type;
  final int time;
  final String name;

  WoD({this.description, this.round, this.type, this.time, this.name});

  factory WoD.fromJson(Map<String, dynamic> json) {
    return WoD(
        description: Map<String, String>.from(json['description'] ?? {'rx' :'Nothing to see here'}),
        round: List<Map<String, dynamic>>.from(json['round'] ?? []),
        type: json['type'],
        time: json['time'],
        name: json['name']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "description" : description,
      "round" : round,
      "type" : type,
      "time" : time,
      "name" : name
    };
  }
}

class Score {
  final int cid;
  final String first_name;
  final String last_name;
  final bool is_rx;
  final String score;
  final String notes;

  Score({this.cid, this.first_name, this.last_name, this.is_rx, this.score, this.notes});

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      cid: json['cid'],
        first_name: json['first_name'],
        last_name: json['last_name'],
      is_rx: json['is_rx'],
      score: json['score'],
      notes: json['notes']
    );
  }
}

Future<WoD> fetch_wod(date) async {
  print('Fetching wod for date ${date}');
  try {
    final response = await http.get('http://127.0.0.1:5000/wod?date=$date');
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var myjson = json.decode(response.body) as Map<String, dynamic>;
      var wod = WoD.fromJson(myjson);
      return wod;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load wod');
    }
  } on Exception {
    return WoD.fromJson({});
  }
}

Future<List<dynamic>> fetch_athletes() async {
  print('Fetching athletes');
  try {
    final response = await http.get('http://127.0.0.1:5000/athletes');
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var myjson = json.decode(response.body) as List<dynamic>;
      //var whatev = WoD.fromJson(myjson);
      return myjson;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load athletes');
    }
  } on Exception {
    return [];
  }
}

Future<List<Score>> fetch_scores(date) async {
  print('Fetching scores for date ${date}');
  try {
    final response = await http.get('http://127.0.0.1:5000/scores?date=$date');
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var scores_json = json.decode(response.body);
      List<Score> scores = [];
      for (var i = 0; i < scores_json.length; i++) {
        scores.add(Score.fromJson(scores_json[i]));
      }
      print(scores);
      return scores;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load scores');
    }
  } on Exception {
    return [];
  }
}

Future<http.Response> put_data(Map<String, dynamic> body) async {
  print('Putting data');
  return http.post('http://127.0.0.1:5000/customers/ABC',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(body),
  );
}

Future<void> put_score(WoD wod, Model data) async {
  final http.Response response = await put_data({'program_id': 4, 'athlete_id': 3, 'scaled_wod' : wod.toJson(), 'score': data.score, 'notes': data.notes});
  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return;
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to put score');
  }
}