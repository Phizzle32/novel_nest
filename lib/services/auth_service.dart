import 'package:firebase_auth/firebase_auth.dart';
import 'package:novel_nest/models/app_user.dart';
import 'package:novel_nest/services/firestore_service.dart';

class AuthService {
  final FirestoreService _firestoreService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthService(this._firestoreService);

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Invalid credentials: $e');
    }
  }

  Future<User?> register(String email, String password, String displayName,
      List<String> preferredGenres) async {
    UserCredential? userCredential;
    try {
      userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestoreService.addUser(
        userId: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        preferredGenres: preferredGenres,
      );
      return userCredential.user;
    } catch (e) {
      userCredential?.user?.delete();
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return await _firestoreService.getUserById(firebaseUser.uid);
  }

  Future<void> deleteAccount() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      await _firestoreService.deleteUser(firebaseUser.uid);
      await firebaseUser.delete();
    }
  }
}
