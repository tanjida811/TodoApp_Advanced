import 'package:to_do_app/prsentation/model/todo.dart'; // Assuming Todo model exists

class Folder {
  String id;
  String? folderName;
  DateTime creationDate;
  List<Todo> todos;  // Tasks (Todos) associated with the folder

  Folder({
    required this.id,
    this.folderName,
    required this.creationDate,
    required this.todos,
  });

  // Static list to hold folders
  static List<Folder> folderList = [];

  // Initialize folders with empty tasks
  static void initializeFolders() {
    folderList.add(Folder(
      id: '1',
      folderName: 'Shopping',
      creationDate: DateTime.now(),
      todos: [],  // Empty list of tasks
    ));
    folderList.add(Folder(
      id: '2',
      folderName: 'Entertainment',
      creationDate: DateTime.now(),
      todos: [],  // Empty list of tasks
    ));
  }

  // fromJson method for deserialization
  factory Folder.fromJson(Map<String, dynamic> json) {
    // Assuming 'todos' is a list of Todo objects in the JSON
    return Folder(
      id: json['id'],
      folderName: json['folderName'],
      creationDate: DateTime.parse(json['creationDate']),
      todos: (json['todos'] as List).map((todo) => Todo.fromJson(todo)).toList(),  // Deserialize Todo objects
    );
  }

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folderName': folderName,
      'creationDate': creationDate.toIso8601String(),  // Convert DateTime to ISO string
      'todos': todos.map((todo) => todo.toJson()).toList(),  // Serialize Todo objects
    };
  }
}
