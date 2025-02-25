import 'package:firebase/auth/login_o_registre.dart';
import 'package:firebase/paginas/pagInici.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PortalAuth extends StatelessWidget {
  const PortalAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {

          if (snapshot.hasData) {
            return const Paginici();
          }else{
            return const LoginORegistre();
          }
        }
      ),
    );
  }
}