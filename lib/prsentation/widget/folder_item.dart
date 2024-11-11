import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import to format the date
import '../constants/color.dart';  // Import your custom color constants
import '../model/folder.dart';

class FolderItem extends StatelessWidget {
  final Folder folder;
  final Function onFolderChanged;
  final Function onDeleteFolder;

  const FolderItem({
    Key? key,
    required this.folder,
    required this.onFolderChanged,
    required this.onDeleteFolder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the creation date
    String formattedDate = DateFormat.yMMMd().format(folder.creationDate);

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () => onFolderChanged(folder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        tileColor: Color(0xFFF5F5F5),  // Light gray background for a clean look
        leading: Icon(
          Icons.folder,
          color: Color(0xFF2196F3),  // Folder icon color (blue shade)
        ),
        title: Text(
          folder.folderName,
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF212121),  // Darker text color for readability
            fontWeight: FontWeight.bold,  // Bold title for better visibility
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adds space between description and date
            Text(
              'Created on: $formattedDate', // Shows the formatted date
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),  // Lighter gray for subtitle
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

  // Function to show delete confirmation dialog
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Folder'),
          content: Text('Are you sure you want to delete this folder?'),
          actions: [
            TextButton(
              onPressed: () {
                onDeleteFolder(folder.id);  // Delete the folder if confirmed
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
