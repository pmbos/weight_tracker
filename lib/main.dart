import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weight_tracker/components/add_weight_entry_modal.dart';
import 'package:weight_tracker/components/drawer.dart';
import 'package:weight_tracker/components/overview_chart.dart';
import 'package:weight_tracker/hive/person.dart';
import 'package:weight_tracker/hive/seeds/person_seeder.dart';
import 'package:weight_tracker/hive/weight_entry.dart';
import 'package:weight_tracker/persons.dart';

void main() async {
  await Hive.initFlutter();
  registerHiveAdapters();
  await Hive.openBox<Person>('personBox');

  runApp(const MyApp());
}

void runSeeders() {
  PersonSeeder().seed();
}

void registerHiveAdapters() {
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(WeightEntryAdapter());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weight Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/persons': (context) => const PersonsScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Box<Person> box;
  late int? selectedPerson;

  _MyHomePageState() {
    box = Hive.box<Person>('personBox');
    selectedPerson = box.values.isNotEmpty
        ? box.values.first.key
        : null;
  }

  @override
  Widget build(BuildContext context) {
    double? interval;
    Person? person;

    try {
      person = box.get(selectedPerson!);
      interval = person
          ?.notifyInterval;
    } catch (_) {
      interval = null;
      person = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your personal weight tracker'),
      ),
      drawer: const SideDrawer(),
      floatingActionButton: box.isNotEmpty
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final personToWeight = await showModalBottomSheet<Map<Person, WeightEntry>>(
                    context: context,
                    builder: (context) => AddWeightEntryModal(selectedPerson: selectedPerson!)
                );

                if (personToWeight != null) {
                  final person = personToWeight.entries.first.key;
                  final weightEntry = personToWeight.entries.first.value;

                  person.weightHistory!.add(weightEntry);
                  person.save();

                  setState(() {
                      selectedPerson = person.key;
                  });

                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    if (person.lostIntervalWeight()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${person.formattedName} lost ${person.notifyInterval} kg!'))
                      );
                    }
                  });
                }
              },
          ) : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: selectedPerson != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton(
                      isExpanded: true,
                      items: box.values.map((e) => DropdownMenuItem(
                        value: int.parse(e.key.toString()),
                        child: Text(e.formattedName),
                      )).toList(),
                      value: selectedPerson,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedPerson = newValue!;
                        });
                      }
                  ),
                  OverviewChart(data: getChartData(person), selectedPerson: selectedPerson!),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: interval != null
                            ? Text('You will be notified every time ${person?.formattedName ?? ''} loses $interval kg.')
                            : Text('You have not set an interval notification for ${person?.formattedName ?? ''}.'),
                      ),
                  ),
                ],
              )
            : const Center(
              child: Text('You are not tracking anyone yet, to start add someone in the participants screen'),
            )
        ),
      );
  }

  List<WeightEntry> getChartData(Person? person) {
    return person?.weightHistory
        ?.where(
            (element)
              => element.registeredAt
                  .isAfter(
                    DateTime.now().subtract(const Duration(days: 7))
              )
        ).toList() ?? [];
  }
}
