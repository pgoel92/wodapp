import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import './src/pages/data.dart';

Text appTitle = Text('Workout of the Day',  style : TextStyle(fontWeight: FontWeight.bold, fontSize: 25));
double verticalPadding = 50.0;
double mainWidth = 1000.0;
DateTime date = DateTime.now();
int daysAgo = 0;
MaterialApp homePage;

String getDisplayDate() {
  return DateFormat('yyyy-MM-dd').format(date.subtract(new Duration(days: daysAgo)));
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

Scaffold scorePage = Scaffold(
    appBar: AppBar(
      title: appTitle,
    ),
    body: SingleChildScrollView(child : Center(
      child : Container(
          padding : EdgeInsets.symmetric(vertical : verticalPadding),
          child : SizedBox(
              width : mainWidth,
              child : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children : [
                    AddScoreWidget()
                  ]
              )
          )),
    )));

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    homePage = MaterialApp(
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
            body: SingleChildScrollView(child: Center(child : Container(
                padding : EdgeInsets.symmetric(vertical : verticalPadding),
                child : SizedBox(
                    width : mainWidth,
                    child : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children : [
                          Padding(
                              padding : EdgeInsets.all(10.0),
                              child : Row(
                                  children : [
                                    IconButton(icon: Icon(IconData(0xe5a8, fontFamily: 'MaterialIcons', matchTextDirection: true)), onPressed: _subtractDate),
                                    Text(DateFormat.yMMMMEEEEd().format(date.subtract(new Duration(days: daysAgo))), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0)),
                                    IconButton(icon: Icon(IconData(0xe5b0, fontFamily: 'MaterialIcons', matchTextDirection: true)), onPressed: _addDate)
                                  ]
                              )
                          ),
                          WodStatefulWidget(),
                          ListScoresWidget()
                        ]
                    ))
            )),
            )));
    return homePage;
  }

  void _subtractDate () {
    setState(() { daysAgo = daysAgo + 1; });
  }
  void _addDate () {
    setState(() { daysAgo = daysAgo - 1; });
  }
}


class Model {
  WoD wod;
  WoD updatedWod;
  String name;
  String score;
  String notes;

  Model({this.name, this.score, this.notes, this.wod, this.updatedWod});

  Map<String, String> toJson() {
    return {
      'name': name,
      'score': score,
      'notes' : notes,
      'wod' : wod.toString(),
      'updatedWod' : updatedWod.toString()
    };
  }
}

Model model = Model();
TextStyle globalTextStyle = TextStyle(fontSize: 18);

class WodStatefulWidget extends StatefulWidget {
  WodStatefulWidget({Key key}) : super(key: key);

  @override
  _WodStatefulWidgetState createState() => _WodStatefulWidgetState();
}

class _WodStatefulWidgetState extends State<WodStatefulWidget> {

  List<bool> isRxSelected = [true, false];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child : Container(
              padding : EdgeInsets.all(20.0),
              child : FutureBuilder<WoD>(
                future: fetch_wod(getDisplayDate()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data;
                    print(data);
                    model.wod = data;
                    if (data.description != null) {
                      if (isRxSelected[0]) {
                        return Text(data.description['rx'],
                            style: globalTextStyle);
                      } else {
                        return Text(data.description['scale'],
                            style: globalTextStyle);
                      }
                    } else {
                      return Text("Rest day", style: globalTextStyle);
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
    );
  }
}

class AddScoreWidget extends StatefulWidget {
  AddScoreWidget({Key key}) : super(key: key);

  @override
  _ScoreWidgetState createState() => _ScoreWidgetState();
}

class _ScoreWidgetState extends State<AddScoreWidget> {
  final _formKey = GlobalKey<FormState>();
  String _selectedAthlete;
  Future<List<dynamic>> futureAthletes;
  String time = '12';

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
                  Container(padding : EdgeInsets.all(10.0), child : amrapScoreForm()),
                  /*Card(child : TextFormField(
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
                            put_score(model.updatedWod, model);
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
  Column amrapScoreForm() {
    WoD wod = model.wod;
    model.updatedWod = model.wod;
    String REPS_KEY = "n_reps";
    String MOVEMENT_KEY = "mov";
    String WEIGHT_KEY = "weight_m";
    if (wod.round == null || wod.round.isEmpty) {
      return Column(children : [Container(padding : EdgeInsets.all(20.0),child : Text("All good :)", style : globalTextStyle))]);
    }
    Row firstRow = Row(children : [
      scoreInputBox("", (String value) { model.score = value; }, width:60),
      Expanded(child : Text('rounds in ' + wod.time.toString() + ' mins of :', style : globalTextStyle)),
    ]);
    List<Row> rows = model.updatedWod.round.map((Map<String, dynamic> mov) {
      var children = [
        scoreInputBox(mov[REPS_KEY].toString(), (String value) {
          mov[REPS_KEY] = value;
        }),
        Text(mov[MOVEMENT_KEY], style : globalTextStyle)
      ];
      if(mov[WEIGHT_KEY] != null) {
        children = children + [
          scoreInputBox(mov[WEIGHT_KEY].toString(), (String value) {
            mov[WEIGHT_KEY] = value;
          }),
          Text('lbs', style : globalTextStyle)
        ];
      }
      return Row(children : children);
    }).toList();

    return Column(children : [firstRow] + rows);
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children : [
              Container(padding : EdgeInsets.all(10),child : Text('Scores', style : TextStyle(fontWeight: FontWeight.bold, fontSize: 25))),
              FutureBuilder<List<Score>>(
              future: fetch_scores(getDisplayDate()),
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
                              score.first_name??'',
                              style: globalTextStyle,
                            )),
                          Container(
                              width : 150,
                          padding : EdgeInsets.symmetric(horizontal: 5),
                          child : Text(
                              score.score,
                              style: globalTextStyle,
                            )),
                            Container(
                                width : 150,
                            padding : EdgeInsets.symmetric(horizontal: 5),
                          child : Text(
                              score.notes??'',
                              style: globalTextStyle,
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
                  return Column(children : [
                    ListView(children : divided, shrinkWrap: true),
                      Padding(
                          padding: const EdgeInsets.all(10.0),
                          child : IconButton(icon: Icon(CupertinoIcons.plus_circle), onPressed: _pushSaved)
                      )]
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                // By default, s  how a loading spinner.
                return CircularProgressIndicator();
              }
              )
            ]

    );
  }
  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          return scorePage;
        }, // ...to here.
      ),
    );
  }

}

