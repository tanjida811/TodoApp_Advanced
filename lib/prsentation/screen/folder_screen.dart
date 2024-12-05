import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/folder.dart';
import '../constants/color.dart';
import '../utils/dialoghelper.dart';
import '../utils/global_search_deleget.dart';
import '../widget/folder_item.dart';


class FolderPage extends StatefulWidget {
  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  List<Folder> folderList = [];
  List<Folder> deletedFolderList = []; // To track deleted folders
  final TextEditingController _folderController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFolders();
    _loadDeletedFolders(); // Load deleted folders from SharedPreferences
  }

  @override
  void dispose() {
    _folderController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Save folders to SharedPreferences
  Future<void> _saveFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final folderData = folderList.map((folder) => folder.toJson()).toList();
    prefs.setString('folders', jsonEncode(folderData));
  }

  // Save deleted folders to SharedPreferences
  Future<void> _saveDeletedFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedData = deletedFolderList.map((folder) => folder.toJson()).toList();
    prefs.setString('deleted_folders', jsonEncode(deletedData));
  }

  // Load folders from SharedPreferences
  Future<void> _loadFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final folderData = prefs.getString('folders');
    if (folderData != null) {
      setState(() {
        final List<dynamic> decodedData = jsonDecode(folderData);
        folderList = decodedData.map((data) => Folder.fromJson(data)).toList();
      });
    }
  }

  // Load deleted folders from SharedPreferences
  Future<void> _loadDeletedFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedData = prefs.getString('deleted_folders');
    if (deletedData != null) {
      setState(() {
        final List<dynamic> decodedData = jsonDecode(deletedData);
        deletedFolderList = decodedData.map((data) => Folder.fromJson(data)).toList();
      });
    }
  }


  void _addFolder(String name) {
    if (name.isEmpty) return;

    setState(() {
      folderList.insert(0, Folder( // Insert the new folder at the top
        id: DateTime.now().toString(),
        folderName: name,
        creationDate: DateTime.now(),
      ));
    });

    _saveFolders();
    _folderController.clear();
  }

  void _renameFolder(String id, String newName) {
    setState(() {
      final folder = folderList.firstWhere((folder) => folder.id == id);
      folder.folderName = newName;
    });

    _saveFolders();
  }

  void _deleteFolder(String folderId) {
    final folder = folderList.firstWhere((folder) => folder.id == folderId);
    setState(() {
      folderList.removeWhere((folder) => folder.id == folderId);
      deletedFolderList.add(folder); // Add to deleted history
    });

    _saveFolders();
    _saveDeletedFolders();
  }

  void _restoreFolder(String folderId) {
    final folder = deletedFolderList.firstWhere((folder) => folder.id == folderId);
    setState(() {
      deletedFolderList.removeWhere((folder) => folder.id == folderId);
      folderList.add(folder); // Restore the folder
    });

    _saveFolders();
    _saveDeletedFolders();
  }

  Future<void> _showAddFolderDialog() async {
    await DialogHelper.showInputDialog(
      context: context,
      title: 'Add Folder',
      hintText: 'Enter folder name',
      initialValue: '',
      onConfirm: (input) => _addFolder(input),
    );
  }

  Future<void> _showRenameFolderDialog(String id, String currentName) async {
    await DialogHelper.showInputDialog(
      context: context,
      title: 'Rename Folder',
      hintText: 'Enter new folder name',
      initialValue: currentName,
      onConfirm: (input) => _renameFolder(id, input),
    );
  }


  // Show the history (deleted folders)
  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deleted Folders'),
          content: deletedFolderList.isEmpty
              ? const Text('No folders in history.')
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: deletedFolderList.map((folder) {
              return ListTile(
                title: Text(folder.folderName ?? 'No Name'),
                trailing: IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () {
                    _restoreFolder(folder.id);
                    Navigator.pop(context); // Close dialog after restoring
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders', style: TextStyle(color: tdTextPrimary)),
        backgroundColor: tdBGColor,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: tdPrimaryColor),
          onPressed: () {
            // Handle sign-in or sign-out
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              showSearch(
                context: context,
                delegate: GlobalSearchDelegate<Folder>(
                  items: folderList,
                  itemNameGetter: (folder) => folder.folderName ?? '',
                  itemBuilder: (folder) => ListTile(
                    title: Text(folder.folderName!),
                    onTap: () {
                      // Navigate or perform actions on folder
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.history, color: tdPrimaryColor), // History icon
            onPressed: _showHistory, // Show deleted folders history
          ),
          CircleAvatar(
            backgroundColor: tdSecondaryColor,
            child: const Text('T', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: folderList.isEmpty
          ? const Center(child: Text('No folders available.'))
          : ListView.builder(
        itemCount: folderList.length,
        itemBuilder: (context, index) {
          final folder = folderList[index];
          return GestureDetector(
            onDoubleTap: () => _showRenameFolderDialog(folder.id, folder.folderName ?? 'No Name'), // Double-tap to rename
            child: Card(  // Wrapping FolderItem in a Card widget
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),  // Increased vertical margin for clean spacing
              elevation: 8,  // Adding more elevation for a sophisticated look
              shape: RoundedRectangleBorder(  // Rounded corners for the Card
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: Colors.black.withOpacity(0.1),  // Subtle shadow effect
              child: FolderItem(
                folder: folder,
                onDeleteFolder: (folderId) => _deleteFolder(folderId),
                onRenameFolder: () => _showRenameFolderDialog(folder.id, folder.folderName ?? 'No Name'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFolderDialog,
        child: const Icon(Icons.add, color: tdBGColor, size: 30),
        backgroundColor: tdSecondaryColor,
      ),


    );
  }
}
