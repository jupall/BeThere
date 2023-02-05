import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';
import 'package:intl/intl.dart' as intl;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart';
import 'popup_modal.dart';

const Color amberColor = Color.fromARGB(255, 247, 156, 38);
const Color salmonColor = Color.fromARGB(255, 231, 103, 103);
const Color lightGreyColor = Color.fromARGB(255, 224, 224, 224);
const Color darkerGreyColor = Color.fromARGB(255, 184, 184, 184);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Be There',
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          //fontFamily: "Roboto",
          primarySwatch: Colors.teal,
        ),
        home: FutureBuilder(
            future: _fbApp,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('You have an error ! ${snapshot.error.toString()}');
                return Center(
                    child: Text('Something went wrong',
                        style:
                            TextStyle(fontSize: 20, color: Colors.amber[700])));
              } else if (snapshot.hasData) {
                return const LoginScreen();
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            })

        //const MyHomePage(title: 'Flutter Demo Home Page'),
        );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double _randInt = 1.0;
  double _randInt2 = 1.0;
  List<String> _entries = <String>['hackermans', 'jam night', 'd&d'];
  List<int> _colorCodes = <int>[600, 700, 800];
  List<bool> _displayGroup = <bool>[false, false, false];
  List<MaterialColor> _colorPalette = <MaterialColor>[
    Colors.blueGrey,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.deepPurple
  ];
  int _colorIndex = 0;
  List<String> _participants = <String>[
    'étienne l.',
    'william m.',
    'jean-luc l.',
    'julien p.',
  ];
  String _userid = "user2";
  int _nextColor = 0;
  bool displayHacker = false;
  bool displayJam = false;
  bool displayDD = false;
  @override
  void initState() {
    super.initState();
    _readData();
    _nextColor = _colorCodes.last - 100;
  }

  void _readData() {
    DatabaseReference refUsers = FirebaseDatabase.instance.ref().child('users');
    DatabaseReference refGroups =
        FirebaseDatabase.instance.ref().child('groups');
    FirebaseDatabase.instance.ref().child('users').onValue.listen((event) {
      final String progress = event.snapshot.value.toString();
      print(progress);
      setState(() {});
    });
    FirebaseDatabase.instance.ref().child('groups').onValue.listen((event) {
      final String progress2 = event.snapshot.value.toString();
      setState(() {
        _randInt2 = double.parse(progress2.toString());
      });
    });
  }

  void _incrementCounter() {
    DatabaseReference _testRef = FirebaseDatabase.instance.ref().child('test');
    _testRef.update({'soc': "${Random().nextDouble()}"});
    _testRef.update({'soh': "${Random().nextDouble()}"});

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return Scaffold(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Row(children: [
            const SizedBox(
              width: 10,
            ),
            Stack(
                alignment: Alignment.center,
                textDirection: TextDirection.rtl,
                fit: StackFit.loose,
                clipBehavior: Clip.hardEdge,
                children: <Widget>[
                  Container(
                    height: 135 * 4,
                    width: 135,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 5), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                          height: 135 * 3 + 50,
                          width: 135.0 - 5,
                          child: ListView(
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8),
                                itemCount: _entries.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: _colorPalette[0]
                                              [_colorCodes[index]],
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15))),
                                      child: Center(
                                          child: Text(
                                        '${_entries[index]}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _displayGroup.fillRange(
                                            0, _displayGroup.length, false);
                                        _displayGroup[index] = true;
                                      });
                                    },
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(
                                            color: Color.fromARGB(0, 0, 0, 0)),
                              )
                            ],
                          )),
                      SizedBox(
                          height: 50,
                          width: 135.0 - 20,
                          child: Container(
                            height: 90,
                            width: 135.0 - 30,
                            decoration: BoxDecoration(
                              color: _colorPalette[0][500],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    hoverColor: Colors.blueGrey,
                                    onPressed: () {
                                      setState(() {
                                        _entries.insert(
                                            _colorCodes.length, "new group");
                                        _nextColor = (_nextColor > 100)
                                            ? _nextColor - 100
                                            : 800;
                                        _colorCodes.insert(
                                            _colorCodes.length, _nextColor);
                                        _displayGroup.insert(
                                            _colorCodes.length, false);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    color: Colors.white)
                              ],
                            ),
                          ))
                    ],
                  )
                ]),
            SizedBox(width: 10),
            Expanded(
                child: Stack(
              children: [
                Container(
                  height: 135 * 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 5), // changes position of shadow
                      ),
                    ],
                  ),
                ),
                whichGroup(_displayGroup[0], _displayGroup[1], _displayGroup[2],
                    _participants)
              ],
            )),
            const SizedBox(width: 10)
          ]),
        ]
            // This trailing comma makes auto-formatting nicer for build methods.
            ));
  }
}

Widget displayGroupInfo(List<String> participants, String title, String jour,
    String heure, String activity) {
  // get what group to display from firebase realtime database
  return Row(
    children: [
      const SizedBox(width: 10),
      Expanded(
          child: Column(children: [
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: const BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: const BorderRadius.all(Radius.circular(15))),
          child: Center(
              child: Text('${title}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white))),
        ),
        const SizedBox(height: 10),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${activity}",
                style: TextStyle(
                  color: Color.fromARGB(255, 122, 98, 85),
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              buttonIcon(Icon(Icons.poll, color: Colors.white), () {}),
            ]),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: '${jour},\n',
                style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal),
                children: <TextSpan>[
                  TextSpan(
                      text: 'at ${heure}',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                      )),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                text: 'list of participants:\n',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        SizedBox(
            height: 135 * 2 - 15,
            child: ListView(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: participants.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.arrow_right),
                        InkWell(
                            child: Text('${participants[index]}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold)))
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(color: Color.fromARGB(0, 0, 0, 0)),
                )
              ],
            )),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buttonIcon(
                Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                ),
                () {}),
            RichText(
              text: const TextSpan(
                text: 'be there',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
            buttonIcon(Icon(Icons.group_add, color: Colors.white), () {})
          ],
        )
      ])),
      const SizedBox(width: 10)
    ],
  );
}

Widget buttonIcon(Icon icone, Function action) {
  return InkWell(
    child: Container(
      height: 30,
      width: 55,
      decoration: const BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Center(child: icone),
    ),
    onTap: () {
      action;
    },
  );
}

Widget whichGroup(bool displayHacker, bool displayJam, bool displayDD,
    List<String> _participants) {
  List<String> temp = [..._participants];

  if (displayHacker == true) {
    return displayGroupInfo(
        _participants, "hackermans", "february 7th", "6:30 pm", "napping");
  } else if (displayJam == true) {
    temp.removeAt(0);
    return displayGroupInfo(
        temp, "jam night", "february 13th", "9:15 pm", "faking jazz together");
  } else if (displayDD == true) {
    temp.removeAt(2);
    temp.removeAt(2);
    return displayGroupInfo(
        temp, "d&d", "february 15th", "7:00 pm", "fighting the demogorgon");
  } else {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            height: 135 * 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "select a group",
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                )
              ],
            ))
      ],
    );
  }
}
