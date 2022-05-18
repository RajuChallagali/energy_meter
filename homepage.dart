import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomePage extends StatelessWidget {
  List<Amps> data = [
    Amps(0, 223),
    Amps(1, 229),
    Amps(2, 231),
    Amps(3, 225),
    Amps(4, 220),
    Amps(5, 219),
    Amps(6, 226),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Line Chart'),
      ),
      body: Container(
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(text: 'current utilization'),
          legend: Legend(isVisible: true),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<Amps, int>>[
            LineSeries(
                dataSource: data,
                xValueMapper: (Amps time, _) => time.time,
                yValueMapper: (Amps time, _) => time.current,
                name: 'Current'),
          ],
        ),
      ),
    );
  }
}

class Amps {
  final int time;
  final int current;
  Amps(this.current, this.time);
}
