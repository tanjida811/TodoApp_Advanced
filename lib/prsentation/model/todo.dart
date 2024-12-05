class Todo {
  String id;
  String todoText;
  DateTime createdAt;
  bool isDone;

  Todo({
    required this.id,
    required this.todoText,
    required this.createdAt,
    this.isDone = false,
  });

  // Convert Todo to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'createdAt': createdAt.toIso8601String(),
      'isDone': isDone,
    };
  }

  // Create Todo from JSON
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      todoText: json['todoText'],
      createdAt: DateTime.parse(json['createdAt']),
      isDone: json['isDone'],
    );
  }
}
