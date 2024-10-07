class CDModel {
  String id;
  String name;

  CDModel({required this.id, required this.name});

  factory CDModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CDModel(
      id: documentId,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
