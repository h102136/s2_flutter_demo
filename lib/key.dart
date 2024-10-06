import 'package:flutter/material.dart';
import 'package:s2geometry_dart/s2geometry_dart.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;

/// Second feature screen
class S2ConverterKeyScreen extends StatefulWidget {
  const S2ConverterKeyScreen({super.key});

  @override
  _S2ConverterKeyScreenState createState() => _S2ConverterKeyScreenState();
}

// S2 Key conversion screen
class _S2ConverterKeyScreenState extends State<S2ConverterKeyScreen> {
  final TextEditingController _keyController = TextEditingController();

  // Define the result variables as member variables
  String latlng = '';
  String cell = '';
  String id = '';
  String nextKey = '';
  String prevKey = '';
  String level = ''; 

  // Google Maps controller
  late gm.GoogleMapController mapController;

  // initial center of the google map
  gm.LatLng _center = const gm.LatLng(37.7749, -122.4194); // San Francisco 的經緯度

  void _onMapCreated(gm.GoogleMapController controller) {
    mapController = controller;
  }

  /// covert function
  void _convertCoordinates() {
    String key = _keyController.text;
    
    if (key.isEmpty || key.isEmpty) {
      setState(() {
        latlng = 'Error: Invalid key input.';
        cell = '';
        id = '';
        level = ''; 
      });
      return;
    }

    /// s2geometry_dart functions
    var latlngVal = S2.keyToLatLng(key);
    var cellVal = S2.fromHilbertQuadKey(key);
    var idVal = S2.keyToId(key);
    var nextKeyVal = S2.nextKey(key);
    var prevKeyVal = S2.prevKey(key);
    var lat = latlngVal.lat;
    var lng = latlngVal.lng;

    var calculatedLevel = (key.length - 2); 
    /// Calculate the zoom level based on the S2 level
    double zoom = (calculatedLevel / 30) * 21; 

    setState(() {
      latlng = latlngVal.toString();
      cell = cellVal.toString();
      id = idVal.toString();
      nextKey = nextKeyVal.toString();
      prevKey = prevKeyVal.toString();
      level = calculatedLevel.toString(); 

      // update the map center
      _center = gm.LatLng(lat, lng);
      mapController.moveCamera(
        gm.CameraUpdate.newLatLngZoom(_center, zoom),
      );
    });
  }

  /// Function to reset the input fields and result variables
  void _resetFields() {
    setState(() {
      _keyController.clear();
      latlng = '';
      cell = '';
      id = '';
      level = ''; 

      // initial center of the google map
      _center = const gm.LatLng(37.7749, -122.4194); 
      mapController.moveCamera(gm.CameraUpdate.newLatLngZoom(_center, 11.0));
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

            /// latlng Label and Copy Button
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

            /// S2Cell Label and Copy Button
            const Text('S2Cell:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: cell),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(cell, 'S2Cell'),
              style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                    color: Colors.black, 
                    width: 2.0, 
                    ),
                  ),
              child: const Text('Copy'),
            ),
            const SizedBox(height: 20),

            /// Key Label and Copy Button
            const Text('S2CellId:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: id),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(id, 'S2CellId'),
              style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                    color: Colors.black, 
                    width: 2.0, 
                    ),
                  ),
              child: const Text('Copy'),
            ),
            const SizedBox(height: 20),

            /// NextKey Label and Copy Button
            const Text('Next Key:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: nextKey),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(nextKey, 'Next Key'),
              style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                    color: Colors.black, 
                    width: 2.0, 
                    ),
                  ),
              child: const Text('Copy'),
            ),
            const SizedBox(height: 20),

            /// PrevKey Label and Copy Button
            const Text('Previous Key:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: prevKey),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(prevKey, 'Previous Key'),
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