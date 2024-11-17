import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../model/todo.dart';

class DialogHelper {
  // Delete Todo dialog
  static Future<void> showDeleteDialog(
      BuildContext context, Todo todo, Function(String) onDeleteTodo) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: tdSurfaceColor,
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
    final TextEditingController todoNameController =
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
            controller: todoNameController,
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
                final todoName = todoNameController.text.trim();
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

  // Rename Todo dialog (simplified version)
  static void showRenameSimpleDialog(
      BuildContext context, String currentName, Function(String) onRename) {
    TextEditingController _controller = TextEditingController(text: currentName);
    showDialog(
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
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'New Todo Name',
              labelStyle: TextStyle(color: tdPrimaryColor),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: tdPrimaryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: tdBorderColor),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
                onRename(_controller.text);
                Navigator.pop(context);
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

  // Delete Todo dialog (simplified version)
  static void showDeleteSimpleDialog(
      BuildContext context, Function() onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: tdSurfaceColor,
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
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
                onDelete();
                Navigator.pop(context);
              },
              child: Text(
                'Delete',
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
