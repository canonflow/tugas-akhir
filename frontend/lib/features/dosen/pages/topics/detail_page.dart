import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/mahasiswa/models/submission.dart';
import 'package:frontend/features/mahasiswa/services/submission_service.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:frontend/shared/app_bar.dart';

class DetailTopicPage extends StatefulWidget {
  final TopicModel topic;
  const DetailTopicPage({super.key, required this.topic});

  static const route = "dosen/topic/detail";

  @override
  State<DetailTopicPage> createState() => _DetailTopicPageState();
}

class _DetailTopicPageState extends State<DetailTopicPage> {
  final submissionService = getIt<SubmissionService>();
  List<SubmissionModel> submissions = [];
  bool isLoading = true;

  Future<void> loadSubmissions() async {
    try {
      final fetchedSubmissions = await submissionService
          .getSubmissionByTopic(widget.topic);

      setState(() {
        submissions = fetchedSubmissions;
      });
    } catch (e) {
      print(e);
      if (mounted) {
        CustomSimpleDialog(context, "Error", e.toString());
      }
    } finally {
      print("FINALLY SCOPE");
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'graded':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.gray;
    }
  }

  String getStatusText(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override void initState() {
    // TODO: implement initState
    super.initState();
    loadSubmissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [CustomAppBar(context, widget.topic.name, true)],
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== TOPIC IMAGE =====
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  widget.topic.image!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print(error);
                    return Container(
                      color: Colors.gray[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 46),
                      ),
                    );
                  },
                ),
              ),

              const Gap(26),

              // ===== SUBMISSIONS ======
              Text(
                "Submission(s)",
                style: TextStyle(
                  fontSize: 20,
                ),
              ).bold,

              // ===== LIST OF SUBMISSION ======
              const Gap(16),
              if (isLoading)
                Column(
                  children: List.generate(3, (index) {
                    return Basic(
                      title: const Text('Loading...').asSkeleton(),
                      content: const Text('Please wait...').asSkeleton(),
                      leading: const Avatar(initials: '').asSkeleton(),
                      trailing: const Text('Status').asSkeleton(),
                    ).withPadding(bottom: 12);
                  }),
              )
              else if (submissions.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.gray[400]),
                      const Gap(16),
                      const Text("No submission(s) yet").h4,
                      const Gap(8),
                      Text(
                        "Students haven't submitted any work for this topic",
                        textAlign: TextAlign.center,
                      )
                        .muted()
                        .small(),
                    ],
                  ).withPadding(vertical: 40),
                )
              else
                Column(
                  children: submissions.map((submission) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Submission Detail'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Student: ${submission.user.name}').semiBold(),
                                  const Gap(4),
                                  Text('Email: ${submission.user.email}').muted().small(),
                                  const Divider().withPadding(vertical: 12),
                                  Text('Topic: ${submission.topic.name}').small(),
                                  const Gap(8),
                                  Row(
                                    children: [
                                      const Text('Status: ').small(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: getStatusColor(submission.status),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          getStatusText(submission.status),
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(8),
                                  Text('Predicted Score: ${submission.predictedScore.toStringAsFixed(1)}').small(),
                                  Text('Final Score: ${submission.finalScore.toStringAsFixed(1)}').small().semiBold(),
                                  if (submission.feedback != null) ...[
                                    const Divider().withPadding(vertical: 12),
                                    const Text('Feedback:').small().semiBold(),
                                    const Gap(4),
                                    Text(submission.feedback!).muted().small(),
                                  ],
                                ],
                              ),
                            ),
                            actions: [
                              PrimaryButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Basic(
                        leading: Avatar(
                          initials: submission.user.name![0].toUpperCase(),
                          backgroundColor: getStatusColor(submission.status).withOpacity(0.2),
                        ),
                        title: Text(submission.user.name ?? 'Unknown'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Predicted: ${submission.predictedScore.toStringAsFixed(1)}').small().muted(),
                            Text('Final: ${submission.finalScore.toStringAsFixed(1)}').small().semiBold(),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: getStatusColor(submission.status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            getStatusText(submission.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ).withPadding(bottom: 12);
                  }).toList(),
                ),
            ],
          ).withPadding(vertical: 11, horizontal: 16),
        ),
      )
    );
  }
}
