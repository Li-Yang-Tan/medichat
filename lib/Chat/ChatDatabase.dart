import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChatDatabase {
  static final ChatDatabase instance = ChatDatabase._init();
  static Database? _database;

  ChatDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chat.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender TEXT,
        message TEXT
      )
    ''');
  }

  Future<int> insertMessage(String sender, String message) async {
    final db = await instance.database;
    return await db.insert(
      'messages',
      {'sender': sender, 'message': message},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, String>>> getMessages() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('messages');

    return maps.map((m) => {
      "sender": m["sender"] as String,  // Explicitly cast as String
      "message": m["message"] as String // Explicitly cast as String
    }).toList();
  }

  Future<void> clearMessages() async {
    final db = await instance.database;
    await db.delete('messages');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
