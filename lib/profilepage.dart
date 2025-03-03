import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login1.dart';
import 'editprofile.dart';
import 'mydetails.dart';
import 'privacy_policy.dart';
import 'terms_conditions.dart';
import 'homepage.dart'; // ✅ Import HomePage

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String? _imageBase64;
  String userName = "Loading...";
  String userEmail = "Loading...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// ✅ Fetches user details from Firestore & SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('user_name');
    String? savedEmail = prefs.getString('user_email');
    String? savedImage = prefs.getString('profile_image');

    if (savedName != null && savedEmail != null) {
      setState(() {
        userName = savedName;
        userEmail = savedEmail;
        _imageBase64 = savedImage;
        isLoading = false;
      });
    } else if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          userName = userData["name"] ?? "User";
          userEmail = userData["email"] ?? "No Email";
          _imageBase64 = userData["profile_image"] ?? "";
          isLoading = false;
        });

        await prefs.setString('user_name', userName);
        await prefs.setString('user_email', userEmail);
        await prefs.setString('profile_image', _imageBase64 ?? "");
      }
    }
  }

  /// ✅ Allows user to pick an image and store it as Base64 in Firestore
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      String base64String = base64Encode(imageBytes);

      // ✅ Update Firestore with Base64 image
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
        "profile_image": base64String,
      });

      // ✅ Save in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', base64String);

      setState(() {
        _imageBase64 = base64String;
      });
    }
  }

  /// ✅ Logs out user, clears saved data, and redirects to login1.dart
  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade800,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // ✅ Redirect to HomePage
            );
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.purple.shade800,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
              ),
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: _imageBase64 != null && _imageBase64!.isNotEmpty
                                  ? Image.memory(base64Decode(_imageBase64!),
                                  width: 110, height: 110, fit: BoxFit.cover)
                                  : Image.asset('assets/default_profile.png',
                                  width: 110, height: 110, fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.purple.shade800,
                                child: Icon(Icons.edit, size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      userName,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 60),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildProfileOption(Icons.person, "Edit Profile", context, EditProfile()),
                _buildProfileOption(Icons.info, "My Details", context, MyDetails()),
                _buildProfileOption(Icons.privacy_tip, "Privacy Policy", context, PrivacyPolicyPage()),
                _buildProfileOption(Icons.description, "Terms & Conditions", context, TermsConditionsPage()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ElevatedButton.icon(
                    onPressed: logoutUser,
                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text("Logout", style: TextStyle(fontSize: 18, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade800,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, BuildContext context, Widget page) {
    return ListTile(
      leading: Icon(icon, size: 28, color: Colors.black54),
      title: Text(title, style: TextStyle(fontSize: 18)),
      trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black38),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}
