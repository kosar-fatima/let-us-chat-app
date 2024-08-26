import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:chat_app/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        width: SizeConfig.screenWidth * 0.6,
        height: SizeConfig.screenHeight * 0.35,
        child: Stack(
          children: [
            //user profile picture
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(SizeConfig.screenHeight * 0.25),
                child: CachedNetworkImage(
                  width: SizeConfig.screenWidth * 0.5,

                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  //placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),
            //user name
            Positioned(
              left: SizeConfig.screenWidth * 0.04,
              top: SizeConfig.screenHeight * 0.02,
              width: SizeConfig.screenWidth * 0.55,
              child: Text(
                user.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            //info button
            Positioned(
              right: 8,
              top: 6,
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return ViewProfileScreen(user: user);
                    }),
                  );
                },
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
