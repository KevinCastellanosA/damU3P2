import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practica32/baseremota.dart';



class P34 extends StatefulWidget {
  const P34({super.key});

  @override
  State<P34> createState() => _P34State();
}

class _P34State extends State<P34> {
  int _index = 0;
  bool? selectedOption;
  String titulo = "App Historial Mascotas";
  List<String> _dropdownItems = [];

  final fecha = TextEditingController();
  final nombre = TextEditingController();
  final edad = TextEditingController();
  final vacuna = TextEditingController();
  final especie = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String  id = "";
  String  nombreTemp = "";
  String  especieTemp = "";
  String  fechaTemp = "";
  bool? vacunaTemp;
  int     edadTemp = 0;



  void actualizarLista() async {
   
    setState(() {

    });
  }
  void actualizarListaMaterias() async {
    
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    cargarMateriasPorDefecto();
    actualizarLista();
    actualizarListaMaterias();
  }

  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      fecha.text = date.toString();
    });
  }

  void cargarMateriasPorDefecto() async {
    

    setState(() {

    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${titulo}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),
        backgroundColor: Colors.deepPurple,
      ),
      body: dinamico(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.pets_outlined), label: "Lista Mascotas"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline),label: "Añadir Mascota"),
          BottomNavigationBarItem(icon: Icon(Icons.edit),label: "Editar"),
        ],
        currentIndex: _index,
        onTap: (valor){
          setState(() {
            _index = valor;
          });
        },
      ),

    );
  }

  Widget dinamico() {
    switch (_index) {
      case 0:
        return mostrarListaMascotas();
      case 1:
        return anadirMascota();
      case 2:
        return editarMascota();
    }
    return  Column(
      children: [
        Container(
          width: double.infinity ,
          height: 120,
        )
      ],
    );
  }

  Widget mostrarListaMascotas() {
    return FutureBuilder(
      future: DB.mostrarTodos(),
      builder: (context, listaJSON) {
        if (listaJSON.hasData) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: listaJSON.data?.length,
                    itemBuilder: (context, indice) {
                      return Card(
                        elevation: 8,
                        margin: EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "Nombre Mascota: ${listaJSON.data?[indice]['nombreMascota']}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Esta Vacunado: ${listaJSON.data?[indice]['estadoVacunacion']}",
                                  style: TextStyle(fontSize: 14)),
                              Text("Edad de la mascota: ${listaJSON.data?[indice]['edad']}",
                                  style: TextStyle(fontSize: 14)),
                              Text("Especie de la mascota: ${listaJSON.data?[indice]['especie']}",
                                  style: TextStyle(fontSize: 14)),
                              Text("Fecha de consulta: ${_formatFechaConsulta(listaJSON.data?[indice]['fechaConsulta'])}",
                                  style: TextStyle(fontSize: 14))
                            ],
                          ),
                          leading: Container(
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${indice + 1}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Eliminar Materia"),
                                    content: Text("¿Está seguro de eliminar esta materia?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Cancelar"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            DB.eliminar(listaJSON.data?[indice]['id'])
                                                .then((value) {
                                              setState(() {
                                                mostrarSnackBar("SE ELIMINÓ LA MATERIA!");
                                              });
                                              cargarMateriasPorDefecto();
                                              actualizarListaMaterias();
                                            });
                                          });
                                        },
                                        child: Text("Aceptar"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              id = listaJSON.data?[indice]['id'];
                              nombreTemp = listaJSON.data?[indice]['nombreMascota'];
                              fechaTemp = _formatFechaConsulta(listaJSON.data?[indice]['fechaConsulta']);
                              especieTemp = listaJSON.data?[indice]['especie'];
                              edadTemp = listaJSON.data?[indice]['edad'];
                              vacunaTemp = listaJSON.data?[indice]['estadoVacuna'];
                              _index = 2;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  String _formatFechaConsulta(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      String formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      return formattedDate;
    }
    return "Fecha no válida";
  }

  Widget anadirMascota() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: nombre,
            decoration: InputDecoration(
              labelText: "Nombre de la Mascota:",
              prefixIcon: Icon(Icons.pets),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
          SizedBox(height: 6),
          TextField(
            controller: especie,
            decoration: InputDecoration(
              labelText: "Especie:",
              prefixIcon: Icon(Icons.bug_report_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
            ),
          ),
          SizedBox(height: 6),
          TextField(
            controller: edad,
            decoration: InputDecoration(
              labelText: "Edad:",
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 6),
          TextField(
            controller: fecha,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              labelText: "Fecha del Vuelo (dd/mm/aa):",
              prefixIcon: Icon(Icons.date_range),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
          SizedBox(height: 6),
          DropdownButtonFormField(
            value: selectedOption,
            items: [
              DropdownMenuItem(
                child: Text("Vacunado"),
                value: true,
              ),
              DropdownMenuItem(
                child: Text("No Vacunado"),
                value: false,
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedOption = value as bool?;
              });
            },
            decoration: InputDecoration(
              labelText: "Vacunado:",
              prefixIcon: Icon(Icons.local_hospital_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                ),
                onPressed: () {
                  if (selectedOption != null) {
                    if (selectedDate != null) {
                      Timestamp timestamp =
                      Timestamp.fromMillisecondsSinceEpoch(selectedDate!.millisecondsSinceEpoch);

                      var JSonTemporal = {
                        'nombreMascota': nombre.text,
                        'edad': int.parse(edad.text),
                        'especie': especie.text,
                        'estadoVacunacion': selectedOption,
                        'fechaConsulta': timestamp,
                      };

                      DB.insertar(JSonTemporal).then((value) {
                        setState(() {
                          mostrarSnackBar("SE INSERTÓ LA MASCOTA!");
                          _index = 0;
                        });
                      });
                    } else {
                      print("Error: Fecha no seleccionada");
                    }
                  } else {
                    print("Error: selectedOption es nulo");
                  }
                },
                child: Text("Agregar"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30),
                ),
                onPressed: () {
                   _index = 0;
                },
                child: Text("Cancelar"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget editarMascota() {
    return ListView(
      padding: EdgeInsets.all(40),
      children: [
        Text(
          "Mascota a editar: ${nombreTemp}  Especie: ${especieTemp}\nEdad: ${edadTemp}",
          style: TextStyle(
            fontSize:   16,
            color: Colors.purple,
            fontStyle: FontStyle.normal,
          ),
        ),
        SizedBox(height: 6),
        TextField(
          controller: nombre,
          decoration: InputDecoration(
            labelText: "Nombre de la Mascota:",
            prefixIcon: Icon(Icons.pets),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: especie,
          decoration: InputDecoration(
            labelText: "Especie:",
            prefixIcon: Icon(Icons.bug_report_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: edad,
          decoration: InputDecoration(
            labelText: "Edad:",
            prefixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
        TextField(
          controller: fecha,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            labelText: "Fecha del Vuelo (dd/mm/aa):",
            prefixIcon: Icon(Icons.date_range),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField(
          value: selectedOption,
          items: [
            DropdownMenuItem(
              child: Text("Vacunado"),
              value: true,
            ),
            DropdownMenuItem(
              child: Text("No Vacunado"),
              value: false,
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedOption = value as bool?;
            });
          },
          decoration: InputDecoration(
            labelText: "Vacunado:",
            prefixIcon: Icon(Icons.local_hospital_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                // Verificar y asignar valores nuevos o antiguos según sea necesario
                String nuevoNombre = nombre.text.isNotEmpty ? nombre.text : nombreTemp;
                String nuevaEspecie = especie.text.isNotEmpty ? especie.text : especieTemp;
                int nuevaEdad = edad.text.isNotEmpty ? int.parse(edad.text) : edadTemp ?? 0; // Utiliza 0 si edadTemp es nulo
                DateTime nuevaFecha = selectedDate ?? DateTime.now(); // Utiliza la fecha seleccionada o la actual si es nula
                bool nuevaOpcion = selectedOption ?? false; // Utiliza false si selectedOption es nulo

                Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(nuevaFecha.millisecondsSinceEpoch);

                var JSONTemporal = {
                  'id': id,
                  'nombreMascota': nuevoNombre,
                  'edad': nuevaEdad,
                  'especie': nuevaEspecie,
                  'estadoVacunacion': nuevaOpcion,
                  'fechaConsulta': timestamp,
                };

                DB.actualizar(JSONTemporal).then((value) {
                  setState(() {
                    mostrarSnackBar("¡SE ACTUALIZÓ LA MASCOTA!");
                    _index = 0;
                  });

                  nombre.text = "";
                  edad.text = "";
                  especie.text = "";
                  fecha.text = "";
                });
              },
              child: Text("Actualizar"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _index = 0;
                });
              },
              child: Text("Cancelar"),
            ),
          ],
        ),
      ],
    );
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        fecha.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void mostrarSnackBar(String mensaje) {
    final snackBar = SnackBar(content: Text(mensaje));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }



}






