# Pakelagi Mobile

Aplikasi mobile Flutter untuk Pakelagi, platform yang membantu masyarakat Indonesia menemukan dan memasang listing pakaian *preloved*. Aplikasi web Pakelagi menjadi layanan backend dan pengelolaan data bersama.

> **Status Checkpoint 1:** semua modul sudah bisa dibuka dari aplikasi. Beranda dan Jurnal memakai data contoh lokal; halaman modul lain masih kerangka navigasi. API DRF sudah tersedia di PWS, tetapi Flutter belum terhubung ke API.

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

Pembagian berikut adalah ruang lingkup web/mobile dan penanggung jawab setiap modul. Petunjuk navigasi menunjukkan cara membuka kerangka modul, bukan fitur yang sudah selesai.

### 1. Clothing Listings — Nugraha Kautsarrizqi Caksana (`2506541250`)

Listing pakaian dengan katalog, pencarian judul/brand, filter kategori/ukuran/kondisi/harga/kota/tag keberlanjutan, detail, pagination, dan pengelolaan listing oleh pemilik. Status listing meliputi `Available`, `Sold`, dan `Hidden`. Form web juga menggunakan pencarian lokasi Nominatim.

**Navigasi Flutter:** tab **Katalog** dan **Jual**. Kartu dan filter Beranda masih memakai data contoh lokal.

### 2. User Profiles — Victoriano Iman Santosa (`2506544353`)

Profil member terhubung satu-ke-satu dengan akun Django. Cakupannya onboarding, display name, bio, kota umum, kontak, dan etalase listing publik. Kontak penjual dibatasi untuk pengguna yang memenuhi aturan akses.

**Navigasi Flutter:** tab **Akun**. Login dan pengelolaan profil belum terhubung ke backend.

### 3. Saved Favorites — David Liman (`2506601956`)

Member dapat menyimpan listing yang memenuhi syarat, melihat daftar privat, mengubah catatan, dan menghapus favorit. Kombinasi member dan listing harus unik.

**Navigasi Flutter:** ikon hati **Favorit** di header Beranda. Tombol simpan pada kartu Beranda hanya mengubah state lokal sementara; belum mengisi halaman Favorit atau tersinkron ke server.

### 4. Sustainable Guides — Muhammad Raihan Al Qadri Kusumaputra (`2506602334`)

Panduan mengenai perawatan, perbaikan, penggunaan ulang, dan *slow fashion*. Member dapat mengirim draf; moderator meninjau dan mengatur publikasinya.

**Navigasi Flutter:** tab **Jurnal** membuka halaman panduan yang sudah ada, dengan data contoh lokal.

### 5. Reports & Moderation — Clevraldo Limuel (`2506656583`)

Rancangan modul untuk pelaporan listing dan peninjauan laporan oleh moderator.

**Navigasi Flutter:** **Akun → Laporan**. Halaman belum bisa mengirim atau meninjau laporan.

---

## Peran Pengguna

| Peran | Kebutuhan dan akses utama pada produk web |
|---|---|
| **Guest** | Menjelajahi listing `Available`, melihat detail/profil publik, dan membaca guide yang sudah terbit. Tidak dapat melihat kontak penjual. |
| **Member** | Menggunakan fitur guest, mengelola listing miliknya, profil, dan favorit; dapat menghubungi penjual sesuai aturan akses. Dapat mengirim/mengelola draf guide sesuai status. |
| **Admin/staff** | Menjaga kualitas konten. Listing dimoderasi melalui Django Admin; peninjauan panduan dan laporan mengikuti izin backend. |

Satu akun member dapat menjadi penjual sekaligus pencari pakaian. Pada prototipe Flutter saat ini, login dan pembagian hak akses tersebut belum diimplementasikan.

---

## Integrasi Aplikasi Mobile dengan Web PWS melalui DRF

### Gambaran alur integrasi

Target arsitektur integrasi adalah aplikasi Flutter menggunakan HTTP/JSON untuk berkomunikasi dengan Django REST Framework (DRF) pada backend Pakelagi yang sama dengan situs web PWS:

1. Aplikasi Flutter mengirim request ke endpoint API backend PWS, bukan mengakses database secara langsung.
2. DRF memvalidasi request, autentikasi, izin akses, dan data masukan.
3. Backend membaca atau mengubah database Pakelagi, lalu mengembalikan response JSON dengan status HTTP.
4. Aplikasi Flutter mengubah response menjadi model/data UI. Perubahan melalui web dan mobile akan menggunakan backend/database yang sama sehingga data dapat dibagikan.

**Kondisi saat ini:** Flutter belum mengirim request ke backend. API bisa dicoba langsung di PWS; endpoint privat memerlukan sesi login yang sesuai.

### Endpoint DRF di PWS

Semua path pada tabel relatif terhadap `/api/v1/` (misalnya `GET /api/v1/categories/`).

| Area | Metode dan path |
|---|---|
| Akun | `POST accounts/register/`; `POST accounts/login/`; `POST accounts/logout/`; `POST accounts/delete/` |
| Profil | `POST profiles/`; `GET`, `PATCH profiles/me/`; `GET profiles/<user_id>/` |
| Kategori | `GET categories/` |
| Listing | `GET`, `POST listings/`; `GET`, `PATCH`, `DELETE listings/<id>/`; `POST listings/<id>/status/`; `GET listings/mine/`; `GET listings/locations/` |
| Favorit | `GET`, `POST favorites/`; `GET`, `PATCH`, `DELETE favorites/<id>/` |
| Panduan | `GET`, `POST guides/`; `GET guides/my-submissions/`; `GET`, `PUT`, `PATCH`, `DELETE guides/<id>/` |
| Laporan | `GET`, `POST reports/`; `GET`, `PUT`, `PATCH`, `DELETE reports/<uuid>/` |

Untuk mencoba endpoint publik: `curl -H 'Accept: application/json' https://david-liman-pakelagi.pws.cs.ui.ac.id/api/v1/categories/`. Jika menjalankan Django lokal, ganti host dengan `http://127.0.0.1:8000`.

Endpoint privat menggunakan **Django session authentication**. Klien perlu menyimpan cookie sesi serta mengirim token CSRF untuk request yang mengubah data. Lihat [README backend](https://github.com/pbp-kelompok-b8/pakelagi/blob/main/README.md#9-api-pakelagi-django-rest-framework) untuk setup, payload, dan alur login/CSRF.

---

## Tautan Proyek

- **Repository web:** [pbp-kelompok-b8/pakelagi](https://github.com/pbp-kelompok-b8/pakelagi)
- **Repository mobile:** [pbp-kelompok-b8/pakelagi_mobile](https://github.com/pbp-kelompok-b8/pakelagi_mobile)
- **Deployment PWS web:** [david-liman-pakelagi.pws.cs.ui.ac.id](https://david-liman-pakelagi.pws.cs.ui.ac.id)
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
git clone --branch dev https://github.com/pbp-kelompok-b8/pakelagi_mobile.git
cd pakelagi_mobile
flutter pub get
flutter run
```

Aplikasi bisa dijalankan tanpa backend. Gunakan bottom navigation untuk berpindah antara Beranda, Katalog, Jual, Jurnal, dan Akun. Buka Favorit lewat ikon hati di Beranda dan Laporan lewat Akun.

### Membuat APK Android (opsional)

```bash
flutter build apk --release
```

APK hasil build secara default berada di `build/app/outputs/flutter-apk/app-release.apk`. Untuk dibagikan, unggah APK ke lokasi distribusi kelompok lalu tambahkan tautannya pada bagian **Tautan Proyek**.

---

## Informasi Implementasi Mobile Saat Ini

- Entry point aplikasi: `lib/main.dart`.
- Navigasi utama dan kerangka halaman: `lib/screens/main_shell.dart`.
- Beranda (`lib/screens/beranda_page.dart`) dan Jurnal (`lib/sustainable_guides/screens/jurnal_page.dart`) menampilkan data contoh lokal. Sebagian aksi di dalam halaman masih berupa pratinjau.
- Asset gambar dan font aplikasi berada di direktori `assets/`.

---

_Arsip spesifikasi web (bukan acuan status API terkini): [`docs/pakelagi-web/pakelagi-spesification.md`](docs/pakelagi-web/pakelagi-spesification.md)._
