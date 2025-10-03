import 'package:frontend/core/utils/date.dart';
import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/dosen/services/topic_service.dart';
import 'package:frontend/features/mahasiswa/pages/topics/browse_page.dart';
import 'package:frontend/shared/app_bar.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MahasiswaPage extends StatefulWidget {
  const MahasiswaPage({super.key});

  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  final authService = getIt<AuthService>();
  final topicService = getIt<TopicService>();
  List<TopicModel> joinedTopics = [];
  bool isLoading = true;

  Future<void> loadJoinedTopics() async {
    try {
      final userId = authService.getCurrentUser().id!;
      final topics = await topicService.getJoinedTopic(userId);

      setState(() {
        joinedTopics = topics;
      });
    } catch (e) {
      if (mounted) {
        CustomSimpleDialog(context, "Error", e.toString());
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override void initState() {
    // TODO: implement initState
    super.initState();
    loadJoinedTopics();
  }


  @override
  Widget build(BuildContext context) {
    final user = authService.getCurrentUser();
    return Scaffold(
        headers: [
          CustomAppBar(context, "Home Page", false)
        ],
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                // ===== WELCOME MESSAGE =====
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

                // ===== BUTTONS =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PrimaryButton(
                      size: ButtonSize.normal,
                      onPressed: () {
                        Navigator.pushNamed(context, BrowseTopicPage.route);
                      },
                      leading: const Icon(Icons.find_in_page_rounded),
                      child: const Text('Browse Topic'),
                    ),
                    Spacer(),
                    OutlineButton(
                      size: ButtonSize.small,
                      density: ButtonDensity.icon,
                      onPressed: () {},
                      child: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // ===== JOINED TOPIC(S) =====
                if (isLoading)
                  Column(
                    children: List.generate(3, (index) {
                      return Row(
                        children: [Expanded(
                          child: Basic(
                            title: const Text('Loading...').asSkeleton(),
                            content: const Text('Please wait...').asSkeleton(),
                            leading: const Avatar(initials: '').asSkeleton(),
                            trailing: const Text('Status').asSkeleton(),
                          ).withPadding(bottom: 12),
                        )],
                      );
                    }),
                  )
                else if (joinedTopics.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.gray[400]),
                        const Gap(16),
                        const Text("No topic(s) yet").h4,
                        const Gap(8),
                        Text(
                          "You haven't joined any topics",
                          textAlign: TextAlign.center,
                        )
                            .muted()
                            .small(),
                      ],
                    ).withPadding(vertical: 40),
                  )
                else
                  IntrinsicHeight(
                    child: Column(
                      children: joinedTopics
                          .map((topic) => [
                        Expanded(
                          child: CardImage(
                            onPressed: () {},
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
        )
    );
  }
}
