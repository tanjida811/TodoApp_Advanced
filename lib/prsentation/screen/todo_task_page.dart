

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/color.dart';
import '../model/folder.dart';
import '../model/todo.dart';
import '../utils/dialoghelper.dart';
import '../utils/global_search_deleget.dart';

class TodoTaskPage extends StatefulWidget {
  final Folder folder;

  const TodoTaskPage({Key? key, required this.folder}) : super(key: key);

  @override
  _TodoTaskPageState createState() => _TodoTaskPageState();
}

class _TodoTaskPageState extends State<TodoTaskPage> {
  List<Todo> tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskData = tasks.map((task) => task.toJson()).toList();
    prefs.setString('${widget.folder.id}_tasks', jsonEncode(taskData));
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskData = prefs.getString('${widget.folder.id}_tasks');
    if (taskData != null) {
      setState(() {
        final List<dynamic> decodedData = jsonDecode(taskData);
        tasks = decodedData.map((data) => Todo.fromJson(data)).toList();
      });
    }
  }

  void _addTask(String taskName) {
    if (taskName.isEmpty) return;

    setState(() {
      tasks.add(Todo(
        id: DateTime.now().toString(),
        todoText: taskName,
        createdAt: DateTime.now(),
      ));
    });

    _saveTasks();
    // _taskController.clear();
  }

  void _deleteTask(String id) {
    setState(() {
      tasks.removeWhere((task) => task.id == id);
    });

    _saveTasks();
  }

  void _renameTask(String id, String newName) {
    setState(() {
      final taskIndex = tasks.indexWhere((task) => task.id == id);
      if (taskIndex != -1) {
        tasks[taskIndex].todoText = newName;
      }
    });

    _saveTasks();
  }

  Future<void> showAddTaskDialog() async {
    await DialogHelper.showInputDialog(
      context: context,
      title: 'Add Task',
      hintText: 'Enter task name',
      initialValue: '',
      onConfirm: (input) => _addTask(input),
    );
  }

  Future<void> showRenameDialog(String id, String currentTaskName) async {
    await DialogHelper.showInputDialog(
      context: context,
      title: 'Rename Task',
      hintText: 'Enter new task name',
      initialValue: currentTaskName,
      onConfirm: (input) => _renameTask(id, input),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Task Manager', style: TextStyle(color: tdTextPrimary)),
        backgroundColor: tdBGColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              showSearch(
                context: context,
                delegate: GlobalSearchDelegate<Todo>(
                  items: tasks,
                  itemNameGetter: (task) => task.todoText,
                  itemBuilder: (task) => ListTile(
                    title: Text(task.todoText),
                    onTap: () {
                      // Navigate or perform actions on task
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),

          const CircleAvatar(
            child: Text('T', style: TextStyle(color: tdTextPrimary)),
            backgroundColor: tdPrimaryColor,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('No tasks added yet.'))
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(
                    task.todoText,
                    style: TextStyle(
                      decoration:
                      task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(
                      task.isDone
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: tdPrimaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        task.isDone = !task.isDone;
                      });
                      _saveTasks();
                    },
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteTask(task.id);
                      } else if (value == 'rename') {
                        DialogHelper.showInputDialog(
                          context: context,
                          title: 'Rename Task',
                          hintText: 'Enter new task name',
                          initialValue: task.todoText,
                          onConfirm: (newName) =>
                              _renameTask(task.id, newName),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'rename',
                        child: Text('Rename'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          DialogHelper.showInputDialog(
            context: context,
            title: 'Add Task',
            hintText: 'Enter task name',
            initialValue: '',
            onConfirm: (newTask) => _addTask(newTask),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: tdPrimaryColor,
      ),
    );
  }
}
