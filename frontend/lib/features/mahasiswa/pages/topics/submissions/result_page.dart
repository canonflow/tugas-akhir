import 'package:frontend/features/mahasiswa/models/submission.dart';
import 'package:frontend/shared/app_bar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
class StudentFinalSubmissionPage extends StatefulWidget {
  final SubmissionModel submission;
  const StudentFinalSubmissionPage({super.key, required this.submission});

  static const route = "/mahasiswa/topic/final";

  @override
  State<StudentFinalSubmissionPage> createState() => _StudentFinalSubmissionPageState();
}

class _StudentFinalSubmissionPageState extends State<StudentFinalSubmissionPage> {

  Color _getStatusColor(String status) {
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

  String _getStatusText(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [CustomAppBar(context, "Final Submission", true)],
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // ===== UPLOADED IMAGE =====
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.submission.image != null
                    ? Image.network(
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
                )
                    : Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.gray[300],
                  child: Center(
                    child: Text('Uploaded Image').h4,
                  ),
                ),
              ),

              const Gap(24),

              // ===== PREDICTED SCORE =====
              const Text('Predicted Score').semiBold(),
              const Gap(8),
              TextField(
                initialValue: widget.submission.predictedScore.toStringAsFixed(0),
                enabled: false,
                style: const TextStyle(fontSize: 18),
              ),

              const Gap(16),

              // ===== FINAL SCORE =====
              const Text('Final Score').semiBold(),
              const Gap(8),
              TextField(
                initialValue: widget.submission.finalScore != null
                    ? widget.submission.finalScore!.toStringAsFixed(0)
                    : 'Not graded yet',
                enabled: false,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: widget.submission.finalScore != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),

              const Gap(16),

              // ===== FEEDBACK =====
              const Text('Feedback').semiBold(),
              const Gap(8),
              TextArea(
                initialValue: widget.submission.feedback != null
                  ? widget.submission.feedback
                  : "No Feedback",
                expandableHeight: true,
                initialHeight: 300,
                enabled: false,
              ),

              const Gap(24),

              // ===== STATUS BADGE =====
              Row(
                children: [
                  const Text('Status: ').semiBold(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.submission.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getStatusText(widget.submission.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}
