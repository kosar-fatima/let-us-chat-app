class Message {
  Message({
    required this.told,
    required this.msg,
    required this.read,
    required this.type,
    required this.formId,
    required this.sent,
  });
  late final String told;
  late final String msg;
  late final String read;
  late final Type type;
  late final String formId;
  late final String sent;

  Message.fromJson(Map<String, dynamic> json) {
    told = json['told'];
    msg = json['msg'];
    read = json['read'];
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    formId = json['formId'];
    sent = json['sent'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['told'] = told;
    _data['msg'] = msg;
    _data['read'] = read;
    _data['type'] = type.name;
    _data['formId'] = formId;
    _data['sent'] = sent;
    return _data;
  }
}

enum Type { text, image }
