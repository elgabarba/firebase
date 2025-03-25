import 'dart:io';
import 'dart:typed_data';

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

    _connectarAmbMongoDB().then((_) => print("Connectats amn MongoDB"));

  }
  Future _connectarAmbMongoDB() async{
    _db = await mongodb.Db.create(BDConf().connectionString);
    await _db!.open();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Dades Usuari")),
      body: Center(
        child: Column(
          children: [
            const Text("Edita les teves dades."),

            //afegir imatge o text
            _imatgeEnBytes != null ? Image.memory(_imatgeEnBytes!, height: 200,) : const Text("No s'ha seleccionat cap imatge."),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed: (){
                _pujarImatge();
              }, 
              child: const Text("pujar imatge")
            ),

            ElevatedButton(
              onPressed: (){
                _recuperarImatge();
              }, 
              child: const Text("Recuperra imagte")
            )
          ],
        ),
      ),
    );
  }

  Future _pujarImatge() async{
    final imatgeSeleccionada = await imagePicker.pickImage(source: ImageSource.gallery);

    if (imatgeSeleccionada != null){
      final bytesImage = await File(imatgeSeleccionada.path).readAsBytes();
      final dadesBinaries = mongodb.BsonBinary.from(bytesImage);
      final collection = _db!.collection("imatges_perfils");
      await collection.replaceOne(
        {
          "id_usuari_firebase": ServeiAuth().getUsuariActual()!.uid,
        }, 
        {
          "id_usuari_firebase": ServeiAuth().getUsuariActual()!.uid,
          "nom_foto" : "foto_perfil",
          "imatge" : dadesBinaries,
          "data_pujada" : DateTime.now()
        },

        //fer que si no troba el doc el crei
        upsert: true
      );
      print("imatge pujada");
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