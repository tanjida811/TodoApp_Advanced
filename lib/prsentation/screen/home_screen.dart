import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/prsentation/model/historyitem.dart';
import '../constants/color.dart';
import '../model/todo.dart';
import '../utils/dialog_helper.dart';
import '../widget/todo_item.dart';
import 'history_screen.dart';
import 'historymanager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HistoryItem> history = [];
  List<Todo> todoList = [];
  List<Todo> _filteredToDo = [];
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchCriteria = 'Text';
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();

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
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController, // Added the controller here
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              _buildSearchBox(),
              const SizedBox(height: 15),
              _buildToDoList(),
            ],
          ),
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
        children: [
          const Text(
            'ToDo List',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: tdTextPrimary,
              letterSpacing: 1.5,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.history, color: tdTextPrimary),
                onPressed: () {
                  // Navigate to the History Page from Home Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen (todoList: todoList)),
                  );
                },
              ),
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/profile.jpeg"),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildSearchDropdown(),
          const SizedBox(width: 16),
          _buildSearchField(),
        ],
      ),
    );
  }

  Widget _buildSearchDropdown() {
    return DropdownButton<String>(
      value: _searchCriteria,
      icon: const Icon(Icons.arrow_downward),
      onChanged: (String? newValue) {
        setState(() {
          _searchCriteria = newValue!;
        });
      },
      items: ['Text', 'Time'].map((value) {
        return DropdownMenuItem(value: value, child: Text(value));
      }).toList(),
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: TextField(
        controller: _searchController,
        onChanged: _runFilter,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: tdTextPrimary),
          hintText: 'Search by $_searchCriteria',
          filled: true,
          fillColor: tdSurfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
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
        focusNode: _focusNode,
        decoration: const InputDecoration(
          hintText: 'Enter your todo item...',
          border: InputBorder.none,
        ),
        onTap: _scrollToEnd,
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
      todoList.insert(0, todo);
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
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() {
          _filteredToDo =
              List.from(todoList); // Reset the filter if the search is empty
        });
        return;
      }

      setState(() {
        _filteredToDo = todoList.where((todo) {
          if (_searchCriteria == 'Text') {
            return todo.todoText.toLowerCase().contains(query.toLowerCase());
          } else {
            final formattedTime = DateFormat('HH:mm').format(todo.createdAt);
            return formattedTime.contains(query);
          }
        }).toList();
      });
    });
  }

  Widget _buildToDoList() {
    return ListView.builder(
      shrinkWrap: true, // Prevent scrolling issue
      itemCount: _filteredToDo.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onDoubleTap: () => _showRenameDialog(_filteredToDo[index].id),
          child: TodoItem(
            todo: _filteredToDo[index],
            onToDoChanged: _onTodoChanged,
            onDeleteItem: _deleteTodoItem,
            onSelectItem: _onTodoSelected,
            onUpdateItem: _updateTodoItem,
          ),
        );
      },
    );
  }

  void _onTodoChanged(Todo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
    Todo.markAsCompleted(todo);
    _saveTodoList();
  }
  void _deleteTodoItem(String todoId) {
    setState(() {
      int index = todoList.indexWhere((item) => item.id == todoId);
      if (index == -1) {
        print("Todo item not found");
        return;
      }

      Todo todo = todoList[index];

      // ইতিহাসে যোগ করুন
      HistoryManager.addHistoryItem(
        HistoryItem(
          id: todo.id,
          actionType: 'deleted', // ডিলিট হয়েছে
          actionDate: DateTime.now(),
          todo: todo, // ডিলিট হওয়া টাস্ক
        ),
      );

      // টাস্ক লিস্ট থেকে মুছে ফেলুন
      todoList.removeAt(index);
      _filteredToDo = List.from(todoList);
    });

    _saveTodoList();
  }





  void _showRenameDialog(String todoId) {
    final todo = todoList.firstWhere((todo) => todo.id == todoId);
    Dialog_Helper.showRenameDialog(
      context,
      todo,
      (String newText) {
        _updateTodoItem(todoId, newText);
        _saveTodoList();
      },
    );
  }

  void _updateTodoItem(String id, String newText) {
    setState(() {
      final index = todoList.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        todoList[index] = todoList[index].copyWith(todoText: newText);
        _filteredToDo = List.from(todoList);
      }
    });
    _saveTodoList();
  }

  void _onTodoSelected(String id) {
    setState(() {
      final index = todoList.indexWhere((item) => item.id == id);
      if (index != -1) {
        todoList[index] =
            todoList[index].copyWith(isSelected: !todoList[index].isSelected);
      }
    });
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  void restoreFromHistory(String taskId) {
    HistoryItem? historyItem = HistoryManager.getHistoryItem(taskId);

    if (historyItem == null) {
      // Handle the case where the history item is not found
      print("History item not found for taskId: $taskId");
      return;
    }

    if (historyItem.actionType == 'deleted' && historyItem.todo != null) {
      // Restore the deleted Todo item
      setState(() {
        // Insert the restored Todo item back at the original position
        todoList.insert(0, historyItem.todo!); // Add to the start, or use another logic to insert at the correct position
      });

      HistoryManager.history.remove(historyItem); // Remove from history after restoring
      _saveTodoList(); // Save the updated list
    }
  }




  void _saveTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todoStrings = todoList.map((todo) {
      return '${todo.id}|${todo.todoText}|${todo.createdAt.toIso8601String()}';
    }).toList();
    prefs.setStringList('todos', todoStrings);
  }
}
