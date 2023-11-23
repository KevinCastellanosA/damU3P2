import 'package:cloud_firestore/cloud_firestore.dart';

var baseRemota = FirebaseFirestore.instance;

class DB{
  static Future insertar(Map<String, dynamic> persona) async {
    return await baseRemota.collection("HistorialMascotas").add(persona);
  }

  static Future <List> mostrarTodos() async {
    List temporal = [];
    var query = await baseRemota.collection("HistorialMascotas").get();

    query.docs.forEach((element) {
      Map<String, dynamic> dataTemp = element.data();
      dataTemp.addAll({'id': element.id});
      temporal.add(dataTemp);
    });
    return temporal;
  }

  static Future eliminar (String id) async{
    return await baseRemota.collection("HistorialMascotas").doc(id).delete();
  }

  static Future actualizar (Map<String, dynamic> persona) async{
    String idActualizar = persona['id'];
    persona.remove('id');
    return await baseRemota.collection("HistorialMascotas").doc(idActualizar).update(persona);
  }

}
