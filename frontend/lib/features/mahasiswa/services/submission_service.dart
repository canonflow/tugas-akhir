import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/mahasiswa/models/submission.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubmissionService {
  final SupabaseClient _supabase = Supabase.instance.client;

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

}