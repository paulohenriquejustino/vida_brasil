import 'package:cloud_firestore/cloud_firestore.dart';
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<List<Map<String, dynamic>>> obtterImoveis() {
    return _db.collection('imoveis').snapshots().map((snapshot) =>
    snapshot.docs.map((doc) => doc.data()).toList());
  }
}
