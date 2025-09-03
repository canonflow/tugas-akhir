import 'package:shadcn_flutter/shadcn_flutter.dart';
class RegisterPage extends StatefulWidget {
  final String role;
  const RegisterPage({super.key, required this.role});

  static const route = 'register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    print(widget.role);
    return Scaffold(
      headers: [
        AppBar(
          title: Text(
            'Register Page',
            style: TextStyle(
              color: Colors.gray[600]
            ),
          ).h4,
          leading: [
            OutlineButton(
              size: ButtonSize.small,
              density: ButtonDensity.icon,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back),
            ),
          ],
        )
      ],
      child: Column(
        children: [
          Text("Register")
        ],
      )
    );
  }
}
