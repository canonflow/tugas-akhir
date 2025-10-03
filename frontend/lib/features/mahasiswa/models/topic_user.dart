class TopicUserModel {
  final int topicId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TopicUserModel({
    required this.topicId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt
  });

  factory TopicUserModel.fromJson(Map<String, dynamic> json) {
    return TopicUserModel(
      topicId: json['topic_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at'])
    );
  }
}