class Message {
  late String msg;
  late String read;
  late String told;
  late Type type;
  late String fromId;
  late String sent;
  late String edited;

  Message({
    required this.msg,
    required this.read,
    required this.told,
    required this.type,
    required this.fromId,
    required this.sent,
    required this.edited,
  });

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    read = json['read'].toString();
    told = json['told'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
    if (json.containsKey("edited")) {
      edited = json["edited"].toString();
    } else {
      edited = "";
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['msg'] = msg;
    data['read'] = read;
    data['told'] = told;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    data['edited'] = edited;
    return data;
  }
}

enum Type { text, image }
