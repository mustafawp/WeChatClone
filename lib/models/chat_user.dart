class ChatUser {
  late String id;
  late String name;
  late String email;
  late String about;
  late String image;
  late String createdAt;
  late String lastActive;
  late String pushToken;
  late bool isOnline;

  ChatUser(
      {required this.about,
      required this.createdAt,
      required this.email,
      required this.id,
      required this.image,
      required this.isOnline,
      required this.lastActive,
      required this.name,
      required this.pushToken});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "about": about,
      "image": image,
      "createdAt": createdAt,
      "lastActive": lastActive,
      "pushToken": pushToken,
      "isOnline": isOnline
    };
  }

  ChatUser.fromMap(Map<String, dynamic> json) {
    id = json["id"] ?? "";
    name = json["name"] ?? "";
    email = json["email"] ?? "";
    about = json["about"] ?? "";
    image = json["image"] ?? "";
    createdAt = json["createdAt"] ?? "";
    lastActive = json["lastActive"] ?? "";
    pushToken = json["pushToken"] ?? "";
    isOnline = json["isOnline"] ?? false;
  }
}
