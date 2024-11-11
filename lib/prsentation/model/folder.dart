class Folder {
  final String id;
  String folderName; // Remove 'late final' to make it mutable

  final DateTime creationDate;
  final List<dynamic> todos;

  Folder({
    required this.id,
    required this.folderName, // Initialize directly with a required parameter
    required this.creationDate,
    required this.todos,
  });

  static List<Folder> folderList() {
    return [
      Folder(
        id: '1',
        folderName: 'Folder 1',
        creationDate: DateTime.now(),
        todos: [],
      ),
    ];
  }
}
