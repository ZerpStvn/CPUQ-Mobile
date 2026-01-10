class Department {
  final String id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;

  Department({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'is_active': isActive,
    };
  }
}
