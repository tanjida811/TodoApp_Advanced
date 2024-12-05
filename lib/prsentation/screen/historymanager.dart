import 'package:shared_preferences/shared_preferences.dart';

import '../model/historyitem.dart';
import '../model/todo.dart';

class HistoryManager {
  static List<HistoryItem> history = [];



  // Save history items to SharedPreferences
  static void saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = history.map((item) {
      return '${item.id}|${item.actionType}|${item.actionDate.toIso8601String()}|${item.todo?.todoText ?? ''}';
    }).toList();
    prefs.setStringList('history', historyList); // Save to SharedPreferences
  }

  // Load history items from SharedPreferences
  static void loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedHistory = prefs.getStringList('history');
    if (savedHistory != null) {
      history = savedHistory.map((item) {
        List<String> parts = item.split('|');
        return HistoryItem(
          id: parts[0],
          actionType: parts[1],
          actionDate: DateTime.parse(parts[2]),
          todo: parts[3].isNotEmpty ? Todo(id: parts[0], todoText: parts[3], createdAt: DateTime.now()) : null,
        );
      }).toList();
    }
  }

  // Add a history item
  static void addHistoryItem(HistoryItem item) {
    history.add(item);
    saveHistory();  // Save updated history after adding an item
  }

  // Fetch a specific history item by ID
  static HistoryItem getHistoryItem(String taskId) {
    return history.firstWhere(
          (item) => item.id == taskId,
      orElse: () => HistoryItem(id: taskId, actionType: 'unknown', actionDate: DateTime.now(), todo: null),
    );
  }

  // Clear all history items from SharedPreferences
  static void clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('history'); // Clear history data from SharedPreferences
    history.clear(); // Clear history list
  }
}
