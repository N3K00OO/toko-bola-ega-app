class SessionUser {
  const SessionUser({
    required this.username,
    this.name,
    this.email,
    this.lastLogin,
  });

  final String username;
  final String? name;
  final String? email;
  final String? lastLogin;

  factory SessionUser.fromJson(
    Map<String, dynamic>? data, {
    String? lastLogin,
  }) {
    if (data == null) {
      return SessionUser(username: '-', name: '-', email: '-', lastLogin: lastLogin);
    }
    return SessionUser(
      username: data['username'] as String? ?? '-',
      name: data['name'] as String?,
      email: data['email'] as String?,
      lastLogin: lastLogin,
    );
  }

  SessionUser copyWith({
    String? username,
    String? name,
    String? email,
    String? lastLogin,
  }) {
    return SessionUser(
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
