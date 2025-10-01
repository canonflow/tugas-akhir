import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/dosen/services/topic_service.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
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
                        onPressed: () {},
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
                      : ListView.builder(
                          shrinkWrap: true, // Important: prevents infinite height error
                          physics: NeverScrollableScrollPhysics(), // Disable inner scrolling
                          itemCount: topics.length,
                          itemBuilder: (context, index) {
                            final topic = topics[index];
                            return CardImage(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Card Image'),
                                      content: const Text('You clicked on a card image.'),
                                      actions: [
                                        PrimaryButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              image: Image.network(
                                'https://picsum.photos/200/300',
                              ),
                              title: Text(topic.name),
                              subtitle: const Text('Lorem ipsum dolor sit amet'),
                            );
                          },
                        )
                ],
              ).withPadding(vertical: 10, horizontal: 16),
            ),
          ),
        )
    );
  }
}
