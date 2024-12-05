import '../screen/historymanager.dart';
import 'historyitem.dart';

class Todo {
  String id;
  String todoText;
  DateTime createdAt;
  bool isDone;
  bool isSelected;

  Todo({
    required this.id,
    required this.todoText,
    required this.createdAt,
    this.isDone = false,
    this.isSelected = false,
  });

  // Copying an existing Todo with potential changes to properties
  Todo copyWith({String? todoText, bool? isDone, bool? isSelected}) {
    return Todo(
      id: id,
      todoText: todoText ?? this.todoText,
      createdAt: createdAt,
      isDone: isDone ?? this.isDone,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Convert a Todo object from JSON
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      todoText: json['todoText'],
      createdAt: DateTime.parse(json['createdAt']),
      isDone: json['isDone'] ?? false,
      isSelected: json['isSelected'] ?? false,
    );
  }

  // Convert a Todo object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'createdAt': createdAt.toIso8601String(),
      'isDone': isDone,
      'isSelected': isSelected,
    };
  }

  // When a task is completed, add it to the history
  static void markAsCompleted(Todo todo) {
    HistoryItem historyItem = HistoryItem(
      id: todo.id,
      actionType: 'completed',
      actionDate: DateTime.now(),
      todo: todo,  // Store the completed task
    );
    HistoryManager.addHistoryItem(historyItem);
  }

  // Handle delete action and add to history
  static void deleteTodoItem(Todo todo) {
    HistoryItem historyItem = HistoryItem(
      id: todo.id,
      actionType: 'deleted',
      actionDate: DateTime.now(),
      todo: todo,  // Store the deleted task
    );
    HistoryManager.addHistoryItem(historyItem);
  }
}
