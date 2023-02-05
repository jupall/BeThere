import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';
import 'package:intl/intl.dart' as intl;

const Color amberColor = Color.fromARGB(255, 247, 156, 38);
const Color salmonColor = Color.fromARGB(255, 231, 103, 103);
const Color lightGreyColor = Color.fromARGB(255, 224, 224, 224);
const Color darkerGreyColor = Color.fromARGB(255, 184, 184, 184);
final List<String> entries = <String>['A', 'B', 'C'];
final List<int> colorCodes = <int>[600, 500, 100];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
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
                return const MyHomePage(title: 'Ma batterie');
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double _randInt = 1.0;
  double _randInt2 = 1.0;

  @override
  void initState() {
    super.initState();
    _readData();
  }

  void _readData() {
    FirebaseDatabase.instance.ref().child('test/soc').onValue.listen((event) {
      final String progress = event.snapshot.value.toString();
      setState(() {
        _randInt = double.parse(progress.toString());
      });
    });
    FirebaseDatabase.instance.ref().child('test/soh').onValue.listen((event) {
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
                          height: 135 * 3 + 35,
                          width: 135.0 - 5,
                          child: ListView(
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                itemCount: 25,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(),
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    title: Text('item $index'),
                                  );
                                },
                              )
                            ],
                          )),
                      SizedBox(
                          height: 90,
                          width: 135.0 - 10,
                          child: ListView(
                            children: [
                              Container(
                                height: 90,
                                width: 135.0 - 30,
                                decoration: const BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, color: Colors.white)
                                  ],
                                ),
                              )
                            ],
                          ))
                    ],
                  )
                ])
          ]),
        ]
            // This trailing comma makes auto-formatting nicer for build methods.
            ));
  }
}
