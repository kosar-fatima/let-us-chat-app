import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/auth/login_screen.dart';
import 'package:chat_app/helper/dialog.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? IMage;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile Screen',
          ),
        ),
        body: Form(
          key: _formkey,
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      IMage != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.file(
                                  File(IMage!),
                                  width: SizeConfig.screenHeight * 0.2,
                                  height: SizeConfig.screenHeight * 0.2,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  width: getProportionateScreenWidth(160),
                                  height: getProportionateScreenHeight(160),
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                  //placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                    child: Icon(CupertinoIcons.person),
                                  ),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          shape: CircleBorder(),
                          color: Colors.white,
                          child: Icon(
                            Icons.edit,
                            color: Color.fromARGB(255, 0, 42, 49),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(10),
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(10),
                  ),
                  TextFormField(
                    onSaved: (newValue) => APIs.me.name = newValue!,
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Required Field',
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Name',
                    ),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(12),
                  ),
                  TextFormField(
                    onSaved: (newValue) => APIs.me.about = newValue!,
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Required Field',
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.info_outline_rounded),
                      hintText: 'About',
                    ),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(12),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();
                        APIs.updateser().then((value) => Dialogs.showSnackBar(
                            context, 'Profile updated successfully'));
                        log('Inside Validator');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 83, 168, 109),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      Icons.edit,
                      color: Color.fromARGB(255, 0, 42, 49),
                    ),
                    label: Text(
                      'Edit',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 42, 49),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Color.fromARGB(255, 83, 168, 109),
          onPressed: () async {
            Dialogs.showProgressBar(context);

            await APIs.updateActiveStatus(false);

            await APIs.auth.signOut().then(
                  (value) async => await GoogleSignIn().signOut().then(
                    (value) {
                      Navigator.pop(context);
                      Navigator.pop(context);

                      APIs.auth = FirebaseAuth.instance;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginScreen();
                          },
                        ),
                      );
                    },
                  ),
                );
          },
          icon: Icon(Icons.add_comment_outlined),
          label: Text('Logout'),
        ),
      ),
    );
  }

  void _showBottomSheet() {
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
            padding: EdgeInsets.only(
                top: SizeConfig.screenHeight * 0.03,
                bottom: SizeConfig.screenHeight * 0.05),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Pick Profile picture',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        log('Image Path: ${image.path} --${image.mimeType}');
                        setState(() {
                          IMage = image.path;
                        });
                        APIs.updateProfilePicture(File(IMage!));
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset(
                      'assets/images/add-image.jpg',
                      width: 300,
                      height: 300,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: CircleBorder(),
                      fixedSize: Size(
                        SizeConfig.screenWidth * 0.03,
                        SizeConfig.screenHeight * 0.15,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);
                      if (image != null) {
                        log('Image Path: ${image.path} --${image.mimeType}');
                        setState(() {
                          IMage = image.path;
                        });
                        APIs.updateProfilePicture(File(IMage!));
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/images/camera.png'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: CircleBorder(),
                      fixedSize: Size(
                        SizeConfig.screenWidth * 0.03,
                        SizeConfig.screenHeight * 0.15,
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }
}
