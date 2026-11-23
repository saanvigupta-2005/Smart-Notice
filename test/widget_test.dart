
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_notice/main.dart';

void main() {
  testWidgets('Smart Notice login screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartNoticeApp());

    expect(find.text('Smart Notice'), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
