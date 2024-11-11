// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../model/todo.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._init();
//   static Database? _database;
//
//   DatabaseHelper._init();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('todo.db');
//     return _database!;
//   }
//
//   Future<Database> _initDB(String path) async {
//     final dbPath = await getDatabasesPath();
//     final fullPath = join(dbPath, path);
//     return await openDatabase(fullPath, version: 1, onCreate: _onCreate);
//   }
//
//   Future _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE todos(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         todoText TEXT NOT NULL,
//         isDone INTEGER NOT NULL
//       )
//     ''');
//   }
//
//   Future<void> insertTodo(Todo todo) async {
//     final db = await instance.database;
//     await db.insert('todos', todo.toMap());
//   }
//
//   Future<List<Todo>> fetchTodos() async {
//     final db = await instance.database;
//     final result = await db.query('todos');
//     return result.map((json) => Todo.fromMap(json)).toList();
//   }
//
//   Future<void> updateTodoStatus(Todo todo) async {
//     final db = await instance.database;
//     await db.update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
//   }
//
//   Future<void> deleteTodo(int id) async {
//     final db = await instance.database;
//     await db.delete('todos', where: 'id = ?', whereArgs: [id]);
//   }
// }
