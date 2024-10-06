import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s2_flutter_demo/main.dart'; 

void main() {
  testWidgets('S2GeometryDemo app initialization and navigation test', (WidgetTester tester) async {
    // Build the S2GeometryDemo app
    await tester.pumpWidget(const S2GeometryDemo());

    // Verify that the app starts on the S2HomePage with the AppBar title
    expect(find.text('S2Geometry Converter'), findsOneWidget);

    // Verify that the BottomNavigationBar has 4 items
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.featured_play_list), findsOneWidget);
    expect(find.byIcon(Icons.featured_video), findsOneWidget);
    expect(find.byIcon(Icons.featured_play_list_outlined), findsOneWidget);

    // Initially, it should display the 'Lat/Lng' page
    expect(find.text('Latitude'), findsOneWidget);
    expect(find.text('Longitude'), findsOneWidget);

    // Tap on the 'Key' tab in the BottomNavigationBar
    await tester.tap(find.byIcon(Icons.featured_play_list));
    await tester.pumpAndSettle(); // Wait for animations to settle

    // Verify that after tapping, the 'Key' page is displayed
    expect(find.textContaining('Key'), findsWidgets); // Finds any widget containing "Key"

    // Tap on the 'S2CellID' tab in the BottomNavigationBar
    await tester.tap(find.byIcon(Icons.featured_video));
    await tester.pumpAndSettle();

    // Verify that after tapping, the 'S2CellID' page is displayed
    expect(find.textContaining('ID'), findsWidgets); // Finds any widget containing "ID"

    // Tap on the 'Stepping' tab in the BottomNavigationBar
    await tester.tap(find.byIcon(Icons.featured_play_list_outlined));
    await tester.pumpAndSettle();

    // Verify that after tapping, the 'Stepping' page is displayed
    expect(find.text('Step'), findsOneWidget);

    // Finally, return to the 'Lat/Lng' page by tapping the 'Lat/Lng' icon
    await tester.tap(find.byIcon(Icons.map));
    await tester.pumpAndSettle();

    // Verify that we are back on the 'Lat/Lng' page
    expect(find.text('Latitude'), findsOneWidget);
    expect(find.text('Longitude'), findsOneWidget);
  });
}
