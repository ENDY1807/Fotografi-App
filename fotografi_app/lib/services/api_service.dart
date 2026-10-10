import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // Base URL server lokal ShutterCloud
  static const String baseUrl = 'http://localhost:5050/api';

  // Fallback Data dimulai dengan keadaan kosong (seperti Google Drive)
  static final StorageStats _emptyStats = StorageStats(
    totalStorageLimitBytes: 100 * 1024 * 1024 * 1024,
    usedStorageBytes: 0,
    photoCount: 0,
    videoCount: 0,
    activePhotographers: 0,
  );

  static final List<EventItem> _mockEvents = [
    EventItem(
      id: "evt-001",
      title: "Dokumentasi Utama",
      date: "2026-10-10",
      location: "Sekolah & Lapangan",
      description: "Folder arsip dokumentasi kegiatan ekskul fotografi.",
      coverUrl: "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80",
      totalFiles: 0,
      leadPhotographer: "Ekskul Fotografi",
      category: "Dokumentasi",
    ),
  ];

  static final List<MediaItem> _mockFiles = [];

  // Fetch Storage Stats
  static Future<StorageStats> getStats() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/stats')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return StorageStats.fromJson(data['data']);
      }
    } catch (_) {}
    return _emptyStats;
  }

  // Fetch Events List
  static Future<List<EventItem>> getEvents() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/events')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List).map((e) => EventItem.fromJson(e)).toList();
        return list;
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

    final index = _mockFiles.indexWhere((f) => f.id == fileId);
    if (index != -1) _mockFiles[index].curationStatus = newStatus;
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
