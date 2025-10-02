import 'package:frontend/core/helper/page_move.dart';
import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/dosen/pages/topics/create_page.dart';
import 'package:frontend/features/dosen/services/topic_service.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:frontend/shared/app_bar.dart';

class DosenPage extends StatefulWidget {
  const DosenPage({super.key});

  @override
  State<DosenPage> createState() => _DosenPageState();
}

class _DosenPageState extends State<DosenPage> {
  final authService = getIt<AuthService>();
  final topicService = getIt<TopicService>();
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey = GlobalKey<RefreshTriggerState>();
  List<TopicModel> topics = [];
  bool isLoading = true;

  // TODO: Fetch all topics from SUPABASE
  Future<void> loadTopics() async {
    try {
      final fetchedTopics = await topicService.getAll();
      setState(() {
        topics = fetchedTopics;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // TODO: Show the error
      CustomSimpleDialog(context, "Error", e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    loadTopics();
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.getCurrentUser();
    print(topics.length);
    return Scaffold(
        headers: [
          CustomAppBar(context, "Home Page", false)
        ],
        // floatingFooter: true,
        child: RefreshTrigger(
          key: _refreshTriggerKey,
          onRefresh: () async {
            setState(() {
              isLoading = true;
            });
            loadTopics();
          },
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Alert(
                            title: Text("Welcome message"),
                            content: Text("Selamat datang, ${user.name ?? 'User'}"), // Fixed string concatenation
                            leading: Icon(Icons.info_outline),
                          )
                      )
                    ],
                  ),
                  SizedBox(height: 24),

                  // ===== REFRESH BUTTON =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PrimaryButton(
                        size: ButtonSize.normal,
                        onPressed: () {
                          Navigator.pushNamed(context, CreateTopicPage.route);
                          // PageMove.PushNamed(
                          //     context,
                          //     CreateTopicPage.route,
                          //     PageTransitionType.rightToLeft,
                          //     Duration(milliseconds: 300),
                          //     pop: true,
                          // );
                        },
                        trailing: const Icon(Icons.add),
                        child: const Text('Add'),
                      ),
                      Spacer(),
                      OutlineButton(
                        size: ButtonSize.small,
                        density: ButtonDensity.icon,
                        onPressed: () {
                          _refreshTriggerKey.currentState!.refresh();
                        },
                        child: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),

                  SizedBox(height: 36),
          
                  isLoading
                    ? Basic(
                        title: const Text('Loading...'),
                        content: const Text('Please wait while we load your topics'),
                        leading: const Avatar(
                          initials: '',
                        ).asSkeleton(),
                        trailing: const Icon(Icons.arrow_forward),
                      ).asSkeleton()
                    : topics.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.topic_outlined, size: 64, color: Colors.gray[400]),
                              SizedBox(height: 16),
                              Text(
                                "No topics yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.gray[400]
                                )
                              ).bold,
                              SizedBox(height: 8),
                              Text(
                                "Create your first topic to get started",
                                style: TextStyle(
                                  color: Colors.gray[500]
                                )
                              ).medium,
                            ],
                          ).withPadding(vertical: 40),
                        )
                      : IntrinsicHeight(
                          child: Row(
                            children: topics
                                .map((topic) => [
                                  Expanded(
                                    child: CardImage(
                                      onPressed: () { /* ... */ },
                                      image: SizedBox(
                                        width: double.infinity,
                                        height: 200,
                                        child: topic.image != null
                                            ? Image.network(topic.image!, fit: BoxFit.cover)
                                            : Container(color: Colors.gray[300]),
                                      ),
                                      title: Text(topic.name),
                                    ),
                                  ),
                                  const Gap(8),
                                ])
                                .expand((widget) => widget)
                                .toList()
                              ..removeLast(), // Remove last gap
                          ),
                        )
                ],
              ).withPadding(vertical: 10, horizontal: 16),
            ),
          ),
        )
    );
  }
}
