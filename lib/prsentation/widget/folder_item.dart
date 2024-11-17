import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/color.dart';
import '../model/folder.dart';
import '../utils/dialoghelper.dart';

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
    String formattedDate =
        DateFormat.yMMMd().format(folder.creationDate ?? DateTime.now());

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () => onFolderChanged(folder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        tileColor: tdSurfaceColor,
        leading: Icon(
          Icons.folder,
          color: tdSecondaryColor,
        ),
        title: Text(
          folder.folderName ?? 'No Name',
          style: TextStyle(
              fontSize: 18, color: tdTextPrimary, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              'Created on: $formattedDate',
              style: TextStyle(fontSize: 12, color: tdTextSecondary),
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
            color: tdSurfaceColor,
            iconSize: 18,
            icon: Icon(Icons.delete),
            onPressed: () =>
                DialogHelper.showDeleteDialog(context, folder, onDeleteFolder),
          ),
        ),
      ),
    );
  }
}
