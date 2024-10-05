import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TaskListScreen(),
    );
  }
}

enum TaskPriority { Low, Medium, High }

extension TaskPriorityExtension on TaskPriority {
  int get value {
    switch (this) {
      case TaskPriority.Low:
        return 1;
      case TaskPriority.Medium:
        return 2;
      case TaskPriority.High:
        return 3;
    }
  }
}

class Task {
  String name;
  bool completed;
  TaskPriority priority;

  Task(
      {required this.name,
      this.completed = false,
      this.priority = TaskPriority.Low});
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.Low;

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(
          name: _taskController.text,
          priority: _selectedPriority,
        ));
        _taskController.clear();
        _selectedPriority = TaskPriority.Low;
        _sortTasks();
      });
    }
  }

  void _sortTasks() {
    _tasks.sort((a, b) => b.priority.value.compareTo(a.priority.value));
  }

  void _completeTask(int index) {
    setState(() {
      _tasks[index].completed = !_tasks[index].completed;
    });
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Enter a task',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<TaskPriority>(
              value: _selectedPriority,
              items: TaskPriority.values.map((TaskPriority priority) {
                return DropdownMenuItem<TaskPriority>(
                  value: priority,
                  child: Text(priority.toString().split('.').last.capitalize()),
                );
              }).toList(),
              onChanged: (TaskPriority? newValue) {
                setState(() {
                  _selectedPriority = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTask,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text('Add Task'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(child: Text('No tasks added yet.'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Checkbox(
                              value: _tasks[index].completed,
                              onChanged: (bool? value) {
                                _completeTask(index);
                              },
                              activeColor: Colors.black,
                            ),
                            title: Text(
                              _tasks[index].name,
                              style: TextStyle(
                                decoration: _tasks[index].completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(
                                'Priority: ${_tasks[index].priority.toString().split('.').last.capitalize()}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeTask(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringCapitalization on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }
}
