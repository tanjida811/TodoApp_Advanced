import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../model/folder.dart';

class FolderTaskScreen extends StatelessWidget {
  final Folder folder;

  const FolderTaskScreen({Key? key, required this.folder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: AppBar(
        backgroundColor: tdBGColor,
        title: Text('${folder.folderName} Details'),
      ),
      body: folder.todos.isEmpty
          ? const Center(
        child: Text(
          'No tasks in this folder!',
          style: TextStyle(
            color: tdTextSecondary,
          ),
        ),
      )
          : ListView.builder(
        itemCount: folder.todos.length,
        itemBuilder: (context, index) {
          final todo = folder.todos[index];
          return Card(
            child: ListTile(
              title: Text(
                todo.todoText ?? 'Unnamed Task',
                style: TextStyle(
                  decoration:
                  todo.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: Icon(
                todo.isDone
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
              ),
            ),
          );
        },
      ),
    );
  }
}
