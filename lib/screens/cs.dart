import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:chat_app/size_config.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CScreen extends StatefulWidget {
  const CScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<CScreen> createState() => _CScreenState();
}

class _CScreenState extends State<CScreen> {
  //storing messages
  List<Message> _list = [];
  bool _showEmoji = false;

  //handling message text changes
  final _textController = TextEditingController();

  //for checking if image is uploading or not
  bool _isuploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        // ignore: deprecated_member_use
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 204, 230, 174),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appbar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          // _list = ['A.O.A', 'How are you?'];
                          if (snapshot.data != null) {
                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                reverse: true,
                                padding: EdgeInsets.only(
                                    top: getProportionateScreenHeight(10)),
                                physics: BouncingScrollPhysics(),
                                itemCount: _list.length,
                                itemBuilder: (context, index) {
                                  print(
                                      "Index: $index, List length: ${_list.length}");
                                  return MessageCard(
                                    message: _list[index],
                                  );
                                },
                              );
                            } else {
                              return Center(child: Text('No data found!'));
                            }
                          } else {
                            return const Center(
                                child: Text('No Connection found!'));
                          }
                        default:
                          return const Center(
                              child: Text('Unknown ConnectionState'));
                      }
                    },
                    //stream: ,
                  ),
                ),
                if (_isuploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: CircularProgressIndicator(),
                      )),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.35,
                    child: EmojiPicker(
                      textEditingController:
                          _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                      config: Config(
                        columns: 7,
                        bgColor: const Color.fromARGB(255, 204, 230, 174),
                        emojiSizeMax: 32 *
                            (Platform.isIOS
                                ? 1.30
                                : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appbar() {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return ViewProfileScreen(user: widget.user);
            },
          ));
        },
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                //backbutton
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black54,
                  ),
                ),
                //user profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: getProportionateScreenWidth(45),
                    height: getProportionateScreenHeight(45),
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                    //placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : APIs.getLastActiveTime(
                                  context: context,
                                  lastActiveTime: list[0].last_active)
                          : APIs.getLastActiveTime(
                              context: context,
                              lastActiveTime: widget.user.last_active),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                )
              ],
            );
          },
        ));
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: SizeConfig.screenHeight * 0.01,
          horizontal: SizeConfig.screenWidth * 0.03),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: Icon(
                      Icons.emoji_emotions,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji)
                          setState(() {
                            _showEmoji = !_showEmoji;
                          });
                      },
                      decoration: InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 83, 168, 109),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 80);
                      if (images.isNotEmpty) {
                        setState(() {
                          _isuploading = !_isuploading;
                        });
                        for (var i in images) {
                          await APIs.sendChatImage(widget.user, File(i.path));
                        }
                        setState(() {
                          _isuploading = !_isuploading;
                        });
                      }
                    },
                    icon: Icon(
                      Icons.image,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(() {
                          _isuploading = !_isuploading;
                        });
                        await APIs.sendChatImage(widget.user, File(image.path));
                      }
                      setState(() {
                        _isuploading = !_isuploading;
                      });
                    },
                    icon: Icon(
                      Icons.camera_alt,
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.screenWidth * 0.02,
                  )
                ],
              ),
            ),
          ),
          // send message button
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  // on first message(add user to my_user collection of chat user)
                  APIs.sendFirstMessage(
                      widget.user, _textController.text, Type.text);
                } else {
                  // simply send messages
                  APIs.sendMessage(
                      widget.user, _textController.text, Type.text);
                }
                _textController.text = '';
              }
            },
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 5),
            child: Icon(Icons.send),
            shape: CircleBorder(),
          ),
        ],
      ),
    );
  }
}
