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

class _HomeScreenState extends State<HomeScreen>{
  @override
  Widget build(BuildContext context){

    int doneCount = TaskRepository.tasks.where((task) => task.done).length;

    return Scaffold(
      appBar: AppBar(title: Text("KrakFlow")),
      body: Center(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Masz dzis ${TaskRepository.tasks.length} zadania | wykonane: $doneCount"),
                Text(
                  "Dzisiejsze zadania",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: TaskRepository.tasks.length,
              itemBuilder: (context, index) {
                final task = TaskRepository.tasks[index];
                return TaskCard(
                  title: task.title,
                  subtitle: "${task.deadline} | ${task.priority}",
                  icon: task.done
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                );
              },
            ),
          ],
        ),
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
}

class AddTaskScreen extends StatelessWidget {

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  String priority = "sredni";

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Nowe zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                labelText: "Termin (np. jutro)",
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
                border: OutlineInputBorder(),
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

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}



class MyTitle extends StatelessWidget{
  const MyTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("KrakFlow");
  }
}



