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
  var voltage;
  var current;
  var energy;
  var pf;

  //_createDB() {
  //  _dbref.child("customer1").set(" my profile");
  //  _dbref
  //     .child("carprofile")
  //      .set({'car1': "family car", 'car2': "company car"});
  //}
  _readdb_onechild() {
    _dbref.once().then((DatabaseEvent databaseEvent) {
      print(" read once - " + databaseEvent.snapshot.toString());
      setState(() {
        databasejson = databaseEvent.snapshot.toString();
      });
    });
  }

  _realdb_once() {
    _dbref.once().then((DatabaseEvent databaseEvent) {
      print(" read once - " + databaseEvent.snapshot.value.toString());
      setState(() {
        databasejson = databaseEvent.snapshot.toString();
      });
    });
  }

  //_updatevalue() {
  // _dbref.child("carprofile").update({"car2": "big company car"});
  //}

  //_delete() {
  //  _dbref.child("profile").remove();
  //}

  @override
  void initState() {
    super.initState();
    _dbref = FirebaseDatabase.instance.ref();
    _readdb_onechild();
    ageChange();
    dataChange();
    // _createDB();
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
            buildText('Voltage is $voltage'),
            buildText('Current is: $current'),
            buildText('Energy is: $energy'),
            buildText('Power Factor is: $pf'),
            StreamBuilder(
              stream: _dbref.onValue,
              builder: (context, AsyncSnapshot snap) {
                if (snap.hasData &&
                    !snap.hasError &&
                    snap.data.snapshot.value != null) {
                  Map data = snap.data.snapshot.value as Map;
                  List item = [];
                  data.forEach(
                      (index, data) => item.add({"key": index, ...data}));
                  return Expanded(
                    child: ListView.builder(
                      itemCount: item.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text("Voltage: ${item[index]['key']}"),
                          subtitle: Text(
                              'current: ${item[index]['current'].toString()} \nEnergy: ${item[index]['energy']}'),
                          isThreeLine: true,
                        );
                      },
                    ),
                  );
                } else {
                  return Center(child: Text("No data"));
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
    _dbref
        .child('energy-meter-database-default-rtdb')
        .child('readings')
        .child('1006')
        .child('1006')
        .onValue
        .listen((DatabaseEvent event) {
      int data = event.snapshot.value as int;
      print('weight data: $data');
      setState(() {
        current = data;
      });
    });
  }

  void dataChange() {
    _dbref.child('customer1').onValue.listen((event) {
      print(event.snapshot.value.toString());
      Map data = event.snapshot.value as Map;
      data.forEach((key, value) {
        setState(() {
          energy = data['energy'];
          pf = data['pf'];
        });
      });
    });
  }
}
