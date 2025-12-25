import 'dart:io';

import 'package:flutter/services.dart';
import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/dosen/models/anchor.dart';
import 'package:frontend/features/dosen/services/anchor_service.dart';
import 'package:frontend/features/dosen/services/topic_service.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:frontend/shared/app_bar.dart';
import 'package:http/http.dart' as http;

class CreateTopicPage extends StatefulWidget {
  const CreateTopicPage({super.key});

  static const route = "dosen/topic/create";

  @override
  State<CreateTopicPage> createState() => _CreateTopicPageState();
}

class _CreateTopicPageState extends State<CreateTopicPage> {
  final _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final topicService = getIt<TopicService>();
  final anchorService = getIt<AnchorService>();
  bool isCreating = false;
  bool isLoadingAnchors = true;

  List<AnchorModel> availableAnchors = [];
  AnchorModel? selectedAnchor;
  File? image = null;

  String? selectedImageKey;

  @override
  void initState() {
    super.initState();
    loadAnchors();
  }

  Future<void> loadAnchors() async {
    try {
      final anchors = await anchorService.getAllActiveAnchors();
      setState(() {
        availableAnchors = anchors;
        isLoadingAnchors = false;
      });
    } catch (e) {
      print('Error loading anchors: $e');
      setState(() {
        isLoadingAnchors = false;
      });
      if (mounted) {
        CustomSimpleDialog(context, "Error", "Failed to load anchors: $e");
      }
    }
  }

  // Filter anchors based on search query
  List<AnchorModel> filterAnchors(String? query) {
    if (query == null || query.isEmpty) {
      return availableAnchors;
    }

    final lowerQuery = query.toLowerCase();
    return availableAnchors.where((anchor) {
      return anchor.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  final Map<String, String> availableImages = {
    // "Test": "public/images/test.jpg",
    // "Test 2": "public/images/test2.jpg",
    "Botol": "public/images/botol.png",
    "Buah 1": "public/images/buah-1.png",
    "Buah 2": "public/images/buah-2.png",
    "Rubik": "public/images/rubik.png"
  };

  // TODO: Pick the image
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100
      );

      if (pickedFile != null) {
        setState(() {
          image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text('Error'),
                content: Text('Failed to pick image: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  void removeImage() {
    setState(() {
      image = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        CustomAppBar(context, "Create New Topic", true)
      ],
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // ===== Nama =====
              const Text('Topic Name').semiBold().small(),
              const SizedBox(height: 4),
              TextField(
                placeholder: Text('Enter topic name'),
                controller: _nameController,
              ),
              const Gap(24),

              // ===== Image Section =====
              const Text('Topic Image').semiBold().small(),
              const SizedBox(height: 8),

              // ===== Image Preview =====
              if (selectedAnchor != null) ...[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.gray[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      selectedAnchor!.image,
                      width: double.infinity,
                      height: 500,
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
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
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
                ),
                const Gap(8),
                Text('Selected: ${selectedAnchor!.name}').small().muted(),
              ],

              const Gap(12),

              // ===== Anchor Dropdown =====
              if (isLoadingAnchors)
                const Center(child: CircularProgressIndicator())
              else if (availableAnchors.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.gray[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.image_not_supported, size: 48, color: Colors.gray[400]),
                      const Gap(8),
                      const Text('No anchors available').muted(),
                      const Gap(4),
                      const Text('Please create anchors first').small().muted(),
                    ],
                  ),
                )
              else
                Select<int>(
                  placeholder: const Text("Search reference image..."),
                  value: selectedAnchor?.id,
                  onChanged: (value) {
                    setState(() {
                      selectedAnchor = availableAnchors.firstWhere(
                            (anchor) => anchor.id == value,
                      );
                    });
                  },
                  itemBuilder: (context, item) {
                    final anchor = availableAnchors.firstWhere(
                          (a) => a.id == item,
                    );
                    return Text(anchor.name);
                  },
                  popupConstraints: const BoxConstraints(
                    maxHeight: 400,
                  ),
                  popup: SelectPopup.builder(
                    builder: (context, query) {
                      final filteredAnchors = filterAnchors(query);

                      if (filteredAnchors.isEmpty) {
                        return SelectItemList(
                          children: [
                            SelectItemButton(
                              value: -1, // Dummy value for empty state
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.search_off, size: 48, color: Colors.gray[400]),
                                    const Gap(8),
                                    const Text('No results found').muted(),
                                  ],
                                ).withPadding(vertical: 20),
                              ),
                            ),
                          ],
                        );
                      }

                      return SelectItemList(
                        children: [
                          for (final anchor in filteredAnchors)
                            SelectItemButton(
                              value: anchor.id,
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      anchor.image,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 40,
                                          height: 40,
                                          color: Colors.gray[300],
                                          child: const Icon(Icons.broken_image, size: 20),
                                        );
                                      },
                                    ),
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: Text(anchor.name),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              const Gap(16),

              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      child: const Text('Create'),
                      onPressed: () async {
                        if (isCreating) return;

                        // TODO: Implement create logic
                        if (_nameController.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Error"),
                              content: Text("Please enter a topic name"),
                              actions: [
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            )
                          );
                          return;
                        }

                        if (selectedAnchor == null) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Error'),
                              content: Text('Please select an image'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        setState(() {
                          isCreating = true;
                        });

                        // TODO: Call Topic Service
                        try {
                          // Download the anchor image from URL
                          final response = await http.get(Uri.parse(selectedAnchor!.image));

                          if (response.statusCode != 200) {
                            throw Exception('Failed to download anchor image');
                          }

                          // Save to temporary file
                          final tempDir = await getTemporaryDirectory();
                          final extension = selectedAnchor!.image.split('.').last.split('?').first;
                          final tempFile = File(
                              '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.$extension'
                          );
                          await tempFile.writeAsBytes(response.bodyBytes);

                          // TODO: 04. Create a new topic
                          final topic = await topicService.create(
                            _nameController.text,
                            tempFile
                          );

                          // Delete temporary file
                          if (await tempFile.exists()) {
                            await tempFile.delete();
                          }

                          if (mounted) {
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Success'),
                                content: const Text('New topic created successfully!'),
                                actions: [
                                  PrimaryButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      Navigator.pop(context); // Go back to previous page
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }

                        } catch (e) {
                          CustomSimpleDialog(context, "Error", e.toString());
                        } finally {
                          setState(() {
                            isCreating = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ).withPadding(vertical: 10, horizontal: 16),
        ),
      )
    );
  }
}
