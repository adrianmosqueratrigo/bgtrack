import 'package:mysql1/mysql1.dart';

class DatabaseConnection {
  static Future<MySqlConnection> getConnection() async {
    final settings = ConnectionSettings(
      host: '10.0.2.2',
      port: 3306,
      user: 'bgtrack',
      password: 'bgtrack',
      db: 'bgtrack',
    );

    final conexion = await MySqlConnection.connect(settings);

    await conexion.query('SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci');

    return conexion;
  }
}
