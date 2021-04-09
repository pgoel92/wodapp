import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
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

Future<List<Workout>> search_workout(searchKeyword) async {
  print('Fetching workouts with ${searchKeyword}');
  try {
    final response = await http.get('http://127.0.0.1:5000/workouts?keyword=$searchKeyword');
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var results_json = json.decode(response.body);
      List<Workout> workouts = [];
      for (var i = 0; i < results_json.length; i++) {
        workouts.add(Workout.fromJson(results_json[i]));
      }
      return workouts;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load scores');
    }
  } on Exception {
    return [];
  }
}

Future<List<Score>> fetch_customer_scores(date, workout_id) async {
  print('Fetching scores for workout_id ${workout_id}');
  try {
    final response = await http.get('http://127.0.0.1:5000/customers/scores?workout_id=$workout_id&date=$date');
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

Future<http.Response> put_data(String path, Map<String, dynamic> body) async {
  print('Putting data');
  return http.post('http://127.0.0.1:5000/' + path,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(body),
  );
}

Future<void> put_wod(date, id) async {
  print('Putting wod ${id} for ${date}');
  final http.Response response = await put_data('wod', {'id': id, 'date': date});
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

Future<void> put_score(Model data) async {
  final http.Response response = await put_data('customers/ABC', {'program_id': data.wod.id, 'athlete_id': data.athlete_id, 'scaled_wod' : data.updatedWod.workout.toJson(), 'score': data.score, 'notes': data.notes, 'is_rx' : data.is_rx});
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