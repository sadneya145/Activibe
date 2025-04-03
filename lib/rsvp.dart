// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';

// class RSVPPage extends StatefulWidget {
//   @override
//   _RSVPPageState createState() => _RSVPPageState();
// }

// class _RSVPPageState extends State<RSVPPage> {
//   GoogleMapController? mapController;
//   LatLng? selectedLocation;
//   TextEditingController eventNameController = TextEditingController();
//   TextEditingController dateController = TextEditingController();
//   TextEditingController timeController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   // Get user's current location safely
//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         selectedLocation = LatLng(position.latitude, position.longitude);
//       });
//     } catch (e) {
//       print("Error getting location: $e");
//     }
//   }

//   // Handle map tap safely
//   void _onMapTap(LatLng latLng) {
//     setState(() {
//       selectedLocation = latLng;
//     });
//   }

//   // Validate and submit RSVP
//   void _submitRSVP() {
//     if (eventNameController.text.isEmpty ||
//         dateController.text.isEmpty ||
//         timeController.text.isEmpty ||
//         nameController.text.isEmpty ||
//         emailController.text.isEmpty ||
//         selectedLocation == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please fill all fields and select a location")),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("RSVP Confirmed 🎉"),
//         content: Text(
//             "You have successfully RSVP'd to ${eventNameController.text}.\n📍 Location: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}\n📅 Date: ${dateController.text}\n⏰ Time: ${timeController.text}"),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context), child: Text("OK"))
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("RSVP for an Event")),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: eventNameController,
//               decoration: InputDecoration(labelText: "Event Name"),
//             ),
//             TextField(
//               controller: dateController,
//               decoration: InputDecoration(labelText: "Date"),
//               readOnly: true,
//               onTap: () async {
//                 DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime(2101));
//                 if (picked != null) {
//                   dateController.text = DateFormat('yyyy-MM-dd').format(picked);
//                 }
//               },
//             ),
//             TextField(
//               controller: timeController,
//               decoration: InputDecoration(labelText: "Time"),
//               readOnly: true,
//               onTap: () async {
//                 TimeOfDay? picked = await showTimePicker(
//                     context: context, initialTime: TimeOfDay.now());
//                 if (picked != null) {
//                   timeController.text = picked.format(context);
//                 }
//               },
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: selectedLocation == null
//                   ? Center(child: CircularProgressIndicator())
//                   : GoogleMap(
//                       initialCameraPosition: CameraPosition(
//                         target: selectedLocation ?? LatLng(0, 0),
//                         zoom: 14,
//                       ),
//                       onMapCreated: (controller) {
//                         mapController = controller;
//                       },
//                       markers: selectedLocation != null
//                           ? {
//                               Marker(
//                                 markerId: MarkerId("selectedLocation"),
//                                 position: selectedLocation!,
//                               ),
//                             }
//                           : {},
//                       onTap: _onMapTap,
//                     ),
//             ),
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: "Your Name"),
//             ),
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(labelText: "Your Email"),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _submitRSVP,
//               child: Text("Confirm RSVP"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
