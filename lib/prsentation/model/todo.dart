class Todo {
  final String id;
  late final String todoText;
  final DateTime createdAt;
  bool isDone;
  bool isSelected;

  Todo({
    required this.id,
    required this.todoText,
    required this.createdAt,
    this.isDone = false,
    this.isSelected = false,
  });

  Todo copyWith({
    String? id,
    String? todoText,
    DateTime? createdAt,
    bool? isDone,
    bool? isSelected,
  }) {
    return Todo(
      id: id ?? this.id,
      todoText: todoText ?? this.todoText,
      createdAt: createdAt ?? this.createdAt,
      isDone: isDone ?? this.isDone,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
