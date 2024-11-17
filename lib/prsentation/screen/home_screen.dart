import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/color.dart';
import '../model/todo.dart';
import '../widget/todo_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> todoList = [];
  List<Todo> _filteredToDo = [];
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchCriteria = 'Text';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  @override
  void dispose() {
    _todoController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            _buildSearchBox(),
            _buildTitle("All Todos"),
            Expanded(child: _buildToDoList()),
          ],
        ),
      ),
      bottomNavigationBar: _buildAddToDoSection(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Icon(Icons.menu, color: tdTextPrimary, size: 30),
          CircleAvatar(radius: 20, backgroundImage: AssetImage("assets/profile.jpeg")),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 50, bottom: 20),
      child: Text(
        title,
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500, color: tdTextPrimary),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _searchCriteria,
            icon: const Icon(Icons.arrow_downward),
            onChanged: (String? newValue) {
              setState(() {
                _searchCriteria = newValue!;
              });
            },
            items: ['Text', 'Date', 'Time'].map((value) {
              return DropdownMenuItem(value: value, child: Text(value));
            }).toList(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _runFilter,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: tdBackgroundColor),
                hintText: 'Search by $_searchCriteria',
                filled: true,
                fillColor: tdSurfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToDoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(child: _buildTodoInputField()),
          const SizedBox(width: 10),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildTodoInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: tdSurfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _todoController,
        decoration: const InputDecoration(
          hintText: 'Enter your task...',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _addTodoItem,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: tdPrimaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _addTodoItem() {
    if (_todoController.text.isEmpty) return;
    final todo = Todo(
      id: DateTime.now().toString(),
      todoText: _todoController.text,
      createdAt: DateTime.now(),
    );
    setState(() {
      todoList.add(todo);
      _filteredToDo = List.from(todoList);
    });
    _saveTodoList();
    _todoController.clear();
  }

  void _loadTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTodos = prefs.getStringList('todos') ?? [];
    setState(() {
      todoList = savedTodos.map((item) {
        final parts = item.split('|');
        return Todo(
          id: parts[0],
          todoText: parts[1],
          createdAt: DateTime.parse(parts[2]),
        );
      }).toList();
      _filteredToDo = List.from(todoList);
    });
  }

  void _runFilter(String query) {
    setState(() {
      _filteredToDo = todoList.where((todo) {
        if (_searchCriteria == 'Text') {
          return todo.todoText.toLowerCase().contains(query.toLowerCase());
        }
        if (_searchCriteria == 'Date' || _searchCriteria == 'Time') {
          return todo.createdAt.toString().contains(query);
        }
        return false;
      }).toList();
    });
  }

  Widget _buildToDoList() {
    return ListView.builder(
      itemCount: _filteredToDo.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onDoubleTap: () => _showRenameDialog(_filteredToDo[index].id),
          child: TodoItem(
            todo: _filteredToDo[index],
            onToDoChanged: (todo) => _onTodoChanged(todo),
            onDeleteItem: (id) => _deleteTodoItem(id),
            onSelectItem: (id) => _onTodoSelected(id),
            onUpdateItem: (id, text) => _updateTodoItem(id, text),
          ),
        );
      },
    );
  }

  void _onTodoChanged(Todo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _deleteTodoItem(String id) {
    setState(() {
      todoList.removeWhere((item) => item.id == id);
      _filteredToDo = List.from(todoList);
    });
    _saveTodoList();
  }

  void _saveTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todoStrings = todoList.map((todo) {
      return '${todo.id}|${todo.todoText}|${todo.createdAt.toIso8601String()}';
    }).toList();
    prefs.setStringList('todos', todoStrings);
  }

  void _onTodoSelected(String id) {
    setState(() {
      final index = todoList.indexWhere((item) => item.id == id);
      if (index != -1) {
        todoList[index] = todoList[index].copyWith(isSelected: !todoList[index].isSelected);
      }
    });
  }

  void _showRenameDialog(String id) {
    final _renameController = TextEditingController();
    final todo = todoList.firstWhere((item) => item.id == id);

    _renameController.text = todo.todoText;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Todo'),
          content: TextField(
            controller: _renameController,
            decoration: const InputDecoration(hintText: 'Enter new todo text'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_renameController.text.isNotEmpty) {
                  _updateTodoItem(id, _renameController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _updateTodoItem(String id, String newText) {
    setState(() {
      final index = todoList.indexWhere((item) => item.id == id);
      if (index != -1) {
        todoList[index] = todoList[index].copyWith(todoText: newText);
      }
      _filteredToDo = List.from(todoList);
    });
    _saveTodoList();
  }
}
