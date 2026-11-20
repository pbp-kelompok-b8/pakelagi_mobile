import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pakelagi_mobile/main.dart';

void main() {
  testWidgets('Guest account fits narrow screens and opens journal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();
    expect(find.text('Masuk'), findsOneWidget);
    await tester.tap(find.text('Daftar akun baru'));
    await tester.pumpAndSettle();
    expect(
      find.text('Daftar akun baru — pratinjau tampilan saja.'),
      findsOneWidget,
    );
    ScaffoldMessenger.of(tester.element(find.text('Masuk')))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();
    final accountScroll = find.descendant(
      of: find.byKey(const PageStorageKey('akun-guest')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Tentang Pakelagi'),
      200,
      scrollable: accountScroll,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tentang Pakelagi'));
    await tester.pumpAndSettle();
    expect(
      find.text('Tentang Pakelagi — pratinjau tampilan saja.'),
      findsOneWidget,
    );
    ScaffoldMessenger.of(tester.element(find.text('Tentang Pakelagi')))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jurnal slow fashion'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Cari panduan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
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
  });

  testWidgets('Navigasi membuka setiap modul dan bisa kembali', (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Katalog'));
    await tester.pumpAndSettle();
    expect(find.text('Katalog Pakaian'), findsOneWidget);

    await tester.tap(find.text('Jual'));
    await tester.pumpAndSettle();
    expect(find.text('Pasang Listing'), findsOneWidget);

    await tester.tap(find.text('Jurnal'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Cari panduan'), findsOneWidget);

    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();
    expect(
      find.text('Satu akun untuk menyimpan, menghubungi, dan menjual.'),
      findsOneWidget,
    );
    expect(find.text('Daftar akun baru'), findsOneWidget);
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Masuk — pratinjau tampilan saja.'), findsOneWidget);

    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Favorit Tersimpan'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Favorit'), findsOneWidget);
    expect(find.text('Favorit Tersimpan'), findsNothing);

    final lihatKatalog = find.descendant(
      of: find.widgetWithText(Row, 'Baru masuk'),
      matching: find.text('Lihat semua'),
    );
    await tester.scrollUntilVisible(
      lihatKatalog,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(lihatKatalog);
    await tester.pumpAndSettle();
    expect(find.text('Katalog Pakaian'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
    await tester.ensureVisible(find.text('Pasang iklan'));
    await tester.tap(find.text('Pasang iklan'));
    await tester.pumpAndSettle();
    expect(find.text('Pasang Listing'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Pasang Listing'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
