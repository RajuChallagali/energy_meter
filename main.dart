import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp firebaseApp = await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseReference _dbref;
  String databasejson = '';
  var current;
  var voltage;
  var power;
  var pf;

  @override
  void initState() {
    super.initState();
    _dbref = FirebaseDatabase.instance.ref().child('readings');

    ageChange();
    dataChange();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildText('Voltage: $voltage'),
            buildText('Current: $current'),
            buildText('Power: $power'),
            buildText('Power Factor: $pf'),
            StreamBuilder(
              stream: _dbref.onValue,
              builder: (context, AsyncSnapshot snap) {
                if (snap.hasData &&
                    !snap.hasError &&
                    snap.data.snapshot.value != null) {
                  Map data = snap.data.snapshot.value;
                  List item = [];
                  data.forEach(
                      (index, data) => item.add({"key": index, ...data}));
                  return Expanded(
                    child: ListView.builder(
                      itemCount: item.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              "Voltage: ${item[index]['voltage'].toString()} \nCurrent: ${item[index]['current'].toString()} \nPF: ${item[index]['Pf'].toString()} \nPower: ${item[index]['power'].toString()} \nTime: ${item[index]['Time'].toString()}"),
                        );
                      },
                    ),
                  );
                } else {
                  return Center(child: Text("Loading data...."));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Text buildText(String s) {
    return Text(
      s,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void ageChange() {
    /*
       var subscription = FirebaseDatabase.instance
      .reference()
      .child('messages')
      .Xxx
      .listen((event) {
        // process event
      });
      where Xxx is one of
      onvalue
      onChildAdded
      onChildRemoved
      onChildChanged
      To end the subscription you can use
      subscription.cancel();
    */
    _dbref.child('readings').onChildAdded.listen((DatabaseEvent databaseEvent) {
      int data = databaseEvent.snapshot.value as int;
      print('weight data: $current');
      setState(() {
        current = current;
      });
    });
  }

  void dataChange() {
    var subscription = FirebaseDatabase.instance
        .ref()
        .child('readings')
        .onValue
        .listen((event) {
      Map data = event.snapshot.value as Map;
      data.forEach((key, value) {
        setState(() {
          current = data['current'];
          voltage = data['voltage'];
          pf = data['Pf'];
          power = data['power'];
        });
      });
    });
  }
}
