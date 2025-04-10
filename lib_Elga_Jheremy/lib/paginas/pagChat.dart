import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/auth/servei_auth.dart';
import 'package:firebase/chat/servei_chat.dart';
import 'package:firebase/componentes/bombolla_missatge.dart';
import 'package:flutter/material.dart';

class Pagchat extends StatefulWidget {
  final String idReceptor;

  const Pagchat({super.key, required this.idReceptor});

  @override
  State<Pagchat> createState() => _PaginaChatState();
}

class _PaginaChatState extends State<Pagchat> {
  final TextEditingController tecMissatge = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? nomReceptor = "Carregant...";

  FocusNode teclatMobil = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    teclatMobil.addListener((){
      Future.delayed(const Duration(milliseconds: 500), (){
        ferScrollCapAvall();
      });
    });

    Future.delayed(const Duration(milliseconds: 500), (){
      ferScrollCapAvall();
    });
    _carregarNomReceptor();
  }

  void ferScrollCapAvall(){
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(seconds: 1), 
        curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        title: Text(nomReceptor ?? "Carregant..."),
      ),
      body: Column(
        children: [
          //Zona missatges
          _crearZonaMostrarMissatges(),

          //Zona escriure missatges
          _crearZonaEscriureMissatge(),
        ],
      ),
    );
  }

  Widget _crearZonaMostrarMissatges() {
    return Expanded(
        child: StreamBuilder(
            stream: ServeiChat().getMissatges(
                ServeiAuth().getUsuariActual()!.uid, widget.idReceptor),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Error caregant datos...");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Carregant missatges...");
              }
              return ListView(
                controller: _scrollController,
                children: snapshot.data!.docs
                    .map((document) => _construirItemMissatge(document))
                    .toList(),
              );
            }));
  }

  Widget _construirItemMissatge(DocumentSnapshot documentSnapshot) {
  Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
  return BombollaMissatge(
    missatge: data["missatge"],
    idAutor: data["idAutor"],
    timestamp: data["timestamp"], // Aquí pasamos el Timestamp
  );
}


  Widget _crearZonaEscriureMissatge() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: tecMissatge,
            decoration:
                InputDecoration(filled: true, fillColor: Colors.amber[200]),
          )),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: enviarMissatge,
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.green),
            ),
          )
        ],
      ),
    );
  }

  void enviarMissatge() {
    if (tecMissatge.text.isNotEmpty) {
      ServeiChat().enviarMissatge(widget.idReceptor, tecMissatge.text);
      tecMissatge.clear();
      Future.delayed(const Duration(milliseconds: 250), (){
        ferScrollCapAvall();
      });
      
    }
  }

  Future<void> _carregarNomReceptor() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection("Usuaris")
          .doc(widget.idReceptor)
          .get();

      if (docSnapshot.exists) {
        final dades = docSnapshot.data()!;
        setState(() {
          nomReceptor = (dades["nom"] != null && dades["nom"].toString().trim().isNotEmpty)
              ? dades["nom"]
              : dades["email"]; // fallback al correu si no hi ha nom
        });
      } else {
        setState(() {
          nomReceptor = "Usuari desconegut";
        });
      }
    } catch (e) {
      setState(() {
        nomReceptor = "Error carregant nom";
      });
      print("Error carregant nom del receptor: $e");
    }
  }
}
