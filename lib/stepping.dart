import 'package:flutter/material.dart';
import 'package:s2geometry_dart/s2geometry_dart.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;

/// Fourth feature screen
class S2ConverterStepScreen extends StatefulWidget {
  const S2ConverterStepScreen({super.key});

  @override
  _S2ConverterStepScreenState createState() => _S2ConverterStepScreenState();
}

class _S2ConverterStepScreenState extends State<S2ConverterStepScreen> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _stepController = TextEditingController();

  // Define the result variables as member variables
  String steppedKey = '';
  String steppedLatLng = '';
  String inputLatLng = ''; 

  // Google Maps controllers
  late gm.GoogleMapController mapController1; // first map controller
  late gm.GoogleMapController mapController2; // second map controller

  // initial center of the google map
  gm.LatLng _center1 = const gm.LatLng(37.7749, -122.4194); 
  gm.LatLng _center2 = const gm.LatLng(37.7749, -122.4194); 

  void _onMapCreated1(gm.GoogleMapController controller) {
    mapController1 = controller;
  }

  void _onMapCreated2(gm.GoogleMapController controller) {
    mapController2 = controller;
  }

  // convert function
  void _convertCoordinates() {
    String inputKey = _keyController.text; 
    int step = int.tryParse(_stepController.text) ?? 0;

    // s2geometry_dart functions
    var inputLatLngVal = S2.keyToLatLng(inputKey); 
    var steppedKeyVal = S2.stepKey(inputKey, step); 
    var steppedLatLngVal = S2.keyToLatLng(steppedKeyVal); 
    var calculatedLevel = (inputKey.length - 2); 

    /// Calculate the zoom level based on the S2 level
    double zoom = (calculatedLevel / 30) * 21; 

    // Update the member variables with results
    setState(() {
      inputLatLng = inputLatLngVal.toString();
      steppedKey = steppedKeyVal;
      steppedLatLng = steppedLatLngVal.toString();

      // update the first map center
      _center1 = gm.LatLng(inputLatLngVal.lat, inputLatLngVal.lng);
      mapController1.moveCamera(
        gm.CameraUpdate.newLatLngZoom(_center1, zoom),
      );

      // update the second map center
      _center2 = gm.LatLng(steppedLatLngVal.lat, steppedLatLngVal.lng);
      mapController2.moveCamera(
        gm.CameraUpdate.newLatLngZoom(_center2, zoom),
      );
    });
  }

  /// Function to reset the input fields and result variables
  void _resetFields() {
    setState(() {
      _keyController.clear();
      _stepController.clear();
      steppedKey = '';
      steppedLatLng = '';
      inputLatLng = '';

      // Reset the map center
      _center1 = const gm.LatLng(37.7749, -122.4194);
      mapController1.moveCamera(gm.CameraUpdate.newLatLngZoom(_center1, 11.0));
      _center2 = const gm.LatLng(37.7749, -122.4194);
      mapController2.moveCamera(gm.CameraUpdate.newLatLngZoom(_center2, 11.0));
    });
  }

  /// Function to copy to clipboard and show snackbar
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            /// Key input field
            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: 'Key',
                hintText: 'ex. 4/0123012301230123',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.blue[50],
                prefixIcon: const Icon(Icons.location_on),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),

            /// Step input field
            TextField(
              controller: _stepController,
              decoration: InputDecoration(
                labelText: 'Step',
                hintText: 'ex. 1, 2, -1, -2...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.blue[50],
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),

            /// Buttons: Convert and Reset
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _convertCoordinates,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 126, 211, 168),
                    side: const BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  child: const Text('Convert',
                      style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: _resetFields,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 238, 108, 99),
                    side: const BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  child: const Text('Reset',
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// first map: show the original coordinates
            const Text('Original Coordinates Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 350,
              child: gm.GoogleMap(
                onMapCreated: _onMapCreated1,
                initialCameraPosition: gm.CameraPosition(
                  target: _center1,
                  zoom: 11.0,
                ),
                mapType: gm.MapType.hybrid,
              ),
            ),
            const SizedBox(height: 20),

            /// show the input latlng
            const Text('Original LatLng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: inputLatLng),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(inputLatLng, 'Original LatLng'),
              style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                    color: Colors.black, 
                    width: 2.0,
                    ),
                  ),
              child: const Text('Copy'),
            ),
            const SizedBox(height: 20),

            /// second map: show the stepped coordinates
            const Text('Stepped Coordinates Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 350,
              child: gm.GoogleMap(
                onMapCreated: _onMapCreated2,
                initialCameraPosition: gm.CameraPosition(
                  target: _center2,
                  zoom: 11.0,
                ),
                mapType: gm.MapType.hybrid,
              ),
            ),
            const SizedBox(height: 20),

            /// stepped key and Copy Button
            const Text('Stepped Key:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: steppedKey),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(steppedKey, 'Stepped Key'),
              style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                    color: Colors.black, 
                    width: 2.0,
                    ),
                  ),
              child: const Text('Copy'),
            ),

            /// show the stepped latlng
            const Text('Stepped LatLng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: steppedLatLng),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(steppedLatLng, 'Stepped LatLng'),
              style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                    color: Colors.black, 
                    width: 2.0,
                    ),
                  ),
              child: const Text('Copy'),
            ),
          ],
        ),
      ),
    );
  }
}