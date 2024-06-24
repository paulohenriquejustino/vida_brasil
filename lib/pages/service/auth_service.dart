
import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login anônimo
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
