class User {
  String userName;
  String email;
  String picture;
  String userId;
  String token;

  User({this.userName, this.email, this.picture, this.userId,this.token});

  factory User.fromJson(Map<String,dynamic> json){
    return User(
      userName: json['userName'],
      email: json['email'],
      picture: json['picture'],
      userId: json['userId'],
      token: json['token'],
    );
  }

}