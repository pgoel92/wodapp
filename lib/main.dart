import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import './src/pages/data.dart';

Text appTitle = Text('Workout of the Day',  style : TextStyle(fontWeight: FontWeight.bold, fontSize: 25));
double verticalPadding = 50.0;
double mainWidth = 1000.0;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

MaterialApp homePage = MaterialApp(
    title: 'Workout of the Day',
    //theme: ThemeData(          // Add the 3 lines from here...
    //  primaryColor: Colors.white,
    //),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    /* dark theme settings */
  ),
  home: Scaffold(
    appBar: AppBar(
      title: appTitle,
    ),
    body: Center(child : Container(
      padding : EdgeInsets.symmetric(vertical : verticalPadding),
      child : SizedBox(
      width : mainWidth,
      child : Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children : [
            WodStatefulWidget(),
            ListScoresWidget()
          ]
      ))
    )),
));

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return homePage;
  }
}


class Model {
  String name;
  String score;
  String notes;

  Model({this.name, this.score, this.notes});

  Map<String, String> toJson() {
    return {
      'name': name,
      'score': score,
      'notes' : notes
    };
  }
}

class ScaledWoD {
  dynamic rounds;

  ScaledWoD({this.rounds});

  Map<String, String> toJson() {
    return {
      'rounds': rounds
    };
  }
}

class WodStatefulWidget extends StatefulWidget {
  WodStatefulWidget({Key key}) : super(key: key);

  @override
  _WodStatefulWidgetState createState() => _WodStatefulWidgetState();
}

class _WodStatefulWidgetState extends State<WodStatefulWidget> {
  Model model = Model();
  List<bool> isRxSelected = [true, false];
  DateTime date = DateTime.now();
  int daysAgo = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(child : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding : EdgeInsets.all(10.0),
            child : Row(
              children : [
                IconButton(icon: Icon(IconData(0xe5a8, fontFamily: 'MaterialIcons', matchTextDirection: true)), onPressed: _subtractDate),
                Text(DateFormat.yMMMMEEEEd().format(date.subtract(new Duration(days: daysAgo))), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0)),
                IconButton(icon: Icon(IconData(0xe5b0, fontFamily: 'MaterialIcons', matchTextDirection: true)), onPressed: _addDate)
              ]
            )
          ),Card(
            child : Container(
              padding : EdgeInsets.all(20.0),
              child : FutureBuilder<Map<String, dynamic>>(
                future: fetch_wod(DateFormat('yyyy-MM-dd').format(date.subtract(new Duration(days: daysAgo)))),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data;
                    if (data.containsKey("description")) {
                      if (isRxSelected[0]) {
                        return Text(snapshot.data['description']['rx'],
                            style: TextStyle(fontSize: 18.0));
                      } else {
                        return Text(snapshot.data['description']['scale'],
                            style: TextStyle(fontSize: 18.0));
                      }
                    } else {
                      return Text("Rest day", style: TextStyle(fontSize: 18.0));
                    }
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  // By default, show a loading spinner.
                  return Center(child : CircularProgressIndicator(strokeWidth: 4.0))
                  ;
                }
              )
        ))
      ]
    ));
  }

  void _subtractDate () {
    setState(() { daysAgo = daysAgo + 1; });
  }
  void _addDate () {
    setState(() { daysAgo = daysAgo - 1; });
  }
}

class AddScoreWidget extends StatefulWidget {
  AddScoreWidget({Key key}) : super(key: key);

  @override
  _ScoreWidgetState createState() => _ScoreWidgetState();
}

class _ScoreWidgetState extends State<AddScoreWidget> {
  final _formKey = GlobalKey<FormState>();
  Model model = Model();
  ScaledWoD scaledWoD = ScaledWoD();
  String _selectedAthlete;
  Future<List<dynamic>> futureAthletes;
  String time = '12';
  var WoD = [{"movement" : "pull ups", "reps" : 5, "weight_lbs" : 10}, {"movement" : "push ups", "reps" : 10}, {"movement" : "squats", "reps" : 15}];

  @override
  void initState() {
    super.initState();
    futureAthletes = fetch_athletes();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children : [
      Container(padding : EdgeInsets.all(10),child : Text('Add Score', style : TextStyle(fontWeight: FontWeight.bold, fontSize: 25))),
      Card(child : Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children : [Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                        /*FutureBuilder<List<dynamic>>(
                          future: futureAthletes,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Card(child : new DropdownButtonFormField<String>(
                                  value : _selectedAthlete,
                                  items: getAthleteNames(snapshot.data).map((dynamic value) {
                                    return new DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {_selectedAthlete = newValue;});
                                    },
                                  onSaved: (String value) {
                                    model.name = value;
                                  }
                                )
                              );
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            }

                            // By default, s  how a loading spinner.
                            return CircularProgressIndicator();
                          }),*/
                  amrapScoreForm(),
                    /*Card(child : Container(
                        height : 50,
                        child : TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Score",
                            border: OutlineInputBorder()
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          onSaved: (String value) {
                            model.score = value;
                          }
                        ))
                      ),
                  Card(child : TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Notes",
                        border: const OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                            borderSide: const BorderSide()
                        ),
                        hintText: 'Notes',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        model.notes = value;
                      },
                    ),
                  ),*/
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child :RaisedButton(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.
                          if (_formKey.currentState.validate()) {
                            // Process data.
                            _formKey.currentState.save();
                            print(WoD);
                            put_score(WoD, model);
                            Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                // NEW lines from here...
                                builder: (BuildContext context) {
                                  return homePage;
                                })
                            );
                          }
                        },
                        child: Text('Submit',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                          ),)
                      ))),
                ],
              )
        )]
    ))]);
  }

  SizedBox scoreInputBox(String initialValue, FormFieldSetter<String> onSaved) {
    return SizedBox(width : 40, child : Card(child : Container(
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
  Column amrapScoreForm() {
    //var round = [{"movement" : "pull ups", "reps" : 5, "weight_lbs" : 10}, {"movement" : "push ups", "reps" : 10}, {"movement" : "squats", "reps" : 15}];
    return Column(children : [
      Row(children : [
        scoreInputBox("", (String value) { model.score = value; }),
        Expanded(child : Text('rounds in ' + time + ' mins of :', style : TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
      ])] +
        WoD.map((dynamic mov) {
        var children = [
          scoreInputBox(mov['reps'].toString(), (String value) {
            mov['reps'] = value;
          }),
          Text(mov['movement'], style : TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
        ];
        if(mov["weight_lbs"] != null) {
          children = children + [
            scoreInputBox(mov['weight_lbs'].toString(), (String value) {
              mov['weight_lbs'] = value;
            }),
            Text('lbs', style : TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
          ];
        }
        return Row(children : children);}).toList()
    );
  }

  List<dynamic> getAthleteNames(athletes) {
    return athletes.map((athlete) => (athlete['first_name'] + " " + athlete['last_name'])).toList();
  }
}

class ListScoresWidget extends StatefulWidget {
  ListScoresWidget({Key key}) : super(key: key);

  @override
  _ListScoresWidgetState createState() => _ListScoresWidgetState();
}

class _ListScoresWidgetState extends State<ListScoresWidget> {
  final _formKey = GlobalKey<FormState>();
  Model model = Model();
  Future<List<Score>> futureScores;

  @override
  void initState() {
    super.initState();
    futureScores = fetch_scores();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children : [
              Container(padding : EdgeInsets.all(10),child : Text('Scores', style : TextStyle(fontWeight: FontWeight.bold, fontSize: 25))),
              FutureBuilder<List<Score>>(
              future: futureScores,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final tiles = snapshot.data.map(
                        (Score score) {
                      return Card(child : ListTile(
                        dense: true,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children : [
                            Container(
                              width : 150,
                              padding : EdgeInsets.symmetric(horizontal: 5),
                              child : Text(
                              score.cname??'',
                              style: TextStyle(fontSize: 18.0),
                            )),
                          Container(
                              width : 150,
                          padding : EdgeInsets.symmetric(horizontal: 5),
                          child : Text(
                              score.score,
                              style: TextStyle(fontSize: 18.0),
                            )),
                            Container(
                                width : 150,
                            padding : EdgeInsets.symmetric(horizontal: 5),
                          child : Text(
                              score.notes??'',
                              style: TextStyle(fontSize: 18.0),
                            ))
                          ]
                        ),
                      ));
                    },
                  );
                  final divided = ListTile.divideTiles(
                    context: context,
                    tiles: tiles,
                  ).toList();
                  return Flexible(child :
                  Column(children : [
                    Expanded(child : ListView(children : divided, shrinkWrap: true)),
                      Padding(
                          padding: const EdgeInsets.all(10.0),
                          child : IconButton(icon: Icon(CupertinoIcons.plus_circle), onPressed: _pushSaved)
                      )]
                  ));
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                // By default, s  how a loading spinner.
                return CircularProgressIndicator();
              }
              )
            ]
        )
    );
  }
  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: appTitle,
            ),
            body: Center(
                child : Container(
                  padding : EdgeInsets.symmetric(vertical : verticalPadding),
                 child : SizedBox(
                  width : mainWidth,
                  child : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children : [
                      WodStatefulWidget(),
                      AddScoreWidget()
                    ]
                )
            )),
          ));
        }, // ...to here.
      ),
    );
  }

}

