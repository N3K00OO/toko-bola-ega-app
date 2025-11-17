 Nama: Gregorius Ega Aditama Sudjali
# NPM: 2406434153
# Toko Bola EGA


## Fitur Utama
- Tiga tombol aksi (`All Products`, `My Products`, `Create Product`) dengan warna berbeda dan snackbar tematik ketika ditekan.
- Ringkasan statistik toko (jumlah produk, stok aktif, kategori, dan item favorit) untuk memberi konteks bisnis secara ringkas.
- Katalog produk berbentuk kartu responsif lengkap dengan kategori, deskripsi singkat, harga dalam rupiah, dan status stok.
- Snack bar kontekstual ketika kartu produk disentuh agar interaksi terasa hidup.
- Desain berbasis Material 3 dengan warna dan tipografi yang disesuaikan agar konsisten dengan brand sepak bola.

## Struktur Widget Inti
- `TokoBolaApp`: Root `MaterialApp` yang mengatur tema dan halaman awal aplikasi.
- `HomePage`: Halaman utama stateless yang merangkai header, menu aksi, statistik, dan katalog produk.
- `ShopHeader`: Kartu hero yang memperkenalkan toko dengan latar warna `primaryContainer`.
- `ShopMenuButton`: Pembungkus tombol aksi yang menegakkan warna masing-masing fitur dan memicu snackbar.
- `ShopStatisticTile`: Kartu ringkas yang menampilkan metrik utama toko dengan ikon pendukung.
- `ProductCard`: Kartu produk dengan detail kategori, deskripsi, harga, dan badge stok.
- `StockBadge`: Indikator stok yang berubah warna sesuai ketersediaan barang.
- Utilitas `ShopMenuAction`, `FootballProduct`, `_showActionSnackBar`, dan `_formatCurrency` membantu menjaga data dan logika tetap terstruktur.

## Cara Menjalankan
1. Pastikan perangkat pengembangan Flutter sudah siap (`flutter doctor` bersih).
2. Dari direktori proyek, jalankan `flutter pub get` untuk memastikan seluruh dependensi tersedia.
3. Jalankan aplikasi dengan `flutter run` pada emulator atau perangkat fisik.

## Pertanyaan Tugas 7
1. **Widget tree & relasi parent-child**  
   Widget tree adalah struktur hierarki widget yang membentuk UI Flutter. Setiap widget memiliki parent yang menentukan konteks tata letak dan state anak-anaknya. Anak menerima constraint, warna, dan event bubbling dari parent, sementara parent bertanggung jawab menempatkan anak pada layout. Pemahaman relasi ini penting agar data, state, dan ukuran mengalir dengan benar.

2. **Widget yang digunakan dan fungsinya**  
   `MaterialApp` (root app & tema), `Scaffold` (kerangka halaman), `AppBar`, `SafeArea`, `SingleChildScrollView`, `LayoutBuilder`, `Column`, `Wrap`, `Card`, `FilledButton.icon`, `CircleAvatar`, `Icon`, `Text`, `SizedBox`, `Row`, `Expanded`, `Container`, dan `InkWell`. Semua widget ini bekerja sama menyediakan layout responsif, interaksi, serta estetika katalog toko.

3. **Fungsi `MaterialApp`**  
   `MaterialApp` menyiapkan konfigurasi global seperti navigator, tema Material, locale, serta pengaturan routing. Widget ini umum dijadikan root karena menyediakan infrastruktur Material Design sekaligus menjadi sumber `ThemeData` dan `MediaQuery` untuk seluruh subtree.

4. **Perbedaan StatelessWidget vs StatefulWidget**  
   `StatelessWidget` tidak menyimpan state internal; UI hanya bergantung pada konfigurasi dan data eksternal. `StatefulWidget` memiliki objek `State` yang bisa berubah dan memicu rebuild. Gunakan `StatelessWidget` untuk tampilan statis (seperti `HomePage` pada tugas ini), gunakan `StatefulWidget` saat membutuhkan perubahan dinamis seperti counter, form yang validasinya bergantung pada input, atau animasi.

5. **Makna `BuildContext` dan penggunaannya**  
   `BuildContext` merepresentasikan posisi widget dalam tree sekaligus pintu akses ke inherited widget (`Theme`, `MediaQuery`, `Navigator`, dsb). Dalam metode `build`, context digunakan untuk membaca tema, ukuran layar, menampilkan snackbar melalui `ScaffoldMessenger`, atau melakukan navigasi.

6. **Hot reload vs hot restart**  
   Hot reload menyuntikkan perubahan kode ke VM tanpa menghapus state `StatefulWidget` yang ada, sehingga cocok untuk iterasi UI cepat. Hot restart merestart aplikasi dari awal, menghapus seluruh state in-memory. Pilih hot reload untuk perubahan tampilan dan hot restart ketika membutuhkan state fresh atau setelah mengubah kode yang tidak didukung hot reload (mis. init state).

## Tugas 8 â€“ Flutter Navigation, Layouts, Forms, and Input Elements

### Jawaban Pertanyaan
1. **Navigator.push() vs Navigator.pushReplacement()**  
   `Navigator.push()` menambahkan halaman baru ke atas tumpukan tanpa menghapus halaman sebelumnya sehingga pengguna masih bisa kembali dengan tombol back. Fitur ini saya gunakan untuk tombol Tambah Produk pada halaman utama supaya setelah menyimpan formulir pengguna bisa menekan tombol back untuk kembali ke dashboard. `Navigator.pushReplacement()` menggantikan halaman aktif dengan halaman baru sehingga halaman awal tidak lagi tersimpan di tumpukan. Mode ini lebih cocok untuk navigasi melalui Drawer agar pengguna tidak membuat banyak instance halaman yang sama ketika memilih opsi Halaman Utama atau Tambah Produk.

2. **Pemanfaatan Scaffold, AppBar, dan Drawer**  
   Saya membungkus setiap halaman utama dengan `Scaffold` agar struktur dasar (AppBar, body, Drawer) selalu tersedia. `AppBar` menampilkan identitas toko dengan latar gradien yang sama di setiap halaman sehingga pengguna merasa berada di aplikasi yang sama meskipun berpindah layar. `Drawer` saya ekstrak menjadi widget terpisah (`AppDrawer`) dan disisipkan pada seluruh halaman agar navigasi antara Halaman Utama dan Tambah Produk konsisten serta mudah dipelihara.

3. **Kelebihan layout widget untuk form**  
   `Padding` memberi ruang napas pada setiap input sehingga form lebih mudah dibaca. `SingleChildScrollView` memastikan form tetap dapat di-scroll pada layar kecil sehingga tidak terjadi overflow saat keyboard muncul. Keduanya saya kombinasikan dengan `Column` di halaman Tambah Produk sehingga seluruh elemen (teks pengantar, input, dropdown, switch, dan tombol) tersusun rapi. Ketika nanti daftar produk ingin ditampilkan dinamis, `ListView` dapat digunakan agar item menyesuaikan tinggi konten tanpa perlu menghitung manual.

4. **Menyesuaikan warna tema**  
   Saya menentukan `ColorScheme.fromSeed` dengan warna hijau utama (#0B8457) serta mengatur `appBarTheme`, `scaffoldBackgroundColor`, dan `inputDecorationTheme`. Dengan cara ini, seluruh komponenâ€”mulai dari tombol aksi, border input, hingga Drawerâ€”memakai kombinasi warna yang sama sehingga identitas Football Shop terasa konsisten di setiap halaman.
## Tugas 9 – Integrasi Django x Flutter

1. **Mengapa perlu model Dart untuk JSON?**  
   Model Dart menjaga validasi tipe, null-safety, serta dokumentasi struktur data sehingga parsing JSON tidak lagi berupa `Map<String, dynamic>` liar yang rawan salah kunci atau tipe. Ketika model berubah, compiler memberi tahu bagian mana yang perlu diperbarui sehingga maintainability meningkat.

2. **Peran package `http` vs `CookieRequest`**  
   Package `http` saya pakai untuk request stateless seperti registrasi karena cukup mengirim JSON tanpa perlu melampirkan cookie sesi. `CookieRequest` menyederhanakan request yang membutuhkan sesi Django (login, logout, serta seluruh endpoint terproteksi) dengan cara menyimpan `Set-Cookie` dan otomatis mengirimkan kembali pada request berikutnya.

3. **Mengapa `CookieRequest` dibagikan?**  
   Satu instance yang disediakan lewat `Provider` memastikan seluruh widget mengakses sesi yang sama, tidak terjadi double login, serta memudahkan logout global. Jika setiap widget membuat instance sendiri, cookie yang tersimpan akan berbeda-beda dan autentikasi Django gagal.

4. **Konfigurasi konektivitas Flutter <-> Django**  
   Saya menambahkan `10.0.2.2` ke `ALLOWED_HOSTS` dan `CSRF_TRUSTED_ORIGINS` agar emulator Android bisa memanggil server lokal. Paket `django-cors-headers` diaktifkan supaya request lintas-origin diterima dan cookie bisa dibaca. Seterusnya `SESSION_COOKIE_SAMESITE`/`CSRF_COOKIE_SAMESITE` diset supaya cookie boleh dikirim dari Flutter, dan manifest Android diberi izin `INTERNET`. Jika salah satu langkah ini lupa, request akan diblokir (CORS/host), cookie tak terkirim (SameSite), atau aplikasi Android gagal membuka jaringan sama sekali (permission).

5. **Alur data dari input sampai tampil di Flutter**  
   Contoh tambah produk: pengguna mengisi form Flutter -> `ProductService` mengubah ke JSON dan memanggil `POST /api/products/` memakai `CookieRequest` -> Django memvalidasi melalui `ProductAPIForm`, menyimpan ke database, lalu merespons JSON -> Flutter mem-parse JSON ke model `Product` dan menampilkan dialog ringkasan beserta daftar terbaru di halaman katalog.

6. **Mekanisme autentikasi (login/register/logout)**  
   Registrasi memakai `http` ke `/api/auth/register/` untuk membuat user, lalu otomatis memanggil `CookieRequest.login` supaya sesi Django aktif. Login hanya memakai `CookieRequest.login`, menyimpan cookie session + `last_login`, dan `SessionState` diperbarui sehingga seluruh UI tahu pengguna aktif. Logout memanggil `CookieRequest.logout`, cookie dihapus di Django, provider `SessionState` dikosongkan, dan seluruh halaman diarahkan ke layar login.

7. **Langkah implementasi checklist**  
   (a) Mengeraskan backend Django: menambah `corsheaders`, `ALLOWED_HOSTS`, endpoint auth JSON, dan payload owner agar Flutter punya data lengkap.  
   (b) Menambah dependency Flutter (`pbp_django_auth`, `provider`, `http`, `intl`) plus konfigurasi manifest Internet.  
   (c) Membuat lapisan model (`Product`, `SessionUser`), state (`SessionState`), dan service (`AuthService`, `ProductService`) sehingga UI tidak ketergantungan langsung pada request mentah.  
   (d) Mendesain ulang alur login/register dengan form validasi, mencatat sesi lewat `Provider`, dan menambah rute baru (login, register, home, list, detail, add).  
   (e) Membangun halaman daftar item + detail memakai data dari endpoint JSON Django dengan filter `mine=1`, `RefreshIndicator`, dan kartu modern.  
   (f) Mengintegrasikan form tambah produk supaya menembakkan data ke endpoint Django, menampilkan dialog sukses, serta menambahkan tombol logout di seluruh halaman.  
   (g) Mengisi README dengan jawaban teknis dan dokumentasi perubahan agar mudah direview.



