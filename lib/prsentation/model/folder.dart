import '../screen/historymanager.dart';
import 'historyitem.dart';
import 'todo.dart';

class Folder {
  String id;
  String? folderName;
  DateTime creationDate;
  List<Todo> todos;

  Folder({
    required this.id,
    this.folderName,
    required this.creationDate,
    required this.todos,
  });

  static List<Folder> folderList = [];

  static void initializeFolders() {
    folderList.add(Folder(
      id: '1',
      folderName: 'Shopping',
      creationDate: DateTime.now(),
      todos: [],
    ));
    folderList.add(Folder(
      id: '2',
      folderName: 'Entertainment',
      creationDate: DateTime.now(),
      todos: [],
    ));
  }
  static void deleteFolder(Folder folder) {
    HistoryItem historyItem = HistoryItem(
      id: folder.id,
      actionType: 'deleted',
      actionDate: DateTime.now(),
      todo: null,  // No todo to restore, just folder info
    );
    HistoryManager.addHistoryItem(historyItem);
  }
}
