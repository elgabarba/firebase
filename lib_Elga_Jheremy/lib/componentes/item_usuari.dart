import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase/mongodb/mongo_service.dart'; // Ajusta la ruta según corresponda

class ItemUsuari extends StatefulWidget {
  final String emailUsuari;
  final String uid; // Añade este parámetro
  final VoidCallback onTap;

  const ItemUsuari({
    Key? key,
    required this.emailUsuari,
    required this.uid,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ItemUsuari> createState() => _ItemUsuariState();
}

class _ItemUsuariState extends State<ItemUsuari> {
  // Implementación que utilice el widget.uid para obtener la imagen
  // Por ejemplo, un FutureBuilder que llame a tu servicio de MongoDB:
  late final MongoService mongoService;

  @override
  void initState() {
    super.initState();
    mongoService = MongoService();
    mongoService.connect().catchError((error) {
      debugPrint("Error conectando a MongoDB: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: mongoService.getImatgePerfil(widget.uid),
      builder: (context, snapshot) {
        Widget leading;
        if (snapshot.connectionState == ConnectionState.waiting) {
          leading = const CircleAvatar(
            child: CircularProgressIndicator(strokeWidth: 2,),
            backgroundColor: Colors.white,
          );
        } else if (snapshot.hasError) {
          leading = const CircleAvatar(
            backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/512/12225/12225935.png"),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          leading = CircleAvatar(
            backgroundImage: MemoryImage(snapshot.data!),
          );
        } else {
          leading = const CircleAvatar(
            backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/512/12225/12225935.png"),
          );
        }
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.amber[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: leading,
            title: Text(widget.emailUsuari),
            onTap: widget.onTap,
          ),
        );
      },
    );
  }
}