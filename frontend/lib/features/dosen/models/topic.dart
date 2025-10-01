class TopicModel {
  final int id;
  final String userId;
  final String name;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TopicModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.image,
    required this.createdAt,
    required this.updatedAt
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      image: json['image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
