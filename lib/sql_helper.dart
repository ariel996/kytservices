import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE clients(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    names TEXT NOT NULL,
    decoder_number TEXT NOT NULL UNIQUE,
    location TEXT NULL,
    telephone TEXT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
        'kyt_services.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
          await createTables(database);
      }
    );
  }

  // create new client
  static Future<int> createClient(String names, String decoder_number,
      String? location, String? telephone) async {
    final db = await SQLHelper.db();

    final data = {'names': names, 'decoder_number': decoder_number, 'location': location,
    'telephone': telephone};
    final id = await db.insert('clients', data,
    conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // read all clients
  static Future<List<Map<String, dynamic>>> getClients() async {
    final db = await SQLHelper.db();
    return db.query('clients', orderBy: "id");
  }

  // Read a single client
  static Future<List<Map<String, dynamic>>> getClient(int id) async {
    final db = await SQLHelper.db();
    return db.query('clients', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // update a client by id
  static Future<int> updateClient(
      int id, String names, String decoder_number, String? location, String? telephone
      ) async {
    final db = await SQLHelper.db();
    final data = {
      'names': names,
      'decoder_number': decoder_number,
      'location': location,
      'telephone': telephone,
      'createdAt': DateTime.now().toString()
    };
    final result = await db.update('clients', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // delete a client
  static Future<void> deleteClient(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('clients', where: "id = ?", whereArgs: [id]);
    } catch(err) {
      print("Une erreur est survenue lors de la suppression de ce client...");
    }
  }
}