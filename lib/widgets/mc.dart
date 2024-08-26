import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/helper/dialog.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MCard extends StatefulWidget {
  const MCard({super.key, required this.message});

  final Message message;

  @override
  State<MCard> createState() => _MCardState();
}

class _MCardState extends State<MCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.auth.currentUser!.uid == widget.message.formId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: APIs.auth.currentUser!.uid == widget.message.formId
          ? _greenMessage()
          : _blueMessage(),
    );
  }

  // sender message
  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? SizeConfig.screenWidth * 0.03
                : SizeConfig.screenWidth * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: SizeConfig.screenWidth * 0.04,
                vertical: SizeConfig.screenHeight * 0.01),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 221, 245, 255),
              border: Border.all(color: Colors.lightBlue),
              //curved border
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    //widget.message,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(
                          Icons.image,
                          size: 79,
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        // message time
        Row(
          children: [
            SizedBox(
              width: SizeConfig.screenWidth * 0.04,
            ),

            // message read time
            SizedBox(
              width: 1,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ],
    );
  }

  // receiver message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: SizeConfig.screenWidth * 0.04,
            ),
// double tick
            if (widget.message.read.isNotEmpty)
              Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),
            // message read time
            SizedBox(
              width: 1,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? SizeConfig.screenWidth * 0.03
                : SizeConfig.screenWidth * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: SizeConfig.screenWidth * 0.04,
                vertical: SizeConfig.screenHeight * 0.01),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 163, 224, 186),
              border: Border.all(color: Colors.lightGreen),
              //curved border
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    //widget.message,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(
                          Icons.image,
                          size: 79,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: SizeConfig.screenHeight * 0.015,
                  horizontal: SizeConfig.screenWidth * 0.4),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            widget.message.type == Type.text
                ? OptionItem(
                    icon: const Icon(
                      Icons.copy_all_outlined,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Copy Text',
                    onTap: () async {
                      log('not copied');
                      Navigator.of(context).pop();
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        Dialogs.showSnackBar(context, 'Text Copied');
                      });
                      log('copied');
                    })
                : OptionItem(
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Save Image',
                    onTap: () async {
                      try {
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: 'Chatting')
                            .then((success) {
                          Navigator.of(context).pop();
                          if (success != null) {
                            Dialogs.showSnackBar(
                                context, 'Image successfully saved');
                          }
                        });
                      } catch (e) {
                        log('Error while saving image');
                      }
                    },
                  ),
            Divider(
              color: Colors.black54,
              endIndent: SizeConfig.screenWidth * 0.04,
              indent: SizeConfig.screenWidth * 0.04,
            ),
            if (widget.message.type == Type.text && isMe)
              OptionItem(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 26,
                  ),
                  name: 'Edit Message',
                  onTap: () {
                    _showMessageUpdateDialog();
                  }),
            if (isMe)
              OptionItem(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 26,
                  ),
                  name: 'Delete Message',
                  onTap: () {
                    APIs.deleteMessage(widget.message)
                        .then((value) => {Navigator.of(context).pop()});
                  }),
            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: SizeConfig.screenWidth * 0.04,
                indent: SizeConfig.screenWidth * 0.04,
              ),
            OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: Colors.blue,
                ),
                name:
                    'Sent At: ${APIs.getMessageTime(context: context, time: widget.message.sent)}',
                onTap: () {}),
            OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: Colors.green,
                ),
                name: widget.message.read.isEmpty
                    ? 'Read At: Not seen yet'
                    : 'Read At: ${APIs.getMessageTime(context: context, time: widget.message.read)}',
                onTap: () {}),
          ],
        );
      },
    );
  }

  void _showMessageUpdateDialog() {
    String updateMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding:
                const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.message,
                  color: Color.fromARGB(255, 0, 42, 49),
                  size: 28,
                ),
                Text('Update Message'),
              ],
            ),
            content: TextFormField(
              maxLines: null,
              onChanged: (value) => updateMsg = value,
              initialValue: updateMsg,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 42, 49), fontSize: 16),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  APIs.updateMessage(widget.message, updateMsg);
                },
                child: Text(
                  'Update',
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 42, 49), fontSize: 16),
                ),
              ),
            ],
          );
        });
  }
}

class OptionItem extends StatelessWidget {
  const OptionItem(
      {super.key, required this.icon, required this.name, required this.onTap});
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: SizeConfig.screenWidth * 0.05,
            top: SizeConfig.screenHeight * 0.015,
            bottom: SizeConfig.screenHeight * 0.015),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '  $name',
                style: TextStyle(letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
