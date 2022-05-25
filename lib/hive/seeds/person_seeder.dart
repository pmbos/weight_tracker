import 'package:hive_flutter/hive_flutter.dart';
import 'package:weight_tracker/hive/person.dart';
import 'package:weight_tracker/hive/weight_entry.dart';

class PersonSeeder {
  void seed() {
    final box = Hive.box<Person>('personBox');

    final pascalWeightHistory = [
      WeightEntry(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day
      ), 80),
      WeightEntry(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day
      ).add(const Duration(days: 1)
      ), 71),
    ];

    final alinaWeightHistory = [
      WeightEntry(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day
      ), 70),
      WeightEntry(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day
      ).add(const Duration(days: 1)
      ), 68),
    ];

    final pascal = Person('Pascal');
    pascal.weightHistory = pascalWeightHistory;
    final alina = Person('Alina');
    alina.weightHistory = alinaWeightHistory;
    final entries = {'pascal': pascal, 'alina': alina};

    box.putAll(entries);
  }
}