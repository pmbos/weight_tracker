import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:weight_tracker/controllers/helpers/date_time.dart';
import 'package:weight_tracker/hive/person.dart';

import '../hive/weight_entry.dart';

Person createOrUpdate(String name, {
  double? notifyInterval,
  double? initialWeight}) {
  final person = Person(name,
      notifyInterval: notifyInterval,
      lastNotifiedAt: initialWeight);

    person.weightHistory = initialWeight != null
      ? <WeightEntry> [
        WeightEntry(
            today(),
            initialWeight),
        ]
      : <WeightEntry>[];

  return person;
}



bool insert(Person person) {
  try {
    final box = Hive.box<Person>('personBox');

    box.add(person);
  } catch (error) {
    if (kDebugMode) print(error);

    return false;
  }

  return true;
}


