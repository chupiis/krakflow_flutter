import 'package:flutter/material.dart';
import 'task_repository.dart';

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

  void showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void deleteAllTasks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Potwierdzenie"),
        content: Text("Czy usunąć wszystkie zadania?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Anuluj"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                TaskRepository.tasks.clear();
              });

              Navigator.pop(context);
              showSnack("Usunięto wszystkie zadania");
            },
            child: Text("Usuń"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int doneCount = TaskRepository.tasks.where((task) => task.done).length;

    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed:
            TaskRepository.tasks.isEmpty ? null : deleteAllTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),

          Text(
            "Masz dziś ${TaskRepository.tasks.length} zadania | wykonane: $doneCount",
          ),

          Text(
            "Dzisiejsze zadania",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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

                return Dismissible(
                  key: ValueKey(task.title),
                  direction: DismissDirection.endToStart,

                  onDismissed: (direction) {
                    setState(() {
                      TaskRepository.tasks.remove(task);
                    });

                    showSnack("Usunięto: ${task.title}");
                  },

                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),

                  child: TaskCard(
                    title: task.title,
                    subtitle: "${task.deadline} | ${task.priority}",
                    done: task.done,

                    onChanged: (value) {
                      setState(() {
                        task.done = value!;
                      });
                    },

                    onTap: () async {
                      final Task? updatedTask = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditTaskScreen(task: task),
                        ),
                      );

                      if (updatedTask != null) {
                        final originalIndex =
                        TaskRepository.tasks.indexOf(task);

                        setState(() {
                          TaskRepository.tasks[originalIndex] =
                              updatedTask;
                        });

                        showSnack("Zadanie zaktualizowane");
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(),
            ),
          );

          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
        child: Icon(Icons.add),
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