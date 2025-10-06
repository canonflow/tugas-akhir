import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/auth/models/user.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/dosen/services/topic_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class EnrolledStudentDialog extends StatefulWidget {
  final TopicModel topic;
  const EnrolledStudentDialog({super.key, required this.topic});

  @override
  State<EnrolledStudentDialog> createState() => _EnrolledStudentDialogState();
}

class _EnrolledStudentDialogState extends State<EnrolledStudentDialog> {
  final topicService = getIt<TopicService>();
  bool isLoading = true;
  List<UserModel> students = [];

  Future<void> loadStudents() async {
    try {
      final fetchedStudents = await topicService.getTopicUsers(widget.topic);
      setState(() {
        students = fetchedStudents;
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.people),
          const Gap(8),
          const Text("Enrolled Student(s)")
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_off, size: 48, color: Colors.gray[400]),
                    const Gap(8),
                    const Text('No students enrolled yet').muted(),
                  ],
                ),
              )
            :
              ListView.builder(
                shrinkWrap: true,
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Basic(
                    leading: Avatar(initials: student.name![0].toUpperCase()),
                    title: Text(student.name ?? "Unknown"),
                    content: Text(student.email ?? '').small().muted(),
                  );
                }
              )
      ),
      actions: [
        OutlineButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Close")
        )
      ],
    );
  }
}
