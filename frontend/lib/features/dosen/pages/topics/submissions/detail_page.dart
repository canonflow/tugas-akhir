import 'package:frontend/features/mahasiswa/models/submission.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LectureSubmissionDetailPage extends StatefulWidget {
  final SubmissionModel submission;
  const LectureSubmissionDetailPage({super.key, required this.submission});

  static const route = "dosen/topic/submission/detail";

  @override
  State<LectureSubmissionDetailPage> createState() => _LectureSubmissionDetailPageState();
}

class _LectureSubmissionDetailPageState extends State<LectureSubmissionDetailPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
