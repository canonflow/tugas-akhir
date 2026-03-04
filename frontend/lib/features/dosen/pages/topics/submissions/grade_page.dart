import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/mahasiswa/models/submission.dart';
import 'package:frontend/features/mahasiswa/services/submission_service.dart';
import 'package:frontend/shared/app_bar.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LectureSubmissionGradePage extends StatefulWidget {
  final SubmissionModel submission;
  final String type;
  const LectureSubmissionGradePage({super.key, required this.submission, required this.type});

  static const route = "dosen/topic/submission/detail";

  @override
  State<LectureSubmissionGradePage> createState() => _LectureSubmissionGradePageState();
}

class _LectureSubmissionGradePageState extends State<LectureSubmissionGradePage> {
  final _submissionService = getIt<SubmissionService>();
  late final TextEditingController _finalScoreController;
  late final TextEditingController _feedbackController;
  bool isGrading = false;

  Future<void> gradeTheSubmission(String type, SubmissionModel submission) async {
    if (isGrading) return;

    if (_finalScoreController.text.isEmpty) {
      CustomSimpleDialog(context, "Error", "Please input the final score");
      return;
    }

    if (_feedbackController.text.isEmpty) {
      _feedbackController.text = "No feedback";
    }

    setState(() {
      isGrading = true;
    });

    print("GRADING ...");

    try {
      // TODO: Perform Update the submission's grade
      final feedback = _feedbackController.text;
      final finalScore = double.parse(_finalScoreController.text);

      await _submissionService.gradeSubmission(submission, finalScore, feedback);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: Text(
              widget.type == "create"
                  ? 'Submission graded successfully!'
                  : 'Grade updated successfully!',
            ),
            actions: [
              PrimaryButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Return to previous page with success flag
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        CustomSimpleDialog(context, "Error", e.toString());
      }
    } finally {
      setState(() {
        isGrading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _finalScoreController = TextEditingController(
        text: widget.submission.finalScore?.toString() ?? ''
    );
    _feedbackController = TextEditingController(
        text: widget.submission.feedback ?? ''
    );
  }

  @override
  void dispose() {
    _finalScoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [CustomAppBar(context, "Grade | " + widget.submission.user.name!, true)],
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sketch Image").h3,
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.submission.image!,
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
              SizedBox(height: 14),

              // ===== Information =====
              Text("Predicted Score").medium,
              SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: widget.submission.predictedScore.toString()),
                enabled: false,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 16),


              // ===== FINAL SCORE ======
              Text("Final Score").medium,
              SizedBox(height: 10),
              TextField(
                controller: _finalScoreController,
                enabled: true,
                placeholder: Text("Input the final score"),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 16),

              // ====== FEEDBACK ======
              Text("Feedback").medium,
              SizedBox(height: 10),
              TextArea(
                controller: _feedbackController,
                expandableHeight: true,
                initialHeight: 160,
                placeholder: Text("Input the feedback (optional)"),
              ),

              SizedBox(height: 22),

              // ===== BUTTON =====
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: isGrading ? null : () async {
                        await gradeTheSubmission(widget.type, widget.submission);
                      },
                      child: widget.type == "update" ? Text("Update") : Text("Grade"),
                    )
                  )
                ],
              )
            ],
          ).withPadding(vertical: 10, horizontal: 16),
        ),
      )
    );
  }
}
