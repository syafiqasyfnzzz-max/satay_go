class AppUser {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.role = 'user',
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
    };
  }
}
