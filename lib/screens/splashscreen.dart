import 'package:flutter/material.dart';
import 'package:leafy_mobile_app/screens/landingscreen.dart';
import 'package:lottie/lottie.dart';

void main() => runApp(Splashscreen());

class Splashscreen extends StatefulWidget {
  const Splashscreen({Key? key}) : super(key: key);

  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the landing screen after a delay
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LandingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor:
            Color.fromARGB(244, 255, 255, 255), // Set background color
        body: Center(
          child: Lottie.asset(
            'assets/animation.json', // Replace with your animation file path
            width: 200, // Adjust width as needed
            height: 200, // Adjust height as needed
            fit: BoxFit.contain, // Adjust the fit
          ),
        ),
      ),
    );
  }
}
