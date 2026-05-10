import 'package:flutter/material.dart';
import 'task_repository.dart';
import 'task_api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  List<Task> get filteredTasks {
    if (selectedFilter == "wykonane") {
      return TaskRepository.tasks.where((task) => task.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      return TaskRepository.tasks.where((task) => !task.done).toList();
    }
    return TaskRepository.tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
      ),

      body: FutureBuilder<List<Task>>(
        future: TaskApiService.fetchTasks(),
        builder: (context, snapshot) {

          // WAITING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERROR
          if (snapshot.hasError) {
            return Center(
              child: Text("Błąd: ${snapshot.error}"),
            );
          }

          // DATA
          TaskRepository.tasks = snapshot.data!;

          int doneCount = TaskRepository.tasks
              .where((task) => task.done)
              .length;

          return Column(
            children: [
              SizedBox(height: 10),

              Text(
                "Masz dziś ${TaskRepository.tasks.length} zadań | wykonane: $doneCount",
              ),

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
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];

                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: task.done,
                          onChanged: (value) {
                            setState(() {
                              task.done = value!;
                            });
                          },
                        ),
                        title: Text(task.title),
                        subtitle: Text(
                          "${task.deadline} | ${task.priority}",
                        ),
                      ),
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

            ElevatedButton(
              onPressed: () {
                final newTask = Task(
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

  EditTaskScreen({required this.task});

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
      appBar: AppBar(title: Text("Edytuj zadanie")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController),
            SizedBox(height: 12),
            TextField(controller: deadlineController),
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

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  Task(
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
            color: done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}

