import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/prsentation/constants/color.dart';

class GlobalSearchDelegate<T> extends SearchDelegate {
  final List<T> items;
  final String Function(T) itemNameGetter; // Extract item name
  final Widget Function(T) itemBuilder; // Build each item UI
  List<String> searchHistory = []; // Store search history

  GlobalSearchDelegate({
    required this.items,
    required this.itemNameGetter,
    required this.itemBuilder,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: tdPrimaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: tdSurfaceColor),
        titleTextStyle: TextStyle(
          color: tdSurfaceColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: tdTextSecondary),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(
          query.isNotEmpty ? Icons.clear : Icons.search,
          color: tdSurfaceColor,
        ),
        onPressed: () {
          if (query.isEmpty) {
            showSuggestions(context); // Show suggestions for search
          } else {
            query = ''; // Clear the search field
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: tdSurfaceColor),
      onPressed: () {
        close(context, null); // Close the search delegate
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = items.where((item) {
      return itemNameGetter(item).toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return _buildEmptyState('No results found for "$query"');
    }

    _updateSearchHistory();
    return _buildItemList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildHistoryList();
    }

    final suggestions = items.where((item) {
      return itemNameGetter(item).toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (suggestions.isEmpty) {
      return _buildEmptyState('No suggestions available for "$query"');
    }

    return _buildItemList(context, suggestions);
  }

  Widget _buildItemList(BuildContext context, List<T> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(color: tdBorderColor),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(
            itemNameGetter(item),
            style: const TextStyle(
              color: tdTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            close(context, item); // Close search and return selected item
          },
        );
      },
    );
  }

  Widget _buildHistoryList() {
    if (searchHistory.isEmpty) {
      return _buildEmptyState('No recent searches');
    }

    return ListView.separated(
      itemCount: searchHistory.length,
      separatorBuilder: (context, index) => Divider(color: tdBorderColor),
      itemBuilder: (context, index) {
        final historyItem = searchHistory[index];
        return ListTile(
          title: Text(
            historyItem,
            style: const TextStyle(
              color: tdTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: tdErrorColor),
            onPressed: () {
              _removeFromHistory(index);
              showSuggestions(context); // Refresh the list
            },
          ),
          onTap: () {
            query = historyItem; // Reuse history query
            showResults(context); // Display results for this query
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: tdSecondaryColor, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: tdTextSecondary,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _updateSearchHistory() {
    if (query.isNotEmpty && !searchHistory.contains(query)) {
      searchHistory.add(query); // Add query to history
      _saveSearchHistory(); // Save to SharedPreferences
    }
  }

  void _removeFromHistory(int index) {
    searchHistory.removeAt(index); // Remove history entry
    _saveSearchHistory(); // Save updated history to SharedPreferences
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('searchHistory') ?? [];
    searchHistory = history;
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('searchHistory', searchHistory); // Save history
  }

  @override
  void close(BuildContext context, dynamic result) {
    super.close(context, result);
    _saveSearchHistory(); // Save history on close
  }
}
