import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import '../constants/color.dart';
import '../model/folder.dart';
import '../widget/folder_item.dart';
import 'home_screen.dart';

class FolderDetailScreen extends StatefulWidget {
  final String folderName;
  final String creationDate;

  FolderDetailScreen({
    Key? key,
    required this.folderName,
    required this.creationDate,
  }) : super(key: key);

  @override
  _FolderDetailScreenState createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  List<Folder> folderList = Folder.folderList();
  List<Folder> _foundFolders = [];
  final _folderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFolders(); // Load saved folders from SharedPreferences
  }

  Future<void> _loadFolders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? folderNames = prefs.getStringList('folderNames');
    if (folderNames != null) {
      setState(() {
        _foundFolders = folderNames.map((name) {
          return Folder(
            id: DateTime.now().toString(),
            folderName: name,
            creationDate: DateTime.now(),
            todos: [],
          );
        }).toList();
      });
    } else {
      setState(() {
        _foundFolders = folderList; // Default folder list if no saved folders
      });
    }
  }

  Future<void> _saveFolders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> folderNames = _foundFolders.map((folder) => folder.folderName).toList();
    await prefs.setStringList('folderNames', folderNames);  // Save folder names
  }

  @override
  void dispose() {
    _folderController.dispose();
    super.dispose();
  }

  void _runFilter(String enteredKeyword) {
    List<Folder> results = enteredKeyword.isEmpty
        ? folderList
        : folderList.where((folder) => folder.folderName
        .toLowerCase()
        .contains(enteredKeyword.toLowerCase()))
        .toList();

    setState(() {
      _foundFolders = results;
    });
  }

  void _showAddFolderDialog() {
    final TextEditingController folderNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Folder', style: TextStyle(color: tdPrimaryColor)),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(
              labelText: 'Folder Name',
              labelStyle: TextStyle(color: tdPrimaryColor),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: tdPrimaryColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: tdPrimaryColor)),
            ),
            TextButton(
              onPressed: () {
                final folderName = folderNameController.text;
                if (folderName.isNotEmpty) {
                  setState(() {
                    _foundFolders.add(Folder(
                      id: DateTime.now().toString(),
                      folderName: folderName,
                      creationDate: DateTime.now(),
                      todos: [],
                    ));
                    _saveFolders();  // Save updated folders list
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add', style: TextStyle(color: tdPrimaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: AppBar(
        backgroundColor: tdBGColor,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.menu, color: tdPrimaryColor, size: 30),
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage("assets/profile.jpeg"),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: tdPrimaryColor),
            onPressed: _showAddFolderDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _folderController,
              onChanged: _runFilter,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: tdPrimaryColor),
                hintText: 'Search for folders',
                filled: true,
                fillColor: tdWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _foundFolders.length,
              itemBuilder: (context, index) {
                final folder = _foundFolders[index];
                return GestureDetector(
                  onDoubleTap: () {
                    _showAddFolderDialog(); // Show edit dialog
                  },
                  child: FolderItem(
                    folder: folder,
                    onFolderChanged: (folder) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                    onDeleteFolder: (folderId) {
                      setState(() {
                        _foundFolders.removeWhere((folder) => folder.id == folderId);
                        _saveFolders();  // Save updated folders list after delete
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
