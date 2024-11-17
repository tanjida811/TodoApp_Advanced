import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../model/folder.dart';

class DialogHelper {
  // Delete folder dialog
  static Future<void> showDeleteDialog(
      BuildContext context, Folder folder, Function onDeleteFolder) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: tdSurfaceColor,
          title: Text(
            'Delete Folder',
            style: TextStyle(
              color: tdPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this folder?',
            style: TextStyle(
              color: tdTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                onDeleteFolder(folder.id);
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

  // Rename folder dialog
  static Future<void> showRenameDialog(
      BuildContext context, Folder folder, Function(String) onRenameFolder) {
    final TextEditingController folderNameController =
    TextEditingController(text: folder.folderName);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: tdSurfaceColor,
          title: Text(
            'Rename Folder',
            style: TextStyle(
              color: tdPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(
              labelText: 'Folder Name',
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
                final folderName = folderNameController.text.trim();
                if (folderName.isNotEmpty) {
                  onRenameFolder(folderName);
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
