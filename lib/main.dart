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

class WodStatefulWidget extends StatefulWidget {
  WodStatefulWidget({Key key}) : super(key: key);

  @override
  _WodStatefulWidgetState createState() => _WodStatefulWidgetState();
}

class _WodStatefulWidgetState extends State<WodStatefulWidget> {
  Model model = Model();
  List<bool> isRxSelected = [true, false];
  Future<WoD> futureWoD;

  @override
  void initState() {
    super.initState();
    futureWoD = fetch_wod();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(child : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding : EdgeInsets.all(10.0),
            child : Text(DateFormat.yMMMMEEEEd().format(DateTime.now()), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0)),
          ),Card(
            child : Container(
              padding : EdgeInsets.all(20.0),
              child : FutureBuilder<WoD>(
                future: futureWoD,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (isRxSelected[0]) {
                      return Text(snapshot.data.desc_rx, style: TextStyle(fontSize: 18.0));
                    } else {
                      return Text(snapshot.data.desc_scale, style: TextStyle(fontSize: 18.0));
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
}

class AddScoreWidget extends StatefulWidget {
  AddScoreWidget({Key key}) : super(key: key);

  @override
  _ScoreWidgetState createState() => _ScoreWidgetState();
}

class _ScoreWidgetState extends State<AddScoreWidget> {
  final _formKey = GlobalKey<FormState>();
  Model model = Model();

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children : [
      Container(padding : EdgeInsets.all(10),child : Text('Add Score', style : TextStyle(fontWeight: FontWeight.bold, fontSize: 25))),
      Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children : [Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children : [Expanded(
                    child : Card(child : Container(
                      height : 50,
                      child : TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder()
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        model.name = value;
                      },
                    ),
                  ))),
                  Expanded(
                    child : Card(child : Container(
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
                      },
                    ),
                  )))]),
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
                  ),
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
                            print(model);
                            put_score(model);
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
    )]);
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
                              score.cname,
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
                              score.notes,
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
                    ListView(children : divided, shrinkWrap: true),
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

