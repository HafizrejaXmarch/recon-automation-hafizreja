# Dokumentasi Laporan Otomatisasi Alat Reconnaissance (Recon-Auto)

Laporan ini disusun untuk memenuhi tugas praktis pada Bootcamp Cyber Security Batch 6. Proyek ini berfokus pada pembuatan skrip otomatisasi menggunakan pemrograman Bash (*Bash Scripting*) untuk menggabungkan beberapa alat pengujian keamanan (*chaining tools*) ke dalam satu pipa kerja (*pipeline*) secara menyeluruh (*end-to-end*).

---

##  Struktur Direktori Proyek
Pengelolaan berkas dan tata letak direktori dalam proyek otomatisasi ini disusun secara terstruktur dengan standarisasi sebagai berikut:

- **`input/`**: Direktori yang menampung berkas target pemindaian.
  - `domains.txt`: Berisi daftar nama domain target utama yang akan dipindai (minimal 5 domain).
- **`output/`**: Direktori hasil pemrosesan data skrip.
  - `all-subdomains.txt`: Menampung seluruh daftar subdomain unik yang berhasil dikumpulkan (sudah melewati proses penyaringan).
  - `live.txt`: Hasil akhir berupa daftar *host* yang aktif/hidup disertai kode respons HTTP dan judul halaman web.
- **`scripts/`**: Direktori komponen utama.
  - `recon-auto.sh`: Skrip Bash utama yang menjalankan seluruh logika otomatisasi (*executable*).
- **`logs/`**: Direktori untuk manajemen rekaman sistem.
  - `progress.log`: Mencatat riwayat jalannya pemindaian secara berkala lengkap dengan penanda waktu (*timestamp*).
  - `errors.log`: Mencatat kesalahan teknis sistem (*standard error*) untuk mempermudah evaluasi (*troubleshooting*).

---

##  Spesifikasi Alat dan Penjelasan Logika Skrip

### 1. Pengecekan Versi Dependensi Alat (Tools)
Sebelum skrip otomatisasi dijalankan, sistem dipastikan telah memperbarui seluruh repositori (`sudo apt upgrade -y`), mengonfigurasi bahasa pemrograman Go (Golang), serta memasang tiga alat utama dengan versi berikut:
- **Subfinder (v2.13.0)**: Alat untuk menemukan subdomain secara pasif melalui pencarian log transparansi sertifikat dan indeks mesin pencari.
- **Httpx (v1.9.0)**: Alat untuk memvalidasi ketersediaan protokol HTTP/HTTPS serta menganalisis respons dari *host* target.
- **Anew**: Alat penyaring baris teks yang berfungsi untuk mengeliminasi duplikasi data secara dinamis.

### 2. Alur Kerja Logika Skrip (`recon-auto.sh`)
Skrip otomatisasi dirancang untuk bekerja baris demi baris secara sekuensial dengan urutan logika sebagai berikut:
- **Validasi Berkas Input**: Skrip memastikan berkas target `input/domains.txt` tersedia di dalam sistem sebelum memulai proses agar tidak terjadi kegagalan eksekusi.
- **Perulangan Dinamis (*Looping*)**: Menggunakan perintah `while read -r DOMAIN`, skrip membaca daftar domain target pada berkas input secara otomatis satu per satu tanpa intervensi manual.
- **Pemindaian Pasif Beserta Flag Khusus**: Proses pencarian menggunakan perintah `subfinder` dengan flag `-d` untuk menentukan target domain, serta flag `-silent` agar output teks yang dihasilkan bersih dari tampilan banner visual bawaan alat.
- **Deduplikasi Melalui Jalur Pipa (*Piping*)**: Hasil pencarian subdomain dari *subfinder* langsung dialirkan ke alat *anew* menggunakan operator pipa (`|`). Alat *anew* akan memfilter dan hanya memasukkan subdomain baru (unik) ke dalam berkas `output/all-subdomains.txt`.
- **Uji Validasi Host Aktif (*Probing*)**: Seluruh daftar subdomain unik yang terkumpul kemudian diproses secara massal oleh alat *httpx*. Hasil akhir berupa *host* yang aktif akan disimpan secara rapi pada berkas `output/live.txt`.

---

## Ringkasan Hasil Eksekusi Pemindaian
Berdasarkan hasil pengujian penuh (*end-to-end*) yang telah berhasil dijalankan pada sistem Kali Linux, skrip otomatisasi mencatat ringkasan data sebagai berikut:

1. **Daftar Domain Target**:
   - google.com
   - tesla.com
   - github.com
   - microsoft.com
   - indonesia.go.id
2. **Total Subdomain Unik Berhasil Difilter**: 43.624 Subdomain.
3. **Total Live Hosts Berhasil Terverifikasi**: 1.784 Host Aktif.

Seluruh log aktivitas pemindaian terdokumentasi secara berkala di dalam `logs/progress.log` sejak proses dimulai (*START*) hingga selesai (*DONE*). Adapun berkas `logs/errors.log` berada dalam kondisi kosong (0 bytes), yang menandakan bahwa skrip berhasil berjalan 100% sukses tanpa ada kesalahan teknis pada sistem.

---
**Catatan Pertanggungjawaban**: Seluruh rangkaian praktik, analisis data, hingga penyusunan dokumentasi ini diselesaikan secara mandiri sebagai bagian dari proses pembelajaran intensif pada program Cyber Security Bootcamp.
