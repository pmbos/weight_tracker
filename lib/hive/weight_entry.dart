import 'package:hive/hive.dart';

part 'weight_entry.g.dart';

@HiveType(typeId: 1)
class WeightEntry extends HiveObject {
  @HiveField(0)
  DateTime registeredAt;

  @HiveField(1, defaultValue: 0.0)
  double weight;
  
  WeightEntry(this.registeredAt, this.weight);

  @override
  String toString() => '$registeredAt - $weight';
}