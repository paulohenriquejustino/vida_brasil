import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;
  bool _isGuest = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null || _isGuest;
  bool get isAdmin => _user != null && _user!.email == 'enzo@auth.com';
  bool get isGuest => _isGuest;

  AuthProvider() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      _isGuest = false;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
      } else {
        print('Erro ao fazer login: ${e.message}');
      }
    }
  }

  Future<void> loginAsGuest() async {
    _isGuest = true;
    _user = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _isGuest = false;
    notifyListeners();
  }
}
