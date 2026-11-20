import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pakelagi_mobile/main.dart';

void main() {
  testWidgets('Beranda renders and local interactions work', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Baru masuk'), findsOneWidget);
    expect(find.text('Flutter Demo Home Page'), findsNothing);
    expect(find.text('Beranda'), findsOneWidget);

    await tester.tap(find.text('Top').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Simpan favorit').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hapus favorit'), findsOneWidget);
    await tester.tap(find.byTooltip('Hapus favorit').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hapus favorit'), findsNothing);

    await tester.scrollUntilVisible(
      find.byTooltip('Filter'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih kategori'), findsOneWidget);
    await tester.tap(find.widgetWithText(ActionChip, 'Dress'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih kategori'), findsNothing);

    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();
    expect(find.text('Akun — pratinjau tampilan saja.'), findsOneWidget);
  });

  testWidgets('Beranda scrolls on narrow mobile screens without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Lemarimu penuh cerita.'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Pasang iklan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
