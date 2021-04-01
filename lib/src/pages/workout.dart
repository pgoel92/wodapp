import 'package:agora_flutter_quickstart/main.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';

import 'dart:convert';

class Program {
  final int id;
  final Workout workout;

  Program({this.id, this.workout});

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
        id: json['id'] ?? -1,
        workout: Workout.fromJson(json['workout'] ?? {})
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id" : id,
      "workout" : workout.toJson()
    };
  }
}

class Score {
  final int cid;
  final String first_name;
  final String last_name;
  final bool is_rx;
  final dynamic score;
  final String type;
  final String notes;

  Score({this.cid, this.first_name, this.last_name, this.is_rx, this.score, this.type, this.notes});

  factory Score.fromJson(Map<String, dynamic> jsonMap) {
    return Score(
        cid: jsonMap['cid'],
        first_name: jsonMap['first_name'],
        last_name: jsonMap['last_name'],
        is_rx: jsonMap['is_rx'],
        score: json.decode(jsonMap['score']),
        type: jsonMap['type'],
        notes: jsonMap['notes']
    );
  }
}

class Model {
  Program wod;
  Program updatedWod;
  int athlete_id;
  dynamic score;
  String notes;

  Model({this.athlete_id, this.score, this.notes, this.wod, this.updatedWod});

  Map<String, String> toJson() {
    return {
      'athlete_id': athlete_id.toString(),
      'score': score,
      'notes' : notes,
      'wod' : wod.toString(),
      'updatedWod' : updatedWod.toString()
    };
  }
}

class Workout {
  int id;
  Map<String, dynamic> description;
  List<Map<String, dynamic>> round;
  String type;
  String name;

  Workout({this.id, this.description, this.round, this.type, this.name});

  factory Workout.fromJson(Map<String, dynamic> json) {
    switch(json['type']) {
      case "amrap": {return AMRAPWorkout.fromJson(json);}
      case "for_time": {return ForTimeWorkout.fromJson(json);}
      case "21-15-9": {return TwentyOne_Fifteen_Nine.fromJson(json);}
    }
    return Workout(
        id: json['id'] ?? -1,
        description: Map<String, String>.from(json['description'] ?? {'rx' :'Nothing to see here'}),
        round: List<Map<String, dynamic>>.from(json['round'] ?? []),
        type: json['type'],
        name: json['name']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id" : id,
      "description" : description,
      "round" : round,
      "type" : type,
      "name" : name
    };
  }

  Column scoreInputColumn(Model model) {
    return Column(children : []);
  }

  String getDescription() {
    return "Nothing to see here";
  }

  static String parseScore(Score score) {
    switch(score.type) {
      case "amrap": {
        return score.score['rounds'].toString() + " + " + score.score['reps'].toString();
      }
      case "for_time": {
        return score.score['mins'].toString() + " : " + score.score['seconds'].toString();
      }
      case "21-15-9": {return score.score.toString();}
    }
  }
}

Expanded scoreInputBox(String initialValue, FormFieldSetter<String> onSaved, String hint, {double width = 40}) {
  return Expanded(child : Card(child : Container(
      height : 100,
      child : TextFormField(
          initialValue : initialValue,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
          onSaved: onSaved,
          style: scoreTextStyle,
          textAlign : TextAlign.center,
          decoration: new InputDecoration(
              border: InputBorder.none,
              contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 25, right: 15),
              hintText: hint)
      )))
  );
}

TextStyle scoreTextStyle = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);

class AMRAPWorkout extends Workout{
  int time;

  AMRAPWorkout(int id, Map<String, dynamic> description, List<Map<String, dynamic>> round, String type, String name, int time) {
    this.id = id;
    this.time = time;
    this.description = description;
    this.round = round;
    this.type = type;
    this.name = name;
  }

  factory AMRAPWorkout.fromJson(Map<String, dynamic> json) {
    return AMRAPWorkout(
        json['id'] ?? -1,
        Map<String, String>.from(json['description'] ?? {'rx' :'Nothing to see here'}),
        List<Map<String, dynamic>>.from(json['round'] ?? []),
        json['type'],
        json['name'],
        json['time']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id" : id,
      "description" : description,
      "round" : round,
      "type" : type,
      "time" : time,
      "name" : name
    };
  }

  Column scoreInputColumn(Model model) {
    return Column(children : [Row(children : [
      scoreInputBox("", (String value) { if (model.score == null) {
        model.score = {'rounds' : int.parse(value)}; } else {model.score['rounds'] = int.parse(value);}}, "rounds", width:60),
      Text(' + ', style : scoreTextStyle),
      scoreInputBox("", (String value) { if (model.score == null) {
        model.score = {'reps' : int.parse(value)}; } else {model.score['reps'] = int.parse(value);}}, "reps", width:60)
    ])]);
  }

  String getDescription() {
    var description = 'AMRAP:\n';
    for (var i = 0; i < this.round.length; i++) {
      var item = this.round[i];
      description = description + item['n_reps'].toString() + " " + item['mov'];
      description = description + '\n';
    }
    return description;
  }
}

class ForTimeWorkout extends Workout {
  int n_rounds;

  ForTimeWorkout(int id, Map<String, dynamic> description, List<Map<String, dynamic>> round, String type, String name, int n_rounds) {
    this.id = id;
    this.n_rounds = n_rounds;
    this.description = description;
    this.round = round;
    this.type = type;
    this.name = name;
  }

  factory ForTimeWorkout.fromJson(Map<String, dynamic> json) {
    return ForTimeWorkout(
        json['id'] ?? -1,
        Map<String, String>.from(json['description'] ?? {'rx' :'Nothing to see here'}),
        List<Map<String, dynamic>>.from(json['round'] ?? []),
        json['type'],
        json['name'],
        json['n_rounds']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id" : id,
      "description" : description,
      "round" : round,
      "type" : type,
      "n_rounds" : n_rounds,
      "name" : name
    };
  }

  Column scoreInputColumn(Model model, {bool timeCap = false}) {
    if (timeCap == false) {
      return Column(children : [Row(children : [
      scoreInputBox("", (String value) { if (model.score == null) {
        model.score = {'mins' : int.parse(value)}; } else {model.score['mins'] = int.parse(value);}}, "minutes", width:60),
      Text(' : ', style : globalTextStyle),
      scoreInputBox("", (String value) { if (model.score == null) {
        model.score = {'seconds' : int.parse(value)}; } else {model.score['seconds'] = int.parse(value);}}, "seconds", width:60)
    ])]);
    } else {
    return Column(children : [Row(children : [
      scoreInputBox("", (String value) { if (model.score == null) {
        model.score = {'rounds' : int.parse(value)}; } else {model.score['rounds'] = int.parse(value);}}, "rounds", width:60),
      Text(' + ', style : globalTextStyle),
      scoreInputBox("", (String value) { if (model.score == null) {
        model.score = {'reps' : int.parse(value)}; } else {model.score['reps'] = int.parse(value);}}, "reps", width:60)
    ])]);
    }
  }

  String getDescription() {
    var description = 'For time:\n';
    for (var i = 0; i < this.round.length; i++) {
        var item = this.round[i];
        description = description + item['n_reps'].toString() + " " + item['mov'];
        description = description + '\n';
    }
    return description;
  }


}

class TwentyOne_Fifteen_Nine extends Workout {

  TwentyOne_Fifteen_Nine(int id, Map<String, dynamic> description, List<Map<String, dynamic>> round, String type, String name) {
    this.id = id;
    this.description = description;
    this.round = round;
    this.type = type;
    this.name = name;
  }

  factory TwentyOne_Fifteen_Nine.fromJson(Map<String, dynamic> json) {
    return TwentyOne_Fifteen_Nine(
        json['id'] ?? -1,
        Map<String, String>.from(json['description'] ?? {'rx' :'Nothing to see here'}),
        List<Map<String, dynamic>>.from(json['round'] ?? []),
        json['type'],
        json['name']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id" : id,
      "description" : description,
      "round" : round,
      "type" : type,
      "name" : name
    };
  }

  Column scoreInputColumn(Model model) {
    return Column(children : [Row(children : [
      scoreInputBox("", (String value) { if (model.score == null) {
        model.score = {'mins' : int.parse(value)}; } else {model.score['mins'] = int.parse(value);}}, "minutes", width:60),
      Text(' : ', style : globalTextStyle),
      scoreInputBox("", (String value) { if (model.score == null) {
        model.score = {'seconds' : int.parse(value)}; } else {model.score['seconds'] = int.parse(value);}}, "seconds", width:60)
    ])]);
  }

  String getDescription() {
    var description = '21-15-9 reps of :\n';
    for (var i = 0; i < this.round.length; i++) {
      var item = this.round[i];
      description = description + item['mov'];
      description = description + '\n';
    }
    return description;
  }
}