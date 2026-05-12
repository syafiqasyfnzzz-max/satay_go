import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:satay_master_pro/main.dart';

void main() {
  testWidgets('SatayGo smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SatayGoApp(),
      ),
    );

    expect(find.textContaining('SatayGo'), findsWidgets);
  });
}
