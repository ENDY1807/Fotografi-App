# 📸 ShutterCloud — Photography Cloud Storage System
> Sistem Penyimpanan & Kurasi Dokumentasi Kegiatan (Foto & Video) Ekskul Fotografi Berbasis Konsep Google Drive Architecture menggunakan Flutter & Node.js Engine.

---

## 🧠 Bagian 1: Analisis Mendalam Sistem Google Drive

Google Drive bukan sekadar "folder di internet", melainkan arsitektur cloud terdistribusi dengan komponen-komponen kunci:

```
+-----------------------------------------------------------------------------------+
|                            ARSITEKTUR GOOGLE DRIVE                                |
+-----------------------------------------------------------------------------------+
|                                                                                   |
|  [ Client (Web/Flutter) ]                                                         |
|         │                                                                         |
|         ├── 1. Resumable Upload Session ───> [ API Gateway / Load Balancer ]       |
|         │                                              │                          |
|         ├── 2. Chunk Upload (8MB - 16MB) ──────────────┼──────────────────────────┤
|         │                                              ▼                          |
|         │                                   [ Storage Engine (Colossus / Blob) ]  |
|         │                                   • Chunk Assembly                      |
|         │                                   • De-duplication (SHA-256 Hash)       |
|         │                                   • Redundant Replication               |
|         │                                              │                          |
|         └── 3. Metadata Query & Search ────────────────┼──────────────────────────┤
|                                                        ▼                          |
|                                             [ Metadata DB (Spanner/Graph) ]       |
|                                             • Virtual Folder Hierarchy (DAG)      |
|                                             • Permissions & ACL (Viewer/Editor)   |
|                                             • File References & Tags              |
|                                                        │                          |
|                                                        ▼                          |
|                                             [ Asynchronous Worker Queue ]         |
|                                             • WebP Thumbnail Multi-resolusi       |
|                                             • Video Transcoding (HLS/DASH)        |
|                                             • OCR & EXIF Extraction Pipeline      |
+-----------------------------------------------------------------------------------+
```

### 1. Pemisahan Blob Storage Fisik vs Virtual File Hierarchy
- **Penyimpanan Fisik**: File biner (JPEG, RAW, MP4) dipecah dan disimpan di Blob Store (seperti Google Colossus / GFS / S3). Setiap file memiliki hash konten sehingga file kembar tidak memakan storage ganda (de-duplikasi).
- **Hirarki Virtual**: Folder di Google Drive bukan folder fisik sistem operasi Windows/Linux, melainkan graf/tabel relasional di database. Satu file memiliki `parent_folder_id`, atribut hak akses, dan tag pencarian.

### 2. Resumable Chunked Upload Protocol
- File besar (seperti video dokumentasi 4K berukuran 1-4 GB atau file burst RAW kamera berukuran ratusan MB) tidak diunggah dalam 1 HTTP POST utuh karena rentan gagal saat koneksi WiFi putus.
- GDrive membuka sesi upload dan membagi file menjadi chunk kecil (misal 8MB per paket).
- Setiap chunk dikirim dengan header HTTP `Content-Range: bytes 0-8388607/104857600`. Jika terputus di 70%, client tinggal mengirim byte ke-70% tanpa mengulang dari 0%.

### 3. Pipeline Transcoding & Thumbnail Asinkron
- Begitu upload tuntas, sistem menaruh tugas ke background worker queue:
  - **Thumbnail Generator**: Membuat thumbnail WebP multi-ukuran (small, medium, large) agar client Flutter bisa melakukan infinite scrolling galeri tanpa lag dan hemat kuota internet.
  - **Video Transcoding**: Video kegiatan dikonversi ke resolusi streaming bertahap (360p, 720p, 1080p via HLS/DASH).

---

## 🎯 Bagian 2: Kustomisasi Khusus Ekskul Fotografi

Google Drive standar memiliki kelemahan untuk kebutuhan ekskul fotografi sekolah/kampus. Sistem **ShutterCloud** ini menambahkan fitur spesifik:

| Kebutuhan Fotografi | Google Drive Standar | ShutterCloud (Sistem Ini) |
|---|---|---|
| **Metadata EXIF Kamera** | Tersembunyi / sulit dilihat | **EXIF Inspector Langsung** (Kamera, Lensa, F-stop, Shutter, ISO) untuk evaluasi teknis anggota |
| **Workflow Kurasi** | Tidak ada, semua file tercampur | **Pipeline 4 Tahap**: `RAW / Burst` ➔ `Lolos Seleksi` ➔ `Color Graded` ➔ `Dokumentasi Resmi` |
| **Pengelompokan Acara** | Folder biasa | **Event-Driven Hub** (Tanggal, Lokasi, PIC Fotografer, Kategori Acara) |
| **Atribusi Fotografer** | Hanya Google Account | **Photographer Credit Tagging** (Mencatat siswa mana yang memotret) |
| **Opsi Unduhan** | Hanya file original | **Dual Download**: Original RAW/JPG (Cetak/Majalah) & Web-Ready (Instagram/Story) |

---

## 🚀 Bagian 3: Menjalankan Sistem

### 1. Menjalankan Backend Server (Node.js)
```bash
# Masuk ke direktori server
cd "d:\Coding\Server Fotografi"

# Jalankan server
node server.js
```
Server akan aktif di:
- Dashboard Web & Preview: `http://localhost:5050`
- REST API Base URL: `http://localhost:5050/api`

### 2. Menjalankan Aplikasi Flutter
```bash
cd "d:\Coding\Server Fotografi\fotografi_app"

# Jalankan di Windows Desktop, Chrome Web, atau Android Emulator
flutter run -d chrome
# atau untuk Windows desktop:
flutter run -d windows
```

---

## 📁 Struktur Proyek

```
d:/Coding/Server Fotografi/
├── server.js               # REST API Server (GDrive architecture & EXIF simulation)
├── package.json            # Backend dependencies (Express, Multer, Cors)
├── sync_config.jsonc       # Konfigurasi kuota, folder, chunk, & preset kamera
├── uploads/                # Direktori penyimpanan blob file biner
├── data/
│   └── metadata.json       # Metadata database virtual (Events, Files, EXIF, Quota)
└── fotografi_app/          # Aplikasi Klien Flutter
    ├── lib/
    │   ├── main.dart
    │   ├── theme.dart      # Luxury dark theme (Charcoal & Amber Gold)
    │   ├── models/
    │   │   └── models.dart # StorageStats, EventItem, MediaItem, ExifData
    │   ├── services/
    │   │   └── api_service.dart # HTTP client ke server lokal + offline fallback
    │   └── screens/
    │       ├── home_screen.dart             # Dashboard Agenda & GDrive Quota
    │       ├── event_gallery_screen.dart    # Galeri foto & filter status kurasi
    │       ├── media_detail_screen.dart     # Viewer + EXIF Inspector Drawer
    │       ├── upload_screen.dart           # Chunked upload & preset kamera
    │       └── storage_analytics_screen.dart # Analisis kapasitas & leaderboard
    └── pubspec.yaml
```
