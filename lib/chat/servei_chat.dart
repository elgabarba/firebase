import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/models/missatge.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServeiChat {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsuaris(){
    return _firestore.collection("Usuaris").snapshots().map((event) {
      return event.docs.map((document) {
        return document.data();
      }).toList();
    });
  }

  Future<void> enviarMissatge(String idReceptor, String missatge) async {

    // La sala de chat es entre dos usuaris. La creem a partir dels seud uid's
    String idUsuariActual = _auth.currentUser!.uid;
    String emailUsuariActual = _auth.currentUser!.email!;
    Timestamp timestamp = Timestamp.now();

    Missatge nouMissatge = Missatge(idAutor: idUsuariActual, emailAutor: emailUsuariActual, idReceptor: idReceptor, missatge: missatge, timestamp: timestamp);

    List<String>  idsUsuaris = [idUsuariActual, idReceptor];
    idsUsuaris.sort();

    String idSalaChat = idsUsuaris.join("_");

    await _firestore.collection("SalesChat").doc(idSalaChat).collection("Missatges").add(nouMissatge.retornaMapaMissatge(),);
  } 

}