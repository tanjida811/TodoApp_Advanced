import 'package:to_do_app/prsentation/model/todo.dart';

class HistoryItem {
  String id;
  String actionType;  // 'completed' or 'deleted'
  DateTime actionDate;
  Todo? todo;  // Optional: For storing deleted Todo items

  HistoryItem({
    required this.id,
    required this.actionType,
    required this.actionDate,
    this.todo,
  });
}

