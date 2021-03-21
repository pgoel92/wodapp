import 'package:agora_flutter_quickstart/main.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'workout.dart';

Future<Program> fetch_wod(date) async {
  print('Fetching wod for date ${date}');
  try {
    final response = await http.get('http://127.0.0.1:5000/wod?date=$date');
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var myjson = json.decode(response.body) as Map<String, dynamic>;
      var wod = Program.fromJson(myjson);
      return wod;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load wod');
    }
  } on Exception {
    return Program.fromJson({});
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

Future<void> put_score(Model data) async {
  final http.Response response = await put_data({'program_id': data.wod.id, 'athlete_id': data.athlete_id, 'scaled_wod' : data.updatedWod.workout.toJson(), 'score': data.score, 'notes': data.notes});
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