import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServeiAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  //Usuari actual
  User? getUsuariActual() {
    return _auth.currentUser;
  }

  //fer logout
  Future<void> ferLogout() async {
    return await _auth.signOut();
  }

  //Fer login
  Future<String?> loginAmbEmailIPassword(String email, String password) async {
    try {
      UserCredential credencialUsuari = await _auth.signInWithEmailAndPassword(email: email, password: password);

      //comprueba si el usario esta dado de alta
      final QuerySnapshot querySnapshot = await _firestore.collection("Usuaris").where("email", isEqualTo: email).get();
      
      if (querySnapshot.docs.isEmpty) {
         _firestore.collection("Usuaris").doc(credencialUsuari.user!.uid).set({
        "uid": credencialUsuari.user!.uid,
        "email": email,
        "nom": "",
      });
      }
      return null;
    } on FirebaseAuthException catch(e) {
      return "Error: ${e.message}";
    }
  }


  Future<String> getNomUsuariActual() async {
    String? email = _auth.currentUser!.email;
    final QuerySnapshot querySnapshot = await _firestore.collection("Usuaris").where("email", isEqualTo: email).get();
    String nomUsActual = querySnapshot.docs.first["nom"];
    if (querySnapshot.docs.first["nom"] == null) {
      return "";
    }else{
      return querySnapshot.docs.first["nom"];
    }
  }
  


  //fer registre
  Future<String?> registreAmbEmailIPassword (String email, password) async {
    try {
      UserCredential credencialUsuari = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _firestore.collection("Usuaris").doc(credencialUsuari.user!.uid).set({
        "uid": credencialUsuari.user!.uid,
        "email": email,
        "nom": "",
      });
    return null;
    } on FirebaseAuthException catch(e){
      switch (e.code) {
        case "email-already-in-use":
          return "Ja hi ha un usuari amb aquest email";

        case "invalid-email":
          return "Email no vàlid";

        case "operation-not-allowed":
          return "Email i/o password no habilitats";

        case "weak-password":
          return "Cal un password més robust.";

        default:
        return "Error ${e.message}";      
      }
    } catch (e) {
      return "Error $e";
    }
  }
}