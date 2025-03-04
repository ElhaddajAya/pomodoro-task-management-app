import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:time_management_app/task_form_page.dart';
import 'package:time_management_app/task_model.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> tasks = [
    Task(title: "Finir le projet Flutter", dateTime: DateTime.now().add(Duration(hours: 3))),
    Task(title: "Réviser pour l'examen", dateTime: DateTime.now().add(Duration(days: 1))),
  ];

  // Marquer une tâche comme faite
  void toggleTaskCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
  }

  // Supprimer une tâche avec confirmation
  void deleteTask(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text("Delete Task ?", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to delete the task ?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                tasks.removeAt(index);
              });
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Task Deleted !",
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
            },
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Ajouter une nouvelle tâche
  void addTask(Task newTask) {
    setState(() {
      tasks.add(newTask);
    });
  }

  // Modifier une tâche existante
  void updateTask(int index, Task updatedTask) {
    setState(() {
      tasks[index] = updatedTask;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Trier les tâches par date
    tasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("My Tasks"),
        backgroundColor: Colors.red,
      ),
      body: tasks.isEmpty
      ? Center(
          child: Text("No tasks yet !", style: TextStyle(color: Colors.white, fontSize: 18)),
        )
      : ListView.builder(
        padding: EdgeInsets.all(5),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          return Card(
            color: Colors.grey[900],
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (value) => toggleTaskCompletion(index),
                checkColor: Colors.white,
                activeColor: Colors.red,
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                "${task.dateTime.day}/${task.dateTime.month}/${task.dateTime.year} à ${task.dateTime.hour}:${task.dateTime.minute.toString().padLeft(2, '0')}",
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      // Modifier une tâche existante
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskFormPage(
                            task: task,
                            onSave: (updatedTask) => updateTask(index, updatedTask),
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteTask(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Ajouter une nouvelle tâche
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskFormPage(
                onSave: (newTask) => addTask(newTask),
              ),
            ),
          );
        },
      ),
    );
  }
}
