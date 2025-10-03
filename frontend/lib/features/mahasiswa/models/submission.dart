import 'package:frontend/features/auth/models/user.dart';
import 'package:frontend/features/dosen/models/topic.dart';

class SubmissionModel {
  final int id;
  final TopicModel topic;
  final UserModel user;
  final double predictedScore;
  final double finalScore;
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
    required this.finalScore,
    required this.image,
    required this.status,
    this.feedback,
    required this.createdAt,
    required this.updatedAt
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'],
      topic: TopicModel.fromJson(json['topic']),
      user: UserModel.fromJson(json['user']),
      predictedScore: json['predicted_score'],
      finalScore: json['final_score'],
      image: json['image'], 
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at'])
    );
  }
}