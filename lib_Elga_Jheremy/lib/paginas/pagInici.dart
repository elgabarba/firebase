// Paginici.dart
import 'package:firebase/auth/servei_auth.dart';
import 'package:firebase/chat/servei_chat.dart';
import 'package:firebase/componentes/item_usuari.dart';
import 'package:firebase/paginas/editar_dades_usuari.dart';
import 'package:firebase/paginas/pagChat.dart';
import 'package:flutter/material.dart';

class Paginici extends StatelessWidget {
  const Paginici({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        title: Text(ServeiAuth().getUsuariActual()!.email.toString()),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditarDadesUsuari(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () {
              ServeiAuth().ferLogout();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder(
        stream: ServeiChat().getUsuaris(),
        builder: (context, snapshot) {
          // Caso de error
          if (snapshot.hasError) {
            return const Center(child: Text("Error en el snapshot"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Carregant dades"));
          }

          // Retornar la lista de usuarios
          return ListView(
            children: snapshot.data!.map<Widget>(
              (dadesUsuari) => _construeixItemUsuari(dadesUsuari, context),
            ).toList(),
          );
        },
      ),
    );
  }

  Widget _construeixItemUsuari(Map<String, dynamic> dadesUsuari, BuildContext context) {
    if (dadesUsuari["email"] == ServeiAuth().getUsuariActual()!.email) {
      return Container();
    }
    return ItemUsuari(
      emailUsuari: dadesUsuari["email"],
      uid: dadesUsuari["uid"], // <-- Debe ser uid:
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Pagchat(idReceptor: dadesUsuari["uid"]), 
          ),
        );
      },
    );
  }
}
