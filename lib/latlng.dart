import 'package:flutter/material.dart';
import 'package:s2geometry_dart/s2geometry_dart.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;

/// First feature screen
class S2ConverterLatlngScreen extends StatefulWidget {
  const S2ConverterLatlngScreen({super.key});
  @override
  _S2ConverterLatlngScreenState createState() => _S2ConverterLatlngScreenState();
}

class _S2ConverterLatlngScreenState extends State<S2ConverterLatlngScreen> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();

  // Define the result variables as member variables
  String s2point = '';
  String s2cell = '';
  String key = '';
  String idFromKey = '';
  String neighborKeys = '';

  // Google Maps controller
  late gm.GoogleMapController mapController;

  // initial center of the google map
  gm.LatLng _center = const gm.LatLng(37.7749, -122.4194);

  void _onMapCreated(gm.GoogleMapController controller) {
    mapController = controller;
  }
  
  /// convert function
  void _convertCoordinates() {
  double lat = double.tryParse(_latController.text) ?? 0.0;
  double lng = double.tryParse(_lngController.text) ?? 0.0;
  int level = int.tryParse(_levelController.text) ?? -1;

  if (level < 0 || level > 30) {
    setState(() {
      s2point = 'Error: Level must be between 0 and 30';
    });
  } else {
    // s2geometry_dart functions
    var latlng = LatLng(lat, lng);
    var s2pointVal = S2.latLngToXYZ(latlng);
    var s2cellVal = S2.fromLatLng(latlng, level);
    var keyVal = S2.latLngToKey(lat, lng, level);
    var idFromKeyVal = S2.keyToId(keyVal);
    var neighborsVal = S2.latLngToNeighborKeys(lat, lng, level);

    /// Update the member variables with results
    setState(() {
      s2point = s2pointVal.toString();
      s2cell = s2cellVal.toString();
      key = keyVal;
      idFromKey = idFromKeyVal.toString();
      neighborKeys = neighborsVal.toString();

      // Calculate the zoom level based on the S2 level
      double zoom = (level / 30) * 21;

      // Update the map center
      _center = gm.LatLng(lat, lng);
      mapController.moveCamera(
        gm.CameraUpdate.newLatLngZoom(_center, zoom),
      );
    });
  }
}


  /// Function to reset the input fields and result variables
  void _resetFields() {
    setState(() {
      _latController.clear();
      _lngController.clear();
      _levelController.clear();
      s2point = '';
      s2cell = '';
      key = '';
      idFromKey = '';
      neighborKeys = '';
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

            /// Latitude input field
            TextField(
              controller: _latController,
              decoration: InputDecoration(
                labelText: 'Latitude',
                hintText: 'Range: -90.0 to 90.0',
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

            /// Longitude input field
            TextField(
              controller: _lngController,
              decoration: InputDecoration(
                labelText: 'Longitude',
                hintText: 'Range: -180.0 to 180.0',
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

            /// Level input field
            TextField(
              controller: _levelController,
              decoration: InputDecoration(
                labelText: 'Level',
                hintText: 'Range: 0-30',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.blue[50],
                prefixIcon: const Icon(Icons.layers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            /// Convert and Reset buttons 
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
            /// S2Point Label and Copy Button
            const Text('S2Point:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, )),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: s2point),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(s2point, 'S2Point'),
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
            const Text('S2Cell (face, ij, level):', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

            /// Key Label and Copy Button
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

            /// ID Label and Copy Button
            const Text('S2CellID:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: idFromKey),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(idFromKey, 'S2CellID'),
              style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                    color: Colors.black, 
                    width: 2.0, 
                    ),
                  ),
              child: const Text('Copy'),
            ),
            const SizedBox(height: 20),

            /// Neighbors Label and Copy Button
            const Text('Neighbor Keys:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: neighborKeys),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard(neighborKeys, 'Neighbor Keys'),
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