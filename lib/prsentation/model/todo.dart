class Todo {
  String id;
  String todoText;
  bool isDone;
  bool isSelected;
  DateTime createdAt;

  Todo({
    required this.id,
    required this.todoText,
    required this.isDone,
    required this.isSelected,
    required this.createdAt,
  });

  // Convert Todo to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'isDone': isDone,
      'isSelected': isSelected,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert JSON to Todo
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      todoText: json['todoText'],
      isDone: json['isDone'],
      isSelected: json['isSelected'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Helper method for testing purposes
  static List<Todo> todoList() {
    return [
      Todo(
        id: '1',
        todoText: 'Learn Flutter',
        isDone: false,
        isSelected: false,
        createdAt: DateTime.now(),
      ),
      Todo(
        id: '2',
        todoText: 'Learn Dart',
        isDone: true,
        isSelected: true,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  }
}
