import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'success.dart';

class Signup2 extends StatefulWidget {
  @override
  _Signup2State createState() => _Signup2State();
}

class _Signup2State extends State<Signup2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void signUp() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showError("Please fill all fields");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 🔹 Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // 🔹 Store user details in Firestore (excluding password for security)
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "email": email,
          "timestamp": FieldValue.serverTimestamp(),
        });

        // 🔹 Save name & email in SharedPreferences for ProfilePage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', name);
        await prefs.setString('user_email', email);

        // 🔹 Navigate to Success Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        showError("This email is already registered. Please login.");
      } else if (e.code == "weak-password") {
        showError("Password should be at least 6 characters long.");
      } else if (e.code == "invalid-email") {
        showError("Enter a valid email address.");
      } else {
        showError("Signup failed: ${e.message}");
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
      backgroundColor: Color(0xFFF8F5F7),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Add your email",
                style: TextStyle(fontFamily: "SF-Pro", fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            SizedBox(height: 30),

            // Name Field
            Text("Name", style: TextStyle(fontFamily: "SF-Pro", fontSize: 16, color: Colors.black)),
            SizedBox(height: 5),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter your name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 15),

            // Email Field
            Text("Email", style: TextStyle(fontFamily: "SF-Pro", fontSize: 16, color: Colors.black)),
            SizedBox(height: 5),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Enter your email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 15),

            // Password Field
            Text("Password", style: TextStyle(fontFamily: "SF-Pro", fontSize: 16, color: Colors.black)),
            SizedBox(height: 5),
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: "Enter your password",
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
            SizedBox(height: 30),

            // Create Account Button
            ElevatedButton(
              onPressed: _isLoading ? null : signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8E24AA), // Purple color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                "Create an account",
                style: TextStyle(fontFamily: "SF-Pro", fontSize: 16, color: Colors.white),
              ),
            ),
            Spacer(),

            // Terms & Privacy Policy
            Center(
              child: Text(
                "By using TurfGo, you agree to the Terms and Privacy Policy.",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "SF-Pro", fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
