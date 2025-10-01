import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MahasiswaPage extends StatefulWidget {
  const MahasiswaPage({super.key});

  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        child: Center(
          child: Column(
            children: [
              Text("Mahasiswa Page"),
              Text(authService.getCurrentUser().name!)
            ],
          ),
        )
    );
  }
}
