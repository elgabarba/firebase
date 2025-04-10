import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/auth/servei_auth.dart';
import 'package:firebase/mongodb/db_conf.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongodb;

class EditarDadesUsuari extends StatefulWidget {
  const EditarDadesUsuari({super.key});

  @override
  State<EditarDadesUsuari> createState() => _EditarDadesUsuariState();
}

class _EditarDadesUsuariState extends State<EditarDadesUsuari> {

  mongodb.Db? _db;
  Uint8List? _imatgeEnBytes;
  final ImagePicker imagePicker = ImagePicker();
  final TextEditingController nomUsuari = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    _db?.close();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _NombreUsuariActual();
    _connectarAmbMongoDB().then((_) => print("Connectats amn MongoDB"));

  }

  Future <void> _NombreUsuariActual() async{
    String nom = await ServeiAuth().getNomUsuariActual();
      setState(() {
        nomUsuari.text = nom!;
      });
  }

  Future _connectarAmbMongoDB() async {
    try {
      _db = await mongodb.Db.create(BDConf().connectionString);
      await _db!.open();
      print("Conexión establecida con MongoDB");
    } catch (e, stackTrace) {
      print("Error al conectar con MongoDB: $e");
      print("StackTrace: $stackTrace");
      // Aquí puedes informar al usuario, por ejemplo, con un SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar con la base de datos."))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Dades Usuari")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("Edita les teves dades."),
              Text(ServeiAuth().getUsuariActual()!.email.toString()),
              TextField(
                controller: nomUsuari,
                decoration: InputDecoration(
                  
                  hintText: nomUsuari == "" ? "Escriu el teu nom..." : "",
                ),
              ),

              ElevatedButton(
                onPressed: (){
                  _guardarNom();
                }, 
                child: const Text("Guardar")
              ),
              const SizedBox(height: 10),
              Text(
                "Edita les teves dades",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              // --- IMAGEN DE PERFIL ---
              Stack(
                alignment: Alignment.center,
                children: [
                  // Componente circular con imagen o defecto
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _imatgeEnBytes != null
                        ? MemoryImage(_imatgeEnBytes!) // imagen en memoria
                        : const NetworkImage("https://cdn-icons-png.flaticon.com/512/12225/12225935.png")
                            as ImageProvider, // imagen por defecto
                  ),
                  // Botón flotante para cambiar la imagen (opcional)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pujarImatge, // Abre galería y sube imagen
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botones para subir y recuperar imagen (depende de tu diseño)
              ElevatedButton(
                onPressed: _pujarImatge,
                child: const Text("Pujar Imatge"),
              ),
              ElevatedButton(
                onPressed: _recuperarImatge,
                child: const Text("Recuperar Imatge"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _guardarNom() async {
    if (nomUsuari.text.isEmpty) {
      return;
    }

    try {
      final String uid = ServeiAuth().getUsuariActual()!.uid;
      await FirebaseFirestore.instance.collection('Usuaris').doc(uid).update({
        'nom': nomUsuari.text,  
      });

      Navigator.pop(context);
    } catch (e) {
      print("Error al guardar el nombre: $e");
    }
  }


 Future _pujarImatge() async {
    try {
      final imatgeSeleccionada = await imagePicker.pickImage(source: ImageSource.gallery);

      if (imatgeSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se ha seleccionado ninguna imagen."))
        );
        return;
      }

      // Verificar que la base de datos esté conectada
      if (_db == null || !_db!.isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Conexión a la base de datos no establecida."))
        );
        return;
      }

      final bytesImage = await File(imatgeSeleccionada.path).readAsBytes();
      final dadesBinaries = mongodb.BsonBinary.from(bytesImage);
      final collection = _db!.collection("imatges_perfils");

      await collection.replaceOne(
        {
          "id_usuari_firebase": ServeiAuth().getUsuariActual()!.uid,
        }, 
        {
          "id_usuari_firebase": ServeiAuth().getUsuariActual()!.uid,
          "nom_foto": "foto_perfil",
          "imatge": dadesBinaries,
          "data_pujada": DateTime.now()
        },
        upsert: true
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Imagen subida correctamente."))
      );
      print("Imagen subida");
    } catch (e, stackTrace) {
      print("Error al subir la imagen: $e");
      print("StackTrace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al subir la imagen."))
      );
    }
  }


  Future<void> _recuperarImatge() async{
    try {
      final collection = _db!.collection("imatges_perfils");
      final doc = await collection.findOne({"id_usuari_firebase": ServeiAuth().getUsuariActual()!.uid});

      if (doc != null && doc["imatge"] != null) {
        final imatgeBson = doc["imatge"] as mongodb.BsonBinary;
        setState(() {
          _imatgeEnBytes = imatgeBson.byteList;
        });
      }else{
        print("Error trobant la imatge en el document");
      }
    } catch (e) {
      print("Error intentant recuperar el document");
    }
  }
}