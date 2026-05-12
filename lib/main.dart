import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'task_api.dart';
import 'task_local_database.dart';
import 'task_sync_service.dart';
import 'task_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox("tasks");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie";

  late Future<List<Task>> tasksFuture;

  @override
  void initState() {
    super.initState();

    tasksFuture = loadTasks();
  }

  Future<List<Task>> loadTasks() async {
    await TaskSyncService.loadInitialDataIfNeeded();

    return TaskLocalDatabase.getTasks();
  }

  List<Task> filteredTasks(List<Task> tasks) {
    if (selectedFilter == "wykonane") {
      return tasks.where((task) => task.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      return tasks.where((task) => !task.done).toList();
    }

    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(),
            ),
          );

          if (newTask != null) {
            await TaskLocalDatabase.addTask(newTask);

            setState(() {
              tasksFuture = loadTasks();
            });
          }
        },
      ),
      body: FutureBuilder<List<Task>>(
        future: tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Błąd: ${snapshot.error}"),
            );
          }

          final tasks = snapshot.data ?? [];

          final filtered = filteredTasks(tasks);

          int doneCount =
              tasks.where((task) => task.done).length;

          return Column(
            children: [
              SizedBox(height: 10),

              Text(
                "Masz dziś ${tasks.length} zadań | wykonane: $doneCount",
              ),

              SizedBox(height: 10),

              Text(
                "Dzisiejsze zadania",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  filterButton("wszystkie"),
                  filterButton("do zrobienia"),
                  filterButton("wykonane"),
                ],
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final task = filtered[index];

                    return TaskCard(
                      title: task.title,
                      subtitle:
                      "${task.deadline} | ${task.priority}",
                      done: task.done,

                      onChanged: (value) async {
                        final updatedTask = Task(
                          id: task.id,
                          title: task.title,
                          deadline: task.deadline,
                          priority: task.priority,
                          done: value ?? false,
                        );

                        await TaskLocalDatabase.updateTask(
                          updatedTask,
                        );

                        setState(() {
                          tasksFuture = loadTasks();
                        });
                      },

                      onTap: () async {
                        final updatedTask =
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditTaskScreen(task: task),
                          ),
                        );

                        if (updatedTask != null) {
                          await TaskLocalDatabase.updateTask(
                            updatedTask,
                          );

                          setState(() {
                            tasksFuture = loadTasks();
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget filterButton(String label) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          color: selectedFilter == label
              ? Colors.blue
              : Colors.grey,
        ),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController deadlineController =
  TextEditingController();

  String priority = "sredni";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nowe zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytul zadania",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 12),

            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: priority,
              items: ["niski", "sredni", "wysoki"]
                  .map((p) => DropdownMenuItem(
                value: p,
                child: Text(p),
              ))
                  .toList(),
              onChanged: (value) {
                priority = value!;
              },
              decoration: InputDecoration(
                labelText: "Priorytet",
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  id: DateTime.now()
                      .millisecondsSinceEpoch,
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: priority,
                );

                Navigator.pop(context, newTask);
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  final Task task;

  EditTaskScreen({
    required this.task,
  });

  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController deadlineController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = task.title;

    deadlineController.text = task.deadline;

    String priority = task.priority;

    return Scaffold(
      appBar: AppBar(
        title: Text("Edytuj zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
            ),

            SizedBox(height: 12),

            TextField(
              controller: deadlineController,
            ),

            SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: priority,
              items: ["niski", "sredni", "wysoki"]
                  .map((p) => DropdownMenuItem(
                value: p,
                child: Text(p),
              ))
                  .toList(),
              onChanged: (value) {
                priority = value!;
              },
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  Task(
                    id: task.id,
                    title: titleController.text,
                    deadline: deadlineController.text,
                    priority: priority,
                    done: task.done,
                  ),
                );
              },
              child: Text("Zapisz"),
            )
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;

  final ValueChanged<bool?>? onChanged;

  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: done,
          onChanged: onChanged,
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: done
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: done
                ? Colors.grey
                : Colors.black,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}