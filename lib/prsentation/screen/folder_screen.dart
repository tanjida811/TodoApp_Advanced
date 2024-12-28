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
  List<Folder> deletedFolderList = [];
  final TextEditingController _folderController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _folderController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final folderData = prefs.getString('folders');
    final deletedData = prefs.getString('deleted_folders');

    if (folderData != null) {
      setState(() {
        final List<dynamic> decodedData = jsonDecode(folderData);
        folderList = decodedData.map((data) => Folder.fromJson(data)).toList();
      });
    }

    if (deletedData != null) {
      setState(() {
        final List<dynamic> decodedData = jsonDecode(deletedData);
        deletedFolderList = decodedData.map((data) => Folder.fromJson(data)).toList();
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('folders', jsonEncode(folderList.map((folder) => folder.toJson()).toList()));
    prefs.setString('deleted_folders', jsonEncode(deletedFolderList.map((folder) => folder.toJson()).toList()));
  }

  void _addFolder(String name) {
    if (name.isEmpty) return;

    setState(() {
      folderList.insert(0, Folder(
        id: DateTime.now().toString(),
        folderName: name,
        creationDate: DateTime.now(),
      ));
    });

    _saveData();
    _folderController.clear();
  }

  void _renameFolder(String id, String newName) {
    setState(() {
      final folder = folderList.firstWhere((folder) => folder.id == id);
      folder.folderName = newName;
      folder.modifiedDate = DateTime.now(); // Update modifiedDate only
    });

    _saveData();
  }

  void _deleteFolder(String folderId) {
    final folder = folderList.firstWhere((folder) => folder.id == folderId);
    setState(() {
      folderList.removeWhere((folder) => folder.id == folderId);
      deletedFolderList.add(folder);
    });

    _saveData();
  }

  void _restoreFolder(String folderId) {
    final folder = deletedFolderList.firstWhere((folder) => folder.id == folderId);
    setState(() {
      deletedFolderList.removeWhere((folder) => folder.id == folderId);
      folderList.add(folder);
    });

    _saveData();
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

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deleted Folders', style: TextStyle(fontWeight: FontWeight.bold)),
          content: deletedFolderList.isEmpty
              ? const Text('No folders in history.', style: TextStyle(color: tdTextSecondary))
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: deletedFolderList.map((folder) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                color: tdSurfaceColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  title: Text(folder.folderName ?? 'No Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Deleted on: ${folder.modifiedDate?.toLocal()}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore, color: tdPrimaryColor),
                    onPressed: () {
                      _restoreFolder(folder.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detect screen width and adjust accordingly
    double screenWidth = MediaQuery.of(context).size.width;

    // Define if the screen is for mobile, tablet, or desktop (based on width)
    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 1200;
    bool isDesktop = screenWidth >= 1200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders', style: TextStyle(color: tdTextPrimary)),
        backgroundColor: tdSurfaceColor,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: tdTextPrimary),
          onPressed: () {
            _showUserMenu(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 25),
            onPressed: () async {
              showSearch(
                context: context,
                delegate: GlobalSearchDelegate<Folder>(
                  items: folderList,
                  itemNameGetter: (folder) => folder.folderName ?? '',
                  itemBuilder: (folder) => ListTile(
                    title: Text(folder.folderName!),
                    subtitle: Text('Created on: ${DateTime.now().toLocal()}'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: tdPrimaryColor),
            onPressed: _showHistory,
          ),
          const SizedBox(width: 10), // Add spacing for the avatar
          CircleAvatar(
            backgroundColor: tdSecondaryColor,
            child: const Text('T', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10), // Additional spacing for better layout
        ],
      ),
      body: folderList.isEmpty
          ? const Center(child: Text('No folders available.'))
          : ListView.builder(
        itemCount: folderList.length,
        itemBuilder: (context, index) {
          final folder = folderList[index];
          return GestureDetector(
            onDoubleTap: () => _showRenameFolderDialog(folder.id, folder.folderName ?? 'No Name'),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: tdBorderColor),
              ),
              shadowColor: Colors.black.withOpacity(0.1),
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
        child: const Icon(Icons.create_new_folder_rounded, color: tdBGColor, size: 30),
        backgroundColor: tdSecondaryColor,
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              leading: Icon(Icons.person, color: tdTextPrimary),
              title: Text('Profile', style: TextStyle(color: tdTextPrimary)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: tdTextPrimary),
              title: Text('Notifications', style: TextStyle(color: tdTextPrimary)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: tdTextPrimary),
              title: Text('Settings', style: TextStyle(color: tdTextPrimary)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
