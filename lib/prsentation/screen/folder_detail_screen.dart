import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/color.dart';
import '../model/folder.dart';
import '../utils/dialoghelper.dart';
import '../widget/folder_item.dart';
import 'home_screen.dart';

class FolderDetailScreen extends StatefulWidget {
  final String folderName;
  final String creationDate;

  const FolderDetailScreen({
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
  final TextEditingController _folderController = TextEditingController();
  String _searchCriteria = 'Name';

  @override
  void initState() {
    super.initState();
    _loadFolders(); // Load saved folders
  }

  // Load folder data from SharedPreferences
  Future<void> _loadFolders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? folderNames = prefs.getStringList('folderNames');
    setState(() {
      _foundFolders = folderNames != null
          ? folderNames.map((name) => Folder(
        id: DateTime.now().toString(),
        folderName: name,
        creationDate: DateTime.now(),
        todos: [],
      )).toList()
          : folderList;
    });
  }

  // Save folder data to SharedPreferences
  Future<void> _saveFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final folderNames = _foundFolders.map((folder) => folder.folderName ?? '').toList();
    await prefs.setStringList('folderNames', folderNames);
  }

  @override
  void dispose() {
    _folderController.dispose();
    super.dispose();
  }

  // Filter folders based on search criteria
  void _runFilter(String enteredKeyword) {
    setState(() {
      _foundFolders = enteredKeyword.isEmpty
          ? folderList
          : folderList.where((item) {
        if (_searchCriteria == 'Name') {
          return item.folderName!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase());
        } else {
          final formattedDate =
              "${item.creationDate.day}-${item.creationDate.month}-${item.creationDate.year}";
          return formattedDate.contains(enteredKeyword);
        }
      }).toList();
    });
  }

  // Add a new folder
  void _addNewFolder(String folderName) {
    if (folderName.isNotEmpty) {
      setState(() {
        _foundFolders.insert(
          0,
          Folder(
            id: DateTime.now().toString(),
            folderName: folderName,
            creationDate: DateTime.now(),
            todos: [],
          ),
        );
        _saveFolders();
      });
    }
  }

  // Dialog for adding or renaming a folder
  Future<void> _showFolderDialog({
    required String title,
    required String buttonText,
    required Function(String) onSubmit,
    String initialText = '',
  }) async {
    final TextEditingController folderNameController =
    TextEditingController(text: initialText);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tdSurfaceColor,
        title: Text(
          title,
          style: const TextStyle(
            color: tdPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: folderNameController,
          decoration: InputDecoration(
            labelText: 'Folder Name',
            labelStyle: const TextStyle(color: tdPrimaryColor),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: tdPrimaryColor),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: tdBorderColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
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
              onSubmit(folderName);
              Navigator.of(context).pop();
            },
            child: Text(
              buttonText,
              style: const TextStyle(
                color: tdPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFolderList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFolderDialog(
          title: 'Add New Folder',
          buttonText: 'Add',
          onSubmit: _addNewFolder,
        ),
        tooltip: 'Add Folder',
        backgroundColor: tdSecondaryColor,
        child: const Icon(Icons.create_new_folder, color: Colors.white),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.menu, color: tdBackgroundColor, size: 30),
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage("assets/profile.jpeg"),
          ),
        ],
      ),
    );
  }

  Padding _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _searchCriteria,
            icon: const Icon(Icons.arrow_downward),
            onChanged: (String? newValue) {
              setState(() {
                _searchCriteria = newValue!;
              });
            },
            items: ['Name', 'Date']
                .map((value) => DropdownMenuItem(
              value: value,
              child: Text(value),
            ))
                .toList(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _folderController,
              onChanged: _runFilter,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: tdBackgroundColor),
                hintText: 'Search folders by $_searchCriteria',
                filled: true,
                fillColor: tdSurfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildFolderList() {
    return Expanded(
      child: _foundFolders.isEmpty
          ? const Center(child: Text('No folders found.'))
          : ListView.builder(
        itemCount: _foundFolders.length,
        itemBuilder: (context, index) {
          final folder = _foundFolders[index];
          return GestureDetector(
            onDoubleTap: () => DialogHelper.showRenameDialog(
              context,
              folder,
                  (newName) {
                setState(() {
                  folder.folderName = newName;
                  _saveFolders();
                });
              },
            ),
            child: FolderItem(
              folder: folder,
              onFolderChanged: (folder) => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
              onDeleteFolder: (folderId) {
                setState(() {
                  _foundFolders.removeWhere(
                        (folder) => folder.id == folderId,
                  );
                  _saveFolders();
                });
              },
            ),
          );
        },
      ),
    );
  }
}
