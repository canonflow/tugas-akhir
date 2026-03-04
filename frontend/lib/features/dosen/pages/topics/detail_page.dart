import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:frontend/core/utils/image_downloader.dart';
import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/dosen/pages/topics/enrolled_student.dart';
import 'package:frontend/features/dosen/pages/topics/submissions/grade_page.dart';
import 'package:frontend/features/mahasiswa/models/submission.dart';
import 'package:frontend/features/mahasiswa/services/submission_service.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
import 'package:frontend/shared/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:frontend/shared/app_bar.dart';
import 'package:http/http.dart' as http;

class DetailTopicPage extends StatefulWidget {
  final TopicModel topic;
  const DetailTopicPage({super.key, required this.topic});

  static const route = "dosen/topic/detail";

  @override
  State<DetailTopicPage> createState() => _DetailTopicPageState();
}

class _DetailTopicPageState extends State<DetailTopicPage> {
  final submissionService = getIt<SubmissionService>();
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey = GlobalKey<RefreshTriggerState>();
  List<SubmissionModel> submissions = [];
  bool isLoading = true;
  bool isDownloading = false;
  bool isDownloadingExcel = false;

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

  Future<void> showEnrolledStudents(TopicModel topic) async {
    showDialog(
      context: context,
      builder: (context) => EnrolledStudentDialog(topic: topic)
    );
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

  Future<void> downloadImage(BuildContext context, SubmissionModel submission) async {
    if (isDownloading) return;

    setState(() {
      isDownloading = true;
    });

    try {
      final finalPath = await imageDownloader(context, submission.image!);

      if (finalPath != null) {
        showToast(
          context: context,
          builder: buildToastSuccess,
          location: ToastLocation.topCenter
        );
      }
    } catch (e) {
      print(e.toString());
      if (mounted) {
        showToast(
          context: context,
          builder: buildToastError,
          location: ToastLocation.topCenter
        );
      }
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<void> exportSubmissionsToExcel(BuildContext context) async {
    if (submissions.isEmpty) {
      CustomSimpleDialog(context, "No Data", "No submissions to export");
      return;
    }

    if (isDownloadingExcel) return;

    setState(() {
      isDownloadingExcel = true;
    });

    try {
      // TODO: 01. Create Excel Workbook
      var excel = Excel.createExcel();

      Sheet sheetObject = excel["Submissions"];

      // TODO: 02. Set Headers
      sheetObject.appendRow([
        TextCellValue("Student Name"),
        TextCellValue("Email"),
        TextCellValue("Predicted Score"),
        TextCellValue("Final Score"),
        TextCellValue("Status"),
        TextCellValue("Feedback"),
      ]);

      // TODO: 03. Group submissions by user_id and get max final score
      Map<String, SubmissionModel> userBestSubmissions = {};
      for (var submission in submissions) {
        String userId = submission.user.id!;

        if (!userBestSubmissions.containsKey(userId)) {
          userBestSubmissions[userId] = submission;
        } else {
          // TODO: 03-01. Compare final scores and keep the highest
          var existingSubmission = userBestSubmissions[userId];
          var existingScore = existingSubmission?.finalScore ?? 0.0;
          var currectScore = submission.finalScore ?? 0.0;

          if (currectScore > existingScore) {
            userBestSubmissions[userId] = submission;
          }
        }
      }

      // TODO: 04. Add data rows
      for (var submission in userBestSubmissions.values) {
        sheetObject.appendRow([
          TextCellValue(submission.user.name ?? "Unknown"),
          TextCellValue(submission.user.email ?? "-"),
          DoubleCellValue(submission.predictedScore),
          submission.finalScore != null
            ? DoubleCellValue(submission.finalScore!)
            : TextCellValue("-"),
          TextCellValue(getStatusText(submission.status)),
          TextCellValue(submission.feedback ?? "-")
        ]);
      }

      // TODO: 05. Delete default Sheet1
      excel.delete('Sheet1');

      // TODO: 06. Save to temporary file
      var fileBytes = excel.save();
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = "${directory.path}/${widget.topic.name}_submissions_$timestamp.xlsx";

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);

      // TODO: 07. Save file using file dialog
      final params = SaveFileDialogParams(
        sourceFilePath: filePath,
        fileName: '${widget.topic.name}_submissions_$timestamp.xlsx',
      );
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null && mounted) {
        showToast(
          context: context,
          builder: buildToastSuccess,
          location: ToastLocation.topCenter,
        );
      }

    } catch (e) {
      print("Error exporting to Excel: $e");
      if (mounted) {
        showToast(
          context: context,
          builder: buildToastError
        );
      }
    } finally {
      setState(() {
        isDownloadingExcel = false;
      });
    }
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
      child: RefreshTrigger(
        key: _refreshTriggerKey,
        onRefresh: () async {
          setState(() {
            isLoading = true;
          });
          loadSubmissions();
        },
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

                // ===== BUTTON DOWLOAD =====
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                          onPressed: () async {
                            showEnrolledStudents(widget.topic);
                          },
                          child: Text("Students")
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Spacer(),
                    PrimaryButton(
                      onPressed: isDownloadingExcel ? null : () async {
                        await exportSubmissionsToExcel(context);
                      },
                      child: Text("Download")
                    ),
                  ]
                ),

                const Gap(20),

                // ===== SUBMISSIONS ======
                Text(
                  "Submission(s)",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ).bold,

                // ===== LIST OF SUBMISSION ======
                const Gap(16),
                // ===== BUTTONS =====
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
                SizedBox(height: 15),
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
                      return Row(
                        children: [Expanded(
                          child: GestureDetector(
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
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.network(
                                            submission.image!,
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
                                        const Gap(8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: PrimaryButton(
                                                child: Text("Download Image"),
                                                onPressed: () async {
                                                  downloadImage(context, submission);
                                                },
                                              ),
                                            )
                                          ],
                                        ),
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
                                        Text('Predicted Score: ${submission.predictedScore.toString()}').small(),
                                        if (submission.finalScore != null)
                                          Text('Final Score: ${submission.finalScore!.toString()}').small().semiBold(),
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
                                  Text('Predicted: ${submission.predictedScore.toString()}').small().muted(),
                                  if (submission.finalScore != null)
                                    Text('Final: ${submission.finalScore?.toString()}').small().semiBold(),

                                  PrimaryButton(
                                    size: ButtonSize.small,
                                    onPressed: () {
                                      if (submission.finalScore != null) {
                                        Navigator.pushNamed(
                                          context,
                                          LectureSubmissionGradePage.route,
                                          arguments: {
                                            "submission": submission,
                                            "type": "update"
                                          }
                                        );
                                      } else {
                                        Navigator.pushNamed(
                                            context,
                                            LectureSubmissionGradePage.route,
                                            arguments: {
                                              "submission": submission,
                                              "type": "create"
                                            }
                                        );
                                      }
                                    },
                                    child: submission.finalScore == null ? Text("Grade the submission") : Text("Update the Grade"),
                                  ),
                                  SizedBox(height: 4),
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
                          ).withPadding(bottom: 24),
                        ),
                      ]);
                    }).toList(),
                  ),
              ],
            ).withPadding(vertical: 11, horizontal: 16),
          ),
        ),
      )
    );
  }
}
