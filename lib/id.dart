import 'package:flutter/material.dart';
import 'package:s2geometry_dart/s2geometry_dart.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;

/// third feature screen
class S2ConverterIdScreen extends StatefulWidget {
  const S2ConverterIdScreen({super.key});

  @override
  _S2ConverterIdScreenState createState() => _S2ConverterIdScreenState();
}

// S2 Key conversion screen
class _S2ConverterIdScreenState extends State<S2ConverterIdScreen> {
  final TextEditingController _idController = TextEditingController();

  // Define the result variables as member variables
  String latlng = '';
  String key = '';
  String level = ''; 
  String s2cell = ''; 

  // Google Maps controller
  late gm.GoogleMapController mapController;

  // initial center of the google map
  gm.LatLng _center = const gm.LatLng(37.7749, -122.4194); 

  void _onMapCreated(gm.GoogleMapController controller) {
    mapController = controller;
  }
  
  /// convert function
  void _convertCoordinates() {
    String id = _idController.text;
    if (id.isEmpty || id.length > 64) {
      setState(() {
        latlng = 'Error: Invalid ID input.';
        key = '';
        level = '';
        s2cell = ''; 
      });
      return;
    }

    try {
      // s2geometry_dart functions
      var latlngVal = S2.idToLatLng(BigInt.parse(id));
      var keyVal = S2.idToKey(BigInt.parse(id));
      var s2cellVal = S2.fromHilbertQuadKey(keyVal); 
      var lat = latlngVal.lat;
      var lng = latlngVal.lng;
      var calculatedLevel = keyVal.length - 2; 

      setState(() {
        latlng = latlngVal.toString();
        key = keyVal.toString();
        level = calculatedLevel.toString();
        s2cell = s2cellVal.toString(); 

        // Calculate the zoom level based on the S2 level
        double zoom = (calculatedLevel / 30) * 21;

        _center = gm.LatLng(lat, lng);
        mapController.moveCamera(
          gm.CameraUpdate.newLatLngZoom(_center, zoom),
        );
      });
    } catch (e) {
      setState(() {
        latlng = 'Error: Failed to convert ID to coordinates.';
        key = '';
        level = '';
        s2cell = ''; 
      });
    }
  }

  /// Function to reset the input fields and result variables
  void _resetFields() {
    setState(() {
      _idController.clear();
      latlng = '';
      key = '';
      level = '';
      s2cell = ''; 
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

            /// id input field
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'ID',
                hintText: 'Maximum digits are 64',
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

            /// Google Maps widget
            SizedBox(
              height: 350, 
              child: gm.GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: gm.CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
              mapType: gm.MapType.hybrid,
              ),
            ),
            const SizedBox(height: 20),

            /// latlng and Copy Button
            const Text('Lat, Lng:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: latlng),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(latlng, 'LatLng'),
              style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                    color: Colors.black, 
                    width: 2.0, 
                    ),
                  ),
              child: const Text('Copy'),
            ),
            const SizedBox(height: 20),

            /// Level Label and Copy Button
            const Text('Level:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: level),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(level, 'Level'),
              style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                    color: Colors.black, 
                    width: 2.0, 
                    ),
                  ),
              child: const Text('Copy'),
            ),
            const SizedBox(height: 20),
            
            /// key Label and Copy Button
            const Text('Key:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: key),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(key, 'Key'),
              style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                    color: Colors.black, 
                    width: 2.0, 
                    ),
                  ),
              child: const Text('Copy'),
            ),
            const SizedBox(height: 20),

            /// S2Cell Label and Copy Button
            const Text('S2Cell:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: s2cell),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(s2cell, 'S2Cell'),
              style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                    color: Colors.black, 
                    width: 2.0, 
                    ),
                  ),
              child: const Text('Copy'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}