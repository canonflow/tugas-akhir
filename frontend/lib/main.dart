import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/auth/pages/login_page.dart';
import 'package:frontend/features/auth/pages/register_page.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/dosen/pages/topics/create_page.dart';
import 'package:frontend/features/dosen/pages/topics/detail_page.dart';
import 'package:frontend/features/dosen/pages/topics/submissions/detail_page.dart';
import 'package:frontend/features/mahasiswa/models/submission.dart';
import 'package:frontend/features/mahasiswa/pages/topics/browse_page.dart';
import 'package:frontend/features/mahasiswa/pages/topics/detail_page.dart';
import 'package:frontend/features/mahasiswa/pages/topics/submissions/result_page.dart';
import 'package:frontend/splash.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  print('All loaded env vars:');
  print(dotenv.env["SUPABASE_PROJECT_URL"]);
  print(dotenv.env["SUPABASE_ANON_KEY"]);


  // Todo: Supabase Setup
  await Supabase.initialize(
    anonKey: dotenv.env["SUPABASE_ANON_KEY"]!,
    url: dotenv.env["SUPABASE_PROJECT_URL"]!,
    debug: true,
    // authOptions: const FlutterAuthClientOptions(
    //   authFlowType: AuthFlowType.pkce,
    // ),
  );

  // TODO: Setup Singleton Object
  setupAllServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'Image Similarity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorSchemes.lightDefaultColor,
        radius: 0.3
      ),
      home: const SplashScreen(),
      // routes: {
      //   // Auth
      //   LoginPage.route: (context) => LoginPage(),
      //   'register': (context, role) => RegisterPage(role)
      // },
      onGenerateRoute: (settings) {
        // ===== Auth =====
        switch (settings.name) {
          case LoginPage.route:
            return MaterialPageRoute(builder: (context) => LoginPage());
          case RegisterPage.route:
            // Ambil role dari parameter
            final role = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(builder: (context) => RegisterPage(role: role['role']!));

          // ===== DOSEN =====
          case CreateTopicPage.route:
            return MaterialPageRoute(builder: (context) => CreateTopicPage());
          case DetailTopicPage.route:
            final topic = settings.arguments as TopicModel;
            return MaterialPageRoute(builder: (context) => DetailTopicPage(topic: topic));
          case LectureSubmissionDetailPage.route:
            final submission = settings.arguments as SubmissionModel;
            return MaterialPageRoute(builder: (context) => LectureSubmissionDetailPage(submission: submission));

          // ===== MAHASISWA =====
          case BrowseTopicPage.route:
            return MaterialPageRoute(builder: (context) => BrowseTopicPage());
        
          case StudentDetailTopicPage.route:
            final topic = settings.arguments as TopicModel;
            return MaterialPageRoute(builder: (context) => StudentDetailTopicPage(topic: topic));

          case StudentFinalSubmissionPage.route:
            final submission = settings.arguments as SubmissionModel;
            return MaterialPageRoute(builder: (context) => StudentFinalSubmissionPage(submission: submission));
        }
      },
    );
  }
}
