import 'dart:io';

import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/mahasiswa/models/submission.dart';
import 'package:frontend/features/mahasiswa/services/submission_service.dart';
import 'package:frontend/shared/app_bar.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class StudentDetailTopicPage extends StatefulWidget {
  final TopicModel topic;
  const StudentDetailTopicPage({super.key, required this.topic});

  static const route = "/mahasiswa/topic/deetail";

  @override
  State<StudentDetailTopicPage> createState() => _StudentDetailTopicPageState();
}

class _StudentDetailTopicPageState extends State<StudentDetailTopicPage> {
  final ImagePicker _picker = ImagePicker();
  final _predictedScoreController = TextEditingController(text: '80');
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey = GlobalKey<RefreshTriggerState>();
  final _submissionService = getIt<SubmissionService>();
  File? uploadedImage;
  bool isCalculating = false;
  bool isSubmitting = false;
  bool isLoadingHistory = true;

  // TODO: Dummy History Data
  List<SubmissionModel> historyData = [];

  // TODO: Load Submission History
  Future<void> loadSubmissionHistory() async {
    try {
      final submissions = await _submissionService.getUserSubmissions(widget.topic.id);
      print("Load Submission History");
      setState(() {
        historyData = submissions;
      });
    } catch (e) {
      print("Error load submission history: $e");
      if (mounted) {
        CustomSimpleDialog(context, "Error", e.toString());
      }
    } finally {
      setState(() {
        isLoadingHistory = false;
      });
    }
  }

  // TODO: Pick the image from galery
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        setState(() {
          uploadedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      CustomSimpleDialog(context, "Error", e.toString());
    }
  }

  // TODO: Remove the image
  void removeImage() {
    setState(() {
      uploadedImage = null;
    });
  }

  // TODO: Calculate the Similarity
  Future<void> calculateSimilarity() async {
    if (isCalculating) {
      CustomSimpleDialog(context, "Waiting", "Wait until the process is finished");
      return;
    }
    setState(() {
      isCalculating = true;
    });

    // TODO: Make API CALL (for now just simulate)
    try {
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _predictedScoreController.text = '${75 + (DateTime.now().millisecond % 20)}';
      });

    } catch (e) {
      CustomSimpleDialog(context, "Error", e.toString());
    } finally {
      setState(() {
        isCalculating = false;
      });
    }
  }

  // TODO: Submit the Submission
  Future<void> submitSubmission() async {

    // TODO: 01. If there is not uploaded image, then reject it
    if (uploadedImage == null) {
      CustomSimpleDialog(context, "Error", "Please upload an image first");
      return;
    }

    if (isSubmitting) {
      CustomSimpleDialog(context, "Waiting", "Wait until the process is finished");
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    // TODO: 2. Make the API Call (for now just simulate)
    try {
      // await Future.delayed(const Duration(seconds: 2));

      // TODO: 01. Get Predicted Score from Controller
      final predictedScore = double.parse(_predictedScoreController.text);

      // TODO: 02. Create submission via service
      final submission = await _submissionService
        .createSubmission(uploadedImage!, widget.topic.id, predictedScore);

      // TODO: 03. Add to history data at the beginning
      setState(() {
        historyData.insert(0, submission);
        uploadedImage = null;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Submission created successfully!'),
            actions: [
              PrimaryButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSimpleDialog(context, "Error", e.toString());
      }
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  String getStatusText(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'graded':
        return Colors.green;
      default:
        return Colors.gray;
    }
  }

  @override
  void initState() {
    super.initState();
    loadSubmissionHistory();
  }

  @override
  void dispose() {
    _predictedScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [CustomAppBar(context, widget.topic.name, true)],
      child: RefreshTrigger(
        key: _refreshTriggerKey,
        onRefresh: () async {
          setState(() {
            isLoadingHistory = true;
          });
          loadSubmissionHistory();
        },
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                // ===== TOPIC IMAGE =====
                Text(
                  "Reference Image",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.gray[700],
                  ),
                ),
                Gap(6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.topic.image!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.gray[300],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        ),
                      );
                    },
                  ),
                ),

                // ===== UPLOADED IMAGE SECTION =====
                if (uploadedImage != null) ...[
                  Gap(20),
                  Text(
                    "Sketch Image",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.gray[700],
                    ),
                  ),
                  Gap(6),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Image.file(
                          uploadedImage!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: OutlineButton(
                            size: ButtonSize.small,
                            density: ButtonDensity.icon,
                            onPressed: removeImage,
                            child: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                ],

                const Gap(16),

                // ===== SELECT IMAGE BUTTON =====
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        leading: const Icon(Icons.image),
                        onPressed: pickImage,
                        child: const Text('Select an image'),
                      ),
                    ),
                  ],
                ),

                const Gap(24),

                // ===== PREDICTED SCORE =====
                const Text('Predicted Score').semiBold(),
                const Gap(8),
                TextField(
                  controller: _predictedScoreController,
                  enabled: false,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const Gap(20),

                // ===== CALCULATE SIMILARITY BUTTON =====
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        leading: isCalculating ? const CircularProgressIndicator() : const Icon(Icons.calculate),
                        onPressed: isCalculating ? null : calculateSimilarity,
                        child: const Text('Calculate the Similarity'),
                      ),
                    ),
                  ],
                ),

                const Gap(12),

                // ===== SUBMIT BUTTON =====
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        leading: isSubmitting ? const CircularProgressIndicator() : const Icon(Icons.send),
                        onPressed: isSubmitting ? null : submitSubmission,
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),

                const Gap(32),

                // ===== HISTORY SECTION =====
                const Text(
                  'History',
                  style: TextStyle(
                    color: Colors.yellow
                  ),
                ).h4.bold().muted(),
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

                const Gap(10),

                if (isLoadingHistory)
                  Column(
                    children: List.generate(3, (index) {
                      return Row(
                        children: [
                          Expanded(
                            child: Basic(
                              title: const Text('Loading...').asSkeleton(),
                              content: const Text('Please wait...').asSkeleton(),
                              leading: const Avatar(initials: '').asSkeleton(),
                              trailing: const Text('Status').asSkeleton(),
                            ).withPadding(bottom: 20),
                          )
                        ]
                      );
                    }),
                  )
                else if (historyData.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.gray[400]),
                        const Gap(8),
                        const Text('No submission history').muted(),
                      ],
                    ).withPadding(vertical: 20),
                  )
                else
                  Column(
                    children: historyData.map((item) {
                      return Row(
                        children: [
                          Expanded(
                            child: CardButton(
                              onPressed: () {
                                print(item);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Leading icon
                                    Icon(
                                      item.finalScore != null
                                          ? Icons.check_circle
                                          : Icons.pending,
                                      color: getStatusColor(item.status),
                                    ),
                                    const Gap(12),

                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Title row with status
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text("Predicted Score"),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2
                                                ),
                                                decoration: BoxDecoration(
                                                    color: getStatusColor(item.status),
                                                    borderRadius: BorderRadius.circular(4)
                                                ),
                                                child: Text(
                                                  getStatusText(item.status),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          const Gap(8),

                                          // Scores
                                          Text('Score: ${item.predictedScore.toStringAsFixed(1)}')
                                              .small(),
                                          if (item.finalScore != null)
                                            Text('Final Score: ${item.finalScore!.toStringAsFixed(1)}')
                                                .small()
                                                .semiBold(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).withPadding(bottom: 12);
                    }).toList(),
                  ),
              ],
            ),
          ).withPadding(vertical: 10, horizontal: 16),
        ),
      )
    );
  }
}

