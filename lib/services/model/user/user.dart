class User {
  final int userId;
  final String username;
  final String email;
  final String mobile;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.mobile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'],
      username: json['username'],
      email: json['email'],
      mobile: json['mobile'],
    );
  }
}
