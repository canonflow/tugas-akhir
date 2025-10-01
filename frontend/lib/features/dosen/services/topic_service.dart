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
}