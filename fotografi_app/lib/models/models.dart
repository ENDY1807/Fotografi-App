class StorageStats {
  final int totalStorageLimitBytes;
  final double usedStorageBytes;
  final int photoCount;
  final int videoCount;
  final int activePhotographers;

  StorageStats({
    required this.totalStorageLimitBytes,
    required this.usedStorageBytes,
    required this.photoCount,
    required this.videoCount,
    required this.activePhotographers,
  });

  factory StorageStats.fromJson(Map<String, dynamic> json) {
    return StorageStats(
      totalStorageLimitBytes: json['totalStorageLimitBytes'] ?? (100 * 1024 * 1024 * 1024),
      usedStorageBytes: (json['usedStorageBytes'] is num) ? (json['usedStorageBytes'] as num).toDouble() : 0.0,
      photoCount: json['photoCount'] ?? 0,
      videoCount: json['videoCount'] ?? 0,
      activePhotographers: json['activePhotographers'] ?? 0,
    );
  }

  double get usedGB => usedStorageBytes / (1024 * 1024 * 1024);
  double get totalGB => totalStorageLimitBytes / (1024 * 1024 * 1024);
  double get usagePercentage => (totalStorageLimitBytes > 0) ? (usedStorageBytes / totalStorageLimitBytes) : 0.0;
}

class EventItem {
  final String id;
  final String title;
  final String date;
  final String location;
  final String description;
  final String coverUrl;
  final int totalFiles;
  final String leadPhotographer;
  final String category;

  EventItem({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.coverUrl,
    required this.totalFiles,
    required this.leadPhotographer,
    required this.category,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      coverUrl: json['coverUrl'] ?? 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80',
      totalFiles: json['totalFiles'] ?? 0,
      leadPhotographer: json['leadPhotographer'] ?? 'Ekskul Fotografi',
      category: json['category'] ?? 'Umum',
    );
  }
}

class ExifData {
  final String camera;
  final String lens;
  final String focalLength;
  final String aperture;
  final String shutterSpeed;
  final int iso;
  final String resolution;
  final String colorProfile;

  ExifData({
    required this.camera,
    required this.lens,
    required this.focalLength,
    required this.aperture,
    required this.shutterSpeed,
    required this.iso,
    required this.resolution,
    required this.colorProfile,
  });

  factory ExifData.fromJson(Map<String, dynamic> json) {
    return ExifData(
      camera: json['camera'] ?? 'Unknown Camera',
      lens: json['lens'] ?? 'Standard Prime',
      focalLength: json['focalLength'] ?? '50mm',
      aperture: json['aperture'] ?? 'f/2.8',
      shutterSpeed: json['shutterSpeed'] ?? '1/250s',
      iso: json['iso'] ?? 400,
      resolution: json['resolution'] ?? '6000 x 4000',
      colorProfile: json['colorProfile'] ?? 'sRGB',
    );
  }
}

class VideoMetadata {
  final int durationSeconds;
  final int fps;
  final String resolution;
  final String codec;
  final String bitrate;

  VideoMetadata({
    required this.durationSeconds,
    required this.fps,
    required this.resolution,
    required this.codec,
    required this.bitrate,
  });

  factory VideoMetadata.fromJson(Map<String, dynamic> json) {
    return VideoMetadata(
      durationSeconds: json['durationSeconds'] ?? 60,
      fps: json['fps'] ?? 60,
      resolution: json['resolution'] ?? '1080p Full HD',
      codec: json['codec'] ?? 'H.264',
      bitrate: json['bitrate'] ?? '25 Mbps',
    );
  }
}

class MediaItem {
  final String id;
  final String eventId;
  final String filename;
  final String originalName;
  final String type; // photo or video
  final String mimeType;
  final int sizeBytes;
  final String url;
  final String? thumbnailUrl;
  String curationStatus; // raw, curated, edited, final
  final String photographer;
  final String uploadDate;
  final ExifData? exif;
  final VideoMetadata? videoMeta;

  MediaItem({
    required this.id,
    required this.eventId,
    required this.filename,
    required this.originalName,
    required this.type,
    required this.mimeType,
    required this.sizeBytes,
    required this.url,
    this.thumbnailUrl,
    required this.curationStatus,
    required this.photographer,
    required this.uploadDate,
    this.exif,
    this.videoMeta,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? '',
      eventId: json['eventId'] ?? '',
      filename: json['filename'] ?? '',
      originalName: json['originalName'] ?? '',
      type: json['type'] ?? 'photo',
      mimeType: json['mimeType'] ?? 'image/jpeg',
      sizeBytes: json['sizeBytes'] ?? 10000000,
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      curationStatus: json['curationStatus'] ?? 'raw',
      photographer: json['photographer'] ?? 'Anggota',
      uploadDate: json['uploadDate'] ?? DateTime.now().toIso8601String(),
      exif: json['exif'] != null ? ExifData.fromJson(json['exif']) : null,
      videoMeta: json['videoMeta'] != null ? VideoMetadata.fromJson(json['videoMeta']) : null,
    );
  }

  String get formattedSize {
    if (sizeBytes >= 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } else if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    }
  }
}
