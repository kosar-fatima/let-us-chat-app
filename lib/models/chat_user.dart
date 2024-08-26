class ChatUser {
  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.created_at,
    required this.isOnline,
    required this.id,
    required this.last_active,
    required this.email,
    required this.pushToken,
  });
  late String image;
  late String about;
  late String name;
  late String created_at;
  late bool isOnline;
  late String id;
  late String last_active;
  late String email;
  late String pushToken;

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    created_at = json['created at'] ?? '';
    isOnline = json['is_online'] ?? false;
    id = json['id'] ?? '';
    last_active = json['last active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['image'] = image;
    _data['about'] = about;
    _data['name'] = name;
    _data['created at'] = created_at;
    _data['is_online'] = isOnline;
    _data['id'] = id;
    _data['last active'] = last_active;
    _data['email'] = email;
    _data['push_token'] = pushToken;
    return _data;
  }
}
