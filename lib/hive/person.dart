import 'package:hive/hive.dart';
import 'package:weight_tracker/extensions/string_extensions.dart';
import 'package:weight_tracker/hive/weight_entry.dart';

part 'person.g.dart';

@HiveType(typeId: 0)
class Person extends HiveObject {
  @HiveField(0, defaultValue: 'no name given')
  String name;

  @HiveField(1)
  List<WeightEntry>? weightHistory;
  
  @HiveField(2)
  double? notifyInterval;
  
  @HiveField(3)
  double? lastNotifiedAt;

  String get formattedName => name.capitalize();

  Person(this.name, { this.notifyInterval, this.lastNotifiedAt });

  @override
  String toString() => '$name with ${weightHistory?.length} weight entries';

  /// Checks if the Person instance lost a net weight greater than or equal to their
  /// indicated interval w.r.t their initial weight.
  /// True if, notifyInterval != null and
  /// weightHistory != null and
  /// Weight was lost with regards to the first entry and
  /// The weightloss is a multiple of notifyInterval or
  /// The weight loss was more than the notifyInterval w.r.t the latest entry and
  /// Weight was lost with regards to the latest entry
  bool lostIntervalWeight() => notifyInterval != null
      && weightHistory != null
      && weightHistory!.last.weight - weightHistory!.first.weight < 0
      && weightHistory!.elementAt(weightHistory!.length - 2).weight
          - weightHistory!.last.weight > 0
      && ((weightHistory!.last.weight - weightHistory!.first.weight) % notifyInterval! == 0
          || weightHistory!.elementAt(weightHistory!.length - 2).weight
            - weightHistory!.last.weight >= notifyInterval!);
}