// lib/features/dosen/pages/anchors/create_anchor_page.dart
import 'dart:io';
import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/dosen/services/anchor_service.dart';
import 'package:frontend/shared/app_bar.dart';
import 'package:frontend/shared/custom_simple_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ImageScorePair {
  File? image;
  TextEditingController scoreController;

  ImageScorePair() : scoreController = TextEditingController();

  void dispose() {
    scoreController.dispose();
  }
}

class CreateAnchorPage extends StatefulWidget {
  const CreateAnchorPage({super.key});

  static const route = "dosen/anchors/create";

  @override
  State<CreateAnchorPage> createState() => _CreateAnchorPageState();
}

class _CreateAnchorPageState extends State<CreateAnchorPage> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  final anchorService = getIt<AnchorService>();

  File? referenceImage;
  List<ImageScorePair> pairs = [];
  bool isCreating = false;

  final int minPairs = 3;

  @override
  void initState() {
    super.initState();
    // Initialize with minimum 3 pairs
    for (int i = 0; i < minPairs; i++) {
      pairs.add(ImageScorePair());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var pair in pairs) {
      pair.dispose();
    }
    super.dispose();
  }

  void addPair() {
    setState(() {
      pairs.add(ImageScorePair());
    });
  }

  void removePair(int index) {
    if (pairs.length > minPairs) {
      setState(() {
        pairs[index].dispose();
        pairs.removeAt(index);
      });
    } else {
      CustomSimpleDialog(
        context,
        "Cannot Remove",
        "Minimum $minPairs pairs required",
      );
    }
  }

  Future<void> pickReferenceImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          referenceImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSimpleDialog(context, "Error", "Failed to pick image: $e");
      }
    }
  }

  Future<void> pickImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          pairs[index].image = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSimpleDialog(context, "Error", "Failed to pick image: $e");
      }
    }
  }

  Future<void> createAnchor() async {
    // Validation
    if (_nameController.text.isEmpty) {
      CustomSimpleDialog(context, "Error", "Please enter anchor name");
      return;
    }

    if (referenceImage == null) {
      CustomSimpleDialog(context, "Error", "Please select reference image");
      return;
    }

    // Check all pairs have images
    for (int i = 0; i < pairs.length; i++) {
      if (pairs[i].image == null) {
        CustomSimpleDialog(
          context,
          "Error",
          "Please select image for pair ${i + 1}",
        );
        return;
      }
    }

    // Check all scores are filled
    for (int i = 0; i < pairs.length; i++) {
      if (pairs[i].scoreController.text.isEmpty) {
        CustomSimpleDialog(
          context,
          "Error",
          "Please enter score for pair ${i + 1}",
        );
        return;
      }

      // Validate score is a number
      final score = double.tryParse(pairs[i].scoreController.text);
      if (score == null) {
        CustomSimpleDialog(
          context,
          "Error",
          "Score for pair ${i + 1} must be a valid number",
        );
        return;
      }

      if (score < 0 || score > 100) {
        CustomSimpleDialog(
          context,
          "Error",
          "Score for pair ${i + 1} must be between 0 and 100",
        );
        return;
      }
    }

    setState(() {
      isCreating = true;
    });

    try {
      // TODO: Call anchor service to create anchor with pairs
      // For now, just simulate creation
      await Future.delayed(const Duration(seconds: 2));

      anchorService.createAnchorWithPairs(
        _nameController.text,
        referenceImage!,
        pairs
      );

      // Here you would upload images and save the anchor with pairs
      // final anchor = await anchorService.createAnchorWithPairs(
      //   _nameController.text,
      //   pairs,
      // );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Anchor created successfully!'),
            actions: [
              PrimaryButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSimpleDialog(context, "Error", "Failed to create anchor: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        CustomAppBar(context, "Create Reference", true)
      ],
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Anchor Name =====
              const Text('Reference Name').semiBold(),
              const Gap(8),
              TextField(
                placeholder: const Text('Enter reference name'),
                controller: _nameController,
              ),
              const Gap(24),

              // ===== Reference Image =====
              const Text('Reference Image').semiBold(),
              const Gap(8),
              if (referenceImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        referenceImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: OutlineButton(
                        size: ButtonSize.small,
                        density: ButtonDensity.icon,
                        onPressed: () {
                          setState(() {
                            referenceImage = null;
                          });
                        },
                        child: const Icon(Icons.close),
                      ),
                    ),
                  ],
                )
              else
                GestureDetector(
                  onTap: pickReferenceImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.gray[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.gray[400]!,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            size: 64,
                            color: Colors.gray[600]
                        ),
                        const Gap(12),
                        const Text('Tap to select reference image').muted(),
                      ],
                    ),
                  ),
                ),

              const Gap(24),

              // ===== Image-Score Pairs =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Image & Score Pairs').semiBold(),
                  Text('(Minimum $minPairs pairs)').small().muted(),
                ],
              ),
              const Gap(12),

              // ===== Pairs List =====
              Column(
                children: List.generate(pairs.length, (index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.gray[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pair header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Pair ${index + 1}').semiBold(),
                            if (pairs.length > minPairs)
                              OutlineButton(
                                size: ButtonSize.small,
                                density: ButtonDensity.icon,
                                onPressed: () => removePair(index),
                                child: const Icon(Icons.delete, size: 18),
                              ),
                          ],
                        ),
                        const Gap(12),

                        // Image section
                        const Text('Image').small().muted(),
                        const Gap(8),
                        if (pairs[index].image != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  pairs[index].image!,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: OutlineButton(
                                  size: ButtonSize.small,
                                  density: ButtonDensity.icon,
                                  onPressed: () {
                                    setState(() {
                                      pairs[index].image = null;
                                    });
                                  },
                                  child: const Icon(Icons.close, size: 18),
                                ),
                              ),
                            ],
                          )
                        else
                          GestureDetector(
                            onTap: () => pickImage(index),
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.gray[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.gray[400]!,
                                  style: BorderStyle.solid,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      size: 48,
                                      color: Colors.gray[600]
                                  ),
                                  const Gap(8),
                                  Text('Tap to select image')
                                      .small()
                                      .muted(),
                                ],
                              ),
                            ),
                          ),

                        const Gap(12),

                        // Score section
                        const Text('Score').small().muted(),
                        const Gap(8),
                        TextField(
                          controller: pairs[index].scoreController,
                          placeholder: const Text('Enter score (0-100)'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              // ===== Add Pair Button =====
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      leading: const Icon(Icons.add),
                      onPressed: addPair,
                      child: const Text('Add Another Pair'),
                    ),
                  ),
                ],
              ),

              const Gap(24),

              // ===== Create Button =====
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: isCreating ? null : createAnchor,
                      child: const Text('Create Reference'),
                    ),
                  ),
                ],
              ),
            ],
          ).withPadding(vertical: 10, horizontal: 16),
        ),
      ),
    );
  }
}