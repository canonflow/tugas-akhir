import 'dart:async';

import 'package:frontend/auth_gate.dart';
import 'package:frontend/features/auth/pages/login_page.dart';
import 'package:lottie/lottie.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  // Make a timer
  startTimer() {
    var duration = Duration(milliseconds: 4500);
    return Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (_, __, ___) => AuthGate(),
        transitionsBuilder: (_, animation, __, child) {
          final slideAnimation = Tween<Offset>(
            // begin: const Offset(0.2, 0.0), // dari kanan
            begin: const Offset(0.0, 0.1), // dari bawah
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(
            position: slideAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // vertikal ke tengah
        crossAxisAlignment: CrossAxisAlignment.center, // horizontal ke tengah
        children: [
          content(),
          const Gap(22),
          Text(
            "Getting Started . . .",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.slate[800]
            ),
          ).h3.withMargin(horizontal: 20),
        ],
      )
    );
  }

  Widget content() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, // 80%
        child: Lottie.network("https://lottie.host/c66bda13-3fb6-46c0-9929-45ee54e1b11a/5ub1bOaIox.json"),
      ),
    );
  }
}
