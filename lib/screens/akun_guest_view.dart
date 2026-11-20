import 'package:flutter/material.dart';

const _ink = Color(0xFF1D1A16);
const _border = Color(0xFFECE5D9);

/// Guest-only account view. Authentication is intentionally not implemented.
class AkunGuestView extends StatelessWidget {
  const AkunGuestView({super.key, required this.onOpenJournal});

  final VoidCallback onOpenJournal;

  void _preview(BuildContext context, String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title — pratinjau tampilan saja.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          key: const PageStorageKey('akun-guest'),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            const SizedBox(
              height: 64,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Akun',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.23,
                    letterSpacing: -0.26,
                    color: _ink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEFE8),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Satu akun untuk menyimpan, menghubungi, dan menjual.',
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      height: 1.23,
                      letterSpacing: -0.26,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _ink,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () => _preview(context, 'Masuk'),
                      child: const Text('Masuk'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _ink,
                        side: const BorderSide(color: Color(0xFFDDD4C5)),
                        textStyle: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () => _preview(context, 'Daftar akun baru'),
                      child: const Text('Daftar akun baru'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _Benefit(
              icon: Icons.favorite_border_rounded,
              title: 'Simpan favorit',
              description:
                  'Lengkap dengan catatan pribadi yang hanya kamu baca.',
            ),
            const SizedBox(height: 14),
            const _Benefit(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Lihat kontak penjual',
              description: 'Hubungi langsung lewat Instagram, email, atau nomor pilihan penjual.',
            ),
            const SizedBox(height: 14),
            const _Benefit(
              icon: Icons.sell_outlined,
              title: 'Pasang iklan gratis',
              description: 'Foto, harga, ukuran, kondisi, dan kota — selesai dalam dua menit.',
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                'LAINNYA',
                style: TextStyle(
                  color: Color(0xFF847B6F),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.27,
                  letterSpacing: 0.88,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: _border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.menu_book_outlined,
                      label: 'Jurnal slow fashion',
                      onTap: onOpenJournal,
                    ),
                    const Divider(height: 1, thickness: 1, color: _border),
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Tentang Pakelagi',
                      onTap: () => _preview(context, 'Tentang Pakelagi'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title, description;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20, color: _ink),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.38,
                color: _ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                height: 1.42,
                color: Color(0xFF645C52),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: _ink),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: _ink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Color(0xFF847B6F),
          ),
        ],
      ),
    ),
  );
}
