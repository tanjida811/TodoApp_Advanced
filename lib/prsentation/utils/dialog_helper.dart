import 'package:flutter/material.dart';

import '../constants/color.dart';
import '../model/todo.dart';

class Dialog_Helper {
  // Delete Todo dialog
  static Future<void> showDeleteDialog(
      BuildContext context, Todo todo, Function(String) onDeleteTodo) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: tdSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete Todo',
            style: TextStyle(
              color: tdPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this todo item?',
            style: TextStyle(
              color: tdTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                onDeleteTodo(todo.id);
                Navigator.pop(context);
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: tdErrorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'No',
                style: TextStyle(
                  color: tdSuccessColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Rename Todo dialog
  static Future<void> showRenameDialog(
      BuildContext context, Todo todo, Function(String) onRenameTodo) {
    final TextEditingController _textController =
    TextEditingController(text: todo.todoText);


    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: tdSurfaceColor,
          title: Text(
            'Rename Todo',
            style: TextStyle(
              color: tdPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'Todo Name',
              labelStyle: TextStyle(color: tdPrimaryColor),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: tdPrimaryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: tdBorderColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: tdErrorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final todoName = _textController.text.trim();
                if (todoName.isNotEmpty) {
                  onRenameTodo(todoName);
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Rename',
                style: TextStyle(
                  color: tdPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
