import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        email TEXT UNIQUE,
        password TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      date TEXT,
      start_time TEXT,
      end_time TEXT
      )
    ''');
  }

  // User operations
  Future<int> insertUser(String email, String password) async {
    final db = await database;
    return await db.insert(
      'users',
      {'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Task operations
  Future<int> insertTask(String title, String description, DateTime date) async {
    try {
      final db = await database;
      await _createTables(db); // Ensure the table exists before inserting
      return await db.insert(
        'tasks',
        {
          'title': title,
          'description': description,
          'date': date.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting task: $e');
      return -1; // Return -1 to indicate failure
    }
  }

  Future<List<Map<String, dynamic>>> getTasksForDate(DateTime date) async {
    try {
      final db = await database;
      await _createTables(db); // Ensure the table exists before querying
      String dateString = date.toIso8601String().split('T')[0];
      return await db.query(
        'tasks',
        where: 'date LIKE ?',
        whereArgs: ['$dateString%'],
      );
    } catch (e) {
      print('Error getting tasks: $e');
      return []; // Return an empty list in case of error
    }
  }

  Future<int> updateTask(int id, String title, String description, DateTime date) async {
    final db = await database;
    return await db.update(
      'tasks',
      {
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Helper method to close the database
  Future close() async {
    final db = await database;
    db.close();
  }

  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    await deleteDatabase(path);
    _database = null;
  }
}