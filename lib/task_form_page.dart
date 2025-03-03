import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:time_management_app/task_model.dart';

class TaskFormPage extends StatefulWidget {
  final Task? task; // Si une tâche est fournie, c'est une modification
  final Function(Task) onSave;

  const TaskFormPage({super.key, this.task, required this.onSave});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? "");
    _selectedDateTime = widget.task?.dateTime ?? DateTime.now();
  }

  // Sélection de la date
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: Colors.red,
            colorScheme: ColorScheme.dark(primary: Colors.red),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  // Sélection de l’heure
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: Colors.red,
            colorScheme: ColorScheme.dark(primary: Colors.red, secondary: Colors.red),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  // Sauvegarder la tâche
  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        title: _titleController.text,
        dateTime: _selectedDateTime,
      );
      widget.onSave(newTask);
      Fluttertoast.showToast(
        msg: widget.task == null ? "Task Added !" : "Task Updated !",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.task == null ? "Add new Task" : "Update Task"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Champ de texte pour le titre
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Task Title",
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer un nom.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Champ pour la date
              TextFormField(
                readOnly: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Date",
                  labelStyle: TextStyle(color: Colors.white),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.red),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                controller: TextEditingController(
                  text: "${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}",
                ),
                onTap: _pickDate,
              ),
              SizedBox(height: 20),

              // Champ pour l’heure
              TextFormField(
                readOnly: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Time",
                  labelStyle: TextStyle(color: Colors.white),
                  suffixIcon: Icon(Icons.access_time, color: Colors.red),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                controller: TextEditingController(
                  text: "${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}",
                ),
                onTap: _pickTime,
              ),
              SizedBox(height: 20),

              // Bouton de soumission
              Center(
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text(
                    widget.task == null ? "Add" : "Update",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}