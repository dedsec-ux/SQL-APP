import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'messages.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('CREATE TABLE messages(id INTEGER PRIMARY KEY, content TEXT)');
    });
  }

  Future<void> insertMessage(String content) async {
    final db = await database;
    await db.insert('messages', {'content': content});
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    final db = await database;
    return await db.query('messages');
  }
}
