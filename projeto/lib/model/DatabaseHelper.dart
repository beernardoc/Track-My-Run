import 'dart:io';

import 'package:projeto/model/RouteEntity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';


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
    String path = join(await getDatabasesPath(), 'routes5.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE routes5 (
        id INTEGER PRIMARY KEY,
        title TEXT,
        start_latitude REAL,
        start_longitude REAL,
        end_latitude REAL,
        end_longitude REAL,
        pathfinal TEXT,
        distance REAL,
        imagePath TEXT

      )
    ''');
  }
  Future<int> insertRoute(RouteEntity route) async {
    Database db = await instance.database;
    return await db.insert('routes5', route.toMap());
  }

  Future<RouteEntity?> getRouteById(int id) async {
  Database db = await instance.database;
  List<Map<String, dynamic>> maps = await db.query(
    'routes5',
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
      pathfinal: maps[0]['pathfinal'],
      distance: maps[0]['distance'],
      imagePath: maps[0]['imagePath'],
    );
  } else {
    return null; // Retorna null se a rota não for encontrada
  }
}

  Future<List<RouteEntity>> getAllRoutes() async {
  Database db = await instance.database;
  List<Map<String, dynamic>> maps = await db.query('routes5');
  return List.generate(maps.length, (i) {
    return RouteEntity(
      id: maps[i]['id'],
      title: maps[i]['title'],
      startLatitude: maps[i]['start_latitude'],
      startLongitude: maps[i]['start_longitude'],
      endLatitude: maps[i]['end_latitude'],
      endLongitude: maps[i]['end_longitude'],
      pathfinal: maps[i]['pathfinal'],
      distance: maps[i]['distance'],
      imagePath: maps[i]['imagePath'],
    );
  });
}

Future<int> updateRoute(RouteEntity route) async {
  Database db = await instance.database;
  return await db.update(
    'routes5',
    route.toMap(),
    where: 'id = ?',
    whereArgs: [route.id],
  );
}

Future<void> deleteRoute(int? id) async {
  Database db = await instance.database;
  await db.delete(
    'routes5',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteDatabaseFile() async {
  try {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String dbPath = appDocDir.path + '/routes.db';
    
    File dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
      print('Banco de dados excluído com sucesso.');
    } else {
      print('Banco de dados não encontrado.');
    }
  } catch (e) {
    print('Erro ao excluir o banco de dados: $e');
  }
}
}