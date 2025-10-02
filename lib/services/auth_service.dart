import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Future<User?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: password.trim(),
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      
      print("Login failed [${e.code}] - ${e.message}");
      return null;
    } catch (e) {
      print(" Unexpected login error: $e");
      return null;
    }
  }

  
  Future<String?> getUserRole(String uid) async {
    try {
      final snap = await _db.collection('admins').doc(uid).get();
      if (snap.exists) {
        final data = snap.data();
        if (data != null && data.containsKey('role')) {
          return data['role'] as String?;
        }
      }
      return null; 
    } catch (e) {
      print(" Role fetch failed: $e");
      return null;
    }
  }

  
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
