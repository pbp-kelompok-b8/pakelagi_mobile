import 'package:flutter/material.dart';

const _ink = Color(0xFF1D1A16);
const _brand = Color(0xFFB04B25);
const _muted = Color(0xFF645C52);
const _tertiary = Color(0xFF847B6F);
const _border = Color(0xFFDDD4C5);
const _borderSubtle = Color(0xFFEBE4D8);
const _subtleBg = Color(0xFFF5F0E8);
const _green = Color(0xFF1F4535);
const _greenSubtle = Color(0xFFE7F0EA);

const _categories = [
  'Semua',
  'Perawatan',
  'Perbaikan',
  'Reuse',
  'Slow Fashion',
  'Conscious Shopping',
];

class _GuideArticle {
  const _GuideArticle({
    required this.title,
    required this.category,
    required this.readTime,
    required this.image,
    this.excerpt = '',
  });

  final String title;
  final String category;
  final String readTime;
  final String image;
  final String excerpt;
}

const _featuredGuides = [
  _GuideArticle(
    title: 'Menjahit kancing & menambal lubang kecil',
    category: 'Perbaikan',
    excerpt: 'Lima menit, satu jarum, dan benang sewarna sudah cukup.',
    readTime: '4 menit baca',
    image: 'shirt',
  ),
  _GuideArticle(
    title: 'Merawat linen agar awet lebih lama',
    category: 'Perawatan',
    excerpt:
        'Cara mencuci, menjemur, dan menyetrika linen supaya seratnya kuat.',
    readTime: '5 menit baca',
    image: 'linen',
  ),
];

const _latestGuides = [
  _GuideArticle(
    title: 'Tiga cara memakai ulang knit yang melar',
    category: 'Reuse',
    readTime: '4 menit baca',
    image: 'knit',
  ),
  _GuideArticle(
    title: 'Membaca label bahan sebelum membeli',
    category: 'Conscious Shopping',
    readTime: '6 menit baca',
    image: 'trousers',
  ),
  _GuideArticle(
    title: 'Menyimpan wol di musim hujan',
    category: 'Perawatan',
    readTime: '3 menit baca',
    image: 'coat',
  ),
  _GuideArticle(
    title: 'Kapsul lemari 30 potong untuk setahun',
    category: 'Slow Fashion',
    readTime: '7 menit baca',
    image: 'tee',
  ),
];

class JurnalPage extends StatefulWidget {
  const JurnalPage({super.key});

  @override
  State<JurnalPage> createState() => _JurnalPageState();
}

class _JurnalPageState extends State<JurnalPage> {
  String _selectedCategory = 'Semua';
  bool _isSearching = false;
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_GuideArticle> _filter(List<_GuideArticle> list) {
    return list.where((article) {
      final matchesCategory =
          _selectedCategory == 'Semua' || article.category == _selectedCategory;
      final q = _query.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          article.title.toLowerCase().contains(q) ||
          article.category.toLowerCase().contains(q) ||
          article.excerpt.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

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
    final featured = _filter(_featuredGuides);
    final latest = _filter(_latestGuides);

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header()),
              if (_isSearching) SliverToBoxAdapter(child: _searchBar()),
              SliverToBoxAdapter(child: _subtitle()),
              SliverToBoxAdapter(child: _categoryChips()),
              if (featured.isNotEmpty)
                SliverToBoxAdapter(child: _featuredSection(featured)),
              SliverToBoxAdapter(child: _latestSection(latest)),
              SliverToBoxAdapter(child: _contributeBanner()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'Jurnal',
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 26,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: _ink,
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: _isSearching ? 'Tutup pencarian' : 'Cari panduan',
          style: IconButton.styleFrom(
            backgroundColor: _subtleBg,
            minimumSize: const Size(40, 40),
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _query = '';
                _searchController.clear();
              }
            });
          },
          icon: Icon(
            _isSearching ? Icons.close_rounded : Icons.search_rounded,
            size: 20,
            color: _ink,
          ),
        ),
      ],
    ),
  );

  Widget _searchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
    child: TextField(
      controller: _searchController,
      autofocus: true,
      onChanged: (value) => setState(() => _query = value),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Cari panduan perawatan atau perbaikan...',
        hintStyle: const TextStyle(color: Color(0xFFA49B8E), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: _muted),
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
  );

  Widget _subtitle() => const Padding(
    padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
    child: Text(
      'Panduan merawat, memperbaiki, dan memakai ulang pakaian — dari komunitas, dikurasi moderator.',
      style: TextStyle(fontSize: 14, height: 1.45, color: _muted),
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
        final selected = label == _selectedCategory;
        return _TapSurface(
          color: selected ? _ink : Colors.white,
          radius: 999,
          border: selected ? null : _border,
          onTap: () => setState(() => _selectedCategory = label),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
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

  Widget _featuredSection(List<_GuideArticle> articles) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Pilihan editor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 332,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: articles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) => _featuredCard(articles[index]),
          ),
        ),
      ],
    ),
  );

  Widget _featuredCard(_GuideArticle article) => SizedBox(
    width: 288,
    child: _TapSurface(
      radius: 20,
      onTap: () => _preview(article.title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _guideImage(article.image, width: 288, height: 192),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _greenSubtle,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              article.category,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _green,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            article.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: _ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            article.excerpt,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: _muted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 13, color: _tertiary),
              const SizedBox(width: 4),
              Text(
                article.readTime,
                style: const TextStyle(fontSize: 12, color: _tertiary),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _latestSection(List<_GuideArticle> articles) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Terbaru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        if (articles.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(
                'Belum ada panduan untuk kategori atau pencarian ini.',
                style: TextStyle(fontSize: 13, color: _muted),
              ),
            ),
          )
        else
          ...List.generate(articles.length, (index) {
            final isLast = index == articles.length - 1;
            return _compactArticleRow(articles[index], showDivider: !isLast);
          }),
      ],
    ),
  );

  Widget _compactArticleRow(
    _GuideArticle article, {
    required bool showDivider,
  }) => Container(
    decoration: BoxDecoration(
      border: showDivider
          ? const Border(bottom: BorderSide(color: _borderSubtle))
          : null,
    ),
    child: _TapSurface(
      radius: 12,
      onTap: () => _preview(article.title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _guideImage(article.image, width: 80, height: 80),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: _green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.readTime,
                    style: const TextStyle(fontSize: 12, color: _tertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _contributeBanner() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Punya tips merawat pakaian?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kirim draf, moderator meninjaunya.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _TapSurface(
            color: Colors.white,
            border: _border,
            radius: 999,
            onTap: () => _preview('Tulis draf jurnal'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 15, color: _ink),
                  SizedBox(width: 6),
                  Text(
                    'Tulis',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _ink,
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

  Widget _guideImage(
    String name, {
    required double width,
    required double height,
  }) => Image.asset(
    'assets/images/$name.jpg',
    width: width,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => Container(
      width: width,
      height: height,
      color: _subtleBg,
      child: const Icon(Icons.image_outlined, color: _tertiary),
    ),
  );
}

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
