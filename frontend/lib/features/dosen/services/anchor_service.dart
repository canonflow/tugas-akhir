import 'dart:io';

import 'package:frontend/core/utils/injections.dart';
import 'package:frontend/features/auth/models/user.dart';
import 'package:frontend/features/dosen/models/anchor.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/dosen/models/topic.dart';
import 'package:frontend/features/dosen/pages/references/create_page.dart';
import 'package:frontend/features/mahasiswa/models/topic_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

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

  // Create new references
  Future<String> createAnchorWithPairs(
      String name,
      File referenceImage,
      List<ImageScorePair> pairs,
      ) async {
    try {
      // Get API URL from .env
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        throw Exception('API_URL not found in environment variables');
      }

      final uri = Uri.parse('$apiUrl/api/re-train');
      final request = http.MultipartRequest('POST', uri);

      // Add reference name
      request.fields['new_reference_name'] = name;

      // Add reference image
      request.files.add(
        await http.MultipartFile.fromPath(
          'reference_image',
          referenceImage.path,
          contentType: MediaType.parse(_getMimeType(referenceImage.path)),
        ),
      );

      // Add sketches (images from pairs)
      for (var pair in pairs) {
        if (pair.image != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'sketches',
              pair.image!.path,
              contentType: MediaType.parse(_getMimeType(pair.image!.path)),
            ),
          );
        }
      }

      // Add scores
      for (var pair in pairs) {
        print(pair.scoreController.text);
        request.files.add(
          await http.MultipartFile.fromString(
            "scores",
              pair.scoreController.text
          )
        );
        // request.fields['scores'] = pair.scoreController.text;
      }

      print('Sending request to: $uri');
      print('Reference name: $name');
      print('Number of sketches: ${pairs.length}');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }

      // Parse response to get the created anchor
      final responseData = jsonDecode(response.body);

      // Assuming the API returns the anchor data
      // You might need to adjust this based on your actual API response
      if (responseData['message'] == "OK") {
        return "Success";
      } else {
        throw Exception('Invalid response from API');
      }
    } catch (e) {
      print('Error creating anchor with pairs: $e');
      rethrow;
    }
  }

  String _getMimeType(String path) {
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.jpeg') || path.endsWith('.jpg')) return 'image/jpeg';
    return 'application/octet-stream';
  }
}