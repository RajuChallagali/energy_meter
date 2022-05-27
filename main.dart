import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

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
      home: const MyHomePage(title: 'Energy Meter'),
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
  List<Amps> amp = [];

  var current;
  String voltage = '';
  String power = '';
  String pf = '';

  @override
  void initState() {
    super.initState();
    _dbref = FirebaseDatabase.instance.ref().child('readings');

    /*valueChange();*/
    dataChange();
  }

  @override
  Widget build(BuildContext context) {
    var data;
    return MaterialApp(
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Energy Meter'),
                centerTitle: true,
                backgroundColor: Colors.green,
                bottom: TabBar(tabs: [
                  Text('Graph'),
                  Text('List'),
                ]),
              ),
              body: TabBarView(children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Container(
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(),
                      title: ChartTitle(text: 'Current Utilization'),
                      legend: Legend(
                        isVisible: true,
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <ChartSeries<Amps, dynamic>>[
                        LineSeries<Amps, dynamic>(
                          dataSource: amp,
                          xValueMapper: (Amps data, _) => data.sec,
                          yValueMapper: (Amps data, _) => data.cur,
                          name: 'Current',
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        buildText('Voltage: $voltage V'),
                        buildText('Current: $current mA'),
                        buildText('Power: $power W'),
                        buildText('Power Factor: $pf'),
                        StreamBuilder(
                          stream: _dbref.onValue,
                          builder: (context, AsyncSnapshot snap) {
                            if (snap.hasData &&
                                !snap.hasError &&
                                snap.data.snapshot.value != null) {
                              List<Amps> amp = <Amps>[];
                              Map data = snap.data.snapshot.value;
                              for (Map childData in data.values) {
                                amp.add(Amps.fromMap(
                                    childData.cast<String, dynamic>()));
                                print(amp);
                              }
                              List item = [];
                              data.forEach((index, data) =>
                                  item.add({"key": index, ...data}));
                              print(item);
                              return Expanded(
                                child: ListView.builder(
                                  itemCount: item.length,
                                  itemBuilder: (context, index) {
                                    print(item);
                                    return ListTile(
                                      title: Text(
                                          "Voltage: ${item[index]['voltage'].toString()} V \nCurrent: ${item[index]['current'].toString()} mA \nPF: ${item[index]['Pf'].toString()} \nPower: ${item[index]['power'].toString()} W \nTime: ${item[index]['Time'].toString()}"),
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
                ),
              ]),
            )));
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

  /*void valueChange() {
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
        .child('readings')
        .child('current')
        .onChildAdded
        .listen((DatabaseEvent databaseEvent) {
      int data = databaseEvent.snapshot.value as int;
      print('weight data: $current');
      setState(() {
        current = data;
      });
    });
  }*/

  void dataChange() {
    var subscription = FirebaseDatabase.instance
        .ref()
        .child('readings')
        .onChildAdded
        .listen((event) {
      Map data = event.snapshot.value as Map;
      data.forEach((key, value) {
        setState(() {
          current = data['current'].toString();
          voltage = data['voltage'].toString();
          pf = data['Pf'].toString();
          power = data['power'].toString();
        });
      });
    });
  }
}

class Amps {
  final dynamic sec;
  final dynamic cur;

  Amps({this.sec, this.cur});
  Amps.fromMap(Map<String, dynamic> dataMap)
      : sec = dataMap['Time'],
        cur = dataMap['current'];
}
