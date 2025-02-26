import 'package:firebase/auth/servei_auth.dart';
import 'package:firebase/chat/servei_chat.dart';
import 'package:firebase/componentes/item_usuari.dart';
import 'package:flutter/material.dart';

class Paginici extends StatelessWidget {
  const Paginici({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        title: const Text("Pagina d'inici"),
        actions: [
          IconButton(onPressed: () {
            ServeiAuth().ferLogout();
          }, 
          icon: const Icon(Icons.logout),)
        ],
      ),
      body: StreamBuilder(
        stream: ServeiChat().getUsuaris(), 
        builder: (context, snapshot){

          //cas que hi hagi un error
          if (snapshot.hasError) {
            return const Text("Error en el snapshot");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Carregant dades");
          }

          //Es retornen les dades
          return ListView(
            children: snapshot.data!.map<Widget> (
              (dadesUsuari) => _construeixItemUsuari(dadesUsuari)
            ).toList(),
          );
        }
      ),
    );
  }

  Widget _construeixItemUsuari(Map<String, dynamic> dadesUsuari) {
    return ItemUsuari(emailUsuari: dadesUsuari["email"]);
  }
}