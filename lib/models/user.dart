class User {
  final int userId;
  final String email;
  final String nickname;
  final String gender; // M/F/U
  final String? birthday; // yyyy-MM-dd
  final String role;
  final String? myps;

  User({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.gender,
    this.birthday,
    required this.role,
    this.myps,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['user_id'],
        email: json['email'],
        nickname: json['nickname'] ?? '',
        gender: json['gender'] ?? 'U',
        birthday: json['birthday'],
        role: json['role'] ?? 'student',
        myps: json['myps'],
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
        'nickname': nickname,
        'gender': gender,
        'birthday': birthday,
        'role': role,
        'myps': myps,
      };
}