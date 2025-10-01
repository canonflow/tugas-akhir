import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:frontend/shared/app_bar.dart';

class DosenPage extends StatefulWidget {
  const DosenPage({super.key});

  @override
  State<DosenPage> createState() => _DosenPageState();
}

class _DosenPageState extends State<DosenPage> {
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = authService.getCurrentUser();
    return Scaffold(
        headers: [
          CustomAppBar(context, "Home Page", false)
        ],
      child: Center(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Alert(
                    title: Text("Welcome message"),
                    content: Text("Selamat datang, " + user.name!),
                    leading: Icon(Icons.info_outline),
                  )
                )
              ],
            )
          ],
        ).withPadding(vertical: 10, horizontal: 16),
      )
    );
  }
}
