import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
class RegisterPage extends StatefulWidget {
  final String role;
  const RegisterPage({super.key, required this.role});

  static const route = 'register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _emailController =  TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final authService = AuthService();

  bool registerPressed = false;

  Future<void> register(String role) async {
    if (registerPressed) return;

    setState(() {
      registerPressed = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;

    // TODO: Attempt Register
    try {
      await authService.registerWithEmailAndPassword(email, password, role, name);

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(
                "$e"
              ),
              actions: [
                PrimaryButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    }

    setState(() {
      registerPressed = !registerPressed;
    });
  }

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
          SizedBox(height: 36),
          Card(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Email =====
                const Text('Email').semiBold().small(),
                const SizedBox(height: 4),
                TextField(
                  placeholder: Text('Username'),
                  controller: _emailController,
                ),

                const SizedBox(height: 16),

                // ===== Password =====
                const Text('Password').semiBold().small(),
                const SizedBox(height: 4),
                TextField(
                  placeholder: Text('Password'),
                  controller: _passwordController,
                  obscureText: true,
                  features: [
                    InputFeature.clear(
                      visibility: InputFeatureVisibility.textNotEmpty,
                    ),
                    InputFeature.passwordToggle(mode: PasswordPeekMode.hold),
                  ],
                ),

                // ===== NAME =====
                const SizedBox(height: 16),
                const Text('Name').semiBold().small(),
                const SizedBox(height: 4),
                TextField(
                  placeholder: Text('Name'),
                  controller: _nameController,
                ),

                const SizedBox(height: 24),

                // ===== ACTION =====
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        child: const Text('Register'),
                        onPressed: () => register(widget.role),
                      ),
                    ),
                  ],
                ),

                // GO TO LOGIN
                GestureDetector(
                  onTap: () => {
                    Navigator.pop(context)
                  },
                  child: Center(
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(
                          color: Colors.gray[500]
                      ),
                    ).xSmall.bold,
                  ),
                ).withMargin(top: 18)
              ],
            ),
          )
        ],
      ).withPadding(horizontal: 12),
    );
  }
}
