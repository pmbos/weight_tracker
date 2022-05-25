import 'package:flutter/material.dart';
import 'package:weight_tracker/hive/person.dart';

import '../controllers/person_controller.dart';

class AddPersonModal extends StatefulWidget {
  final Person? person;

  const AddPersonModal({Key? key, this.person,}) : super(key: key);

  @override
  State<AddPersonModal> createState() => _AddPersonModalState();
}

class _AddPersonModalState extends State<AddPersonModal> {
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    String newName = widget.person != null
        ? widget.person!.name
        : '';
    double? initialWeight = widget.person != null
          && widget.person!.weightHistory != null
          && widget.person!.weightHistory!.isNotEmpty
        ? widget.person!.weightHistory?.first.weight
        : null;
    double? notificationInterval = widget.person != null
        ? widget.person!.notifyInterval
        : null;

    return Form(
      key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 16.0),
                child: Text(
                  widget.person != null
                  ? 'Edit ${widget.person!.name}'
                  : 'Track someone new!',
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
               ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                initialValue: newName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }

                  return null;
                },
                onSaved: (value) {
                  newName = value!;
                },
              ),
              Visibility(
                  visible: widget.person == null,
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Initial weight'),
                    keyboardType: TextInputType.number,
                    enabled: widget.person == null,
                    initialValue: initialWeight == null ? '' : initialWeight.toString(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }

                      final convertedValue = double.tryParse(value);
                      if (convertedValue == null) {
                        return 'Please enter a valid numeric weight.';
                      }

                      return null;
                    },
                    onSaved: (value) {
                      initialWeight = value != null && value.isNotEmpty
                          ? double.parse(value)
                          : null;
                    },
                  ),
              ),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Notification interval (kg)'),
                keyboardType: TextInputType.number,
                initialValue: notificationInterval == null
                    ? ''
                    : notificationInterval.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }

                  final convertedValue = double.tryParse(value);
                  if (convertedValue == null) {
                    return 'Please enter a valid numeric interval (kg).';
                  }

                  return null;
                },
                onSaved: (value) {
                  notificationInterval = value != null && value.isNotEmpty
                      ? double.parse(value)
                      : null;
                },
              ),
              Padding(padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                    onPressed: () {
                      final state = _formKey.currentState!;

                      if (state.validate()) {
                        state.save();

                        final person = createOrUpdate(
                          newName,
                          notifyInterval: notificationInterval,
                          initialWeight: initialWeight,
                        );

                        Navigator.pop(context, person);
                      }
                    },
                    child: const Text('Track!')
                ),
              ),
            ],
          ),
        ),
    );
  }
}
