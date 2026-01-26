enum UserRole { farmer, admin }

class User {
  final String id;
  final String phoneNumber;
  final String? name;
  final UserRole role;

  User({required this.id, required this.phoneNumber, this.name, required this.role});
}
