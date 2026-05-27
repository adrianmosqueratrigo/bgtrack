import '../database/connection.dart';
import '../models/juego.dart';

class JuegosService {
  Future<List<Juego>> obtenerJuegos() async {
    final conexion = await DatabaseConnection.getConnection();

    final resultados = await conexion.query(
      'SELECT * FROM juegos ORDER BY nombre',
    );

    List<Juego> juegos = [];

    for (var row in resultados) {
      juegos.add(Juego.fromMap(row.fields));
    }

    await conexion.close();

    return juegos;
  }
}