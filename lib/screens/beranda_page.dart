import 'package:flutter/material.dart';

const _ink = Color(0xFF1D1A16);
const _brand = Color(0xFFB04B25);
const _muted = Color(0xFF645C52);
const _border = Color(0xFFDDD4C5);
const _green = Color(0xFF1F4535);
const _categories = [
  'Semua',
  'Top',
  'Bottom',
  'Dress',
  'Outerwear',
  'Modest Wear',
];

class _Product {
  const _Product(
    this.name,
    this.price,
    this.condition,
    this.city,
    this.image, {
    this.isNew = false,
  });

  final String name, price, condition, city, image;
  final bool isNew;
}

const _newProducts = [
  _Product(
    'Wool-blend oversized coat',
    'Rp285.000',
    'M · Like New',
    'Bandung',
    'coat',
    isNew: true,
  ),
  _Product('Linen midi dress', 'Rp145.000', 'S · Good', 'Bandung', 'dress'),
  _Product(
    'Relaxed poplin shirt',
    'Rp95.000',
    'L · Like New',
    'Surabaya',
    'shirt',
    isNew: true,
  ),
  _Product(
    'Tailored wide-leg trousers',
    'Rp120.000',
    'M · Good',
    'Yogyakarta',
    'trousers',
  ),
];
const _nearProducts = [
  _Product('Knit top blush', 'Rp110.000', 'S · Fair', 'Bandung', 'knit'),
  _Product(
    'Heavyweight organic tee',
    'Rp75.000',
    'M · Like New',
    'Bandung',
    'tee',
  ),
  _Product(
    'Oversized knit cardigan',
    'Rp240.000',
    'Free Size · Like New',
    'Bandung',
    'coat',
  ),
];

/// UI-only preview: selections and favourites are kept locally, without an API.
class BerandaPage extends StatefulWidget {
  const BerandaPage({
    super.key,
    required this.onOpenFavorites,
    required this.onOpenCatalog,
    required this.onOpenJournal,
    required this.onOpenSell,
  });

  final VoidCallback onOpenFavorites;
  final VoidCallback onOpenCatalog;
  final VoidCallback onOpenJournal;
  final VoidCallback onOpenSell;

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  String _category = 'Semua';

  final Set<String> _favourites = {};

  void _preview(String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title — pratinjau tampilan saja.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header()),
              SliverToBoxAdapter(child: _hero()),
              SliverToBoxAdapter(child: _categoryChips()),
              SliverToBoxAdapter(child: _banner()),
              SliverToBoxAdapter(
                child: _sectionHeading(
                  'Baru masuk',
                  subtitle: 'Diunggah minggu ini di sekitarmu',
                  onViewAll: widget.onOpenCatalog,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.crossAxisExtent - 16) / 2;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 24,
                        mainAxisExtent: width * 1.25 + 164,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _productCard(_newProducts[index]),
                        childCount: _newProducts.length,
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(child: _exploreCategories()),
              SliverToBoxAdapter(child: _nearby()),
              SliverToBoxAdapter(child: _journal()),
              SliverToBoxAdapter(child: _sellBanner()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
    child: Row(
      children: [
        const Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontWeight: FontWeight.w600,
                fontSize: 24,
                letterSpacing: -0.48,
                color: _ink,
              ),
              children: [
                TextSpan(text: 'pakelagi'),
                TextSpan(
                  text: '.',
                  style: TextStyle(color: _brand),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Favorit',
          onPressed: widget.onOpenFavorites,
          icon: const Icon(Icons.favorite_border_rounded, size: 22),
        ),
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: () => _preview('Notifikasi'),
          icon: const Icon(Icons.notifications_none_rounded, size: 24),
        ),
      ],
    ),
  );

  Widget _hero() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 32,
              fontWeight: FontWeight.w600,
              height: 1.19,
              letterSpacing: -0.48,
              color: _ink,
            ),
            children: [
              TextSpan(text: 'Dipakai lagi,\n'),
              TextSpan(
                text: 'dicintai lagi.',
                style: TextStyle(color: _brand, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onSubmitted: (_) => _preview('Pencarian'),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cari judul atau brand',
            hintStyle: const TextStyle(color: Color(0xFFA49B8E), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 22,
              color: _muted,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(5),
              child: IconButton.filledTonal(
                tooltip: 'Filter',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F0E8),
                  minimumSize: const Size(38, 38),
                  padding: EdgeInsets.zero,
                ),
                onPressed: _showFilters,
                icon: const Icon(Icons.tune_rounded, size: 21, color: _ink),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: _brand),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _categoryChips() => SizedBox(
    height: 36,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemCount: _categories.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final label = _categories[index];
        final selected = label == _category;
        return _TapSurface(
          color: selected ? _ink : Colors.white,
          radius: 999,
          border: selected ? null : _border,
          onTap: () => setState(() => _category = label),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _ink,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _banner() => Padding(
    padding: const EdgeInsets.all(20),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: ColoredBox(
        color: _green,
        child: Stack(
          children: [
            Positioned(
              right: -24,
              top: 25,
              bottom: -30,
              child: Transform.rotate(
                angle: 0.12,
                child: Opacity(
                  opacity: 0.85,
                  child: Image.asset(
                    'assets/images/coat.jpg',
                    width: 155,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: FractionallySizedBox(
                widthFactor: 0.63,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MUSIM HUJAN 2026',
                      style: TextStyle(
                        color: Color(0xFFD9A23A),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.88,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Outerwear hangat, mulai Rp85.000',
                      style: TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: 26,
                        height: 1.23,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.26,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TapSurface(
                      onTap: () {
                        setState(() => _category = 'Outerwear');
                        _preview('Koleksi outerwear');
                      },
                      color: Colors.white,
                      radius: 999,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'Lihat koleksi',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
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

  Widget _sectionHeading(
    String title, {
    String? subtitle,
    required VoidCallback onViewAll,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.09,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _muted,
                    height: 1.42,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        _TapSurface(
          onTap: onViewAll,
          radius: 8,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lihat semua',
                  style: TextStyle(
                    color: _brand,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 16, color: _brand),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _productCard(_Product product) {
    final saved = _favourites.contains(product.name);
    return _TapSurface(
      radius: 20,
      onTap: () => _preview(product.name),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.8,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/${product.image}.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                if (product.isNew)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEFE8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Baru',
                        style: TextStyle(
                          color: _brand,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: SizedBox.square(
                    dimension: 34,
                    child: IconButton(
                      tooltip: saved ? 'Hapus favorit' : 'Simpan favorit',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => setState(() {
                        saved
                            ? _favourites.remove(product.name)
                            : _favourites.add(product.name);
                      }),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          saved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(saved),
                          size: 18,
                          color: saved ? _brand : _ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 10, 2, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.price,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 3),
                Text(
                  product.condition,
                  style: const TextStyle(fontSize: 12, color: _muted),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Color(0xFF847B6F),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        product.city,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF847B6F),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _exploreCategories() {
    const items = [
      ('Outerwear', '38 item', 'coat'),
      ('Dress', '47 item', 'dress'),
      ('Top', '64 item', 'shirt'),
      ('Bottom', '51 item', 'trousers'),
      ('Modest Wear', '29 item', 'knit'),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        children: [
          _sectionHeading('Jelajahi kategori', onViewAll: widget.onOpenCatalog),
          const SizedBox(height: 16),
          SizedBox(
            height: 128,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final (name, count, image) = items[index];
                return SizedBox(
                  width: 180,
                  child: _TapSurface(
                    radius: 20,
                    onTap: () {
                      setState(() => _category = name);
                      _preview(name);
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/$image.jpg',
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  count,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _nearby() => Padding(
    padding: const EdgeInsets.only(top: 28),
    child: Column(
      children: [
        _sectionHeading(
          'Dekat kamu · Bandung',
          subtitle: 'Serah terima lebih mudah',
          onViewAll: widget.onOpenCatalog,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 345,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _nearProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) =>
                SizedBox(width: 167, child: _productCard(_nearProducts[index])),
          ),
        ),
      ],
    ),
  );

  Widget _journal() => Padding(
    padding: const EdgeInsets.only(top: 28),
    child: Column(
      children: [
        _sectionHeading(
          'Dari jurnal',
          subtitle: 'Merawat, memperbaiki, memakai ulang',
          onViewAll: widget.onOpenJournal,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _TapSurface(
            radius: 24,
            color: Colors.white,
            border: _border,
            onTap: () => _preview('Merawat linen agar awet lebih lama'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/linen.jpg',
                  width: double.infinity,
                  height: 170,
                  fit: BoxFit.cover,
                ),
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perawatan',
                        style: TextStyle(
                          color: _brand,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Merawat linen agar awet lebih lama',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cara mencuci, menjemur, dan menyetrika linen supaya seratnya tetap kuat.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: _muted,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: _muted),
                          SizedBox(width: 5),
                          Text(
                            '5 menit baca',
                            style: TextStyle(fontSize: 12, color: _muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _sellBanner() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lemarimu penuh cerita.',
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pasang iklan gratis dalam dua menit: foto, harga, ukuran, kondisi, dan kota. Pembeli menghubungimu langsung.',
            style: TextStyle(fontSize: 13, color: _muted, height: 1.6),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: widget.onOpenSell,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Pasang iklan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );

  void _showFilters() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih kategori',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories
                    .map(
                      (label) => ActionChip(
                        label: Text(label),
                        backgroundColor: label == _category
                            ? const Color(0xFFFCEFE8)
                            : Colors.white,
                        onPressed: () {
                          setState(() => _category = label);
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A clipped Material surface keeps ripple feedback visible even over images.
class _TapSurface extends StatelessWidget {
  const _TapSurface({
    required this.child,
    required this.onTap,
    this.color = Colors.transparent,
    this.radius = 20,
    this.border,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final double radius;
  final Color? border;

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: border == null ? BorderSide.none : BorderSide(color: border!),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      splashColor: _brand.withValues(alpha: 0.12),
      highlightColor: _brand.withValues(alpha: 0.06),
      child: child,
    ),
  );
}
