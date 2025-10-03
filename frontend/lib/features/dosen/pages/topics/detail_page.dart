import 'package:frontend/features/dosen/models/topic.dart';
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
              Text("SD")
            ],
          ).withPadding(vertical: 11, horizontal: 16),
        ),
      )
    );
  }
}
