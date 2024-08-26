import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/size_config.dart';
import 'package:chat_app/widgets/dialog/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChattingUser extends StatefulWidget {
  const ChattingUser({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChattingUser> createState() => _ChatUserState();
}

class _ChatUserState extends State<ChattingUser> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            //navigating to chatscreen
            return ChatScreen(
              user: widget.user,
            );
          }));
        },
        child: Card(
            // margin: EdgeInsets.symmetric(
            //   horizontal: getProportionateScreenHeight(100),
            //   vertical: getProportionateScreenWidth(100),
            // ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: Colors.green.shade100,
            elevation: 1,
            child: StreamBuilder(
                stream: APIs.getLastMessage(widget.user),
                builder: (context, snapshot) {
                  final data = snapshot.data?.docs;
                  final list =
                      data?.map((e) => Message.fromJson(e.data())).toList() ??
                          [];
                  if (list.isNotEmpty) {
                    _message = list[0];
                  }
                  return ListTile(
                    leading: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return ProfileDialog(
                                user: widget.user,
                              );
                            });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: getProportionateScreenWidth(45),
                          height: getProportionateScreenHeight(45),
                          imageUrl: widget.user.image,
                          //placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          ),
                        ),
                      ),
                    ),
                    title: Text(widget.user.name),
                    subtitle: Text(
                      _message != null
                          ? _message!.type == Type.image
                              ? 'image'
                              : _message!.msg
                          : widget.user.about,
                      maxLines: 1,
                    ),
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty &&
                                _message!.formId != APIs.auth.currentUser!.uid
                            ? Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 0, 42, 49),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              )
                            : Text(
                                APIs.getLastMessageTime(
                                    context: context, time: _message!.sent),
                                style: TextStyle(color: Colors.black54),
                              ),
                  );
                })));
  }
}
