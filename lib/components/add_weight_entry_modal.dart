import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weight_tracker/hive/weight_entry.dart';

import '../hive/person.dart';

class AddWeightEntryModal extends StatefulWidget {
  final int selectedPerson;

  const AddWeightEntryModal({Key? key, required this.selectedPerson}) : super(key: key);

  @override
  State<AddWeightEntryModal> createState() => _AddWeightEntryModalState();
}

class _AddWeightEntryModalState extends State<AddWeightEntryModal> {
  final _formKey = GlobalKey<FormState>();
  late Box<Person> _box;

  late int _selectedPerson;
  DateTime _selectedDate = DateTime.now();
  double _selectedWeight = 0.0;

  @override
  initState() {
    super.initState();

    _box = Hive.box<Person>('personBox');
    _selectedPerson = widget.selectedPerson;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: 'Tracked person'),
                items: _box.values.map((person) => DropdownMenuItem(
                    value: int.parse(person.key.toString()),
                    child: Text(person.name)),
                ).toList(),
                value: _selectedPerson,
                onChanged: (int? value) {
                  setState(() {
                    _selectedPerson = value!;
                  });
                },
              ),
              InputDatePickerFormField(
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 3)),
                lastDate: DateTime.now().add(const Duration(days: 3)),
                onDateSaved: (dateTime) {
                  _selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null) {
                    return 'Please enter a weight.';
                  }

                  final convertedValue = double.tryParse(value);
                  if (convertedValue == null) {
                    return 'Please enter a valid numeric weight.';
                  }

                  return null;
                },
                onSaved: (value) {
                  _selectedWeight = double.parse(value!);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final person = _box.get(_selectedPerson)!;

                        Navigator.pop(
                            context,
                            { person: WeightEntry(_selectedDate, _selectedWeight) }
                        );
                      }
                    },
                    child: const Text('Add!')
                ),
              ),
            ],
          ),
        )
    );
  }
}
