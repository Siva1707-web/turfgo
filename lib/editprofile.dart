import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool isLoading = true;
  bool isError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// ✅ **Fetches user details from Firestore (Fast & Reliable)**
  Future<void> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw "User is not logged in";

      DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = userData["name"] ?? "N/A";
          _emailController.text = userData["email"] ?? "N/A";
          _locationController.text = userData["location"] ?? "N/A";
          _mobileController.text = userData["mobile"] ?? ""; // ✅ Mobile remains empty if not set
          isLoading = false;
        });
      } else {
        throw "⚠ User data not found in Firestore.";
      }
    } catch (error) {
      print("🔥 Error fetching user data: $error");
      setState(() {
        isError = true;
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  /// ✅ **Updates user details (including mobile number) in Firestore**
  Future<void> updateProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw "User is not logged in";

      await _firestore.collection("users").doc(user.uid).update({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "location": _locationController.text.trim(),
        "mobile": _mobileController.text.trim(), // ✅ Updates mobile number
      });

      showSnackBar("Profile updated successfully!");
    } catch (error) {
      print("❌ Error updating profile: $error");
      showSnackBar("Error updating profile!");
    }
  }

  /// ✅ **Helper function to show snackbar messages**
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile", style: TextStyle(fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.purple[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
          ? Center(child: Text(errorMessage))
          : Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            inputField(Icons.person, "Full Name", _nameController, readOnly: false),
            inputField(Icons.email, "Email", _emailController, readOnly: true),
            inputField(Icons.location_on, "Location", _locationController, readOnly: false),
            inputField(Icons.phone, "Mobile Number", _mobileController, readOnly: false),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text("Update", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget inputField(IconData icon, String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.purple[700]),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
