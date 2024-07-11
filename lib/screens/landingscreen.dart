import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leafy_mobile_app/screens/loginscreen.dart';
import 'package:leafy_mobile_app/screens/registerscreen.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: BackgroundImage());
  }
}

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/leafyleafyh.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'L E A F Y',
              style: GoogleFonts.oswald(
                color: Colors.white,
                fontSize: 43,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const RegisterScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(89, 149, 180, 158),
                        minimumSize: const Size(114, 40),
                      ),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.oswald(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      )),
                  const SizedBox(height: 26.0),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                // ignore: prefer_const_constructors
                                builder: (context) => LoginScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(89, 149, 180, 158),
                        minimumSize: const Size(114, 40),
                      ),
                      child: Text('Login',
                          style: GoogleFonts.oswald(
                            color: Colors.white,
                            fontSize: 20,
                          )))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
