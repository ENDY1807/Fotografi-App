import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // Base URL server lokal ShutterCloud
  // Jika di emulator Android gunakan 10.0.2.2, jika web/desktop gunakan localhost
  static const String baseUrl = 'http://localhost:5050/api';

  // Fallback Mock Data agar aplikasi tetap interaktif dan hidup
  static final StorageStats _mockStats = StorageStats(
    totalStorageLimitBytes: 100 * 1024 * 1024 * 1024,
    usedStorageBytes: 24.8 * 1024 * 1024 * 1024,
    photoCount: 1420,
    videoCount: 86,
    activePhotographers: 12,
  );

  static final List<EventItem> _mockEvents = [
    EventItem(
      id: "evt-001",
      title: "Pentas Seni & HUT Sekolah 2026",
      date: "18 Sep 2026",
      location: "Auditorium Utama",
      description: "Dokumentasi penampilan band, tari kreasi, dan pesta kembang api.",
      coverUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=1200&q=80",
      totalFiles: 450,
      leadPhotographer: "Arya Pratama",
      category: "Konser & Panggung",
    ),
    EventItem(
      id: "evt-002",
      title: "Class Meeting & Turnamen Futsal",
      date: "25 Agu 2026",
      location: "Gedung Olahraga",
      description: "Jepretan momen gol dramatis, ekspresi suporter, dan penyerahan piala.",
      coverUrl: "https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&q=80",
      totalFiles: 320,
      leadPhotographer: "Nadia Salsabila",
      category: "Olahraga",
    ),
    EventItem(
      id: "evt-003",
      title: "Hunting Bareng: Street Photography Kota Tua",
      date: "14 Jul 2026",
      location: "Kawasan Kota Lama",
      description: "Praktik komposisi golden ratio, bayangan kontras, dan human interest.",
      coverUrl: "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=1200&q=80",
      totalFiles: 215,
      leadPhotographer: "Dimas Anggara",
      category: "Eksplorasi",
    ),
    EventItem(
      id: "evt-004",
      title: "Upacara Bendera 17 Agustus",
      date: "17 Agu 2026",
      location: "Lapangan Utama",
      description: "Dokumentasi khidmat prosesi pengibaran duplikat bendera pusaka.",
      coverUrl: "https://images.unsplash.com/photo-1533227268428-f9ed0900fb3b?auto=format&fit=crop&w=1200&q=80",
      totalFiles: 180,
      leadPhotographer: "Rizky Firmansyah",
      category: "Seremonial",
    ),
  ];

  static final List<MediaItem> _mockFiles = [
    MediaItem(
      id: "f-101",
      eventId: "evt-001",
      filename: "Pensi_Vocalist_Stage.jpg",
      originalName: "DSC04928.JPG",
      type: "photo",
      mimeType: "image/jpeg",
      sizeBytes: 14200000,
      url: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=1200&q=80",
      curationStatus: "final",
      photographer: "Arya Pratama",
      uploadDate: "2026-09-19",
      exif: ExifData(
        camera: "Sony Alpha 7 III",
        lens: "FE 70-200mm f/2.8 GM OSS",
        focalLength: "135mm",
        aperture: "f/2.8",
        shutterSpeed: "1/500s",
        iso: 3200,
        resolution: "6000 x 4000 (24 MP)",
        colorProfile: "sRGB",
      ),
    ),
    MediaItem(
      id: "f-102",
      eventId: "evt-001",
      filename: "Stage_Lighting_Crowd.jpg",
      originalName: "DSC04955.JPG",
      type: "photo",
      mimeType: "image/jpeg",
      sizeBytes: 16800000,
      url: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=1200&q=80",
      curationStatus: "curated",
      photographer: "Nadia Salsabila",
      uploadDate: "2026-09-19",
      exif: ExifData(
        camera: "Canon EOS R6",
        lens: "RF 24-70mm f/2.8 L IS USM",
        focalLength: "28mm",
        aperture: "f/3.2",
        shutterSpeed: "1/250s",
        iso: 6400,
        resolution: "5472 x 3648 (20 MP)",
        colorProfile: "sRGB",
      ),
    ),
    MediaItem(
      id: "f-103",
      eventId: "evt-001",
      filename: "Teaser_Highlight_Reel_Pensi.mp4",
      originalName: "CLIP_PENSI_01.MP4",
      type: "video",
      mimeType: "video/mp4",
      sizeBytes: 185000000,
      url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      thumbnailUrl: "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80",
      curationStatus: "final",
      photographer: "Dimas Anggara",
      uploadDate: "2026-09-20",
      videoMeta: VideoMetadata(
        durationSeconds: 145,
        fps: 60,
        resolution: "3840 x 2160 (4K UHD)",
        codec: "H.264 / AAC",
        bitrate: "45 Mbps",
      ),
    ),
    MediaItem(
      id: "f-104",
      eventId: "evt-002",
      filename: "Futsal_Goal_Celebration.jpg",
      originalName: "NIK_8920.JPG",
      type: "photo",
      mimeType: "image/jpeg",
      sizeBytes: 12400000,
      url: "https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&q=80",
      curationStatus: "final",
      photographer: "Rizky Firmansyah",
      uploadDate: "2026-08-25",
      exif: ExifData(
        camera: "Nikon Z6 II",
        lens: "NIKKOR Z 70-200mm f/2.8 VR S",
        focalLength: "85mm",
        aperture: "f/2.8",
        shutterSpeed: "1/1000s",
        iso: 1600,
        resolution: "6048 x 4024 (24.5 MP)",
        colorProfile: "sRGB",
      ),
    ),
    MediaItem(
      id: "f-105",
      eventId: "evt-003",
      filename: "Street_Shadow_Geometry.jpg",
      originalName: "FUJI_1102.RAF",
      type: "photo",
      mimeType: "image/jpeg",
      sizeBytes: 28900000,
      url: "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=1200&q=80",
      curationStatus: "edited",
      photographer: "Dimas Anggara",
      uploadDate: "2026-07-15",
      exif: ExifData(
        camera: "Fujifilm X-T4",
        lens: "XF 23mm f/1.4 R LM WR",
        focalLength: "23mm (35mm equiv)",
        aperture: "f/5.6",
        shutterSpeed: "1/800s",
        iso: 200,
        resolution: "6240 x 4160 (26 MP)",
        colorProfile: "Classic Chrome Sim",
      ),
    ),
    MediaItem(
      id: "f-106",
      eventId: "evt-001",
      filename: "Backstage_Preparation_RAW.jpg",
      originalName: "DSC04810.ARW",
      type: "photo",
      mimeType: "image/jpeg",
      sizeBytes: 31200000,
      url: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=1200&q=80",
      curationStatus: "raw",
      photographer: "Arya Pratama",
      uploadDate: "2026-09-18",
      exif: ExifData(
        camera: "Sony Alpha 7 III",
        lens: "FE 50mm f/1.8",
        focalLength: "50mm",
        aperture: "f/1.8",
        shutterSpeed: "1/160s",
        iso: 1250,
        resolution: "6000 x 4000 (RAW)",
        colorProfile: "RAW Uncompressed",
      ),
    ),
  ];

  // Fetch Storage Stats
  static Future<StorageStats> getStats() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/stats')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return StorageStats.fromJson(data['data']);
      }
    } catch (_) {}
    return _mockStats;
  }

  // Fetch Events List
  static Future<List<EventItem>> getEvents() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/events')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List).map((e) => EventItem.fromJson(e)).toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return _mockEvents;
  }

  // Fetch Files for Event
  static Future<List<MediaItem>> getEventFiles(String eventId, {String? status, String? type}) async {
    try {
      String query = '$baseUrl/events/$eventId/files?';
      if (status != null && status != 'all') query += 'status=$status&';
      if (type != null && type != 'all') query += 'type=$type&';

      final res = await http.get(Uri.parse(query)).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List).map((f) => MediaItem.fromJson(f)).toList();
        return list;
      }
    } catch (_) {}

    // Fallback filter
    var result = _mockFiles.where((f) => f.eventId == eventId).toList();
    if (status != null && status != 'all') {
      result = result.where((f) => f.curationStatus == status).toList();
    }
    if (type != null && type != 'all') {
      result = result.where((f) => f.type == type).toList();
    }
    return result;
  }

  // Update Curation Status
  static Future<bool> updateStatus(String fileId, String newStatus) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/files/$fileId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      ).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) return true;
    } catch (_) {}

    // Update in local fallback
    final item = _mockFiles.firstWhere((f) => f.id == fileId, orElse: () => _mockFiles[0]);
    item.curationStatus = newStatus;
    return true;
  }

  // Add Uploaded Media
  static Future<MediaItem> uploadMedia({
    required String eventId,
    required String photographer,
    required String curationStatus,
    required String camera,
    required String lens,
    required String aperture,
    required String shutterSpeed,
    required int iso,
    required String type,
    required String filename,
    required String url,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'eventId': eventId,
          'photographer': photographer,
          'curationStatus': curationStatus,
          'camera': camera,
          'lens': lens,
          'aperture': aperture,
          'shutterSpeed': shutterSpeed,
          'iso': iso,
          'type': type,
          'filename': filename,
          'url': url,
        }),
      ).timeout(const Duration(seconds: 3));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return MediaItem.fromJson(data['data']);
      }
    } catch (_) {}

    // Local fallback addition
    final newItem = MediaItem(
      id: "f-${DateTime.now().millisecondsSinceEpoch}",
      eventId: eventId,
      filename: filename,
      originalName: filename,
      type: type,
      mimeType: type == 'video' ? 'video/mp4' : 'image/jpeg',
      sizeBytes: type == 'video' ? 120000000 : 18500000,
      url: url,
      curationStatus: curationStatus,
      photographer: photographer,
      uploadDate: DateTime.now().toIso8601String().split('T')[0],
      exif: ExifData(
        camera: camera,
        lens: lens,
        focalLength: "50mm",
        aperture: aperture,
        shutterSpeed: shutterSpeed,
        iso: iso,
        resolution: "6000 x 4000",
        colorProfile: "sRGB",
      ),
    );
    _mockFiles.insert(0, newItem);
    return newItem;
  }
}
