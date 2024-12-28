import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/color.dart';
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
    // Get the screen width to apply responsiveness
    double screenWidth = MediaQuery.of(context).size.width;

    // Determine if the screen is wider (PC) or smaller (Mobile)
    bool isWideScreen = screenWidth > 600;

    // Adjust sizes based on screen width
    double iconSize = isWideScreen ? 40 : 30; // Larger icon for wide screens
    double fontSize = isWideScreen ? 18 : 16; // Larger font for wide screens
    double padding = isWideScreen ? 16 : 12; // More padding for larger screens

    // Limit folder name to 20 characters
    String folderName = folder.folderName ?? 'No Name';
    if (folderName.length > 20) {
      folderName = folderName.substring(0, 20); // Restrict to 20 characters
    }

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
      leading: Icon(
        Icons.folder,
        color: tdSecondaryColor,
        size: iconSize, // Adjusted icon size
      ),
      title: Text(
        folderName,
        style: TextStyle(
          fontSize: fontSize, // Adjusted font size
          color: tdTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis, // Auto-adjust for long names
        maxLines: 1, // Restrict to a single line
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4), // Adjust spacing for subtitle
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Created: ${DateFormat('yyyy-MM-dd').format(folder.creationDate)}',
              style: TextStyle(
                fontSize: fontSize * 0.9, // Slightly smaller font for the subtitle
                color: tdTextSecondary,
              ),
            ),
            if (folder.modifiedDate != null) ...[
              SizedBox(height: 4),
              Text(
                'Modified: ${DateFormat('yyyy-MM-dd').format(folder.modifiedDate!)}',
                style: TextStyle(
                  fontSize: fontSize * 0.9, // Slightly smaller font for the subtitle
                  color: tdTextSecondary,
                ),
              ),
            ]
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: tdErrorColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.delete,
                color: tdBGColor,
                size: 25,
              ),
              padding: EdgeInsets.zero,
              onPressed: () {
                DialogHelper.showConfirmationDialog(
                  context: context,
                  title: 'Delete Folder',
                  message: 'Are you sure you want to delete this folder?',
                  onConfirm: () {
                    onDeleteFolder(folder.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
