import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import './src/pages/data.dart';
import './src/pages/workout.dart';
import './src/utils/utils.dart';

Text appTitle = Text('Workout of the Day',  style : TextStyle(fontWeight: FontWeight.bold, fontSize: 25));
double verticalPadding = 20.0;
double mainWidth = 1000.0;
DateTime date = DateTime.now();
Color iconColor = Colors.blue.shade300;
Model model = Model();
TextStyle globalTextStyle = TextStyle(fontSize: 18);
TextStyle fallbackTextStyle = TextStyle(fontSize: 18, color: Colors.grey[400]);

void main() {
  runApp(MyApp());
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
                    Container(padding : EdgeInsets.all(10),child : Text('Add Score', style : TextStyle(fontWeight: FontWeight.bold, fontSize: 25))),
                    WodUpdateWidget(),
                    AddScoreWidget()
                  ]
              )
          )),
    )));

Scaffold newWodPage = Scaffold(
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
                    Container(padding : EdgeInsets.all(10),child : Text('Add workout of the day', style : TextStyle(fontWeight: FontWeight.bold, fontSize: 25))),
                    WodSearchWidget()
                  ]
              )
          )),
    )));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Workout of the Day',
        //theme: ThemeData(          // Add the 3 lines from here...
        //  primaryColor: Colors.white,
        //),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          /* dark theme settings */
        ),
        home: HomePageWidget());
  }
}

class HomePageWidget extends StatefulWidget {

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  Future<Program> futureWod;
  StreamController<int> _controller = StreamController<int>();
  StreamController<Program> _pController = StreamController<Program>();
  int daysAgo = 0;
  String displayDate;
  @override
  void initState() {
    super.initState();
    displayDate = DateFormat('yyyy-MM-dd').format(date.subtract(new Duration(days: daysAgo)));
    futureWod = fetch_wod(displayDate);
    _controller.add(daysAgo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: appTitle,
            ),
            body: SingleChildScrollView(child: Center(child : Container(
                padding : EdgeInsets.symmetric(vertical : verticalPadding),
                child : SizedBox(
                    width : mainWidth,
                    child : FutureBuilder<Program>(
                        future: futureWod,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data;
                            model.wod = data;
                            if (model.wod.workout.id != -1) {
                              _pController.add(model.wod);
                            }
                            return Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Row(
                                          children: [
                                            Expanded(child: IconButton(icon: Icon(IconData(
                                                0xe5a8, fontFamily: 'MaterialIcons',
                                                matchTextDirection: true)),
                                                color: iconColor,
                                                onPressed: _subtractDate)),
                                            Text(DateFormat.yMMMMEEEEd().format(
                                                date.subtract(new Duration(days: daysAgo))),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 22.0)),
                                            Expanded(child: IconButton(icon: Icon(IconData(
                                                0xe5b0, fontFamily: 'MaterialIcons',
                                                matchTextDirection: true)),
                                                color: iconColor,
                                                onPressed: _addDate))
                                          ]
                                      )
                                  ),
                                  WodStatefulWidget(),
                                  Center(child :Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child : IconButton(icon: Icon(CupertinoIcons.plus_circle), color: iconColor, onPressed: _pushSaved)
                                  )),
                                  ListScoresWidget(stream: _controller.stream,  pStream: _pController.stream)
                                ]
                            );
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }

                          // By default, show a loading spinner.
                          return Center(child: CircularProgressIndicator(strokeWidth: 4.0));
                        })
                ))),
            ));
  }

  void _subtractDate () {
    daysAgo = daysAgo + 1;
    displayDate = DateFormat('yyyy-MM-dd').format(date.subtract(new Duration(days: daysAgo)));
    _controller.add(daysAgo);
    setState(() {
      futureWod = fetch_wod(displayDate);
    });
  }
  void _addDate () {
    daysAgo = daysAgo - 1;
    displayDate = DateFormat('yyyy-MM-dd').format(date.subtract(new Duration(days: daysAgo)));
    _controller.add(daysAgo);
    setState(() {
      futureWod = fetch_wod(displayDate);
    });
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          return newWodPage;
        }, // ...to here.
      ),
    ).then((dynamic value) {setState(() {});});
  }
}


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
              child : generateDescription()
        ))
      ]
    );
  }

  Text generateDescription() {
    return Text(model.wod.getDescription(),
          style: globalTextStyle);
  }

}

class WodUpdateWidget extends StatefulWidget {
  WodUpdateWidget({Key key}) : super(key: key);

  @override
  _WodUpdateWidgetState createState() => _WodUpdateWidgetState();
}

class _WodUpdateWidgetState extends State<WodUpdateWidget> {

  List<bool> isRxSelected = [true, false];
  bool isEdit = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        GestureDetector(
        onTap: () => {setState(() {isEdit = !isEdit; _formKey.currentState.save();})},
        child: Card(
              child : Form(
                key: _formKey,
                child: Container(
                  padding : EdgeInsets.all(20.0),
                  child : workoutEditColumn()
              ))))
        ]
    );
  }

  Column workoutEditColumn() {
    var children;
    if (model.updatedWod == null) {
      model.updatedWod = Program.fromProgram(model.wod);
    }

    if (isEdit) {
      children = [ Container(padding : EdgeInsets.all(10.0), child : workoutForm()) ];
    } else {
      children = [ Text(model.updatedWod.getDescription(), style: globalTextStyle)];
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children);
  }

  Column workoutForm() {
    if (model.wod.workout.round == null || model.wod.workout.round.isEmpty) {
      return Column(children : [Container(padding : EdgeInsets.all(20.0),child : Text("All good :)", style : globalTextStyle))]);
    }
    List<Row> rows = model.updatedWod.workout.getWorkoutUpdateForm();
    return Column(children : rows);
  }
}

class WodSearchWidget extends StatefulWidget {
  String displayDate;
  WodSearchWidget({Key key, this.displayDate}) : super(key: key);

  @override
  _WodSearchWidgetState createState() => _WodSearchWidgetState();
}

class _WodSearchWidgetState extends State<WodSearchWidget> {

  List<bool> isRxSelected = [true, false];
  bool isEdit = false;
  String searchKeyword;
  final _formKey = GlobalKey<FormState>();

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
                  child : Form(
                      key: _formKey,
                      child: Container(
                          padding : EdgeInsets.all(20.0),
                          child : globalTextFormField("Enter a movement", (String value) {searchKeyword = value;})
                      ))),
          Center(
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child :RaisedButton(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          setState(() {});
                        }
                      },
                      child: Text('Submit',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),),
                      color: iconColor
                  ))),
          getSearchResults()
        ]
    );
  }

  Container getSearchResults() {
    if (searchKeyword != null) {
      return Container(child : FutureBuilder<List<Workout>>(
          future: search_workout(searchKeyword),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.count(shrinkWrap: true, crossAxisCount: 2, children : snapshot.data.map((Workout w) {
                return Card(child : Container(padding: EdgeInsets.all(20.0),
                    child : Column(children : [
                      Text(w.getDescription()),
                    RaisedButton(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        onPressed: () {
                          put_wod(widget.displayDate, w.id);
                          Navigator.of(context).pop();
                          },
                        child: Text('Select',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                          ),),
                        color: iconColor)
                    ])));
              }).toList());
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, s  how a loading spinner.
            return CircularProgressIndicator();
          }));
    } else {
      return Container();
    }
  }
}


class AddScoreWidget extends StatefulWidget {
  AddScoreWidget({Key key}) : super(key: key);

  @override
  _ScoreWidgetState createState() => _ScoreWidgetState();
}

class _ScoreWidgetState extends State<AddScoreWidget> {
  final _formKey = GlobalKey<FormState>();
  int _selectedAthlete;
  Future<List<dynamic>> futureAthletes;
  String time = '12';

  @override
  void initState() {
    super.initState();
    futureAthletes = fetch_athletes();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children : [
          FutureBuilder<List<dynamic>>(
              future: futureAthletes,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Card(child : new DropdownButtonFormField<int>(
                      value : _selectedAthlete,
                      items: snapshot.data.map((dynamic value) {
                        String name = value['first_name'] + " " + value['last_name'];
                        return new DropdownMenuItem<int>(
                          value: value['athlete_id'],
                          child: Padding(padding : EdgeInsets.only(left : 10.0), child : Text(name)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {_selectedAthlete = newValue;});
                      },
                      onSaved: (int value) {
                        model.athlete_id = value;
                      },
                      decoration: new InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding:
                          EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                          hintText: "Athlete")
                  )
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, s  how a loading spinner.
                return CircularProgressIndicator();
              }),
      scoreForm(),
          Center(
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: RaisedButton(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          model.is_rx = (model.wod.workout == model.updatedWod.workout);
                          put_score(model);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Submit',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),),
                      color: iconColor
                  )))
    ]));
  }

  Column scoreForm() {
    Program wod = model.wod;
    if (model.updatedWod == null) {
      model.updatedWod = Program.fromProgram(model.wod);
    }
    if (wod.workout.round == null || wod.workout.round.isEmpty) {
      return Column(children : [Container(padding : EdgeInsets.all(20.0),child : Text("All good :)", style : globalTextStyle))]);
    }

    return wod.workout.scoreInputColumn(model);
  }

  List<dynamic> getAthleteNames(athletes) {
    return athletes.map((athlete) => (athlete['first_name'] + " " + athlete['last_name'])).toList();
  }
}

class ListScoresWidget extends StatefulWidget {
  final Stream<int> stream;
  final Stream<Program> pStream;
  String displayDate;
  ListScoresWidget({Key key, this.stream,  this.pStream}) : super(key: key);

  @override
  _ListScoresWidgetState createState() => _ListScoresWidgetState();
}

class _ListScoresWidgetState extends State<ListScoresWidget> {
  Future<List<Score>> futureScores;
  Future<List<Score>> previousScores;

  @override
  void initState() {
    super.initState();
    widget.stream.asBroadcastStream().listen((daysAgo) {
      _update(daysAgo);
    });
    widget.pStream.asBroadcastStream().listen((program) {
      _updateProgram(program);
    });
  }

  void _update(int daysAgo) {
    setState(() {
      widget.displayDate = DateFormat('yyyy-MM-dd').format(date.subtract(new Duration(days: daysAgo)));
      futureScores = fetch_scores(widget.displayDate);
      previousScores = fetch_customer_scores(widget.displayDate, model.wod.workout.id);
    });
  }

  void _updateProgram(Program wod) {
    setState(() {
      previousScores = fetch_customer_scores(widget.displayDate, wod.workout.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children : [
              Container(padding : EdgeInsets.all(10),child : Text('Scores', style : TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
              scoreBuilder(futureScores),
              Center(child :Padding(
                  padding: const EdgeInsets.all(10.0),
                  child : IconButton(icon: Icon(CupertinoIcons.plus_circle), color: iconColor, onPressed: _pushSaved)
              )),
              Container(padding : EdgeInsets.all(10),child : Text('Previous scores', style : TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
              scoreBuilder(previousScores)
            ]

    );
  }

  FutureBuilder<List<Score>> scoreBuilder(Future<List<Score>> future) {
    return FutureBuilder<List<Score>>(
        future: future,
        builder: (context, snapshot) {
          var tiles;
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              tiles = [ Card(child : ListTile(
                dense: true,
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children : [
                      Expanded(child : Container(
                          width : 150,
                          padding : EdgeInsets.symmetric(horizontal: 5),
                          child : Text(
                            'Nothing to see here',
                            style: fallbackTextStyle,
                          )))
                    ]
                ),
              ))];
            } else {
              tiles = snapshot.data.map(
                    (Score score) {
                  return Card(child : ListTile(
                    dense: true,
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children : [
                          Expanded(child : Container(
                              width : 150,
                              padding : EdgeInsets.symmetric(horizontal: 5),
                              child : Text(
                                score.first_name??'',
                                style: globalTextStyle,
                              ))),
                          Expanded(child : Container(
                              width : 150,
                              padding : EdgeInsets.symmetric(horizontal: 5),
                              child : Text(
                                Workout.parseScore(score, model.wod),
                                style: globalTextStyle,
                              ))),
                          Expanded(child : Container(
                              width : 150,
                              padding : EdgeInsets.symmetric(horizontal: 5),
                              child : Text(
                                Workout.rx_or_scaled(score, model.wod),
                                style: globalTextStyle,
                              ))),
                          Expanded(child : Container(
                              width : 150,
                              padding : EdgeInsets.symmetric(horizontal: 5),
                              child : Text(
                                score.date??'',
                                style: globalTextStyle,
                              )))
                        ]
                      ),
                    ));
                  },
                );
              }

              final divided = ListTile.divideTiles(
                context: context,
                tiles: tiles,
              ).toList();
              return Column(children : [
                ListView(children : divided, shrinkWrap: true)
              ]
              );
          } else if (snapshot.hasError) {
            return Card(child : ListTile(
              dense: true,
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children : [
                    Expanded(child : Container(
                        width : 150,
                        padding : EdgeInsets.symmetric(horizontal: 5),
                        child : Text(
                          'Nothing to see here',
                          style: globalTextStyle,
                        ))),
                  ]
              ),
            ));
          }

          // By default, s  how a loading spinner.
          return CircularProgressIndicator();
        }
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
    ).then((dynamic value) {setState(() {});});;
  }

}
