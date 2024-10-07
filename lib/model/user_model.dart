class UserModel {
  final String id;
  final String name;
  final DateTime dob;
  final String gender;
  final String phone;
  final String roleId; // Assuming role is stored as an ID
  final String departmentId; // Assuming department is stored as an ID
  final List<String> subjects; // List of subjects
  final DateTime joinDate;
  final String levelId; // New levelId field

  UserModel({
    required this.id,
    required this.name,
    required this.dob,
    required this.gender,
    required this.phone,
    required this.roleId,
    required this.departmentId,
    required this.subjects,
    required this.joinDate,
    required this.levelId, // Add levelId to constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'name': name,
      'dob': dob.toIso8601String(),
      'gender': gender,
      'phone': phone,
      'roleId': roleId,
      'departmentId': departmentId,
      'subjects': subjects,
      'joinDate': joinDate.toIso8601String(),
      'levelId': levelId, // Add levelId to map
    };
  }

  static UserModel fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'],
      dob: DateTime.parse(map['dob']),
      gender: map['gender'],
      phone: map['phone'],
      roleId: map['roleId'],
      departmentId: map['departmentId'],
      subjects: List<String>.from(map['subjects']),
      joinDate: DateTime.parse(map['joinDate']),
      levelId: map['levelId'], // Add levelId to fromMap
    );
  }
}
