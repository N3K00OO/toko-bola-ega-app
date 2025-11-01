# Nama: Gregorius Ega Aditama Sudjali
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
