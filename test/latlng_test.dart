import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s2_flutter_demo/latlng.dart';

void main() {
  testWidgets('Test input for Latitude, Longitude, and Level TextFields', (WidgetTester tester) async {
    // 加載 S2ConverterLatlngScreen
    await tester.pumpWidget(const MaterialApp(home: S2ConverterLatlngScreen()));

    // 調試信息：打印當前 widget 樹
    debugPrint(tester.allWidgets.toString());

    // 找到 Latitude TextField
    final latTextField = find.widgetWithText(TextField, 'Latitude');
    // 找到 Longitude TextField
    final lngTextField = find.widgetWithText(TextField, 'Longitude');
    // 找到 Level TextField
    final levelTextField = find.widgetWithText(TextField, 'Level');

    // 驗證三個 TextField 是否存在
    expect(latTextField, findsOneWidget);
    expect(lngTextField, findsOneWidget);
    expect(levelTextField, findsOneWidget);
  });
}
