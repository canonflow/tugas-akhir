/*
AUTH GATE - This will continuously listen for auth state changes.

----------------------------------------------------------------

unauthenticated -> Login Page
authenticated -> Dosen / Mahasiswa Page
*/
import 'package:frontend/features/auth/pages/login_page.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/dosen/pages/dosen_page.dart';
import 'package:frontend/features/mahasiswa/pages/mahasiswa_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class AuthGate extends StatelessWidget {
  final authService = AuthService();


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // TODO: Listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,

      // TODO: Build the appropriate widget based on the auth state
      builder: (context, snapshot) {
        // Loading Statte
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // TODO: Check if there is a valid session
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          // TODO: Check the user's role
          final currentUser = authService.getCurrentUser();
          print(currentUser);
          if (currentUser.role == "dosen") {
            return DosenPage();
          } else {
            return MahasiswaPage();
          }
        } else {
          return LoginPage();
        }
      }
    );
  }
}