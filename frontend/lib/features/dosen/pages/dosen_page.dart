import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class DosenPage extends StatefulWidget {
  const DosenPage({super.key});

  @override
  State<DosenPage> createState() => _DosenPageState();
}

class _DosenPageState extends State<DosenPage> {
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Center(
        child: Column(
          children: [
            Text("Dosen Page"),
            Text(authService.getCurrentUser().name!)
          ],
        ),
      )
    );
  }
}
