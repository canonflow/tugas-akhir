class AnchorModel {
  final int id;
  final String image;
  final String status;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnchorModel({
    required this.id,
    required this.image,
    required this.status,
    required this.name,
    required this.createdAt,
    required this.updatedAt
  });

  factory AnchorModel.fromJson(Map<String, dynamic> json) {
    return AnchorModel(
      id: json['id'],
      image: json['image'],
      status: json['status'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}