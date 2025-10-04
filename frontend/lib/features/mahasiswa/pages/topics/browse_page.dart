import 'package:frontend/core/utils/date.dart';
import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/dosen/services/topic_service.dart';
import 'package:frontend/shared/app_bar.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class BrowseTopicPage extends StatefulWidget {
  const BrowseTopicPage({super.key});

  static const route = "/mahasiswa/topic/browse";

  @override
  State<BrowseTopicPage> createState() => _BrowseTopicPageState();
}

class _BrowseTopicPageState extends State<BrowseTopicPage> {
  final authService = getIt<AuthService>();
  final topicService = getIt<TopicService>();
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey = GlobalKey<RefreshTriggerState>();
  List<TopicModel> availableTopics = [];
  bool isLoading = true;

  // TODO: Fetch all available topics from SUPABASE
  Future<void> loadAvailableTopics() async {
    try {
      final userId = authService.getCurrentUser().id!;
      final fetchedAvailableTopics = await topicService.getAvailableTopic(userId);
      setState(() {
        availableTopics = fetchedAvailableTopics;
      });
    } catch (e) {
      CustomSimpleDialog(context, "Error", e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // TODO: Join the topic
  Future<void> joinTheTopic(TopicModel topic) async {
    try {
      final response = await topicService.joinTopic(topic);
    } catch (e) {
      rethrow;
    }
  }

  void openModalJoin(TopicModel topic) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Join the Topic"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure to join this topic? (${topic.name})').xSmall,
                const Gap(16),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: DestructiveButton(
                          child: Text("Cancel"),
                          onPressed: () => {
                            Navigator.pop(context)
                          },
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: PrimaryButton(
                          child: Text("Join"),
                          onPressed: () async {
                            try {
                              final response = await joinTheTopic(topic);
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Success"),
                                    content: Column(
                                      children: [
                                        Text("You have successfully joined this topic."),
                                        Gap(10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: PrimaryButton(
                                                child: Text("OK"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                }
                                              )
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }
                              );
                            } catch (e) {
                              CustomSimpleDialog(context, "Error", e.toString());
                            }
                          }
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

  @override void initState() {
    // TODO: implement initState
    super.initState();
    loadAvailableTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [CustomAppBar(context, "Browse Topic(s)", true)],
      child: RefreshTrigger(
        key: _refreshTriggerKey,
        onRefresh: () async {
          setState(() {
            isLoading = true;
          });
          loadAvailableTopics();
        },
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [

                Text(
                  "Available Topic(s)",
                  style: TextStyle(
                    color: Colors.gray[600]
                  ),
                ).h4,

                const Gap(8),
                // ===== REFRESH BUTTON =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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

                SizedBox(height: 20),

                isLoading
                    ? Column(
                        children: List.generate(14, (index) {
                          return Row(
                            children: [Expanded(
                              child: Basic(
                                title: const Text('Loading...').asSkeleton(),
                                content: const Text('Please wait...').asSkeleton(),
                                leading: const Avatar(initials: '').asSkeleton(),
                                trailing: const Text('Status').asSkeleton(),
                              ).withPadding(bottom: 18),
                            )],
                          );
                        }),
                      )
                    : availableTopics.isEmpty
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
                  child: Column(
                    children: availableTopics
                        .map((topic) => [
                      Expanded(
                        child: CardImage(
                          onPressed: () {
                            // TODO: Open Model to Join the topic
                            openModalJoin(topic);
                          },
                          image: SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: topic.image != null
                                ? Image.network(topic.image!, fit: BoxFit.cover)
                                : Container(color: Colors.gray[300]),
                          ),
                          title: Text(topic.name),
                          subtitle: Text(dateFormatter(topic.createdAt)),
                        ),
                      ),
                      const Gap(20),
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
