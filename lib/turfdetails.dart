import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'selectionslot.dart';

class TurfDetailsPage extends StatelessWidget {
  void _callNumber() async {
    final Uri phoneUri = Uri.parse('tel:8072833015');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print("Could not open the dialer.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F7FC),
      body: Column(
        children: [
          // Top Image with overlay icons
          Stack(
            children: [
              Image.asset(
                'assets/sun_turf.jpg',
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 40,
                left: 15,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 15,
                child: FloatingActionButton(
                  onPressed: _callNumber,
                  backgroundColor: Color(0xFFEADFF0),
                  child: Icon(Icons.call, color: Colors.purple),
                  mini: true,
                ),
              ),
            ],
          ),

          // Turf Details Card with increased width
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sun Turf",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Krishnankoil",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: "₹800.00 ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(text: "/ hour"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Description Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Detail",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Sun Turf is a well-known turf located in Krishnankoil, offering high-quality facilities for sports enthusiasts. "
                      "It provides well-maintained synthetic grass, proper lighting for night games, and a spacious playing area. "
                      "The turf is ideal for football, cricket, and other sports, ensuring a great experience for players. "
                      "Additionally, Sun Turf offers seating areas for spectators, ample parking space, and clean restrooms, "
                      "making it a convenient choice for sports lovers.",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
          ),

          Spacer(),

          // Book Turf Button
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectSlotPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Book Turf",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
