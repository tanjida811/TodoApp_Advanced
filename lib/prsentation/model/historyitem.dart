import 'package:to_do_app/prsentation/model/todo.dart';
import 'folder.dart';

class HistoryItem {
  final String id;
  final String actionType; // 'completed', 'deleted'
  final DateTime actionDate;
  final Todo? todo; // For deleted todo items
  final Folder? folder; // For deleted folders

  HistoryItem({
    required this.id,
    required this.actionType,
    required this.actionDate,
    this.todo,
    this.folder,
  });

  // From JSON constructor
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      actionType: json['actionType'] as String,
      actionDate: DateTime.parse(json['actionDate'] as String),
      todo: json['todo'] != null ? Todo.fromJson(json['todo']) : null,
      folder: json['folder'] != null ? Folder.fromJson(json['folder']) : null,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actionType': actionType,
      'actionDate': actionDate.toIso8601String(),
      'todo': todo?.toJson(),
      'folder': folder?.toJson(),
    };
  }
}
