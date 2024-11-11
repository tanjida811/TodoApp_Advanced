import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/color.dart';
import '../model/todo.dart';
import '../widget/todo_item.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> todoList = [];
  List<Todo> _foundToDo = [];
  final _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodoList(); // Load the to-do list when the screen is initialized
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                _buildSearchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 50, bottom: 20),
                        child: Text(
                          "All ToDos",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w500, color: tdBlack),
                        ),
                      ),
                      for (Todo todo in _foundToDo.reversed)
                        TodoItem(
                          todo: todo,
                          OnToDoChanged: _handleToDoChange,
                          OnDeleteItem: _deleteToDoItem,
                          OnSelectItem: _selectToDoItem,
                          OnUpdateItem: (updatedText) => _updateToDoItem(updatedText, todo.id),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: tdWhite,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          offset: Offset(0.0, 2.0),
                          blurRadius: 8.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                        hintText: "Add a new todo item",
                        hintStyle: TextStyle(color: tdGrey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20, right: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      _addToDoItem(_todoController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(60, 60),
                      backgroundColor: tdBlue,
                      elevation: 10,
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(fontSize: 30, color: tdWhite),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(Todo todo) {
    setState(() {
      int index = todoList.indexOf(todo);
      todoList[index] = Todo(
        id: todo.id,
        todoText: todo.todoText,
        isDone: !todo.isDone,
        createdAt: todo.createdAt,
        isSelected: todo.isSelected,
      );
      _saveTodoList(); // Save the updated to-do list
    });
  }

  void _selectToDoItem(String id) {
    setState(() {
      Todo selectedTodo = todoList.firstWhere((item) => item.id == id);
      selectedTodo.isSelected = !selectedTodo.isSelected;
      _saveTodoList(); // Save the updated to-do list
    });
  }

  void _deleteToDoItem(String id) {
    setState(() {
      todoList.removeWhere((todo) => todo.id == id);
      _foundToDo = todoList;
      _saveTodoList(); // Save the updated to-do list
    });
  }

  void _updateToDoItem(String updatedText, String id) {
    setState(() {
      Todo todo = todoList.firstWhere((item) => item.id == id);
      todo.todoText = updatedText;
      _saveTodoList(); // Save the updated to-do list
    });
  }

  void _addToDoItem(String toDo) {
    if (toDo.isNotEmpty) {
      setState(() {
        todoList.add(
          Todo(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            todoText: toDo,
            isDone: false,
            createdAt: DateTime.now(),
            isSelected: false,
          ),
        );
        _foundToDo = todoList;
        _saveTodoList(); // Save the updated to-do list
      });
      _todoController.clear();
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Todo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todoList;
    } else {
      results = todoList
          .where((item) =>
          item.todoText!.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundToDo = results;
    });
  }

  Container _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: tdGrey,
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          prefixIcon: Icon(Icons.search, color: tdBlack, size: 30),
          prefixIconConstraints: BoxConstraints(maxHeight: 25, maxWidth: 30),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdBlack),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.menu, color: tdBlack, size: 30),
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage("assets/profile.jpeg"),
          ),
        ],
      ),
    );
  }

  // Load the to-do list from SharedPreferences
  Future<void> _loadTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListData = prefs.getStringList('todoList') ?? [];
    setState(() {
      todoList = todoListData.map((todoText) {
        return Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          todoText: todoText,
          isDone: false,
          createdAt: DateTime.now(),
          isSelected: false,
        );
      }).toList();
      _foundToDo = todoList;
    });
  }

  // Save the to-do list to SharedPreferences
  Future<void> _saveTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> todoListData = todoList.map((todo) => todo.todoText!).toList();
    await prefs.setStringList('todoList', todoListData);
  }
}
