import 'package:flutter/material.dart';
import 'login1.dart'; // Import login page
import 'signup2.dart'; // Import next signup page

class Signup1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F5F7), // Light background color
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80), // Added space at the top

            // Title
            Text(
              "Create new account",
              style: TextStyle(
                fontFamily: "SF-Pro",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 10),

            // Subtitle
            Text(
              "Start by creating your free TurfGo account. This makes it simple to manage bookings and access your favorite turfs with ease.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "SF-Pro", fontSize: 14, color: Colors.black54),
            ),

            SizedBox(height: 30),

            // Continue with email button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Signup2()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8E24AA), // Purple color from image
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                "Continue with email",
                style: TextStyle(fontFamily: "SF-Pro", fontSize: 16, color: Colors.white),
              ),
            ),

            SizedBox(height: 20),

            // "or" divider
            Text("or", style: TextStyle(fontFamily: "SF-Pro", color: Colors.black54)),

            SizedBox(height: 20),

            // Sign-in link
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                "Already have an account? Sign in",
                style: TextStyle(fontFamily: "SF-Pro", fontSize: 16, color: Colors.blue),
              ),
            ),

            Spacer(),

            // Terms and privacy policy
            Text(
              "By using TurfGo, you agree to the\nTerms and Privacy Policy.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "SF-Pro", fontSize: 12, color: Colors.black54),
            ),

            SizedBox(height: 30), // Space at bottom
          ],
        ),
      ),
    );
  }
}