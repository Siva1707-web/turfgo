import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'payment.dart';

class SelectSlotPage extends StatefulWidget {
  @override
  _SelectSlotPageState createState() => _SelectSlotPageState();
}

class _SelectSlotPageState extends State<SelectSlotPage> {
  DateTime? selectedDate;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> timeSlots = [];
  List<int> selectedSlots = [];
  User? user;

  @override
  void initState() {
    super.initState();
    generateTimeSlots();
    checkUserAuthentication(); // Check if user is logged in
  }

  void checkUserAuthentication() {
    user = _auth.currentUser; // Get logged-in user
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must log in to book slots")),
        );
        Navigator.pop(context); // Go back to previous screen
      });
    }
  }

  void generateTimeSlots() {
    for (int i = 0; i < 24; i++) {
      String start = DateFormat("hh:mma").format(DateTime(0, 0, 0, i, 0));
      String end = DateFormat("hh:mma").format(DateTime(0, 0, 0, i + 1, 0));
      timeSlots.add("$start - $end");
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchSlotAvailability() {
    if (selectedDate == null || user == null) {
      return const Stream.empty();
    }
    String dateStr = DateFormat("yyyy-MM-dd").format(selectedDate!);
    return _firestore.collection("bookings").doc(dateStr).snapshots();
  }

  void toggleSlotSelection(int index) {
    if (user == null) return; // Prevent selection if user is not logged in

    setState(() {
      if (selectedSlots.contains(index)) {
        selectedSlots.remove(index);
      } else {
        selectedSlots.add(index);
      }
    });
  }

  String _formatSelectedTime(List<int> selectedSlots) {
    if (selectedSlots.isEmpty) return "N/A";
    List<int> sortedSlots = List.from(selectedSlots)..sort();
    String startTime = timeSlots[sortedSlots.first].split(" - ")[0];
    String endTime = timeSlots[sortedSlots.last].split(" - ")[1];
    return "$startTime - $endTime";
  }

  void navigateToPayment() {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must log in to proceed to payment")),
      );
      return;
    }

    if (selectedSlots.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date and at least one slot")),
      );
      return;
    }

    String dateStr = DateFormat("yyyy-MM-dd").format(selectedDate!);
    String formattedTime = _formatSelectedTime(selectedSlots);
    int totalAmount = selectedSlots.length * 800;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          turfName: "Sun Turf",
          selectedDate: dateStr,
          selectedTime: formattedTime,
          slotNumbers: selectedSlots.map((index) => "Slot ${index + 1}").toList(),
          totalAmount: totalAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Select Slot"),
        backgroundColor: Colors.blue,
      ),
      body: user == null
          ? const Center(child: Text("You must log in to book slots"))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                    selectedSlots.clear();
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedDate == null
                      ? "Select Date"
                      : DateFormat("yyyy-MM-dd").format(selectedDate!),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          Expanded(
            child: selectedDate == null
                ? const Center(child: Text("Please select a date"))
                : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: fetchSlotAvailability(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                Map<String, dynamic>? data = asyncSnapshot.data?.data();
                bool documentExists = data != null;

                return ListView.builder(
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    String slot = timeSlots[index];
                    bool isBooked =
                    documentExists ? (data?[slot]?['booked'] ?? false) : false;
                    bool isSelected = selectedSlots.contains(index);

                    return GestureDetector(
                      onTap: isBooked ? null : () => toggleSlotSelection(index),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: isSelected ? Colors.blue.shade100 : Colors.white,
                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(slot,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500)),
                              Text("Slot ${index + 1}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800)),
                              Text(
                                isBooked
                                    ? "Unavailable"
                                    : (isSelected ? "Selected" : "Available"),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isBooked
                                        ? Colors.red
                                        : (isSelected ? Colors.blue : Colors.green)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (selectedSlots.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: navigateToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Next",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
