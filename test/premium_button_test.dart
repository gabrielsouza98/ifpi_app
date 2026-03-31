import 'package:app_ifpi/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PremiumButton dispara callback uma unica vez por toque', (
    WidgetTester tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PremiumButton(
              label: 'Salvar',
              icon: Icons.save,
              onPressed: () => tapCount++,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PremiumButton));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets('PremiumButton em loading nao dispara callback', (
    WidgetTester tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PremiumButton(
              label: 'Salvar',
              icon: Icons.save,
              isLoading: true,
              onPressed: () => tapCount++,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PremiumButton));
    await tester.pump();

    expect(tapCount, 0);
  });
}
