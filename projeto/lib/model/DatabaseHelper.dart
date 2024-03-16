import 'package:projeto/model/RouteEntity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'routes.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE routes (
        id INTEGER PRIMARY KEY,
        title TEXT,
        start_latitude REAL,
        start_longitude REAL,
        end_latitude REAL,
        end_longitude REAL
      )
    ''');
  }

  Future<int> insertRoute(RouteEntity route) async {
    Database db = await instance.database;
    return await db.insert('routes', route.toMap());
  }

  Future<RouteEntity?> getRouteById(int id) async {
  Database db = await instance.database;
  List<Map<String, dynamic>> maps = await db.query(
    'routes',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return RouteEntity(
      id: maps[0]['id'],
      title: maps[0]['title'],
      startLatitude: maps[0]['start_latitude'],
      startLongitude: maps[0]['start_longitude'],
      endLatitude: maps[0]['end_latitude'],
      endLongitude: maps[0]['end_longitude'],
    );
  } else {
    return null; // Retorna null se a rota não for encontrada
  }
}

  Future<List<RouteEntity>> getAllRoutes() async {
  Database db = await instance.database;
  List<Map<String, dynamic>> maps = await db.query('routes');
  return List.generate(maps.length, (i) {
    return RouteEntity(
      id: maps[i]['id'],
      title: maps[i]['title'],
      startLatitude: maps[i]['start_latitude'],
      startLongitude: maps[i]['start_longitude'],
      endLatitude: maps[i]['end_latitude'],
      endLongitude: maps[i]['end_longitude'],
    );
  });
}

Future<int> updateRoute(RouteEntity route) async {
  Database db = await instance.database;
  return await db.update(
    'routes',
    route.toMap(),
    where: 'id = ?',
    whereArgs: [route.id],
  );
}

Future<void> deleteRoute(int? id) async {
  Database db = await instance.database;
  await db.delete(
    'routes',
    where: 'id = ?',
    whereArgs: [id],
  );
}
}