import 'package:flutter/material.dart';
import 'package:to_do_app/prsentation/constants/color.dart';
import 'package:to_do_app/prsentation/screen/historymanager.dart';

import '../model/historyitem.dart';
import '../model/todo.dart';

class HistoryScreen extends StatefulWidget {
  final List<Todo> todoList;

  const HistoryScreen({Key? key, required this.todoList}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    HistoryManager.loadHistory(); // Load history when the page is opened
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: AppBar(
        backgroundColor: tdBGColor,
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: tdTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              // Clear all history from SharedPreferences and the list
              HistoryManager.clearHistory();
              setState(() {}); // Rebuild the UI after clearing history
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: HistoryManager.history.length,
        itemBuilder: (context, index) {
          final historyItem = HistoryManager.history[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: tdBorderColor),
            ),
            child: ListTile(
              leading: _buildLeadingIcon(historyItem),
              title: Text(
                historyItem.todo?.todoText ?? 'No Text',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: historyItem.actionType == 'completed'
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Text(
                'Action: ${historyItem.actionType}\nDate: ${historyItem.actionDate}',
                style: const TextStyle(color: tdTextSecondary),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Restore Button
                  IconButton(
                    icon: const Icon(Icons.restore, color: tdPrimaryColor),
                    onPressed: () {
                      setState(() {
                        if (historyItem.todo != null) {
                          // Add the restored todo at the correct position
                          widget.todoList.add(historyItem.todo!);
                          HistoryManager.history.removeAt(index); // Remove from history after restore
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Task Restored!')),
                          );
                        }
                      });
                    },
                  ),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: tdErrorColor),
                    onPressed: () {
                      setState(() {
                        HistoryManager.history.removeAt(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Task Permanently Deleted!')),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Build Leading Icon Based on Task Type
  Widget _buildLeadingIcon(HistoryItem historyItem) {
    if (historyItem.actionType == 'completed') {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (historyItem.actionType == 'deleted') {
      return const Icon(Icons.delete, color: Colors.red);
    }
    return const Icon(Icons.info, color: tdTextSecondary);
  }
}
