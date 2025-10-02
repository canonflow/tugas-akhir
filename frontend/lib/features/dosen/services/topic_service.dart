import 'dart:io';

import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TopicService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final authService = getIt<AuthService>();

  Future<List<TopicModel>> getAll() async {
    final userId = authService.getCurrentUser().id!;

    final response = await _supabase.from("topics")
      .select()
      .eq("user_id", userId)
      .order("created_at", ascending: false);

    return (response as List)
      .map((json) => TopicModel.fromJson(json))
      .toList();
  }

  Future<TopicModel> create(String name, File image) async {
    try {
      final userId = authService.getCurrentUser().id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = image.path.split(".").last;
      final fileName = '$userId/$timestamp.$fileExtension';

      // TODO: 01. Upload the image to Supabase Storage
      final uploadResponse = await _supabase.storage
        .from("references")
        .upload(
          fileName,
          image,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: false,
            contentType: 'image/$fileExtension',
          ),
        );

      // TODO: 02. Get the public url of the uploaded image
      final publicImageUrl = _supabase.storage
        .from("references")
        .getPublicUrl(fileName);

      // TODO: 03. Insert data into database
      final data = await _supabase.from("topics")
        .insert({
          "name": name,
          "image": publicImageUrl
        })
        .select()
        .limit(1)
        .single();

      return TopicModel.fromJson(data);
    } catch (e) {
      print("Error creating topic: $e");
      rethrow;
    }
  }
}