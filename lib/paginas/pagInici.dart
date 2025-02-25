import 'package:firebase/auth/servei_auth.dart';
import 'package:flutter/material.dart';

class Paginici extends StatelessWidget {
  const Paginici({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pagina d'inici"),
        actions: [
          IconButton(onPressed: () {
            ServeiAuth().ferLogout();
          }, 
          icon: const Icon(Icons.logout),)
        ],
      ),
      body: const Text("Pagina d'inici"),
    );
  }
}