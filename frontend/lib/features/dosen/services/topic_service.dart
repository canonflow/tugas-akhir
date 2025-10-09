import 'dart:io';

import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/auth/models/user.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/mahasiswa/models/topic_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TopicService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final authService = getIt<AuthService>();

  // DOSEN
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

  // DOSEN
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

  // MAHASISWA
  // TODO: Get All topics user (student) has not joined
  Future<List<TopicModel>> getAvailableTopic(String userId) async {
    try {
      // TODO: 01. Get all topic IDs user has joined
      final joinedTopicsResponse = await _supabase
          .from("topic_users")
          .select('topic_id')
          .eq("user_id", userId);

      final joinedTopicIds = (joinedTopicsResponse as List)
        .map((item) => item['topic_id'] as int)
        .toList();

      // TODO: 02. Get all topics that user has not joined
      var query = _supabase.from("topics")
        .select();

      if (joinedTopicIds.isNotEmpty) {
        query = query.not("id", "in", joinedTopicIds);
      }

      final data = await query.order("created_at", ascending: false);

      return (data as List).map((json) => TopicModel.fromJson(json)).toList();
    } catch (e) {
      print("Error getting available topics: $e");
      rethrow;
    }
  }

  // MAHASISWA
  // TODO: Get All topics user has joined
  Future<List<TopicModel>> getJoinedTopic(String userId) async {
    try {
      final data = await _supabase
          .from('topics')
          .select("*")
          .inFilter(
            'id',
            await _supabase
              .from('topic_users')
              .select('topic_id')
              .eq('user_id', userId)
              .then((response) => (response as List).map((item) => item['topic_id']).toList())
          )
          .order('created_at', ascending: false);

      return (data as List).map((json) => TopicModel.fromJson(json)).toList();
    } catch (e) {
      print("Error getting joined topic: $e");
      rethrow;
    }
  }

  // MAHASISWA
  // TODO: Join the topic
  Future<TopicUserModel> joinTopic(TopicModel topic) async {
    try {
      final userId = authService.getCurrentUser().id!;

      final data = await _supabase
        .from("topic_users")
        .insert({
          'topic_id': topic.id,
          'user_id': userId
        })
        .select()
        .single();

      return TopicUserModel.fromJson(data);
    } catch (e) {
      print("Error Join Topic: $e");
      rethrow;
    }
  }

  // DOSEN
  // TODO: Get all users by topic
  Future<List<UserModel>> getTopicUsers(TopicModel topic) async {
    try {
      final response = await _supabase
        .from('topic_users')
        .select('''
          user_id,
          users!inner (
            id,
            email,
            name,
            role,
            created_at,
            updated_at
          )
        ''')
        .eq('topic_id', topic.id);

      return (response as List).map((json) {
        return UserModel.fromJson(json['users']);
      }).toList();
    } catch (e) {
      print("Error fetching topic users: $e");
      rethrow;
    }
  }
}