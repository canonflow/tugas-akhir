import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/auth/models/user.dart';
import 'package:frontend/features/dosen/models/anchor.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/mahasiswa/models/topic_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnchorService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final authService = getIt<AuthService>();

  // DOSEN
  // TODO: Get all reference image from supabase (table 'anchors')
  // Get all anchors (reference images)
  Future<List<AnchorModel>> getAllAnchors() async {
    try {
      final response = await _supabase
          .from('anchors')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AnchorModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching anchors: $e');
      rethrow;
    }
  }

  // Get all active anchors (reference images)
  Future<List<AnchorModel>> getAllActiveAnchors() async {
    try {
      final response = await _supabase
          .from('anchors')
          .select()
          .eq("status", "active")
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AnchorModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching anchors: $e');
      rethrow;
    }
  }
}