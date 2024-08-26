import 'dart:io';

import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/helper/dialog.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(microseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        if (await APIs.userExist()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return HomeScreen();
              },
            ),
          );
        } else {
          await APIs.createUser().then((value) => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return HomeScreen();
                  },
                ),
              ));
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print('_signInwithgoogle: $e');
      Dialogs.showSnackBar(
          context, 'Something went wrong Check Internet connection');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Let us Chat',
        ),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            //curve: Curves.linear,
            duration: Duration(seconds: 1),
            top: getProportionateScreenHeight(10),
            left: getProportionateScreenWidth(10),
            right: _isAnimate
                ? getProportionateScreenWidth(10)
                : -SizeConfig.screenWidth - 300,
            bottom: getProportionateScreenHeight(100),
            child: Image.asset(
              'assets/images/emoji.png',
              scale: getProportionateScreenHeight(1.8),
            ),
          ),
          Positioned(
            top: getProportionateScreenHeight(610),
            left: getProportionateScreenWidth(50),
            right: getProportionateScreenWidth(50),
            bottom: getProportionateScreenHeight(80),
            child: ElevatedButton.icon(
              onPressed: () {
                _handleGoogleBtnClick();
              },
              icon: Image.asset(
                'assets/images/google.png',
                scale: getProportionateScreenHeight(24),
              ),
              label: Text(
                'Login with Google',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
