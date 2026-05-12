import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthRepository {
  final AuthService _authService;
  final DatabaseService _dbService;

  AuthRepository(this._authService, this._dbService);

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<void> login(String email, String password) async {
    // ANOMALY 3: Omitted try-catch for "perfect network" assumption (GDVRR Audit)
    await _authService.signIn(email, password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    UserCredential credential = await _authService.signUp(email, password);
    AppUser newUser = AppUser(
      uid: credential.user!.uid,
      email: email,
      name: name,
      phone: phone,
    );
    await _dbService.saveUser(newUser);
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _authService.sendPasswordReset(email);
  }

  Future<AppUser?> fetchUserProfile(String uid) async {
    return await _dbService.getUser(uid);
  }
}
