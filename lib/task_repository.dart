class TaskRepository {
  static List<Task> tasks = [
    Task(
        id: 1, title: "HTML/CSS", deadline: "dzisiaj", done: true, priority: "wysoki"),
    Task(id: 2, title: "Python", deadline: "2 dni", done: true, priority: "sredni"),
    Task(id: 3, title: "Java",
        deadline: "w nastepnym tygodniu",
        done: false,
        priority: "niski"),
    Task(id: 4, title: "C++", deadline: "jutro", done: false, priority: "wysoki"),
  ];
}

class Task {
  String title;
  String deadline;
  bool done;
  String priority;
  final int id;

  Task({required this.title, required this.deadline, required this.done, required this.priority, required this.id});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "deadline": deadline,
      "done": done,
      "priority": priority,
    };
  }

  factory Task.fromMap(Map map) {
    return Task(
      id: map["id"],
      title: map["title"],
      deadline: map["deadline"],
      done: map["done"],
      priority: map["priority"],
    );
  }
}