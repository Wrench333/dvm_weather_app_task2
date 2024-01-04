import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import  'package:weather_app_dvm/models.dart';

class Statistics extends StatefulWidget {
  final List<double> minTemperatures;
  final List<double> maxTemperatures;

  const Statistics({Key? key, required this.minTemperatures, required this.maxTemperatures})
      : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("5-Day Forecast Statistics"),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: Container(
        height: size.height/2,
        width: size.width,
        child: SfCartesianChart(
            legend: Legend(isVisible: true),
            primaryXAxis: CategoryAxis(),
            primaryYAxis: CategoryAxis(),
          series: <CartesianSeries>[
            LineSeries<ChartData, String>(
              dataSource: _generateChartData(widget.minTemperatures),
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              name: 'Min Temperature',
            ),
            LineSeries<ChartData, String>(
              dataSource: _generateChartData(widget.maxTemperatures),
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              name: 'Max Temperature',
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> _generateChartData(List<double> temperatures) {
    return List.generate(
      temperatures.length,
          (index) => ChartData('Day ${index + 1}', temperatures[index]),
    );
  }
}

