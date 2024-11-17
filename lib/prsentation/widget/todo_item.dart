import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../model/todo.dart';
import '../utils/dialog_helper.dart';


class TodoItem extends StatefulWidget {
  final Todo todo;
  final Function onToDoChanged;
  final Function onDeleteItem;
  final Function onUpdateItem;
  final void Function(String) onSelectItem;

  const TodoItem({
    Key? key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
    required this.onUpdateItem,
    required this.onSelectItem,
  }) : super(key: key);

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  bool isEditing = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.todo.todoText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () => widget.onToDoChanged(widget.todo),
        onLongPress: () => _showRenameDialog(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        tileColor: tdBGColor,
        leading: Icon(
          widget.todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: widget.todo.isDone ? tdSuccessColor : tdGrey,
        ),
        title: Text(
          widget.todo.todoText,
          style: TextStyle(
            fontSize: 18,
            color: tdTextPrimary,
            fontWeight: FontWeight.bold,
            decoration: widget.todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Created on: ${_formatDate(widget.todo.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: tdTextSecondary,
              ),
            ),
          ],
        ),
        trailing: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: tdErrorColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
            color: Colors.white,
            iconSize: 18,
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    DialogHelper.showDeleteDialog(
      context,
      widget.todo, // Make sure this is a Todo
          (id) => widget.onDeleteItem(id),
    );
  }

  void _showRenameDialog() {
    DialogHelper.showRenameDialog(
      context,
      widget.todo,
          (newText) {
        if (newText.isNotEmpty) {
          widget.onUpdateItem(widget.todo.id, newText);
          setState(() {
            widget.todo.todoText = newText;
          });
        }
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour < 12 ? 'AM' : 'PM'}, ${dateTime.month}/${dateTime.day}/${dateTime.year}";
  }
}
