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
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditarDadesUsuari()));
            }, 
            icon: const Icon(Icons.person)
            ),
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
              (dadesUsuari) => _construeixItemUsuari(dadesUsuari, context)
            ).toList(),
          );
        }
      ),
    );
  }

  Widget _construeixItemUsuari(Map<String, dynamic> dadesUsuari, BuildContext context) {

    if (dadesUsuari["email"] == ServeiAuth().getUsuariActual()!.email) {
      return Container();
    }
    return ItemUsuari(emailUsuari: dadesUsuari["email"], onTap: () {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => Pagchat(idReceptor: dadesUsuari["uid"],),
        ),
      );
    },);
  }
}