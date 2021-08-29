import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../components/rounded_button.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();

    controller.addListener(() {
      setState(() {});
      print(animation.value);
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: [
                Hero(
                  tag: 'love',
                  child: Container(
                      child: Image.asset('image/love.png'), height: 60.h),
                ),
                TextLiquidFill(
                  boxBackgroundColor: Colors.white,
                  boxWidth: 200.w,
                  boxHeight: 80.h,
                  text: 'SanG Chat',
                  textStyle: TextStyle(
                    fontSize: 45.sp,
                    fontWeight: FontWeight.w900,
                  ),
                  waveColor: Colors.purple[900],
                )
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              title:'Log In',
              color: Colors.lightBlueAccent,
            onPressed: () {
            //Go to login screen.
            Navigator.pushNamed(context, LoginScreen.id);
          },),
            RoundedButton(
              title:'Register',
              color: Colors.blueAccent,
            onPressed: () {
            //Go to login screen.
            Navigator.pushNamed(context, RegistrationScreen.id);
          },),
          ],
        ),
      ),
    );
  }
}

