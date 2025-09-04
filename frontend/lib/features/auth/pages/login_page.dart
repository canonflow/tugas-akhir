import 'package:frontend/core/helper/page_move.dart';
import 'package:frontend/features/auth/pages/register_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const route = 'login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text Controllers
  final _emailController =  TextEditingController();
  final _passwordController = TextEditingController();
  bool loginPressed = false;
  bool registerPressed = false;

  Future<void> login() async {
    if (loginPressed) return;

    setState(() {
      loginPressed = !loginPressed;
    });
    final email = _emailController.text;
    final password = _passwordController.text;

    await Future.delayed(Duration(seconds: 2));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alert title'),
          content: const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'),
          actions: [
            OutlineButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
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

    setState(() {
      loginPressed = !loginPressed;
    });
  }

  void openModalRegister() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Register"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pilih role yang kamu inginkan untuk mendaftarkan akun.").xSmall,
              const Gap(16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        child: Text("Dosen"),
                        onPressed: () => {
                          // Navigator.popAndPushNamed(
                          //   context,
                          //   RegisterPage.route,
                          //   arguments: {
                          //     "role": "dosen"
                          //   }
                          // )
                          // Navigator.pop(context),
                          PageMove.PushNamed(
                              context,
                              RegisterPage.route,
                              PageTransitionType.rightToLeft,
                              Duration(milliseconds: 300),
                              pop: true,
                              arguments: {
                                "role": "dosen"
                              }
                          )
                        },
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: PrimaryButton(
                        child: Text("Mahasiswa"),
                        onPressed: () => {
                          PageMove.PushNamed(
                            context,
                            RegisterPage.route,
                            PageTransitionType.rightToLeft,
                            Duration(milliseconds: 300),
                            arguments:{
                              "role": "mahasiswa"
                            },
                            pop: true
                          )
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // vertikal ke tengah
        crossAxisAlignment: CrossAxisAlignment.center, // horizontal ke tengah
        children: [
          Text(
            "Login Page",
            style: TextStyle(
              color: Colors.gray[600]
            ),
          ).h2,
          const SizedBox(height: 24),
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
                const SizedBox(height: 24),

                // ===== ACTION =====
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        child: const Text('Login'),
                        onPressed: () => login(),
                      ),
                    ),
                  ],
                ),

                // GO TO REGISTER
                GestureDetector(
                  onTap: () => openModalRegister(),
                  child: Center(
                    child: Text(
                      "Don't have an account? Register here.",
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
