import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/auth/login_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            systemNavigationBarColor: Colors.white),
      );
      if (APIs.auth.currentUser == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
          return LoginScreen();
        }));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
          return HomeScreen();
        }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            //curve: Curves.linear,

            top: getProportionateScreenHeight(10),
            left: getProportionateScreenWidth(10),
            right: getProportionateScreenWidth(10),

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
            child: Center(child: Text('Let us Communicate 😊')),
          ),
        ],
      ),
    );
  }
}
