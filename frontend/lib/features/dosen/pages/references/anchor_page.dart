import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/dosen/models/anchor.dart';
import 'package:frontend/features/dosen/pages/references/create_page.dart';
import 'package:frontend/features/dosen/services/anchor_service.dart';
import 'package:frontend/shared/app_bar.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AnchorsPage extends StatefulWidget {
  const AnchorsPage({super.key});

  static const route = "dosen/anchors";

  @override
  State<AnchorsPage> createState() => _AnchorsPageState();
}

class _AnchorsPageState extends State<AnchorsPage> {
  final anchorService = getIt<AnchorService>();
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey = GlobalKey<RefreshTriggerState>();

  List<AnchorModel> anchors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAnchors();
  }

  Future<void> loadAnchors() async {
    try {
      final fetchedAnchors = await anchorService.getAllAnchors();
      setState(() {
        anchors = fetchedAnchors;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading anchors: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        CustomSimpleDialog(context, "Error", "Failed to load anchors: $e");
      }
    }
  }

  void viewAnchorDetail(AnchorModel anchor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(anchor.name),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  anchor.image,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.gray[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
                      color: Colors.gray[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider().withPadding(vertical: 12),

              // Information
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ID: ').semiBold().small(),
                  Text('${anchor.id}').small().muted(),
                ],
              ),
              const Gap(8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Name: ').semiBold().small(),
                  Expanded(
                    child: Text(anchor.name).small().muted(),
                  ),
                ],
              ),
              const Gap(8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Created: ').semiBold().small(),
                  Expanded(
                    child: Text(
                        '${anchor.createdAt.day}/${anchor.createdAt.month}/${anchor.createdAt.year} ${anchor.createdAt.hour}:${anchor.createdAt.minute.toString().padLeft(2, '0')}'
                    ).small().muted(),
                  ),
                ],
              ),
              const Gap(8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Updated: ').semiBold().small(),
                  Expanded(
                    child: Text(
                        '${anchor.updatedAt.day}/${anchor.updatedAt.month}/${anchor.updatedAt.year} ${anchor.updatedAt.hour}:${anchor.updatedAt.minute.toString().padLeft(2, '0')}'
                    ).small().muted(),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        CustomAppBar(context, "All References", true)
      ],
      child: RefreshTrigger(
        key: _refreshTriggerKey,
        onRefresh: () async {
          setState(() {
            isLoading = true;
          });
          loadAnchors();
        },
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and refresh button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Anchors").h4().bold(),
                    OutlineButton(
                      size: ButtonSize.small,
                      density: ButtonDensity.icon,
                      onPressed: () {
                        _refreshTriggerKey.currentState!.refresh();
                      },
                      child: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ).withMargin(bottom: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        child: Text("New Reference"),
                        onPressed: () {
                          Navigator.pushNamed(context, CreateAnchorPage.route);
                        },
                      )
                    )
                  ],
                ).withMargin(bottom: 12),

                // Loading state
                if (isLoading)
                  Column(
                    children: List.generate(3, (index) {
                      return Basic(
                        title: const Text('Loading...').asSkeleton(),
                        content: const Text('Please wait...').asSkeleton(),
                        leading: Container(
                          width: 60,
                          height: 60,
                          color: Colors.gray[300],
                        ).asSkeleton(),
                      ).withPadding(bottom: 12);
                    }),
                  )

                // Empty state
                else if (anchors.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, size: 64, color: Colors.gray[400]),
                        const Gap(16),
                        const Text("No anchors yet").h4,
                        const Gap(8),
                        const Text("Create your first anchor to get started")
                            .muted()
                            .small(),
                      ],
                    ).withPadding(vertical: 40),
                  )

                // Anchors list
                else
                // Replace the anchors list section with:
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: anchors.length,
                    itemBuilder: (context, index) {
                      final anchor = anchors[index];
                      return GestureDetector(
                        onTap: () => viewAnchorDetail(anchor),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  anchor.image,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.gray[300],
                                      child: const Center(
                                        child: Icon(Icons.broken_image, size: 40),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(anchor.name).semiBold(),
                                    const Gap(4),
                                    Text('ID: ${anchor.id}').small().muted(),
                                    const Gap(4),
                                    Text("Status: ${anchor.status}").small()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ).withPadding(vertical: 10, horizontal: 16),
          ),
        ),
      ),
    );
  }
}