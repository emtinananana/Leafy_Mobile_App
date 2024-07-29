import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'L E A F Y',
          style: GoogleFonts.oswald(
            fontSize: 24,
            color: const Color.fromARGB(221, 44, 163, 58),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Got Questions or Issues?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Call : +91-9129-9129-91',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Email : support@leafy.com',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 60),
            const Text(
              'Follow us on:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    'assets/facebook.svg',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    'assets/twitter.svg',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    'assets/instagram.svg',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
