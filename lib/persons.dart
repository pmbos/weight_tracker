import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weight_tracker/components/add_person_modal.dart';
import 'package:weight_tracker/components/drawer.dart';
import 'package:weight_tracker/controllers/person_controller.dart';
import 'package:weight_tracker/hive/person.dart';

class PersonsScreen extends StatefulWidget {
  const PersonsScreen({Key? key}) : super(key: key);

  @override
  State<PersonsScreen> createState() => _PersonsScreenState();
}

class _PersonsScreenState extends State<PersonsScreen> {
  final _persons = Hive.box<Person>('personBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People you are tracking'),
      ),
      drawer: const SideDrawer(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Open modal to add participant
          final person = await showModalBottomSheet<Person>(
              context: context,
              builder: (BuildContext context) => const AddPersonModal(),
            );

          if (person != null) {
            setState(() {
              insert(person);
            });
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: _persons.isEmpty
          ? const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('No tracked people! Click the plus sign to start!'),
            )
          )
          : ListView.builder(
            shrinkWrap: true,
            itemCount: _persons.length,
            itemBuilder: (BuildContext context, int index) {
              var person = _persons.getAt(index);
              return ListTile(
                key: ValueKey(person!.key),
                title: Text(person.formattedName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () async {
                          final editedPerson = await showModalBottomSheet<Person>(
                            context: context,
                            builder: (BuildContext context) => AddPersonModal(
                              person: person,
                            ),
                          );

                          setState(() {
                            person.name = editedPerson!.name;
                            person.notifyInterval = editedPerson.notifyInterval;
                            person.save();
                          });

                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                  content: Text('Updated ${person.formattedName}!')
                            ));
                          });
                        },
                        icon: const Icon(Icons.edit),
                        color: Colors.green,
                    ) ,
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        // confirm deletion and delete
                        setState(() {
                          person.delete();
                        });
                      },
                    ),
                  ]
                )
              );
            },
          ),
      ),
    );
  }
}
