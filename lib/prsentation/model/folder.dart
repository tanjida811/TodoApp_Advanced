

class Folder {
  String id;
  String? folderName;
  DateTime creationDate;
  List<Todo> todos;  // Assuming Task is a model that holds task details

  Folder({
    required this.id,
    this.folderName,
    required this.creationDate,
    required this.todos,
  });

  // Method to generate a list of folders, modify if needed
  static List<Folder> folderList() {
    return [
      Folder(
        id: '1',
        folderName: 'Personal',
        creationDate: DateTime.now(),
        todos: [
          Todo(title: 'Buy groceries'),
          Todo(title: 'Do laundry'),
        ],
      ),
      // Add other folders
    ];
  }
}

class Todo {
  String title;

  Todo({required this.title});
}
