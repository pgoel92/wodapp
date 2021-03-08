import 'package:agora_flutter_quickstart/main.dart';
import 'package:flutter/material.dart';

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

  Row scoreInputRow(Model model) {
    return Row(children : []);
  }
}

SizedBox scoreInputBox(String initialValue, FormFieldSetter<String> onSaved, {double width = 40}) {
  return SizedBox(width : width, child : Card(child : Container(
      height : 40,
      child : TextFormField(
          initialValue : initialValue,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
          onSaved: onSaved
      ))
  ));
}

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

  Row scoreInputRow(Model model) {
    return Row(children : [
      scoreInputBox("", (String value) { model.score = value; }, width:60),
      Expanded(child : Text('rounds in ' + this.time.toString() + ' mins of :', style : globalTextStyle)),
    ]);
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
    print("here");
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

  Row scoreInputRow(Model model) {
    return Row(children : [
      Expanded(child : Text(this.n_rounds.toString() + ' rounds in ', style : globalTextStyle)),
      scoreInputBox("", (String value) { model.score = value; }, width:60),
      Expanded(child : Text(' mins of :', style : globalTextStyle))
    ]);
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
    print("here");
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

  Row scoreInputRow(Model model) {
    return Row(children : [
      scoreInputBox("", (String value) { model.score = value; }, width:60),
      Expanded(child : Text(' mins for :', style : globalTextStyle))
    ]);
  }
}