// lib/services/database_manager.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modele/redacteur.dart';

class DatabaseManager {
  static Database? _database;
  static const String _databaseName = 'redacteurs.db';
  static const int _databaseVersion = 1;

  // Table et colonnes
  static const String tableRedacteurs = 'redacteurs';
  static const String columnId = 'id';
  static const String columnNom = 'nom';
  static const String columnPrenom = 'prenom';
  static const String columnEmail = 'email';

  // Singleton pour éviter les multiples instances
  DatabaseManager._privateConstructor();
  static final DatabaseManager instance = DatabaseManager._privateConstructor();

  // Getter pour la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialisation de la base de données
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Création de la table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableRedacteurs (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNom TEXT NOT NULL,
        $columnPrenom TEXT NOT NULL,
        $columnEmail TEXT NOT NULL
      )
    ''');
  }

  // Récupérer tous les rédacteurs
  Future<List<Redacteur>> getAllRedacteurs() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(tableRedacteurs);
    return List.generate(maps.length, (i) {
      return Redacteur.fromMap(maps[i]);
    });
  }

  // Insérer un rédacteur
  Future<int> insertRedacteur(Redacteur redacteur) async {
    Database db = await instance.database;
    return await db.insert(tableRedacteurs, redacteur.toMap());
  }

  // Mettre à jour un rédacteur
  Future<int> updateRedacteur(Redacteur redacteur) async {
    Database db = await instance.database;
    return await db.update(
      tableRedacteurs,
      redacteur.toMap(),
      where: '$columnId = ?',
      whereArgs: [redacteur.id],
    );
  }

  // Supprimer un rédacteur
  Future<int> deleteRedacteur(int id) async {
    Database db = await instance.database;
    return await db.delete(
      tableRedacteurs,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Fermer la base de données
  Future<void> close() async {
    Database db = await instance.database;
    db.close();
  }
}