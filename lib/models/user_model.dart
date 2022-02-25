class UserModel {
  String? name;
  String? phone;
  String? bio;
  String? uId;
  String? image;
  bool? announcement;

  UserModel({
    this.name,
    this.phone,
    this.bio,
    this.uId,
    this.image,
    this.announcement,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    bio = json['bio'];
    uId = json['uId'];
    image = json['image'];
    announcement = json['announcement'];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'bio': bio,
      'uId': uId,
      'image': image,
      'announcement': announcement,
    };
  }
}
