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

  Todo copyWith({String? todoText, bool? isDone, bool? isSelected}) {
    return Todo(
      id: id,
      todoText: todoText ?? this.todoText,
      createdAt: createdAt,
      isDone: isDone ?? this.isDone,
      isSelected: isSelected ?? this.isSelected,
    );
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
