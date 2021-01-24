import 'package:agora_flutter_quickstart/main.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class WoD {
  final int id;
  final String date;
  final int wid;
  final String name;
  final String desc_rx;
  final String desc_scale;

  WoD({this.id, this.date, this.wid, this.name, this.desc_rx, this.desc_scale});

  factory WoD.fromJson(Map<String, dynamic> json) {
    return WoD(
        id: json['id'],
        date: json['date'],
        wid: json['wid'],
        name: json['name'],
        desc_rx: json['desc_rx'],
        desc_scale: json['desc_scale']
    );
  }
}

class Score {
  final int cid;
  final String cname;
  final String date;
  final int wid;
  final String score;
  final String notes;

  Score({this.cid, this.cname, this.date, this.wid, this.score, this.notes});

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      cid: json['cid'],
      cname: json['cname'],
      date: json['date'],
      wid: json['wid'],
      score: json['score'],
      notes: json['notes']
    );
  }
}

Future<WoD> fetch_wod() async {
  print('Fetching data');
  final response = await http.get('http://127.0.0.1:5000/wod');
  print(response.body);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return WoD.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load wod');
  }
}

Future<List<Score>> fetch_scores() async {
  print('Fetching data');
  final response = await http.get('http://127.0.0.1:5000/scores');
  print(response.body);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var scores_json = json.decode(response.body);
    List<Score> scores = [];
    for(var i = 0; i < scores_json.length; i++) {
      scores.add(Score.fromJson(scores_json[i]));
    }
    return scores;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load scores');
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
  final http.Response response = await put_data({'wod_id': 123, 'cid': 3, 'cname' : data.name, 'score': data.score, 'notes': data.notes});
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