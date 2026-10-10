import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme.dart';

class MediaDetailScreen extends StatefulWidget {
  final MediaItem item;
  final String eventTitle;

  const MediaDetailScreen({super.key, required this.item, required this.eventTitle});

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  late String _curationStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _curationStatus = widget.item.curationStatus;
  }

  Future<void> _updateCuration(String newStatus) async {
    setState(() => _isUpdating = true);
    final success = await ApiService.updateStatus(widget.item.id, newStatus);
    if (success) {
      setState(() {
        _curationStatus = newStatus;
        widget.item.curationStatus = newStatus;
        _isUpdating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.getStatusColor(newStatus),
            content: Text('Status kurasi diperbarui ke: ${AppTheme.getStatusLabel(newStatus)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.item.type == 'video';
    final exif = widget.item.exif;
    final videoMeta = widget.item.videoMeta;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.filename, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(widget.eventTitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppTheme.accentGold),
            tooltip: 'EXIF Metadata Inspector',
            onPressed: () => _showExifSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Bagikan Link GDrive',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link Google Drive dokumentasi disalin ke clipboard!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Preview
          Expanded(
            child: Center(
              child: isVideo
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          widget.item.thumbnailUrl ?? widget.item.url,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80, color: Colors.white24),
                        ),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.accentGold, width: 2),
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: AppTheme.accentGold, size: 48),
                        ),
                      ],
                    )
                  : InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Image.network(
                        widget.item.url,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 80, color: Colors.white24),
                        ),
                      ),
                    ),
            ),
          ),

          // Bottom Control Panel (Curation Status Pipeline & Quick EXIF Bar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceDark,
              border: Border(top: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photographer & Camera Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: AppTheme.accentGold,
                          child: Icon(Icons.camera_alt, size: 13, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Text('Fotografer: ${widget.item.photographer}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentGold,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      icon: const Icon(Icons.tune_rounded, size: 14),
                      label: const Text('Detail EXIF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _showExifSheet(context),
                    )
                  ],
                ),
                const SizedBox(height: 10),

                // Fast EXIF stats chips
                if (exif != null)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildExifMiniBadge(Icons.camera, exif.camera),
                        const SizedBox(width: 6),
                        _buildExifMiniBadge(Icons.shutter_speed, exif.shutterSpeed),
                        const SizedBox(width: 6),
                        _buildExifMiniBadge(Icons.lens, exif.aperture),
                        const SizedBox(width: 6),
                        _buildExifMiniBadge(Icons.iso, 'ISO ${exif.iso}'),
                        const SizedBox(width: 6),
                        _buildExifMiniBadge(Icons.photo_size_select_actual_outlined, exif.resolution),
                      ],
                    ),
                  ),

                if (videoMeta != null)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildExifMiniBadge(Icons.videocam, videoMeta.resolution),
                        const SizedBox(width: 6),
                        _buildExifMiniBadge(Icons.speed, '${videoMeta.fps} FPS'),
                        const SizedBox(width: 6),
                        _buildExifMiniBadge(Icons.timer_outlined, '${videoMeta.durationSeconds} Detik'),
                        const SizedBox(width: 6),
                        _buildExifMiniBadge(Icons.high_quality, videoMeta.bitrate),
                      ],
                    ),
                  ),

                const SizedBox(height: 14),
                const Divider(color: AppTheme.cardBorder, height: 1),
                const SizedBox(height: 10),

                // Curation Stage Switcher
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tahap Kurasi Ekskul:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    if (_isUpdating)
                      const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentGold)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildStatusOption('raw', 'RAW'),
                    const SizedBox(width: 6),
                    _buildStatusOption('curated', 'Seleksi'),
                    const SizedBox(width: 6),
                    _buildStatusOption('edited', 'Edited'),
                    const SizedBox(width: 6),
                    _buildStatusOption('final', 'Resmi'),
                  ],
                ),
                const SizedBox(height: 12),

                // Download Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textLight,
                          side: const BorderSide(color: AppTheme.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.share_outlined, size: 16),
                        label: const Text('Medsos Ready', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mengunduh versi kompresi untuk Instagram / Story sekolah...')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text('Original High-Res', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Mengunduh file original (${widget.item.formattedSize})...')),
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusOption(String statusKey, String label) {
    final isSelected = _curationStatus == statusKey;
    final color = AppTheme.getStatusColor(statusKey);

    return Expanded(
      child: InkWell(
        onTap: () => _updateCuration(statusKey),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? color : AppTheme.cardBorder, width: isSelected ? 1.5 : 1),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                color: isSelected ? color : AppTheme.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExifMiniBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.accentGold),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showExifSheet(BuildContext context) {
    final exif = widget.item.exif;
    final videoMeta = widget.item.videoMeta;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🔍 EXIF & Technical Metadata', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.accentGold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 20),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(color: AppTheme.cardBorder),
              const SizedBox(height: 8),

              if (exif != null) ...[
                _buildExifRow('Body Kamera', exif.camera, Icons.photo_camera),
                _buildExifRow('Lensa Terpasang', exif.lens, Icons.camera),
                _buildExifRow('Focal Length', exif.focalLength, Icons.straighten),
                _buildExifRow('Bukaan (Aperture)', exif.aperture, Icons.lens_blur),
                _buildExifRow('Kecepatan Shutter', exif.shutterSpeed, Icons.shutter_speed),
                _buildExifRow('Sensitivitas ISO', '${exif.iso}', Icons.iso),
                _buildExifRow('Dimensi & Megapixel', exif.resolution, Icons.aspect_ratio),
                _buildExifRow('Color Profile', exif.colorProfile, Icons.palette_outlined),
              ],

              if (videoMeta != null) ...[
                _buildExifRow('Resolusi Video', videoMeta.resolution, Icons.videocam),
                _buildExifRow('Frame Rate', '${videoMeta.fps} FPS', Icons.speed),
                _buildExifRow('Durasi Klip', '${videoMeta.durationSeconds} Detik', Icons.timer),
                _buildExifRow('Video Bitrate', videoMeta.bitrate, Icons.analytics_outlined),
                _buildExifRow('Format Codec', videoMeta.codec, Icons.code),
              ],

              _buildExifRow('Ukuran File Fisik', widget.item.formattedSize, Icons.storage),
              _buildExifRow('File Original Kamera', widget.item.originalName, Icons.file_present),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExifRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
        ],
      ),
    );
  }
}
