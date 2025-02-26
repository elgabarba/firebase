import 'package:flutter/material.dart';

class Pagchat extends StatefulWidget {
  const Pagchat({super.key});

  @override
  State<Pagchat> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Pagchat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
    return const Text("1");
  }
  
  Widget _crearZonaEscriureMissatge() {
    return const Text("2");
  }
}