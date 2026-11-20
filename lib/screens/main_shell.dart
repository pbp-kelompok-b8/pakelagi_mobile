import 'package:flutter/material.dart';

import '../sustainable_guides/screens/jurnal_page.dart';
import 'beranda_page.dart';

enum _Tab { beranda, katalog, jual, jurnal, akun }

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  _Tab _tab = _Tab.beranda;

  void _select(_Tab tab) {
    if (tab == _tab) return;
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    setState(() => _tab = tab);
  }

  void _openModule(String title, String description) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: _ModulePreview(description: description),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: _tab == _Tab.beranda,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(_Tab.beranda);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _tab.index,
          children: [
            BerandaPage(
              onOpenFavorites: () => _openModule(
                'Favorit Tersimpan',
                'Daftar listing yang kamu simpan akan tampil di sini.',
              ),
              onOpenCatalog: () => _select(_Tab.katalog),
              onOpenJournal: () => _select(_Tab.jurnal),
              onOpenSell: () => _select(_Tab.jual),
            ),
            const _ModulePreview(
              title: 'Katalog Pakaian',
              description: 'Daftar pakaian preloved akan tampil di sini.',
            ),
            const _ModulePreview(
              title: 'Pasang Listing',
              description: 'Form untuk memasang listing akan tersedia di sini.',
            ),
            const JurnalPage(),
            _ModulePreview(
              title: 'Profil dan Akun',
              description:
                  'Informasi profil dan pengaturan akun akan tampil di sini.',
              action: OutlinedButton.icon(
                onPressed: () => _openModule(
                  'Laporan dan Moderasi',
                  'Pelaporan listing dan status laporan akan tersedia di sini.',
                ),
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Laporan'),
              ),
            ),
          ],
        ),
        bottomNavigationBar: ColoredBox(
          color: Colors.white,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: NavigationBar(
                height: 72,
                backgroundColor: Colors.white,
                selectedIndex: _tab.index,
                onDestinationSelected: (index) => _select(_Tab.values[index]),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Beranda',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view_rounded),
                    label: 'Katalog',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.add_rounded),
                    label: 'Jual',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book_rounded),
                    label: 'Jurnal',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Akun',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModulePreview extends StatelessWidget {
  const _ModulePreview({this.title, required this.description, this.action});

  final String? title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              Text(description, textAlign: TextAlign.center),
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}
