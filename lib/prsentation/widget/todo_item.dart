import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../model/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function OnToDoChanged;
  final Function OnDeleteItem;
  final Function OnSelectItem;
  final Function OnUpdateItem;

  const TodoItem({
    Key? key,
    required this.todo,
    required this.OnToDoChanged,
    required this.OnDeleteItem,
    required this.OnSelectItem,
    required this.OnUpdateItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () => OnToDoChanged(todo),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        tileColor: Color(0xFFF5F5F5),  // Light gray background for a clean look
        leading: Icon(
          todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: todo.isDone ? tdGreen : tdGrey, // Green if completed, grey otherwise
        ),
        title: Text(
          todo.todoText,
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF212121),  // Darker text color for readability
            fontWeight: FontWeight.bold,  // Bold title for better visibility
            decoration: todo.isDone ? TextDecoration.lineThrough : null, // Strike-through if done
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the time added in a formatted way
            Text(
              'Created on: ${_formatDate(todo.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: Color(0xFFE53935),  // Red background color for the delete button
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
            color: Colors.white,
            iconSize: 18,
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),  // Show delete confirmation dialog
          ),
        ),
      ),
    );
  }

  // Function to format the DateTime into a readable string
  String _formatDate(DateTime dateTime) {
    // Format the date to a string like "12:30 PM, Oct 10, 2024"
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour < 12 ? 'AM' : 'PM'}, ${dateTime.month}/${dateTime.day}/${dateTime.year}";
  }

  // Function to show delete confirmation dialog
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Todo'),
          content: Text('Are you sure you want to delete this todo item?'),
          actions: [
            TextButton(
              onPressed: () {
                OnDeleteItem(todo.id);  // Delete the todo if confirmed
                Navigator.pop(context);  // Close the dialog
              },
              child: Text('Yes', style: TextStyle(color: tdBlue)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),  // Close dialog without deleting
              child: Text('No', style: TextStyle(color: tdBlue)),
            ),
          ],
        );
      },
    );
  }
}
