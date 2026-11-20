# Pakelagi Mobile

Aplikasi mobile Flutter untuk Pakelagi, platform yang membantu masyarakat Indonesia menemukan dan memasang listing pakaian *preloved*. Aplikasi web Pakelagi menjadi layanan backend dan pengelolaan data bersama.

> **Status saat ini:** repository Flutter berisi prototipe UI beranda dengan data contoh lokal. Aplikasi mobile ini belum melakukan request ke PWS/DRF. Endpoint DRF yang telah didokumentasikan pada backend web saat ini mencakup akun dan profil; endpoint REST untuk listing, favorit, panduan, dan laporan belum tercantum dalam spesifikasi web. Status implementasi perlu dibedakan dari rancangan integrasi di bawah.

---

## Deskripsi Aplikasi

Pakelagi mempertemukan orang yang memiliki pakaian layak pakai tetapi tidak lagi digunakan dengan orang yang mencari pakaian terjangkau. Katalog dirancang untuk membantu pengguna menjelajah berdasarkan kategori, ukuran, kondisi, harga, kota, dan informasi keberlanjutan. Aplikasi juga mendukung tujuan *slow fashion* melalui panduan perawatan dan penggunaan ulang pakaian.

Pakelagi merupakan **platform listing**, bukan toko online penuh. Pengguna menemukan barang dan menghubungi penjual; transaksi, pembayaran, pengiriman, dan serah terima dilakukan di luar aplikasi.

### Manfaat bagi masyarakat

- **Ekonomi:** pilihan pakaian layak pakai yang lebih terjangkau serta lapak untuk penjual individu.
- **Lingkungan:** mendorong pakaian digunakan lebih lama dan mengurangi limbah tekstil.
- **Edukasi:** panduan untuk merawat, memperbaiki, dan menggunakan kembali pakaian.
- **Lokal:** informasi kota membantu pengguna menemukan listing di area yang sesuai.

Fitur seperti pembayaran, checkout, keranjang, pemesanan, chat internal, dan pengiriman bukan bagian dari fungsi platform listing.

---

## Anggota Kelompok

| No. | Nama | NPM | Modul tanggung jawab |
|---:|---|---|---|
| 1 | Nugraha Kautsarrizqi Caksana | `2506541250` | Clothing Listings |
| 2 | Victoriano Iman Santosa | `2506544353` | User Profiles |
| 3 | David Liman | `2506601956` | Saved Favorites |
| 4 | Muhammad Raihan Al Qadri Kusumaputra | `2506602334` | Sustainable Guides |
| 5 | Clevraldo Limuel | `2506656583` | Reports & Moderation |

---

## Modul dan Pembagian Kerja

Pembagian berikut adalah modul proyek web Pakelagi dan penanggung jawab kelompok. Modul-modul ini merupakan ruang lingkup produk lintas web/mobile, **bukan pernyataan bahwa semuanya sudah tersedia di aplikasi Flutter**. Kondisi implementasi backend di bawah dirangkum dari [spesifikasi web](docs/pakelagi-web/pakelagi-spesification.md).

### 1. Clothing Listings — Nugraha Kautsarrizqi Caksana (`2506541250`)

Listing pakaian dengan katalog, pencarian judul/brand, filter kategori/ukuran/kondisi/harga/kota/tag keberlanjutan, detail, pagination, dan pengelolaan listing oleh pemilik. Status listing meliputi `Available`, `Sold`, dan `Hidden`. Form web juga menggunakan pencarian lokasi Nominatim.

**Status web:** fitur listing tersedia melalui halaman web dan Django Admin. **Status Flutter:** kartu serta filter pada beranda masih menggunakan data statis lokal; belum mengambil listing dari API.

### 2. User Profiles — Victoriano Iman Santosa (`2506544353`)

Profil member terhubung satu-ke-satu dengan akun Django. Cakupannya onboarding, display name, bio, kota umum, kontak, dan etalase listing publik. Kontak penjual dibatasi untuk pengguna yang memenuhi aturan akses.

**Status web:** onboarding, edit profil, profil publik, serta endpoint JSON akun/profil tersedia. Penghapusan profil saja belum tersedia di web; penghapusan akun merupakan alur terpisah. **Status Flutter:** belum ada alur profil atau autentikasi yang terhubung ke backend.

### 3. Saved Favorites — David Liman (`2506601956`)

Member dapat menyimpan listing yang memenuhi syarat, melihat daftar privat, mengubah catatan, dan menghapus favorit. Kombinasi member dan listing harus unik.

**Status web:** tambah/hapus favorit, daftar, dan catatan tersedia di web. **Status Flutter:** ikon favorit hanya mengubah state lokal sementara dan hilang ketika aplikasi dimulai ulang; belum tersinkron dengan akun atau server.

### 4. Sustainable Guides — Muhammad Raihan Al Qadri Kusumaputra (`2506602334`)

Panduan mengenai perawatan, perbaikan, penggunaan ulang, dan *slow fashion*. Member dapat mengirim draf; moderator meninjau dan mengatur publikasinya.

**Status web:** pembacaan guide terbit, pengiriman/pengelolaan draf `PENDING`, serta moderasi/publikasi tersedia. Pembuatan dan edit konten guide oleh admin melalui dashboard belum tersedia. **Status Flutter:** terdapat kartu jurnal contoh pada beranda, belum mengambil artikel dari backend.

### 5. Reports & Moderation — Clevraldo Limuel (`2506656583`)

Rancangan modul untuk pelaporan listing dan peninjauan laporan oleh moderator.

**Status web:** model, endpoint, dan UI report/moderasi report belum diimplementasikan menurut spesifikasi web. **Status Flutter:** belum tersedia.

---

## Peran Pengguna

| Peran | Kebutuhan dan akses utama pada produk web |
|---|---|
| **Guest** | Menjelajahi listing `Available`, melihat detail/profil publik, dan membaca guide yang sudah terbit. Tidak dapat melihat kontak penjual. |
| **Member** | Menggunakan fitur guest, mengelola listing miliknya, profil, dan favorit; dapat menghubungi penjual sesuai aturan akses. Dapat mengirim/mengelola draf guide sesuai status. |
| **Admin/staff** | Menjaga kualitas konten. Listing dimoderasi melalui Django Admin; moderasi guide memiliki dashboard tersendiri dan memerlukan superuser. Moderasi report belum tersedia. |

Satu akun member dapat menjadi penjual sekaligus pencari pakaian. Pada prototipe Flutter saat ini, login dan pembagian hak akses tersebut belum diimplementasikan.

---

## Integrasi Aplikasi Mobile dengan Web PWS melalui DRF

### Gambaran alur integrasi

Target arsitektur integrasi adalah aplikasi Flutter menggunakan HTTP/JSON untuk berkomunikasi dengan Django REST Framework (DRF) pada backend Pakelagi yang sama dengan situs web PWS:

1. Aplikasi Flutter mengirim request ke endpoint API backend PWS, bukan mengakses database secara langsung.
2. DRF memvalidasi request, autentikasi, izin akses, dan data masukan.
3. Backend membaca atau mengubah database Pakelagi, lalu mengembalikan response JSON dengan status HTTP.
4. Aplikasi Flutter mengubah response menjadi model/data UI. Perubahan melalui web dan mobile akan menggunakan backend/database yang sama sehingga data dapat dibagikan.

**Kondisi repository:** alur tersebut belum terhubung dari aplikasi Flutter. Belum ada API client, base URL konfigurasi, atau dependency HTTP di project. Beranda saat ini adalah prototipe UI dengan data contoh. Karena itu, tautan PWS di bawah merupakan deployment web dan belum membuktikan bahwa semua fitur dapat dikonsumsi melalui API oleh mobile.

### Endpoint DRF yang didokumentasikan pada backend

Base URL PWS: `http://david-liman-pakelagi.pws.cs.ui.ac.id`

| Area | Endpoint yang tersedia menurut spesifikasi web |
|---|---|
| Registrasi akun | `POST /api/v1/accounts/register/` |
| Login | `/api/v1/accounts/login/` |
| Logout | `/api/v1/accounts/logout/` |
| Hapus akun | `POST /api/v1/accounts/delete/` |
| Daftar/buat profil | `/api/v1/profiles/` |
| Profil pengguna saat ini | `/api/v1/profiles/me/` |
| Profil berdasarkan ID pengguna | `/api/v1/profiles/<user_id>/` |

Dokumentasi web menyebut API tersebut menggunakan **Django session authentication**, bukan bearer token. Implementasi klien mobile perlu menangani sesi/cookie dan perlindungan CSRF untuk request yang mengubah data sesuai kontrak API backend.

**Batasan API yang diketahui:** spesifikasi web menyatakan API listing belum termasuk. Endpoint DRF untuk listing, favorite, guide, dan report tidak didokumentasikan sebagai tersedia. Sebelum mengintegrasikan modul-modul tersebut, kontrak endpoint/JSON, izin, serta metode autentikasi perlu disepakati dan disediakan pada backend. Jangan menganggap halaman web Django atau interaksi HTMX sebagai endpoint REST.

Spesifikasi web juga mencatat detail implementasi, status fitur, dan keterbatasan lainnya di [`docs/pakelagi-web/pakelagi-spesification.md`](docs/pakelagi-web/pakelagi-spesification.md).

---

## Tautan Proyek

- **Repository web:** [pbp-kelompok-b8/pakelagi](https://github.com/pbp-kelompok-b8/pakelagi)
- **Repository mobile:** [pbp-kelompok-b8/pakelagi_mobile](https://github.com/pbp-kelompok-b8/pakelagi_mobile)
- **Deployment PWS web:** [david-liman-pakelagi.pws.cs.ui.ac.id](http://david-liman-pakelagi.pws.cs.ui.ac.id)
- **Figma web:** [Web Design](https://www.figma.com/design/dCekkdFnlpwdcTY6vaXyrX/Web-Design?m=auto&t=WEkEhoembXHyU27W-1)
- **Figma mobile:** [Mobile Design](https://www.figma.com/design/QZEtPQaa7BCS3UM4BhxhkX/Mobile-Design?node-id=20-4&m=dev)
- **APK:** Belum tersedia. Tautan dapat ditambahkan setelah APK release dipublikasikan.

---

## Menjalankan Aplikasi Flutter

### Prasyarat

- Flutter SDK yang mendukung Dart `^3.13.7` (lihat `environment` pada `pubspec.yaml`).
- Android Studio/emulator, perangkat Android, atau target Flutter lain yang didukung.

### Menjalankan secara lokal

```bash
git clone https://github.com/pbp-kelompok-b8/pakelagi_mobile.git
cd pakelagi_mobile
flutter pub get
flutter run
```

Aplikasi yang berjalan saat ini menampilkan prototipe beranda dan tidak memerlukan koneksi ke backend.

### Membuat APK Android (opsional)

```bash
flutter build apk --release
```

APK hasil build secara default berada di `build/app/outputs/flutter-apk/app-release.apk`. Untuk dibagikan, unggah APK ke lokasi distribusi kelompok lalu tambahkan tautannya pada bagian **Tautan Proyek**.

---

## Informasi Implementasi Mobile Saat Ini

- Entry point aplikasi: `lib/main.dart`.
- Halaman utama prototipe: `lib/screens/beranda_page.dart`.
- Data produk dan panduan yang terlihat pada halaman utama merupakan contoh lokal.
- Pencarian, navigasi, dan sebagian tombol masih menampilkan notifikasi pratinjau.
- Favorit hanya disimpan dalam state halaman selama aplikasi aktif, bukan ke server atau penyimpanan permanen.
- Asset gambar dan font aplikasi berada di direktori `assets/`.

---

_Spesifikasi produk dan implementasi web: [`docs/pakelagi-web/pakelagi-spesification.md`](docs/pakelagi-web/pakelagi-spesification.md)._ 
