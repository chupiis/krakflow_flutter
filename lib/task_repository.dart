class TaskRepository {
  static List<Task> tasks = [
    Task(
        title: "HTML/CSS", deadline: "dzisiaj", done: true, priority: "wysoki"),
    Task(title: "Python", deadline: "2 dni", done: true, priority: "sredni"),
    Task(title: "Java",
        deadline: "w nastepnym tygodniu",
        done: false,
        priority: "niski"),
    Task(title: "C++", deadline: "jutro", done: false, priority: "wysoki"),
  ];
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({required this.title, required this.deadline, required this.done, required this.priority});
}