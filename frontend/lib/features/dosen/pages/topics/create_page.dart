import 'dart:io';

import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/dosen/services/topic_service.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:frontend/shared/app_bar.dart';

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
  bool isCreating = false;
  File? image = null;

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
              const Gap(16),

              // ===== Image Section =====
              const Text('Topic Image').semiBold().small(),
              const SizedBox(height: 8),

              // Show image preview if image is selected
              if (image != null) ...[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.gray[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Image.file(
                          image!,
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
                ),
                const Gap(8),
              ],

              // Image picker button
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      leading: const Icon(Icons.image),
                      onPressed: pickImage,
                      child: Text(image == null ? 'Select Image' : 'Change Image'),
                    ),
                  ),
                ],
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

                        if (image == null) {
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
                          final response = await topicService.create(_nameController.text, image!);
                          print(response);
                          CustomSimpleDialog(context, "Success", "New topic inserted successfully");
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
