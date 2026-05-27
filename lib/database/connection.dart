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

    return await MySqlConnection.connect(settings);
  }
}
