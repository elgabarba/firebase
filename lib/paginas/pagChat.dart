import 'package:firebase/chat/servei_chat.dart';
import 'package:flutter/material.dart';

class Pagchat extends StatefulWidget {

  final String idReceptor;

  const Pagchat({super.key, required this.idReceptor});


  @override
  State<Pagchat> createState() => _PaginaChatState();
}

class _PaginaChatState extends State<Pagchat> {

  final TextEditingController tecMissatge = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        title: const Text("Sala Chat"),
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
    return const Expanded(child: Text("1"));
  }
  
  Widget _crearZonaEscriureMissatge() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(child: TextField( 
            controller:  tecMissatge,
            decoration: InputDecoration(
              filled: true, 
              fillColor: Colors.amber[200]
            ),
          )),
          const SizedBox(width: 10,),
          IconButton(
            onPressed: enviarMissatge, 
            icon: const Icon(Icons.send, color: Colors.white,),
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.green),
            ),
          )
        ],
      ),
    );
  }

  void enviarMissatge() {
    if (tecMissatge.text.isNotEmpty){
      ServeiChat().enviarMissatge(widget.idReceptor, tecMissatge.text);
    }

  }
}