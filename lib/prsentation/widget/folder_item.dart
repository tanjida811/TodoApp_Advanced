

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/prsentation/constants/color.dart';

import '../model/folder.dart';
import '../screen/todo_task_page.dart';
import '../utils/dialoghelper.dart';

class FolderItem extends StatelessWidget {
  final Folder folder;
  final Function onRenameFolder;
  final Function onDeleteFolder;

  const FolderItem({
    Key? key,
    required this.folder,
    required this.onRenameFolder,
    required this.onDeleteFolder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TodoTaskPage(folder: folder),
          ),
        );
      },
      tileColor: tdSurfaceColor,
      leading: Icon(Icons.folder, color: tdSecondaryColor),
      title: Text(
        folder.folderName ?? 'No Name',
        style: const TextStyle(
          fontSize: 18,
          color: tdTextPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: tdErrorColor, // Background color (red for delete)
              shape: BoxShape.rectangle, // Circular shape
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Shadow for elevation effect
                  spreadRadius: 2,
                  blurRadius: 4,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.delete, color: tdBGColor), // Delete icon
              onPressed: () {
                DialogHelper.showConfirmationDialog(
                  context: context,
                  title: 'Delete Folder',
                  message: 'Are you sure you want to delete this folder?',
                  onConfirm: ()  {onDeleteFolder(folder.id);
                  },
                );
              }, // Pass the folder ID to the callback
            ),
          ),
        ],
      ),
    );
  }
}
