import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:weight_tracker/extensions/string_extensions.dart';

import '../hive/person.dart';
import '../hive/weight_entry.dart';

class OverviewChart extends StatelessWidget {
  const OverviewChart({Key? key, required this.data, required this.selectedPerson}) : super(key: key);
  
  final List<WeightEntry> data;
  final int selectedPerson;
  
  @override
  Widget build(BuildContext context) {
    final person = Hive.box<Person>('personBox').get(selectedPerson);
    return data.length >= 2
        ? SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              interval: 1,
              intervalType: DateTimeIntervalType.days,
              rangePadding: ChartRangePadding.round,
            ),
            title: ChartTitle(text: 'Weight history for ${person!.name.capitalize()}'),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries<WeightEntry, DateTime>>[
              StepLineSeries(
                dataSource: data,
                xValueMapper: (WeightEntry entry, _) => entry.registeredAt,
                yValueMapper: (WeightEntry entry, _) => entry.weight,
                name: 'Tracked weight',
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          )
        : Center(
            child: Text('Not enough entries for historic overview.\n ${person!.name.capitalize()} currently weights: ${data.isNotEmpty ? data.first.weight : 'nothing entered'}'),
          );
  }
}



