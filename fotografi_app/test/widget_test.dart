import 'package:flutter_test/flutter_test.dart';
import 'package:fotografi_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ShutterCloudApp());
    expect(find.text('SHUTTER DRIVE'), findsOneWidget);
  });
}
