import 'package:agora_flutter_quickstart/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../utils/utils.dart';

import 'dart:convert';

var REPS_KEY = "n_reps";
var MOVEMENT_KEY = "mov";
var WEIGHT_KEY = "weight_m";

class Program {
  int id;
  Workout workout;

  Program({this.id, this.workout});

  Program.empty() {
    this.id = -1;
    this.workout = Workout();
  }

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

  Program.fromProgram(Program p) {
    this.id = p.id;
    this.workout = Workout.fromWorkout(p.workout);
  }

  String getDescription() {
    if (this.workout != null && this.workout.getDescription().isNotEmpty) {
      return this.workout.getDescription();
    }
    return "Rest day";
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
  final String date;

  Score({this.cid, this.first_name, this.last_name, this.is_rx, this.score, this.type, this.notes, this.date});

  factory Score.fromJson(Map<String, dynamic> jsonMap) {
    return Score(
        cid: jsonMap['cid'],
        first_name: jsonMap['first_name'],
        last_name: jsonMap['last_name'],
        is_rx: jsonMap['is_rx'],
        score: json.decode(jsonMap['score']),
        type: jsonMap['type'],
        notes: jsonMap['notes'],
        date: jsonMap['date']
    );
  }
}

class Model {
  Program wod;
  Program updatedWod;
  int athlete_id;
  dynamic score;
  String notes;
  bool is_rx;

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
  List<Map<String, dynamic>> round;
  String type;
  String name;

  Workout({this.id, this.round, this.type, this.name});

  Workout.empty() {
    this.id = -1;
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    switch(json['type']) {
      case "amrap": {return AMRAPWorkout.fromJson(json);}
      case "for_time": {return ForTimeWorkout.fromJson(json);}
      case "21-15-9": {return TwentyOne_Fifteen_Nine.fromJson(json);}
    }
    return Workout(
        id: json['id'] ?? -1,
        round: List<Map<String, dynamic>>.from(json['round'] ?? []),
        type: json['type'],
        name: json['name']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id" : id,
      "round" : round,
      "type" : type,
      "name" : name
    };
  }

  Column scoreInputColumn(Model model) {
    return Column(children : []);
  }

  String getDescription() {
    return '';
  }

  static String parseScore(Score score, Program wod) {
    switch(score.type) {
      case "amrap": {
        return score.score['rounds'].toString() + " + " + score.score['reps'].toString();
      }
      case "for_time": {
        var f = new NumberFormat("00", "en_US");
        return score.score['mins'].toString() + " : " + f.format(score.score['seconds']).toString();
      }
      case "21-15-9": {
        var f = new NumberFormat("00", "en_US");
        return score.score['mins'].toString() + " : " + score.score['seconds'].toString();
      }
    }
  }

  static String rx_or_scaled(Score score, Program wod) {
    if (score.is_rx) {
      return "Rx";
    } else {
      return "";
    }
  }

  List<Row> getWorkoutUpdateForm() {
    return this.round.map((Map<String, dynamic> mov) {
      var children = [
        workoutInputBox(mov[REPS_KEY].toString(), (String value) {
          mov[REPS_KEY] = value;
        }),
        Text(mov[MOVEMENT_KEY], style : globalTextStyle)
      ];
      if(mov[WEIGHT_KEY] != null) {
        children = children + [
          workoutInputBox(mov[WEIGHT_KEY].toString(), (String value) {
            mov[WEIGHT_KEY] = value;
          }),
          Text('lbs', style : globalTextStyle)
        ];
      }
      return Row(children : children);
    }).toList();
  }

  factory Workout.fromWorkout(Workout w) {
    switch(w.type) {
      case "for_time": {return ForTimeWorkout.fromWorkout(w);}
      case "amrap": {return AMRAPWorkout.fromWorkout(w);}
      case "21-15-9": {return TwentyOne_Fifteen_Nine.fromWorkout(w);}
    }
    return Workout(
        id: w.id,
        round: w.round,
        type: w.type,
        name: w.name
    );
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

SizedBox workoutInputBox(String initialValue, FormFieldSetter<String> onSaved, {double width = 40}) {
  return SizedBox(width : width, child : Card(
      color: Colors.black12,
      child : Container(child : globalTextFormField(initialValue, onSaved))
  ));
}

TextStyle scoreTextStyle = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);

class AMRAPWorkout extends Workout{
  int time;

  AMRAPWorkout(int id, List<Map<String, dynamic>> round, String type, String name, int time) {
    this.id = id;
    this.time = time;
    this.round = round;
    this.type = type;
    this.name = name;
  }

  factory AMRAPWorkout.fromJson(Map<String, dynamic> json) {
    return AMRAPWorkout(
        json['id'] ?? -1,
        List<Map<String, dynamic>>.from(json['round'] ?? []),
        json['type'],
        json['name'],
        json['time']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id" : id,
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
    var description = 'AMRAP in ${this.time} mins of :\n\n';
    for (var i = 0; i < this.round.length; i++) {
      var item = this.round[i];
      if (item['n_reps'] != null) {
        description = description + item['n_reps'].toString() + " " + item['mov'];
      } else if (item['seconds'] != null) {
        description = description + item['seconds'].toString() + " second " + item['mov'];
      }
      description = description + '\n';
    }
    return description;
  }

  List<Row> getWorkoutUpdateForm() {
    return this.round.map((Map<String, dynamic> mov) {
      var children = <Widget>[];
      if (mov[REPS_KEY] != null) {
        children = children + [ workoutInputBox(mov[REPS_KEY].toString(), (String value) {
          mov[REPS_KEY] = value;
        })];
      } else if (mov["seconds"] != null) {
        children = children + [ workoutInputBox(mov["seconds"].toString(), (String value) {
          mov["seconds"] = value;
        })];
      }

      children = children + [ Text(mov[MOVEMENT_KEY], style : globalTextStyle) ];

      if(mov[WEIGHT_KEY] != null) {
        children = children + [
          workoutInputBox(mov[WEIGHT_KEY].toString(), (String value) {
            mov[WEIGHT_KEY] = value;
          }),
          Text('lbs', style : globalTextStyle)
        ];
      }
      return Row(children : children);
    }).toList();
  }

  AMRAPWorkout.fromWorkout(AMRAPWorkout w) {
    this.id = w.id;
    this.round = w.round.map((Map<String, dynamic> item) {return new Map<String, dynamic>.from(item);}).toList();
    this.type = w.type;
    this.name = w.name;
    this.time = w.time;
  }

  @override
  bool operator ==(other) {
    Function deepEq = const DeepCollectionEquality().equals;
    return (other is AMRAPWorkout)
        && other.id == this.id
        && other.type == this.type
        && other.time == this.time
        && deepEq(other.round, this.round);
  }
}

class ForTimeWorkout extends Workout {
  int n_rounds;

  ForTimeWorkout(int id, List<Map<String, dynamic>> round, String type, String name, int n_rounds) {
    this.id = id;
    this.n_rounds = n_rounds;
    this.round = round;
    this.type = type;
    this.name = name;
  }

  factory ForTimeWorkout.fromJson(Map<String, dynamic> json) {
    return ForTimeWorkout(
        json['id'] ?? -1,
        List<Map<String, dynamic>>.from(json['round'] ?? []),
        json['type'],
        json['name'],
        json['n_rounds']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id" : id,
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
    var description = 'For time:\n\n';
    for (var i = 0; i < this.round.length; i++) {
        var item = this.round[i];
        description = description + item['n_reps'].toString() + " " + item['mov'];
        description = description + '\n';
    }
    return description;
  }

  List<Row> getWorkoutUpdateForm() {
    return this.round.map((Map<String, dynamic> mov) {
      var children = <Widget>[
        workoutInputBox(mov[REPS_KEY].toString(), (String value) {
          mov[REPS_KEY] = value;
        }),
        Text(mov[MOVEMENT_KEY], style : globalTextStyle)
      ];
      if(mov[WEIGHT_KEY] != null) {
        children = children + [
          workoutInputBox(mov[WEIGHT_KEY].toString(), (String value) {
            mov[WEIGHT_KEY] = value;
          }),
          Text('lbs', style : globalTextStyle)
        ];
      }
      return Row(children : children);
    }).toList();
  }

  ForTimeWorkout.fromWorkout(ForTimeWorkout w) {
    this.id = w.id;
    this.round = w.round.map((Map<String, dynamic> item) {return new Map<String, dynamic>.from(item);}).toList();
    this.type = w.type;
    this.name = w.name;
    this.n_rounds = w.n_rounds;
  }

  @override
  bool operator ==(other) {
    Function deepEq = const DeepCollectionEquality().equals;
    return (other is ForTimeWorkout)
        && other.id == this.id
        && other.type == this.type
        && other.n_rounds == this.n_rounds
        && deepEq(other.round, this.round);
  }
}

class TwentyOne_Fifteen_Nine extends Workout {
  List<int> n_reps;

  TwentyOne_Fifteen_Nine(int id, List<Map<String, dynamic>> round, String type, List<int> n_reps, String name) {
    this.id = id;
    this.round = round;
    this.type = type;
    this.n_reps = n_reps;
    this.name = name;
  }

  factory TwentyOne_Fifteen_Nine.fromJson(Map<String, dynamic> json) {
    return TwentyOne_Fifteen_Nine(
        json['id'] ?? -1,
        List<Map<String, dynamic>>.from(json['round'] ?? []),
        json['type'],
        List<int>.from(json['n_reps']),
        json['name']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id" : id,
      "round" : round,
      "type" : type,
      "name" : name,
      "n_reps" : n_reps
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
    var description = n_reps.join("-") + ' reps of :\n';
    for (var i = 0; i < this.round.length; i++) {
      var item = this.round[i];
      description = description + item['mov'];
      if (item['weight_m'] != null && item['weight_f'] != null) {
        description = description + " (" + item['weight_m'].toString() + "/" + item['weight_f'].toString() + ")";
      }
      description = description + '\n';
    }
    return description;
  }

  List<Row> getWorkoutUpdateForm() {
    var children = <Widget>[];
    for (var i=0;i<this.n_reps.length;i++) {
      children.add(workoutInputBox(this.n_reps[i].toString(), (String value) {
        this.n_reps[i] = int.parse(value);
      }));
    }
    var rows = [Row(children : children)];
    rows = rows + this.round.map((Map<String, dynamic> mov) {
      var children = <Widget>[];
      children.add(Text(mov[MOVEMENT_KEY], style : globalTextStyle));
      if(mov[WEIGHT_KEY] != null) {
        children.add(workoutInputBox(mov[WEIGHT_KEY].toString(), (String value) {
            mov[WEIGHT_KEY] = value;
          }));
      }
      return Row(children : children);
    }).toList();
    return rows;
  }

  TwentyOne_Fifteen_Nine.fromWorkout(TwentyOne_Fifteen_Nine w) {
    this.id = w.id;
    this.round = w.round.map((Map<String, dynamic> item) {return new Map<String, dynamic>.from(item);}).toList();
    this.type = w.type;
    this.name = w.name;
    this.n_reps = w.n_reps;
  }

  @override
  bool operator ==(other) {
    Function deepEq = const DeepCollectionEquality().equals;
    return (other is TwentyOne_Fifteen_Nine)
        && other.id == this.id
        && other.type == this.type
        && other.n_reps == this.n_reps
        && deepEq(other.round, this.round);
  }
}