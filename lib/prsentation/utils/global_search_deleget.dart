

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlobalSearchDelegate<T> extends SearchDelegate {
  final List<T> items;
  final String Function(T) itemNameGetter;
  final Widget Function(T) itemBuilder;

  GlobalSearchDelegate({
    required this.items,
    required this.itemNameGetter,
    required this.itemBuilder,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = items.where((item) {
      return itemNameGetter(item).toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return itemBuilder(results[index]);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = items.where((item) {
      return itemNameGetter(item).toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return itemBuilder(suggestions[index]);
      },
    );
  }
}
