import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  List<Task> tasks = [
    Task(title: "HTML/CSS", deadline: "dzisiaj"),
    Task(title: "Python", deadline: "2 dni"),
    Task(title: "Java", deadline: "w nastepnym tygodniu"),
    Task(title: "C++", deadline: "jutro"),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("KrakFlow")),
        body: Center(
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Masz dzis ${tasks.length} zadania"),
                ],
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index){
                    final task = tasks[index];
                    return TaskCard(title: task.title,
                        subtitle: task.deadline,
                        icon: Icons.ice_skating);
                  }
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Text(
                  "Dzisiejsze zadania",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
              ),
              TaskCard(title: tasks[0].title,
                subtitle: "Hello",
                icon: Icons.face,
              ),
              TaskCard(title: tasks[1].title,
                subtitle: "Hello",
                icon: Icons.face_2,
              ),
              TaskCard(title: tasks[2].title,
                subtitle: "Hello",
                icon: Icons.face_3,
              ),
              TaskCard(title: tasks[3].title,
                subtitle: "Hello",
                icon: Icons.face_4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String deadline;
  final bool done;

  Task({required this.title, required this.deadline, required this.done});
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



