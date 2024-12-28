class Todo {
  String id;
  String todoText;
  DateTime createdAt;
  DateTime? completedAt;
  bool isDone;

  Todo({
    required this.id,
    required this.todoText,
    required this.createdAt,
    this.completedAt,
    this.isDone = false,
  });

  // Convert Todo to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(), // Serialize completedAt
      'isDone': isDone,
    };
  }

  // Create Todo from JSON
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      todoText: json['todoText'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      isDone: json['isDone'],
    );
  }
}
