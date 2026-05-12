import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'task_repository.dart';

class TaskApiService {
  static Future<List<Task>> fetchTasks() async {
    final response =
    await http.get(Uri.parse("https://dummyjson.com/todos"));

    if (response.statusCode != 200) {
      throw Exception("Błąd pobierania");
    }

    final data = jsonDecode(response.body);
    final List todos = data["todos"];

    final random = Random();
    final priorities = ["niski", "sredni", "wysoki"];

    return todos.map<Task>((item) {
      return Task(
        id: item["id"],
        title: item["todo"],
        done: item["completed"],
        priority:
        priorities[random.nextInt(priorities.length)],
        deadline: "${random.nextInt(28) + 1}.12.2026",
      );
    }).toList();
  }
}