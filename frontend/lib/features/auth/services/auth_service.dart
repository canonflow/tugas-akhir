import 'package:frontend/features/auth/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // TODO: Login with email and password
  Future<AuthResponse> loginWithEmailAndPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password
    );
  }

  // TODO: Register with email and password
  Future<AuthResponse> registerWithEmailAndPassword(String email, String password, String role, String name) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        "role": role,
        "name": name
      },
    );
  }

  // TODO: Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // TODO: Get User
  UserModel getCurrentUser() {
    final user = _supabase.auth.currentUser!;
    final Map<String, dynamic> metadata = user.userMetadata!;

    return UserModel(
      id: user.id,
      email: user.email,
      role: metadata["role"],
      name: metadata["name"],
    );
  }
}