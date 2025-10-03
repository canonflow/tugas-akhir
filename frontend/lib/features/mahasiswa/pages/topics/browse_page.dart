import 'package:frontend/shared/app_bar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class BrowseTopicPage extends StatefulWidget {
  const BrowseTopicPage({super.key});

  static const route = "/mahasiswa/topic/browse";

  @override
  State<BrowseTopicPage> createState() => _BrowseTopicPageState();
}

class _BrowseTopicPageState extends State<BrowseTopicPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [CustomAppBar(context, "Browse Topic", true)],
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text("SD")
            ],
          ).withPadding(vertical: 10, horizontal: 16),
        ),
      )
    );
  }
}
