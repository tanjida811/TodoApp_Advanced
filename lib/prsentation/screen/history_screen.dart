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
  String _searchQuery = ''; // Store the search query
  int _selectedTabIndex = 0; // For bottom navigation or AppBar buttons

  @override
  void initState() {
    super.initState();
    HistoryManager.loadHistory(); // Load history when the page is opened
  }

  @override
  Widget build(BuildContext context) {
    // Filtered history items based on search query and selected tab
    final filteredHistory = HistoryManager.history.where((item) {
      final matchesSearchQuery = item.todo?.todoText
          ?.toLowerCase()
          .contains(_searchQuery.toLowerCase()) ??
          false;

      switch (_selectedTabIndex) {
        case 0: // All
          return matchesSearchQuery;
        case 1: // Folders
          return matchesSearchQuery && item.actionType == 'deleted' && item.todo == null;
        case 2: // Todo Items
          return matchesSearchQuery && item.todo != null;
        case 3: // Checkboxes (Completed tasks)
          return matchesSearchQuery && item.actionType == 'completed';
        default:
          return matchesSearchQuery;
      }
    }).toList();

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
          // Search Icon and Text Field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value; // Update search query
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, color: tdTextPrimary),
                  filled: true,
                  fillColor: tdSurfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: tdErrorColor),
            onPressed: () {
              HistoryManager.clearHistory();
              setState(() {}); // Rebuild UI after clearing history
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAppBarButton('All', Icons.all_inbox, 0),
              _buildAppBarButton('Folders', Icons.folder, 1),
              _buildAppBarButton('Todo Items', Icons.checklist, 2),
              _buildAppBarButton('Completed', Icons.check_circle, 3),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredHistory.length,
        itemBuilder: (context, index) {
          final historyItem = filteredHistory[index];
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

  // Build AppBar Buttons for Filtering
  Widget _buildAppBarButton(String label, IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index; // Change selected tab
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedTabIndex == index ? tdPrimaryColor : tdTextSecondary,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedTabIndex == index ? tdPrimaryColor : tdTextSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
