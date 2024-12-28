import 'dart:async';
import 'package:flutter/material.dart';

import '../constants/color.dart';
import 'folder_screen.dart'; // Import the color constants

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to FolderPage after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FolderPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width; // Get screen width

    return Scaffold(
      backgroundColor: tdBGColor, // Light grey background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Splash Logo
            Container(
              decoration: BoxDecoration(
                color: tdSurfaceColor, // White background for the logo
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: tdBorderColor.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(width > 600 ? 32 : 16), // Adjust padding based on screen width
              child: Image.asset(
                "assets/logo.jpeg", // Add your splash logo here
                width: width > 600 ? 160 : 120, // Adjust logo size based on screen width
                height: width > 600 ? 160 : 120, // Adjust logo size based on screen width
              ),
            ),
            SizedBox(height: width > 600 ? 48 : 24), // Adjust spacing based on screen width
            // App Name
            Text(
              'To-Do App',
              style: TextStyle(
                fontSize: width > 600 ? 40 : 28, // Adjust font size for larger screens
                fontWeight: FontWeight.bold,
                color: tdPrimaryColor, // Green shade for the title
              ),
            ),
            SizedBox(height: width > 600 ? 16 : 8), // Adjust spacing based on screen width
            // App Slogan
            Text(
              'Organize your tasks, simplify your life!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width > 600 ? 24 : 16, // Adjust font size for larger screens
                fontWeight: FontWeight.w400,
                color: tdTextSecondary, // Secondary text color
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: width > 600 ? 80 : 40), // Adjust spacing based on screen width
            // Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(tdPrimaryColor), // Green color for loading indicator
            ),
          ],
        ),
      ),
    );
  }
}
