# Pakelagi — Spesifikasi Produk dan Teknis
## Catatan

Dokumen ini diperbarui agar mencerminkan project Pakelagi yang sudah ada di repository, bukan hanya rancangan awal. Bagian yang menjelaskan fitur diberi penanda **Sudah ada**, **Sebagian**, atau **Belum ada** berdasarkan implementasi repository yang diperiksa pada 20 November 2026. Status tersebut tidak dengan sendirinya membuktikan layanan PWS sedang sehat atau seluruh data deployment sama dengan lingkungan lokal.

Spesifikasi tetap mencatat tujuan produk dan perilaku yang diinginkan. Jika tujuan awal berbeda dari perilaku yang sudah terimplementasi, perilaku aktual dijelaskan apa adanya dan selisihnya dicatat sebagai pekerjaan lanjutan—bukan dianggap sudah selesai.

| Metadata | Nilai |
|---|---|
| Status | Dokumentasi kondisi project dan ruang lingkup MVP PBP 2026 |
| Spesifikasi awal | 16 September 2026 |
| Revisi berdasarkan repository | 20 November 2026 |
| Nama kerja | Pakelagi |
| Bahasa aplikasi dan dokumen | Bahasa Indonesia |
| Target deployment | PWS dengan PostgreSQL; konfigurasi repository memiliki catatan keamanan yang perlu dibereskan sebelum dianggap production-ready |

> Dokumen ini adalah acuan ruang lingkup, istilah domain, implementasi yang sudah ada, dan sisa pekerjaan Pakelagi. README tetap menjadi sumber informasi anggota, tautan, dan petunjuk menjalankan project.

## 1. Ringkasan

Pakelagi adalah platform web untuk komunitas Indonesia yang ingin menemukan dan memasang iklan pakaian preloved dengan harga terjangkau. Platform ini membantu memperpanjang usia pakaian dan mempromosikan slow fashion melalui informasi kondisi barang, tag keberlanjutan, serta panduan konsumsi yang lebih sadar.

Pakelagi adalah **platform listing**, bukan toko online penuh. Pengguna dapat menemukan barang dan menghubungi penjual melalui kontak yang dipilih penjual, tetapi transaksi, pembayaran, pengiriman, dan serah terima berlangsung di luar aplikasi.

### Ringkasan status implementasi

| Area | Status repository per 20 November 2026 | Catatan |
|---|---|---|
| Beranda, kategori, katalog, detail, CRUD listing, Nominatim | Sudah ada | Beranda tidak memuat kartu listing; tersedia halaman kategori tersendiri. |
| Registrasi, login/logout, onboarding, edit profil, etalase, hapus akun | Sudah ada | Hapus profil saja belum ada. Akun yang dihapus menghapus data terkait melalui cascade model saat ini. |
| Favorite | Sudah ada | Toggle tambah/hapus tersedia; catatan dapat diedit. |
| Sustainable guide dan moderasi guide | Sudah ada | Tidak ada slug atau CRUD admin untuk membuat/mengedit artikel; publikasi dapat dijadwalkan. |
| JSON API Accounts dan Profiles | Sudah ada | DRF dengan session authentication; bukan API untuk listing/favorite/guide. Kontrak rinci ada di dokumen API terkait. |
| Reports dan moderasi report | Belum ada | App, model, route, dan UI report tidak ditemukan dalam repository. |
| Halaman 404 bermerek | Sudah ada | Halaman khusus 403/500 belum ditemukan. |
| Production hardening | Belum memadai | `DEBUG=True` dan `SECRET_KEY` tertulis di settings; jangan anggap konfigurasi siap produksi tanpa perbaikan dan verifikasi. |

## 2. Masalah dan tujuan

### Masalah

- Pengguna sulit menemukan pakaian preloved yang sesuai harga, ukuran, kondisi, dan lokasi.
- Penjual individu membutuhkan tempat sederhana untuk menampilkan pakaian yang sudah tidak digunakan.
- Informasi tentang penggunaan kembali pakaian sering tidak terlihat dalam pengalaman belanja biasa.

### Tujuan MVP

1. Menyediakan katalog listing pakaian preloved yang dapat dicari dan difilter.
2. Memudahkan member membuat, mengubah, melihat, dan menghapus listing miliknya.
3. Menampilkan lokasi umum penjual agar pengguna dapat menemukan pilihan lokal.
4. Menyediakan favorit agar member dapat menyimpan barang untuk dilihat kembali.
5. Mempromosikan slow fashion melalui tag transparan dan sustainable guide.
6. Menyediakan moderasi dasar. **Status saat ini:** listing dapat disembunyikan melalui Django Admin; alur pelaporan listing belum diimplementasikan.

### Non-goals

Fitur berikut tidak termasuk MVP:

- pembayaran, checkout, dan keranjang belanja;
- pemesanan, reservasi, dan status transaksi;
- pengiriman atau integrasi kurir;
- chat internal;
- kalkulator emisi atau klaim penghematan karbon;
- alamat pickup yang tepat atau alamat rumah;
- upload berkas gambar; listing menggunakan satu URL gambar.

## 3. Pengguna dan peran

| Peran | Kebutuhan | Akses utama |
|---|---|---|
| Guest | Menemukan pakaian dan membaca informasi slow fashion | Melihat listing Available, kategori, guide yang terbit, detail listing dan profil publik |
| Member | Menjual pakaian dan menyimpan pilihan | Semua akses guest; CRUD listing/favorite milik sendiri, membuat dan mengubah profil; melihat kontak penjual jika profilnya lengkap. Penghapusan profil dan report belum tersedia. |
| Admin/staff | Menjaga kualitas dan keamanan konten | Django Admin mengelola listing dan user; dashboard guide hanya untuk superuser. Ini bukan satu panel moderasi terpadu. |

Dalam kode, gate untuk beberapa aksi listing menggunakan `is_staff`, sementara dashboard moderasi guide memerlukan `is_superuser`. Pautan moderasi pada header ditampilkan bagi `is_staff`; karena itu staff non-superuser tidak otomatis memiliki izin memakai dashboard guide.

Satu akun member dapat berperan sebagai penjual dan pencari barang. Tidak ada akun buyer dan seller yang terpisah.

## 4. Ruang lingkup fitur MVP

### 4.1 Beranda

- Menjelaskan tujuan Pakelagi secara singkat.
- Menampilkan tombol menuju katalog listing.
- Menampilkan ajakan untuk mendaftar/memasang listing dan tautan menuju katalog serta sustainable guide.
- **Implementasi saat ini:** beranda tidak mengambil atau menampilkan kartu listing terbaru/unggulan. Navigasi kategori tersedia terpisah di `/categories/`, dengan jumlah listing Available per kategori.

### 4.2 Katalog listing

- Menampilkan hanya listing berstatus `Available` kepada publik.
- Mendukung pencarian berdasarkan judul atau brand.
- Mendukung filter kategori, ukuran, kondisi, rentang harga, kota, dan tag keberlanjutan.
- Menggunakan pagination 12 listing per halaman; pencarian dan filter dikirim melalui query URL. Pencarian judul/brand, kategori, ukuran, kondisi, rentang harga, kota (cocok penuh tanpa membedakan kapitalisasi), tag, serta urutan Terbaru/Harga terendah/Harga tertinggi tersedia.
- Beberapa nilai filter divalidasi/dibatasi; kata-kata pencarian harus cocok pada judul atau brand.
- Hasil katalog diperbarui melalui HTMX dan tetap memiliki navigasi HTML biasa. Respons parsial katalog menggunakan partial hasil; URL tetap mewakili filter dan pagination.
- Member dapat menambah/menghapus favorite melalui HTMX. Guest atau user yang belum memiliki profil lengkap diarahkan ke login/onboarding.

### 4.3 Detail listing

- Menampilkan gambar, judul, harga, kategori, ukuran, kondisi, brand, deskripsi, kota, dan tag keberlanjutan.
- Menampilkan nama/display name penjual.
- Menampilkan kontak penjual hanya kepada pemilik atau user login dengan profil lengkap. Kontak hanya ditampilkan untuk listing Available milik orang lain; Sold tetap dapat dibuka, tetapi kontak tidak disediakan.
- Aksi report belum tersedia karena modul Report belum diimplementasikan.
- Listing Hidden menghasilkan 404 untuk publik dan user lain; pemilik dan user staff dapat melihat detailnya.
- Tidak menampilkan alamat lengkap. Detail juga menampilkan hingga empat listing Available lain dari penjual.

### 4.4 Pengelolaan listing

Member dapat:

- membuat listing;
- melihat seluruh listing miliknya, termasuk yang `Sold` atau `Hidden`;
- mengubah listing miliknya;
- menghapus listing miliknya;
- mengubah status listing miliknya menjadi `Available` atau `Sold`.

Admin dapat menyembunyikan listing yang melanggar aturan. Listing berstatus `Hidden` tidak tampil pada katalog publik.

### 4.5 Profile dan kontak

Member membuat profil setelah registrasi akun dan wajib melengkapi profil sebelum menggunakan fitur yang memakai gate `member_required` (terutama listing dan favorite). `display_name` yang tidak kosong setelah trim menyelesaikan onboarding; bio, kota, kontak, dan nomor telepon opsional. Member dapat membaca dan mengubah profilnya. **Penghapusan profil saja belum tersedia**: route HTML/API profil tidak memiliki operasi delete. Penghapusan akun tersedia sebagai alur terpisah dan menghapus akun; relasi profil mengikuti cascade. Contact value hanya ditampilkan kepada pemilik atau member login lengkap, dan tidak boleh berisi alamat rumah. Halaman profil publik menampilkan ringkasan listing Available (Dijual) dan Sold (Terjual); listing Hidden tidak ditampilkan.

Rincian etalase dan kriteria penerimaan mengikuti [spesifikasi profil](feat/profile/profile-specification.md). Avatar dan sampul opsional memakai `avatar_url`/`cover_url` HTTPS eksternal; tidak ada upload file atau pemrosesan gambar di server. Nomor telepon opsional merupakan kontak tambahan tanpa verifikasi, hanya terlihat pemilik/member lengkap. Gambar publik dari layanan eksternal dapat mengungkap alamat IP pengunjung kepada layanan tersebut. Profil sendiri dan publik memakai etalase sama; edit melalui menu akun ke `/profile/edit/`, email akun tetap privat. API JSON untuk akun/profil tersedia terpisah dan didokumentasikan di [spesifikasi API akun dan profil](feat/profile/accounts-profiles-api-specification.md).

Etalase memakai tab Dijual default dan Terjual, masing-masing 8 barang per pemuatan, urutan Terbaru/Harga terendah/Harga tertinggi, serta URL yang mempertahankan tab, urutan, dan posisi pemuatan. Tab Dijual memiliki cuplikan maksimal empat Sold terbaru berdasarkan waktu transisi Sold dan tautan ke tab Terjual. Hitungan hanya mencakup listing publik per status; Hidden/moderasi dikecualikan juga bagi pemilik di etalase. URL publik profil tidak ada/belum lengkap menghasilkan 404; etalase valid tanpa listing memiliki empty state.

### 4.6 Autentikasi, onboarding, dan API

- Autentikasi menggunakan Django Authentication dan model `User` bawaan. Registrasi memakai username, password, konfirmasi password, serta email akun opsional (belum diverifikasi). Email akun berbeda dari kontak publik `contact_type`/`contact_value`.
- HTML tersedia di `/accounts/register/`, `/accounts/login/`, `/accounts/logout/`, dan `/accounts/delete/`. Registrasi memulai sesi dan mengarahkan pengguna ke pembuatan/pelengkapan profil. Sampai `display_name` terisi setelah trim, pengguna belum menjadi member lengkap; akses publik dan logout tetap tersedia.
- Endpoint JSON DRF dengan session authentication tersedia pada `/api/v1/accounts/register/`, `/login/`, `/logout/`, `/delete/`, serta `/api/v1/profiles/`, `/me/`, dan `/<user_id>/`. API tidak menggunakan bearer token, listing API tidak termasuk, dan kontraknya dijelaskan di [spesifikasi API akun dan profil](feat/profile/accounts-profiles-api-specification.md). OpenAPI belum tersedia.
- Email/telepon tidak diverifikasi; OTP, CAPTCHA, dan autentikasi sosial bukan bagian implementasi.
- **Penghapusan akun sudah diimplementasikan** melalui GET (konfirmasi) dan POST (aksi, CSRF) `/accounts/delete/`, serta POST API. Pengguna harus mengonfirmasi username/password; staff/superuser ditolak; lima kegagalan dalam 15 menit dikenai throttle. Penghapusan model User saat ini menghapus profil, listing, favorite, dan guide yang memiliki relasi cascade. Perilaku tepat terhadap sesi, keterbatasan fitur, dan rencana penghapusan lintas data dicatat dalam [spesifikasi penghapusan akun](feat/profile/account-deletion-specification.md). Tidak ada penghapusan profil saja.

### 4.7 Halaman error

Halaman 404 Not Found bermerek Pakelagi tersedia melalui `templates/404.html` dan memberi tautan kembali ke beranda. Template saat ini tidak menampilkan rekomendasi listing maupun tautan katalog khusus. Halaman 403/500 khusus dan handler khusus belum ditemukan; pastikan mode deployment production menampilkan halaman 404 custom sesuai konfigurasi Django.

### 4.8 Favorite

Member dengan profil lengkap dapat menambahkan listing Available milik orang lain ke favorite dari katalog/detail (tombol juga dapat muncul di etalase bila item eligible), melihat daftar privat, mengubah catatan, serta menghapus favorite. Model menjamin satu favorite per kombinasi user-listing. Tidak ada aksi tambah untuk listing sendiri atau listing yang tidak Available. Item yang berubah menjadi Sold tetap muncul pada daftar favorite dan dapat dihapus; Hidden tidak termasuk daftar yang ditampilkan. Request tambah memeriksa status dan ownership di server. Guest diarahkan login dan user login tanpa profil lengkap diarahkan onboarding. Penghapusan favorite dilakukan melalui POST; edit catatan tersedia di `/favorites/<id>/edit/`.

### 4.9 Sustainable guide

Member login dapat mengirim draf panduan, melihat drafnya, dan mengubah/menghapusnya hanya ketika status `PENDING`. Berbeda dari listing/favorite, implementasi view draf menggunakan gate login, bukan gate profil lengkap. Guest dan member dapat membaca hanya guide yang telah disetujui, ditandai terbit, dan waktu terbitnya sudah tercapai. Daftar publik mendukung filter kategori dan pilihan artikel unggulan acak; detail memuat Markdown yang disanitasi, daftar isi, waktu baca, dan hingga tiga artikel terkait acak.

Dashboard `/moderation/guides/` menyediakan peninjauan, persetujuan/penolakan, penghapusan, publikasi sekarang, penarikan publikasi, dan penjadwalan. Persetujuan dapat langsung menerbitkan atau menyimpan artikel disetujui untuk diterbitkan kemudian. **Pembuatan/edit guide admin melalui dashboard tidak tersedia**; admin tidak memiliki route khusus untuk membuat atau mengedit artikel, dan Guide tidak didaftarkan di Django Admin.

### 4.10 Report dan moderasi

**Belum diimplementasikan.** Repository tidak berisi app/model `Report`, route `/reports/` atau `/moderation/reports/`, maupun UI create/read/update/delete dan moderasi report. Desain awalnya tetap dicatat sebagai tujuan lanjutan, bukan fitur yang dapat digunakan pada project saat ini. Moderasi guide dilakukan melalui dashboard tersendiri untuk superuser; moderasi listing tersedia sebagai aksi hide di Django Admin untuk staff berizin.

### 4.11 Integrasi lokasi dengan Nominatim

Pada form listing, seller mencari kota atau area pickup umum melalui Nominatim. Aplikasi menyimpan nama kota/area, latitude, dan longitude untuk ditampilkan dan difilter.

Pakelagi menggunakan [Nominatim Search API](https://nominatim.org/release-docs/latest/api/Search/) dengan batas negara Indonesia (`countrycodes=id`). Implementasi mengirim request dari server menggunakan User-Agent yang mengidentifikasi Pakelagi, melakukan cache hasil, jeda satu detik, cooldown saat API menolak, membatasi hasil ke area setingkat kota/area umum, membulatkan koordinat, mencantumkan atribusi OpenStreetMap, serta membolehkan input kota manual saat gagal. **Catatan selisih operasional:** kode tidak mengirim Referer; rate limit memakai Django cache lokal bawaan dan belum menjamin koordinasi lintas worker. Pastikan cache terdistribusi dikonfigurasi jika deployment multi-worker dan tinjau kepatuhan kebijakan Nominatim.

## 5. Modul dan pembagian anggota

Tabel berikut mempertahankan pembagian kelompok dari README, tetapi menggambarkan cakupan implementasi repository. Pembagian penanggung jawab adalah informasi proyek, bukan bukti bahwa setiap fitur dalam rancangan modul telah tersedia.

| Modul / penanggung jawab | Data utama | Implementasi saat ini |
|---|---|---|
| Clothing Listings — Anggota 1, Nugraha Kautsarrizqi Caksana (`2506541250`) | `Listing` | Katalog, filter/pagination, detail, CRUD pemilik, status, pencarian lokasi, serta hide melalui Django Admin. |
| User Profiles — Anggota 2, Victoriano Iman Santosa (`2506544353`) | `Profile` | Onboarding, edit, profil publik dengan storefront; penghapusan profil mandiri belum ada. |
| Saved Favorites — Anggota 3, David Liman (`2506601956`) | `Favorite` | Tambah/hapus, daftar privat, catatan. |
| Sustainable Guides — Anggota 4, Muhammad Raihan Al Qadri Kusumaputra (`2506602334`) | `Guide` | Submit/edit/delete draf Pending; moderasi/publikasi dashboard; baca publik. CRUD admin create/edit tidak tersedia. |
| Reports & Moderation — Anggota 5, Clevraldo Limuel (`2506656583`) | Belum ada model | Fitur report dan moderasi report belum diimplementasikan. |

Autentikasi dan onboarding akun/profil adalah fondasi lintas modul. Rincian perilaku profil ada di [`docs/feat/profile/profile-specification.md`](feat/profile/profile-specification.md); API JSON dan hapus akun di [`docs/feat/profile/accounts-profiles-api-specification.md`](feat/profile/accounts-profiles-api-specification.md) dan [`docs/feat/profile/account-deletion-specification.md`](feat/profile/account-deletion-specification.md). Kategori, ukuran, kondisi, status, dan tag listing menggunakan pilihan terkontrol. Tidak ada pilihan report dalam implementasi karena model report belum tersedia.

### 5.1 Pemetaan operasi CRUD per modul

Tabel ini mencatat route HTML yang benar-benar ada di repository; route API JSON dicatat pada §8. Akses tetap tunduk pada gate login/profil, kepemilikan, dan izin admin yang diterapkan server.

| Modul | Create | Read | Update | Delete |
|---|---|---|---|---|
| **Clothing Listings** (`Listing`) | `GET/POST /listings/create/` (member lengkap). | `/listings/`, `/listings/<id>/`, `/listings/mine/`. | `/listings/<id>/edit/`; status melalui `POST /listings/<id>/status/`. | `GET/POST /listings/<id>/delete/`; POST menghapus. Admin hide melalui action Django Admin. |
| **User Profiles** (`Profile`) | `GET/POST /profile/create/` untuk onboarding. | `/profile/` milik sendiri dan `/profile/<user_id>/` publik. | `GET/POST /profile/edit/`. | **Belum ada route hapus profil.** Hapus akun tersedia di `/accounts/delete/`. |
| **Saved Favorites** (`Favorite`) | `POST /favorites/listings/<listing_id>/add/`. | `/favorites/`. | `GET/POST /favorites/<id>/edit/` untuk catatan. | `POST /favorites/listings/<listing_id>/remove/`; tidak ada route `/favorites/<id>/delete/`. |
| **Sustainable Guides** (`Guide`) | `POST /guides/submit/` untuk member login; admin create belum tersedia. | `/guides/`, `/guides/<int:id>/`, `/guides/my-submissions/`, `/moderation/guides/`. | Pengirim melalui `/guides/submissions/<int:id>/edit/` selama `PENDING`; admin memutuskan/mengatur publikasi, bukan mengedit isi di dashboard. | Pengirim melalui `/guides/submissions/<int:id>/delete/` selama `PENDING`; admin POST `/moderation/guides/<int:id>/delete/`. |
| **Reports & Moderation** | Belum ada. | Belum ada. | Belum ada. | Belum ada. |

Aksi perubahan data yang tersedia memeriksa autentikasi dan kepemilikan/izin pada server. Mutasi memakai POST ber-CSRF; beberapa operasi hapus menampilkan halaman konfirmasi GET tetapi penghapusan hanya terjadi pada POST. Tombol favorite memiliki respons HTMX dan fallback HTML.

## 6. Model domain

### 6.1 Entitas dan hubungan

```text
User (Django auth)
├── 1—1 Profile
├── 1—N Listing
├── 1—N Favorite ── N—1 Listing
└── 1—N Guide (author)

Superuser ── meninjau/menerbitkan ── Guide
Staff berizin ── mengelola Listing melalui Django Admin

Report tidak memiliki model/relasi di repository saat ini.
```

### 6.2 `Profile`

| Field | Tipe/aturan |
|---|---|
| `user` | One-to-one ke Django `User`, wajib unik |
| `display_name` | wajib, maksimal 150 karakter, bukan hanya whitespace |
| `bio` | opsional, maksimal 500 karakter |
| `city` | opsional, maksimal 100 karakter, kota/area umum |
| `contact_type` | opsional; `email`, `instagram`, atau `other`; berpasangan dengan nilai |
| `contact_value` | opsional, maksimal 254 karakter; kosong bersama jenis atau terisi bersama jenis |
| `phone_number` | opsional, `08…` dinormalisasi ke `+62…`; hasil harus `+` dan 2–15 digit setelah tanda `+`, digit pertama bukan nol; tidak terverifikasi, hanya pemilik/member lengkap |
| `avatar_url`, `cover_url` | opsional, URL HTTPS gambar eksternal; dapat diganti/dikosongkan terpisah; fallback jika kosong/gagal dimuat |
| `created_at`, `updated_at` | timestamp |

Satu user dapat belum memiliki profil sebelum onboarding lalu memiliki paling banyak satu profil. Create/edit dilakukan melalui form profil; **delete profil saja belum tersedia**. Email akun opsional disimpan pada field Django `User`, bukan di `Profile`; tidak menjadi kontak publik dan tidak diverifikasi. Relasi profil menggunakan cascade saat akun dihapus. Penghapusan akun kini tersedia; cakupan relasi yang ikut dihapus harus dibaca bersama [spesifikasi penghapusan akun](feat/profile/account-deletion-specification.md).

### 6.3 `Listing`

| Field | Tipe/aturan |
|---|---|
| `seller` | ForeignKey ke `User`, wajib |
| `title` | teks 5–120 karakter, wajib |
| `description` | teks, wajib |
| `category` | `Top`, `Bottom`, `Dress`, `Outerwear`, `Modest Wear` |
| `brand` | teks pendek, opsional |
| `size` | `XS`, `S`, `M`, `L`, `XL`, `XXL`, `Free Size` |
| `condition` | `Like New`, `Good`, `Fair`, `Needs Repair` |
| `price` | integer Rupiah, wajib, 0–100.000.000 (positive integer di database; validasi form menolak nilai di atas batas) |
| `image_url` | URL HTTP/HTTPS, wajib, panjang maksimal 2048 karakter |
| `city` | kota/area umum, wajib |
| `latitude`, `longitude` | koordinat Nominatim, opsional bila input manual |
| `is_repairable` | boolean tag, default false |
| `is_upcycled` | boolean tag, default false |
| `is_locally_available` | boolean tag, default true |
| `extends_clothing_life` | boolean tag, default true |
| `status` | `Available` (default), `Sold`, `Hidden` |
| `sold_at` | waktu transisi terakhir ke Sold, untuk urutan cuplikan profil; tidak memakai waktu edit umum |
| `created_at`, `updated_at` | timestamp |

Untuk pengurutan profil, waktu publikasi harus tersedia; pada MVP publikasi saat create dapat memakai `created_at`. Transisi dari status selain Sold ke Sold mengisi `sold_at`; save ketika tetap Sold tidak mengubahnya. Listing yang dibuat langsung Sold dapat memiliki `sold_at` kosong bergantung pada proses save awal. Rincian pagination dan pembeda urutan deterministik mengikuti spesifikasi profil.

Constraint penting:

- Harga tidak boleh negatif.
- Seller pemilik atau staff berizin dapat mengelola listing sesuai gate masing-masing. Route HTML mengembalikan 404 untuk pihak selain pemilik/staff.
- Listing `Hidden` tidak boleh muncul pada katalog publik.
- `image_url` harus menggunakan skema HTTP atau HTTPS; batas maksimum harga model adalah Rp100.000.000.
- Admin hide memakai Django Admin action dan query update status menjadi Hidden; admin (staff) dapat mengubah/menghapus listing melalui admin.
- Form lokasi tidak menerima alamat presisi; input manual tetap mungkin dan koordinat kosong bila tidak dipilih hasil pencarian.

### 6.4 `Favorite`

| Field | Tipe/aturan |
|---|---|
| `user` | ForeignKey ke `User`, wajib |
| `listing` | ForeignKey ke `Listing`, wajib |
| `note` | catatan pribadi, opsional, maksimal 1000 karakter |
| `created_at`, `updated_at` | timestamp |

Constraint: kombinasi `user` dan `listing` harus unik. Member hanya boleh membaca dan mengubah favorite miliknya.

### 6.5 `Guide`

Model yang digunakan repository berbeda dari rancangan awal: tidak ada slug, dan nama field/model berbahasa Indonesia dipakai langsung.

| Field | Tipe/aturan saat ini |
|---|---|
| `author` | ForeignKey ke Django User, `CASCADE`, terkait `guides` |
| `title` | CharField, wajib, maksimal 255 karakter |
| `ringkasan` | CharField, wajib, maksimal 300 karakter |
| `image_url` | URL eksternal opsional, maksimal 2048; validator URL HTTPS eksternal profil |
| `konten` | TextField wajib; Markdown dirender dan disanitasi untuk tampilan |
| `category` | `PERAWATAN`, `PERBAIKAN`, `REUSE`, `SLOW_FASHION`, `CONSCIOUS_SHOPPING`; default `PERAWATAN` |
| `status` | `PENDING`, `DISETUJUI`, `DITOLAK`; default `PENDING` |
| `is_published` | Boolean, default false; untuk status DISETUJUI dapat dijadwalkan |
| `rejected_notes` | Catatan penolakan opsional |
| `date_submitted` | Timestamp kirim otomatis; urutan default terbaru |
| `date_published` | Timestamp jadwal/publikasi, nullable |

Daftar publik hanya memuat Guide `DISETUJUI`, `is_published=True`, dan `date_published` yang tidak berada di masa depan. Model menghitung `reading_time`; author superuser ditampilkan sebagai “Tim Pakelagi”.

### 6.6 Report

**Tidak ada model `Report` di repository saat ini.** Field report, status, relasi, dan kebijakan retensinya pada rancangan awal belum dapat dianggap schema atau fitur yang tersedia. Jika modul ini dikerjakan, model dan aturan akses harus ditetapkan tersendiri sebelum implementasi.

## 7. User stories

### Guest

- Sebagai guest, saya ingin melihat katalog agar dapat menemukan pakaian preloved tanpa membuat akun.
- Sebagai guest, saya ingin memfilter berdasarkan harga, ukuran, kondisi, kategori, kota, dan tag agar hasil pencarian relevan.
- Sebagai guest, saya ingin membaca sustainable guide agar memahami slow fashion.
- Sebagai guest, saya ingin mengetahui bahwa kontak seller hanya tersedia untuk member agar aturan privasi jelas.

### Member

- Sebagai member, saya ingin membuat listing agar pakaian yang tidak saya gunakan dapat ditemukan orang lain.
- Sebagai member, saya ingin mengubah atau menghapus listing milik saya agar informasinya tetap akurat.
- Sebagai member, saya ingin menandai listing sebagai sold agar tidak terus ditawarkan.
- Sebagai member, saya ingin menyimpan listing dan menulis catatan pribadi agar dapat membandingkannya nanti.
- Sebagai member, saya ingin melihat kontak seller setelah login agar dapat melanjutkan komunikasi di luar aplikasi.
- **Kebutuhan lanjutan (belum tersedia):** sebagai member, saya ingin melaporkan listing bermasalah agar admin dapat meninjaunya.

### Admin

- Sebagai admin, saya ingin menyembunyikan listing bermasalah agar katalog tetap aman.
- **Kebutuhan lanjutan (belum tersedia):** sebagai moderator report, saya ingin meninjau laporan dan mengubah statusnya agar proses moderasi terlacak.
- Sebagai admin, saya ingin mengelola guide agar konten slow fashion tetap relevan.

## 8. Halaman dan URL yang direncanakan / tersedia

| Halaman | URL contoh | Akses |
|---|---|---|
| Beranda | `/` | Semua |
| Jelajah kategori | `/categories/` | Semua |
| Daftar akun | `GET/POST /accounts/register/` | Guest |
| Masuk | `GET/POST /accounts/login/` | Guest |
| Keluar | `POST /accounts/logout/` | Semua; aksi POST |
| Hapus akun | `GET/POST /accounts/delete/` | Pemilik login non-staff/non-superuser |
| Katalog listing | `/listings/` | Semua |
| Detail listing | `/listings/<id>/` | Semua; Hidden untuk pemilik/staff |
| Buat listing | `/listings/create/` | Member lengkap |
| Pencarian lokasi | `/listings/location-search/` | Member lengkap |
| Listing saya | `/listings/mine/` | Member lengkap |
| Edit listing | `/listings/<id>/edit/` | Pemilik/staff |
| Hapus listing | `/listings/<id>/delete/` | Pemilik/staff; POST melakukan hapus |
| Profil saya | `/profile/` | Member |
| Buat profil | `/profile/create/` | Member tanpa profil |
| Edit profil | `/profile/edit/` | Pemilik |
| Profil publik pengguna | `/profile/<user_id>/` | Semua; ringkasan listing Available dan Sold |
| Halaman tidak ditemukan | 404 | Semua |
| Favorite saya | `/favorites/` | Member lengkap |
| Tambah favorite | `POST /favorites/listings/<listing_id>/add/` (HTMX dengan fallback) | Member lengkap |
| Edit catatan favorite | `/favorites/<id>/edit/` | Pemilik |
| Hapus favorite | `POST /favorites/listings/<listing_id>/remove/` (HTMX dengan fallback) | Pemilik |
| Daftar guide | `/guides/` | Semua |
| Detail guide | `/guides/<int:id>/` | Semua untuk guide yang telah terbit |
| Draf guide saya | `/guides/my-submissions/` | User login |
| Kirim draf guide | `/guides/submit/` | User login |
| Edit draf Pending | `/guides/submissions/<id>/edit/` | Pengirim selama `PENDING`, user login |
| Hapus draf Pending | `/guides/submissions/<id>/delete/` | Pengirim selama `PENDING`, user login; POST menghapus |
| Hapus guide | `POST /moderation/guides/<id>/delete/` | Superuser |
| Moderasi | `/moderation/` | Superuser |
| Kelola/review/publikasi guide | `/moderation/guides/` dan aksi POST `/moderation/guides/<id>/.../` | Superuser |
| Kelola report | Belum ada route | Belum tersedia |

Template menggunakan struktur bersama `base.html`, header/navbar, footer, halaman error, kartu listing, dan partial hasil katalog/favorite/profil. Route JSON API yang tersedia: Accounts `/api/v1/accounts/register/`, `/login/`, `/logout/`, `/delete/`; Profiles `/api/v1/profiles/`, `/me/`, `/<user_id>/`. Spesifikasi API terperinci dirujuk pada §4.6.

## 9. Interaktivitas HTMX

### Filter katalog

- Form filter memakai method `GET` ke `/listings/`.
- HTMX menerima hasil partial katalog; navigasi pagination/filter biasa tetap dapat dibuka penuh dan query URL mempertahankan filter, sort, serta page.
- Perubahan filter tidak memuat ulang seluruh halaman saat HTMX tersedia.
- Tombol favorite menggunakan HTMX untuk mengganti button/list partial sesuai konteks, dengan respons HTML redirect sebagai fallback.
- Jika tidak ada hasil, tampilkan empty state yang jelas.

### Favorite toggle

- Tombol favorite mengirim request `POST` dengan CSRF token.
- Response hanya mengganti tombol atau counter terkait.
- Guest diarahkan ke login.
- Request duplikat tidak boleh membuat favorite ganda.

### Fallback

Alur filter dan favorite memiliki fallback HTML; beberapa pengalaman catatan favorite/profil juga memiliki partial HTMX. Perilaku setiap kontrol harus tetap diuji dengan JavaScript/HTMX tidak tersedia.

Template dasar `base.html` mengatur CSRF token/header untuk request HTMX secara global, sehingga request yang mengubah data tetap dilindungi Django CSRF.

## 10. Integrasi Nominatim

### Alur

1. Member mengetik kota atau area pickup umum pada form listing; route pencarian tersedia di `/listings/location-search/`.
2. Antarmuka mencari secara bertahap/debounce. Server mengirim query ke endpoint Search API dengan `format=jsonv2`, `countrycodes=id`, `addressdetails=1`, bahasa Indonesia, serta jumlah hasil kecil.
3. Member memilih hasil yang sesuai.
4. Aplikasi menyimpan nama area, latitude, dan longitude pada listing.
5. Katalog memakai field kota untuk filter; koordinat tidak digunakan untuk menunjukkan alamat presisi.

### Batasan operasional

- Request dilakukan dari server Django dengan User-Agent yang menjelaskan Pakelagi; **header Referer belum dikirim**.
- Hasil query positif disimpan 24 jam, hasil kosong 1 jam; query dinormalisasi dan cache key di-hash.
- `cache.add` membatasi request maksimal satu per detik; error 403/429 menimbulkan cooldown lima menit. Cache saat ini lokal-memory default dan tidak menjamin koordinasi antarproses/worker.
- Request membawa `format=jsonv2`, `countrycodes=id`, `limit=8`, `addressdetails=1`, `accept-language=id`; paling banyak enam hasil area umum dipresentasikan. Koordinat dibulatkan sekitar 0,01 derajat dan hasil non-kota/area ditolak.
- UI menampilkan atribusi OpenStreetMap/Nominatim.
- Jika Nominatim tidak tersedia, input kota manual tetap dapat digunakan; error tidak memutus form.
- Untuk deployment multi-worker, konfigurasi cache bersama dan koordinasi rate limit merupakan pekerjaan lanjutan.

## 11. Design system

Tailwind CSS digunakan melalui CDN seperti pada template dasar project; CSS custom digunakan untuk identitas dan komponen khusus Pakelagi. Tailwind menjadi acuan UI dokumen ini.

| Token | Nilai awal | Penggunaan |
|---|---|---|
| Bottle green | `#1F3D33` | Footer dan section gelap |
| Terracotta | `#B5532F` | CTA dan aksen |
| Ivory | `#F7F4EE` | Background utama |
| Ink | `#1A1C1A` | Teks utama |
| Sage | `#E3E8E1` | Surface tag |
| Pendukung | Sand `#EDE7DC`, stone `#57524B`, ochre `#C39A4A` | Panel, teks sekunder, detail aksen |

Token aktual didefinisikan di `static/css/base.css`; typography memakai Cormorant Garamond untuk display dan Jost untuk sans-serif. Tailwind dimuat melalui CDN di template dasar.

Prinsip UI:

- mobile-first dan usable pada layar kecil;
- kontras teks dan background memadai;
- setiap input memiliki label dan pesan error;
- gambar memiliki alt text;
- status memakai teks selain warna;
- tombol dan link dapat digunakan dengan keyboard;
- kartu listing menonjolkan harga, kondisi, kota, dan status.

Tag keberlanjutan harus ditampilkan sebagai fakta yang dipilih seller, bukan sebagai klaim angka dampak lingkungan.

## 12. Keamanan dan privasi

- Gunakan Django authentication; aksi listing/favorite yang mensyaratkan member lengkap menggunakan gate profil lengkap, sedangkan sebagian view guide mensyaratkan login saja. Terapkan gate yang sesuai kebutuhan dan jangan menyamakan login dengan profil lengkap.
- Gunakan validasi Django bawaan untuk username/password; registrasi meminta konfirmasi password. Jangan log atau menampilkan password.
- Profil wajib dilengkapi sampai memiliki `display_name` sebelum fitur member dapat digunakan; jangan memblokir halaman publik atau logout.
- Email akun opsional, belum terverifikasi, dan tidak boleh diperlakukan otomatis sebagai kontak publik.
- Terapkan ownership check pada setiap update/delete; jangan hanya mengandalkan ID dari URL.
- Gunakan CSRF protection pada seluruh form POST.
- Validasi semua input melalui Django Forms.
- URL gambar listing hanya HTTP/HTTPS; avatar/sampul profil hanya HTTPS. Server tidak mengambil gambar profil eksternal. URL kosong/gagal dimuat menggunakan fallback.
- Kontak Instagram dinormalisasi menjadi handle, email kontak divalidasi sebagai email, dan other di-escape sebagai teks; hanya URL HTTP/HTTPS valid yang dijadikan tautan (email memakai `mailto:`).
- Jangan mengirim nilai kontak atau nomor telepon kepada guest maupun user login yang belum melengkapi profil, termasuk melalui partial dan respons data. Nomor telepon hanya diperiksa formatnya, bukan diverifikasi kepemilikannya.
- **Pekerjaan keamanan deployment:** konfigurasi saat ini memiliki `DEBUG=True` tanpa syarat, `SECRET_KEY` hard-coded, dan `ALLOWED_HOSTS` literal. Jangan deploy konfigurasi ini sebagai production tanpa mengubah settings agar secret/hosts berasal dari environment, menonaktifkan DEBUG, lalu menguji checklist keamanan Django. Kredensial DB production diambil dari environment saat `PRODUCTION=true`.
- Jangan menampilkan contact value kepada guest.
- Jangan menyimpan atau menampilkan alamat rumah.
- Gunakan escaping bawaan template Django untuk konten user.
- Gunakan pesan sukses/error yang tidak membocorkan detail internal.

## 13. Rencana testing

Gunakan Django `TestCase` dan test client bawaan sebagai baseline.

### Test minimum

- model menerima data valid dan menolak harga negatif;
- URL gambar dan pilihan status tervalidasi;
- guest dapat membaca listing published/available dan guide published;
- halaman profil publik hanya menampilkan listing Available dan Sold, bukan Hidden;
- member login dapat mengirim draf guide, mengubah/menghapus draf Pending miliknya; gate profil lengkap tidak digunakan pada view draf saat ini;
- superuser dapat menyetujui/menolak draf guide, menerbitkan sekarang/terjadwal, menarik publikasi; persetujuan dapat langsung menerbitkan;
- listing dapat di-hide melalui Django Admin oleh staff yang berwenang; Report tidak diimplementasikan;
- guest tidak dapat membuat, mengubah, atau menghapus data member;
- registrasi username/password berhasil, password dikonfirmasi dan disimpan melalui mekanisme hashing Django, serta username duplikat ditolak;
- email akun boleh kosong dan tidak dianggap terverifikasi;
- member baru diarahkan ke onboarding profil dan tidak dapat memakai fitur member sebelum `display_name` tersedia; setelah profil lengkap akses member normal diberikan;
- route hapus profil saat ini belum tersedia; hapus akun merupakan operasi berbeda dan menghapus user, profil, listing, favorite, serta guide melalui cascade model yang ada;
- URL yang tidak ditemukan menampilkan halaman 404 Pakelagi yang aman dan menyediakan navigasi kembali;
- member hanya dapat mengubah atau menghapus listing/favorite miliknya; report dan hapus profil belum tersedia;
- staff berizin dapat mengelola/hide listing melalui Django Admin; tidak ada moderasi report;
- CRUD listing, profil (tanpa delete), favorite, dan sebagian alur guide berjalan; report dan pembuatan/edit guide oleh admin belum tersedia;
- API/HTML profil hanya mengubah profil milik user login; delete profil saja belum tersedia. Penghapusan akun terpisah dan menghapus data terkait melalui cascade model;
- pengirim guide tidak dapat mengubah/menghapus draf setelah statusnya bukan `Pending`;
- filter kombinasi menghasilkan data yang benar;
- favorite unik per member-listing;
- listing hidden tidak tampil di katalog publik;
- contact seller tidak tampil untuk guest;
- endpoint HTMX mengembalikan partial yang sesuai;
- respons Nominatim di-mock dalam test, sehingga test tidak bergantung pada internet;
- gambar yang gagal dimuat menampilkan placeholder lokal;
- kegagalan Nominatim memiliki fallback ke input kota manual.

Target coverage: minimal 80% sebagai sasaran kelompok, dengan fokus pada permission dan alur CRUD.

## 14. Seed data dan deployment

Listing memakai satu URL gambar eksternal dan tidak menerima upload berkas. Jika URL tidak valid atau gambar gagal dimuat, template menampilkan placeholder lokal yang relevan agar katalog dan detail tetap utuh. URL gambar pada data demo harus diperiksa agar dapat diakses.

Perintah `python manage.py seed_listings` tersedia dan aman diulang: memperbarui sample yang sama alih-alih menggandakan, dengan opsi `--reset` yang hanya menghapus listing milik akun contoh. Seed menyertakan 5 akun penjual contoh tanpa password yang dapat dipakai login, 50 listing Available (10 per kategori) dan 10 listing Sold. Ini adalah kapabilitas seed repository; jumlah data di PWS perlu diverifikasi terpisah.

Distribusi seed yang tersedia:

- 10 Top;
- 10 Bottom;
- 10 Dress;
- 10 Outerwear;
- 10 Modest Wear;
- variasi ukuran, kondisi, harga, kota, dan tag keberlanjutan;
- semua listing sample menggunakan image URL yang valid;
- gunakan akun sample, bukan data kontak pribadi anggota.

Checklist deployment:

- PostgreSQL digunakan pada environment deployment;
- `PRODUCTION=true` mengaktifkan PostgreSQL menggunakan `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`, dan opsional `SCHEMA`; development default memakai SQLite. Secret key/hosts saat ini belum aman: hard-coded; `DEBUG` selalu true. Perbaiki sebelum deployment production dan validasi settings production secara nyata;
- migration berhasil dijalankan;
- static files berhasil dikumpulkan;
- `DEBUG=False` pada production setelah konfigurasi diperbaiki (saat ini selalu `True`, jadi checklist belum terpenuhi);
- halaman utama, kategori, login/registrasi/hapus akun, katalog, detail, form CRUD yang tersedia, guide, favorite, dan moderasi guide dapat diuji; report belum tersedia;
- registrasi, login/logout, onboarding profil wajib, serta halaman 404 berjalan;
- fixture/seed data dapat diulang tanpa membuat data duplikat yang tidak terkendali;
- URL PWS dicantumkan di README; keberadaan URL tidak menggantikan health check dan review konfigurasi keamanan production.

## 15. Milestone

| Waktu | Hasil yang harus tersedia |
|---|---|
| Checkpoint 1 — 16 September 2026 | Repository bersama, README awal, ide, peran, modul, API, dan pembagian anggota |
| Checkpoint 2 — 28 September–2 Oktober 2026 | Template dasar, design system, integrasi awal, dan deployment pertama ke PWS |
| Pengumpulan akhir — 23 Oktober 2026 | Semua modul terintegrasi, data awal minimal 50 listing, testing lulus, deployment aktif, README lengkap |

Urutan kerja paling aman:

Tahapan berikut adalah catatan rencana awal, bukan status pekerjaan saat ini. Project telah memiliki aplikasi Django, modul listing/profile/favorite/guide, API Accounts/Profiles, interaksi HTMX, seed listing, dan integrasi Nominatim. Pekerjaan lanjutan berdasarkan selisih implementasi meliputi: menambah modul Report jika masih menjadi target; melengkapi kebijakan moderasi guide/admin CRUD bila dibutuhkan; memutuskan apakah delete profil dibutuhkan; mengirim Referer dan mengonfigurasi cache Nominatim lintas worker; serta memperbaiki konfigurasi keamanan deployment sebelum menyatakan siap production. Lihat README dan dokumen fitur terkait untuk cara menjalankan/menguji.

## 16. Kriteria penerimaan

Ringkasan kriteria yang **sudah diverifikasi pada implementasi repository**:

- Guest dapat menjelajah kategori, katalog Available, filter, pagination, detail listing, guide terbit, dan profil publik.
- Member dengan profil lengkap dapat mengelola listing milik sendiri dan favorite; ownership diterapkan di server. Onboarding dan kontak seller memiliki gate profil lengkap.
- Filter katalog dan aksi favorite menyediakan interaksi HTMX serta fallback HTML.
- Guide mendukung draf member, review superuser, dan pengaturan publikasi sekarang/terjadwal.
- Integrasi Nominatim, cache lokal, throttling, atribusi, dan input manual tersedia; Referer dan cache lintas worker belum ada.
- Seed command dapat menyediakan 50 Available + 10 Sold sample secara idempotent; data PWS aktual harus diverifikasi.
- Template bersama, UI responsive, dan halaman 404 bermerek tersedia.
- Tests tersedia untuk sejumlah alur utama, tetapi jalankan suite/coverage untuk mengetahui hasil terkini.

**Belum terpenuhi/belum tersedia:** Report dan moderasi report; hapus profil saja; admin guide create/edit; cache Nominatim terdistribusi/Referer; konfigurasi security production (`DEBUG=False`, secret key dan hosts dari environment). Data deployment dan health PWS tidak diverifikasi oleh inspeksi repository. Kriteria target berikutnya harus dipisahkan dari fitur yang sudah ada.

## 17. Checklist README kelompok

- [ ] Deskripsi aplikasi dan manfaat bagi masyarakat
- [ ] Nama dan NPM lima anggota
- [ ] Daftar lima modul dan pembagian kerja
- [ ] Peran pengguna: guest, member, admin
- [ ] Dokumentasi [Nominatim Search API](https://nominatim.org/release-docs/latest/api/Search/)
- [ ] Tautan [Nominatim Usage Policy](https://operations.osmfoundation.org/policies/nominatim/)
- [ ] Tautan repository Git
- [ ] Tautan deployment PWS
- [ ] Tautan desain Figma
- [ ] Cara menjalankan project dan melakukan seed data

Informasi proyek saat ini (ikuti README untuk pembaruan):

- Repository: https://github.com/pbp-kelompok-b8/pakelagi
- Deployment PWS: http://david-liman-pakelagi.pws.cs.ui.ac.id
- Figma: https://www.figma.com/design/dCekkdFnlpwdcTY6vaXyrX/Web-Design?m=auto&t=WEkEhoembXHyU27W-1

## 18. Dokumen terkait dan informasi proyek

Rincian auth, onboarding profil, storefront, dan halaman 404: [`docs/feat/profile/profile-specification.md`](feat/profile/profile-specification.md). Rincian JSON API: [`docs/feat/profile/accounts-profiles-api-specification.md`](feat/profile/accounts-profiles-api-specification.md). Rincian perilaku penghapusan akun dan gap cascade: [`docs/feat/profile/account-deletion-specification.md`](feat/profile/account-deletion-specification.md). Untuk petunjuk instalasi, seed, test, dan deployment, gunakan README.

```text
Anggota 1: Nugraha Kautsarrizqi Caksana — 2506541250 — Clothing Listings
Anggota 2: Victoriano Iman Santosa — 2506544353 — User Profiles
Anggota 3: David Liman — 2506601956 — Saved Favorites
Anggota 4: Muhammad Raihan Al Qadri Kusumaputra — 2506602334 — Sustainable Guides
Anggota 5: Clevraldo Limuel — 2506656583 — Reports & Moderation

Repository for Web : https://github.com/pbp-kelompok-b8/pakelagi
Repository for Web : https://github.com/pbp-kelompok-b8/pakelagi_mobile
Figma for Web : https://www.figma.com/design/dCekkdFnlpwdcTY6vaXyrX/Web-Design?m=auto&t=WEkEhoembXHyU27W-1
Figma for mobile : https://www.figma.com/design/QZEtPQaa7BCS3UM4BhxhkX/Mobile-Design?node-id=20-4&p=f&m=dev
PWS deployment for Web : http://david-liman-pakelagi.pws.cs.ui.ac.id

```
