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
int daysAgo = 0;
MaterialApp homePage;
Color iconColor = Colors.blue.shade300;

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
                    child : FutureBuilder<Program>(
                        future: fetch_wod(getDisplayDate()),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data;
                            model.wod = model.updatedWod = data;
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
                                  ListScoresWidget()
                                ]
                            );
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }

                          // By default, show a loading spinner.
                          return Center(child: CircularProgressIndicator(strokeWidth: 4.0));
                        })
                ))),
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




Model model = Model();
TextStyle globalTextStyle = TextStyle(fontSize: 18);
TextStyle fallbackTextStyle = TextStyle(fontSize: 18, color: Colors.grey[400]);

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
        )),
          Center(child :Padding(
              padding: const EdgeInsets.all(10.0),
              child : IconButton(icon: Icon(CupertinoIcons.plus_circle), color: iconColor, onPressed: _pushSaved)
          ))
      ]
    );
  }

  Text generateDescription() {
    var description = model.wod.workout.getDescription();
    if (description.isNotEmpty) {
      return Text(description,
          style: globalTextStyle);
    } else {
      return Text("Rest day", style: globalTextStyle);
    }
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          return newWodPage;
        }, // ...to here.
      ),
    );
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
    if (isEdit) {
      children = [ Container(padding : EdgeInsets.all(10.0), child : workoutForm()) ];
    } else {
      var description;
      if (model.updatedWod != null) {
        description = model.updatedWod.workout.getDescription();
      } else {
        description = model.wod.workout.getDescription();
      }
      if (description != null) {
        children = [ Text(description, style: globalTextStyle)];
      } else {
        children = [ Text("Rest day", style: globalTextStyle)];
      }
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children);
  }

  Column workoutForm() {
    Program wod = model.wod;
    if (model.updatedWod == null) {
      model.updatedWod = model.wod;
    }

    if (wod.workout.round == null || wod.workout.round.isEmpty) {
      return Column(children : [Container(padding : EdgeInsets.all(20.0),child : Text("All good :)", style : globalTextStyle))]);
    }
    List<Row> rows = model.updatedWod.workout.getWorkoutUpdateForm();

    return Column(children : rows);
  }
}

class WodSearchWidget extends StatefulWidget {
  WodSearchWidget({Key key}) : super(key: key);

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
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        if (_formKey.currentState.validate()) {
                          // Process data.
                          _formKey.currentState.save();
                          setState(() {

                          });
                        }
                      },
                      child: Text('Submit',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),),
                      color: iconColor
                  ))),
          Card(child : getSearchResults())
        ]
    );
  }

  Container getSearchResults() {
    if (searchKeyword != null) {
      return Container(child : FutureBuilder<List<Workout>>(
          future: search_workout(searchKeyword),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.count(shrinkWrap: true, crossAxisCount: 2, children : snapshot.data.map((Workout w) {return Card(child : Text(w.getDescription()));}).toList());
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
                        ),),
                      color: iconColor
                  )))
    ]));
  }

  Column scoreForm() {
    Program wod = model.wod;
    if (model.updatedWod == null) {
      model.updatedWod = model.wod;
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
  ListScoresWidget({Key key}) : super(key: key);

  @override
  _ListScoresWidgetState createState() => _ListScoresWidgetState();
}

class _ListScoresWidgetState extends State<ListScoresWidget> {

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
              Container(padding : EdgeInsets.all(10),child : Text('Scores', style : TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
              scoreBuilder(fetch_scores(getDisplayDate())),
              Center(child :Padding(
                  padding: const EdgeInsets.all(10.0),
                  child : IconButton(icon: Icon(CupertinoIcons.plus_circle), color: iconColor, onPressed: _pushSaved)
              )),
              Container(padding : EdgeInsets.all(10),child : Text('Previous scores', style : TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
              scoreBuilder(fetch_customer_scores(getDisplayDate(), model.wod.workout.id))
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
                                Workout.parseScore(score),
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
    );
  }

}
