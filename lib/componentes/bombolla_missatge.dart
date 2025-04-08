import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/auth/servei_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BombollaMissatge extends StatelessWidget {
  final String missatge;
  final String idAutor;
  final Timestamp timestamp; // Nuevo parámetro para la fecha del mensaje

  const BombollaMissatge({
    Key? key,
    required this.missatge,
    required this.idAutor,
    required this.timestamp,
  }) : super(key: key);

  // Función para formatear la fecha del mensaje
  String getFormattedTime() {
    DateTime messageTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration diff = now.difference(messageTime);

    if (diff.inDays < 1) {
      return DateFormat('HH:mm').format(messageTime);
    } else if (diff.inDays == 1) {
      return "Fa 1 dia";
    } else {
      return "Fa ${diff.inDays} dies";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
      child: Align(
        alignment: idAutor == ServeiAuth().getUsuariActual()!.uid
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: idAutor == ServeiAuth().getUsuariActual()!.uid
                ? Colors.green[200]
                : Colors.amber[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(missatge),
                const SizedBox(height: 5),
                Text(
                  getFormattedTime(),
                  style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
