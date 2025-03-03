import 'package:flutter/material.dart';
import 'package:time_management_app/task_model.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  // Ajouter une tâche
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  // Supprimer une tâche
  void deleteTask(Task task) {
    _tasks.remove(task);
    notifyListeners();
  }

  // Marquer une tâche comme terminée
  void toggleTaskCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    notifyListeners();
  }

  // Trier les tâches par date d'échéance
  void sortTasksByDate() {
    _tasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    notifyListeners();
  }

  // Filtrer les tâches non terminées
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();

  // Filtrer les tâches terminées
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
}
