import 'dart:io';

import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/mahasiswa/models/submission.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubmissionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = getIt<AuthService>();

  Future<String> getEndpoint() async {
    try {
      final response = await _supabase
          .from("server")
          .select("endpoint")
          .order('created_at', ascending: false)
          .single();

      return response['endpoint'] as String;
    } catch (e) {
      print("Error Fetching Endpoint: $e");
      rethrow;
    }
  }

  // DOSEN
  Future<List<SubmissionModel>> getSubmissionByTopic(TopicModel topic) async {
    try {
      final response = await _supabase
          .from("submissions")
          .select('''
            *,
            topics!inner (
              id,
              user_id,
              name,
              image,
              created_at,
              updated_at
            ),
            users!inner (
              id,
              email,
              name,
              role
            )
          ''')
          .eq("topic_id", topic.id)
          .order('created_at', ascending: false);


      return (response as List)
          .map((json) {
            final Map<String, dynamic> restructured = {
              ...json,
              'topic': json['topics'],
              'user': {
                "id": json['users']['id'],
                'email': json['users']['email'],
                'name': json['users']['name'],
                'role': json['users']['role']
              },
            };

            return SubmissionModel.fromJson(restructured);
          })
          .toList();
    } catch (e) {
      print("Error Fetching Submission: $e");
      rethrow;
    }
  }

  // MAHASISWA
  Future<List<SubmissionModel>> getUserSubmissions(int topicId) async {
    try {
      final userId = _authService.getCurrentUser().id!;

      // TODO: 01. Get the submissions by topic and user
      final response = await _supabase
        .from('submissions')
        .select('''
          *,
          topics!inner (
            id,
            user_id,
            name,
            image,
            created_at,
            updated_at
          ),
          users!inner (
            id,
            email,
            name,
            role,
            created_at,
            updated_at
          )
        ''')
        .eq("user_id", userId)
        .eq("topic_id", topicId)
        .order('created_at', ascending: false);

      // print("Response: $response");

      return (response as List).map((json) {
        // print("JSON: $json");
        final Map<String, dynamic> restructured = {
          ...json,
          'topic': json['topics'],
          'user': json['users'],
        };
        print(restructured);

        return SubmissionModel.fromJson(restructured);
      }).toList();
    } catch (e) {
      print("Error fetching user submissions: $e");
      rethrow;
    }
  }

  // MAHASISWA
  Future<SubmissionModel> createSubmission(File image, int topicId, double predictedScore) async {
    try {
      final userId = _authService.getCurrentUser().id!;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = image.path.split(".").last;
      final fileName = '$userId/$timestamp.$fileExtension';

      print("Uploading image to sketches bucket ...");

      // TODO: 01. Upload image to Supabase Storage
      await _supabase.storage
        .from("sketches")
        .upload(fileName, image)
        .timeout(const Duration(seconds: 30));

      // TODO: 02. Get Public URL
      final imageUrl = _supabase.storage
        .from("sketches")
        .getPublicUrl(fileName);

      print("Image uploaded: $imageUrl");

      // TODO: 03. Insert submission data
      final data = await _supabase.from("submissions")
        .insert({
          'topic_id': topicId,
          'image': imageUrl,
          'predicted_score': predictedScore,
          'status': 'pending'
        })
        .select('''
          *,
          topics!inner (
            id,
            user_id,
            name,
            image,
            created_at,
            updated_at
          ),
          users!inner (
            id,
            email,
            name,
            role
          )
        ''')
        .single()
        .timeout(const Duration(seconds: 15));

      print("Submission created successfully!");

      final restructured = {
        ...data,
        'topic': data['topics'],
        'user': data['users'],
      };
      print(restructured);

      return SubmissionModel.fromJson(restructured);
    } catch (e) {
      print("Error create submission: $e");
      rethrow;
    }
  }

  // DOSEN
  Future<void> gradeSubmission(SubmissionModel submission, double finalScore, String feedback) async {
    try {
      // TODO: 01. Prepare the query
      print(submission.id);
      await _supabase.from("submissions")
        .update({
          'final_score': finalScore,
          'feedback': feedback,
          'status': 'graded',
        })
        .eq('id', submission.id);
    } catch (e) {
      print("Error grade submission: $e");
      rethrow;
    }
  }
}