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
  List<Todo> completedTasks = [];
  final TextEditingController _taskController = TextEditingController();
  int _selectedIndex = 0; // Track the selected tab index

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks when the screen is initialized
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  // Method to get tasks based on selected index
  List<Todo> getFilteredTasks() {
    switch (_selectedIndex) {
      case 1:
        return tasks.where((task) => task.isDone).toList(); // Checked tasks
      case 2:
        return tasks.where((task) => !task.isDone).toList(); // Unchecked tasks
      default:
        return tasks; // All tasks
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskData = tasks.map((task) => task.toJson()).toList();
    prefs.setString('${widget.folder.id}_tasks', jsonEncode(taskData)); // Store by folder ID

    final completedData = completedTasks.map((task) => task.toJson()).toList();
    prefs.setString('${widget.folder.id}_completedTasks', jsonEncode(completedData)); // Store by folder ID
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskData = prefs.getString('${widget.folder.id}_tasks'); // Load by folder ID
    if (taskData != null) {
      final List<dynamic> decodedData = jsonDecode(taskData);
      tasks = decodedData.map((data) => Todo.fromJson(data)).toList();
    }

    final completedData = prefs.getString('${widget.folder.id}_completedTasks'); // Load by folder ID
    if (completedData != null) {
      final List<dynamic> decodedData = jsonDecode(completedData);
      completedTasks = decodedData.map((data) => Todo.fromJson(data)).toList();
    }

    setState(() {});
  }

  void _addTask(String taskName) {
    if (taskName.isEmpty) return;

    setState(() {
      tasks.insert(0, Todo(
        id: DateTime.now().toString(),
        todoText: taskName,
        createdAt: DateTime.now(),
      ));
    });

    _saveTasks();
  }

  void _deleteTask(String id) {
    DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Delete Task',
      message: 'Are you sure you want to delete this task?',
      onConfirm: () {
        setState(() {
          final task = tasks.firstWhere((task) => task.id == id);
          tasks.removeWhere((task) => task.id == id);
          completedTasks.add(task);  // Add to completed tasks (history)
        });
        _saveTasks();  // Save the updated tasks and completed tasks
      },
    );
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints for responsive design
    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 1200;
    bool isDesktop = screenWidth >= 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.folderName ?? 'Untitled Folder', style: const TextStyle(color: tdTextPrimary)),
        backgroundColor: tdSurfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: GlobalSearchDelegate<Todo>(
                items: tasks,
                itemNameGetter: (task) => task.todoText,
                itemBuilder: (task) {
                  return ListTile(
                    title: Text(task.todoText),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: tdSecondaryColor,
              child: const Text(
                'T',
                style: TextStyle(
                  color: tdSurfaceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: tdBGColor,
        child: Column(
          children: [
            Expanded(
              child: getFilteredTasks().isEmpty
                  ? const Center(
                child: Text(
                  'No tasks added yet.',
                  style: TextStyle(color: tdTextSecondary),
                ),
              )
                  : ListView.builder(
                itemCount: getFilteredTasks().length,
                itemBuilder: (context, index) {
                  final task = getFilteredTasks()[index];
                  return GestureDetector(
                    onDoubleTap: () => showRenameDialog(task.id, task.todoText),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: tdBorderColor),
                      ),
                      child: ListTile(
                        title: Text(
                          task.todoText,
                          style: TextStyle(
                            color: tdTextPrimary,
                            decoration: task.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        leading: GestureDetector(
                          child: Checkbox(
                            value: task.isDone,
                            onChanged: (value) {
                              setState(() {
                                task.isDone = value ?? false;
                                task.completedAt = task.isDone ? DateTime.now() : null;
                              });
                              _saveTasks();
                            },
                            activeColor: tdSecondaryColor, // Set checkbox color when clicked
                          ),
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: tdErrorColor, // Rectangular background for delete
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: tdSurfaceColor),
                            onPressed: () => _deleteTask(task.id),
                          ),
                        ),
                        subtitle: Text(
                          'Add: ${task.createdAt.toLocal().toString().substring(0, 16)}' +
                              (task.isDone ? '\nEnd: ${task.completedAt?.toLocal().toString().substring(0, 16)}' : ''),
                          style: TextStyle(color: tdTextSecondary),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
        onPressed: showAddTaskDialog,
        backgroundColor: tdSecondaryColor,
        child: const Icon(Icons.add_task, color: tdSurfaceColor),
      )
          : null, // Hide FAB on tablet and desktop
      bottomNavigationBar: isMobile // Use BottomNavigationBar on mobile
          ? BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: tdSecondaryColor, // Light color when selected
        unselectedItemColor: tdTextSecondary, // Default color for unselected
        backgroundColor: tdSurfaceColor, // Set background color
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radio_button_unchecked),
            label: 'Uncompleted',
          ),
        ],
      )
          : null, // Hide BottomNavigationBar on tablet and desktop
    );
  }
}
