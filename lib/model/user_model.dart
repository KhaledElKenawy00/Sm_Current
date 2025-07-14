class Users {
  final int? usrId;
  final String fullName;
  final String email;
  final String usrName;
  final String password;

  Users({
    this.usrId,
    required this.fullName,
    required this.email,
    required this.usrName,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'usrId': usrId,
      'fullName': fullName,
      'email': email,
      'usrName': usrName,
      'usrPassword': password,
    };
  }

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      usrId: map['usrId'],
      fullName: map['fullName'],
      email: map['email'],
      usrName: map['usrName'],
      password: map['usrPassword'],
    );
  }
}
