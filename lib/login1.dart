import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profilepage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Password visibility toggle
  bool _isLoading = false; // Loading indicator

  void loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Please enter email and password");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ Firebase Authentication Login
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ Fetch user details from Firestore
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        // ✅ Save user details in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', userDoc["name"]);
        await prefs.setString('user_email', userDoc["email"]);
        await prefs.setString('profile_image', userDoc["profile_image"] ?? "");

        // ✅ Navigate to Profile Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      } else {
        showError("User data not found.");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showError("No account found. Please sign up.");
      } else if (e.code == 'wrong-password') {
        showError("Incorrect password. Please try again.");
      } else {
        showError("Login failed: ${e.message}");
      }
    } catch (e) {
      showError("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Log into account",
              style: TextStyle(fontFamily: "SF-Pro", fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              "Welcome back! Let’s continue learning",
              style: TextStyle(fontFamily: "SF-Pro", fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // ✅ Email Input
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 15),

            // ✅ Password Input with Visibility Toggle
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            // ✅ Login Button with Loading Indicator
            ElevatedButton(
              onPressed: _isLoading ? null : loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                "Log In",
                style: TextStyle(fontFamily: "SF-Pro", fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}