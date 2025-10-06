import 'package:frontend/features/auth/models/user.dart';
import 'package:frontend/features/dosen/models/topic.dart';

class SubmissionModel {
  final int id;
  final TopicModel topic;
  final UserModel user;
  final double predictedScore;
  final double? finalScore;
  final String? image;
  final String status;
  final String? feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubmissionModel({
    required this.id,
    required this.topic,
    required this.user,
    required this.predictedScore,
    this.finalScore,
    required this.image,
    required this.status,
    this.feedback,
    required this.createdAt,
    required this.updatedAt
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    print('=== SubmissionModel.fromJson DEBUG ===');
    print('Full JSON keys: ${json.keys}');
    print('topic data: ${json['topic']}');
    print('user data: ${json['user']}');

    try {
      print('Parsing topic...');
      final topic = TopicModel.fromJson(json['topic']);
      print('Topic parsed successfully');

      print('Parsing user...');
      final user = UserModel.fromJson(json['user']);
      print('User parsed successfully');

      return SubmissionModel(
        id: json['id'],
        topic: topic,
        user: user,
        predictedScore: (json['predicted_score'] ?? 0.0).toDouble(),
        finalScore: json['final_score']?.toDouble(),
        image: json['image'],
        status: json['status'] ?? 'pending',
        feedback: json['feedback'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
    } catch (e, stackTrace) {
      print('Error in SubmissionModel.fromJson: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // factory SubmissionModel.fromJson(Map<String, dynamic> json) {
  //   return SubmissionModel(
  //     id: json['id'],
  //     topic: TopicModel.fromJson(json['topic']),
  //     user: UserModel.fromJson(json['user']),
  //     predictedScore: (json['predicted_score'] ?? 0.0).toDouble(),
  //     finalScore: (json['final_score'] ?? 0.0).toDouble(),
  //     image: json['image'],
  //     status: json['status'] ?? 'pending',
  //     feedback: json['feedback'] ?? "",
  //     createdAt: DateTime.parse(json['created_at']),
  //     updatedAt: DateTime.parse(json['updated_at']),
  //   );
  // }
}