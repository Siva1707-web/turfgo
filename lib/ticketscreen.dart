import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class TicketScreen extends StatelessWidget {
  final String ticketId;
  final String turfName;
  final String selectedDate;
  final String selectedTime;
  final List<String> slotNumbers;
  final int totalAmount;

  const TicketScreen({
    Key? key,
    required this.ticketId,
    required this.turfName,
    required this.selectedDate,
    required this.selectedTime,
    required this.slotNumbers,
    required this.totalAmount,
  }) : super(key: key);

  // Fetch Ticket Details from Firestore
  Future<Map<String, dynamic>?> fetchTicketDetails() async {
    DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
        .collection('tickets') // Ensure collection name is correct
        .doc(ticketId)
        .get();

    return bookingDoc.exists ? bookingDoc.data() as Map<String, dynamic> : null;
  }

  // Generate & Share Ticket as PDF
  Future<void> generateAndSharePDF(Map<String, dynamic> details) async {
    final pdf = pdfLib.Document();

    pdf.addPage(
      pdfLib.Page(
        build: (context) => pdfLib.Column(
          crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
          children: [
            pdfLib.Text("Turf Ticket", style: pdfLib.TextStyle(fontSize: 24, fontWeight: pdfLib.FontWeight.bold)),
            pdfLib.SizedBox(height: 10),
            pdfLib.Text("Turf Name: ${details['turfName']}"),
            pdfLib.Text("Date: ${details['date']}"),
            pdfLib.Text("Time: ${details['time']}"),
            pdfLib.Text("Slots: ${details['slots'].join(', ')}"),
            pdfLib.Text("Amount Paid: ₹${details['amount']}"),
            pdfLib.Text("Ticket ID: $ticketId"),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/ticket_$ticketId.pdf");
    await file.writeAsBytes(await pdf.save());

    Share.shareFiles([file.path], text: "Here is your turf booking ticket.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Ticket")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchTicketDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Ticket not found"));
          }

          // Extract Ticket Details
          Map<String, dynamic> details = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Turf: ${details['turfName']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Date: ${details['date']}", style: const TextStyle(fontSize: 18)),
                Text("Time: ${details['time']}", style: const TextStyle(fontSize: 18)),
                Text("Slots: ${List<String>.from(details['slots']).join(', ')}", style: const TextStyle(fontSize: 18)),
                Text("Amount Paid: ₹${details['amount']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Ticket ID: $ticketId", style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => generateAndSharePDF(details),
                      child: const Text("Print"),
                    ),
                    ElevatedButton(
                      onPressed: () => generateAndSharePDF(details),
                      child: const Text("Share"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
