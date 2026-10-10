import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'media_detail_screen.dart';
import 'upload_screen.dart';

class EventGalleryScreen extends StatefulWidget {
  final EventItem event;

  const EventGalleryScreen({super.key, required this.event});

  @override
  State<EventGalleryScreen> createState() => _EventGalleryScreenState();
}

class _EventGalleryScreenState extends State<EventGalleryScreen> {
  List<MediaItem> _files = [];
  bool _isLoading = true;
  String _selectedStatus = 'all'; // all, raw, curated, edited, final
  String _selectedType = 'all'; // all, photo, video

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    final files = await ApiService.getEventFiles(
      widget.event.id,
      status: _selectedStatus == 'all' ? null : _selectedStatus,
      type: _selectedType == 'all' ? null : _selectedType,
    );
    setState(() {
      _files = files;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220.0,
              pinned: true,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                title: Text(
                  widget.event.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.event.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1E293B)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 45,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.event.category,
                              style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '📍 ${widget.event.location} • 📅 ${widget.event.date}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            _buildFiltersBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                  : _files.isEmpty
                      ? _buildEmptyState()
                      : _buildGridGallery(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentGold,
        foregroundColor: Colors.black,
        tooltip: 'Upload ke Kegiatan Ini',
        child: const Icon(Icons.cloud_upload_rounded),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UploadScreen(events: [widget.event]),
            ),
          );
          if (res == true) _loadFiles();
        },
      ),
    );
  }

  Widget _buildFiltersBar() {
    final statuses = [
      {'id': 'all', 'label': 'Semua Kurasi'},
      {'id': 'raw', 'label': 'RAW / Burst'},
      {'id': 'curated', 'label': 'Lolos Seleksi'},
      {'id': 'edited', 'label': 'Color Graded'},
      {'id': 'final', 'label': 'Final / Resmi'},
    ];

    return Container(
      color: AppTheme.surfaceDark,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      child: Column(
        children: [
          // Filter Kurasi Pipeline
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, idx) {
                final s = statuses[idx];
                final isSelected = _selectedStatus == s['id'];
                return ChoiceChip(
                  label: Text(s['label']!),
                  selected: isSelected,
                  selectedColor: AppTheme.accentGold,
                  backgroundColor: AppTheme.bgDark,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : AppTheme.textLight,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.accentGold : AppTheme.cardBorder,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (_) {
                    setState(() => _selectedStatus = s['id']!);
                    _loadFiles();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          // Filter Format Media (Semua, Foto, Video)
          Row(
            children: [
              _buildTypeChip('all', 'Semua Media (${_files.length})', Icons.collections_rounded),
              const SizedBox(width: 6),
              _buildTypeChip('photo', 'Foto', Icons.photo_camera_rounded),
              const SizedBox(width: 6),
              _buildTypeChip('video', 'Video', Icons.videocam_rounded),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        setState(() => _selectedType = type);
        _loadFiles();
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppTheme.accentGold.withOpacity(0.5) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isSelected ? AppTheme.accentGold : AppTheme.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.textLight : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridGallery() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final item = _files[index];
        final isVideo = item.type == 'video';
        final statusColor = AppTheme.getStatusColor(item.curationStatus);

        return InkWell(
          onTap: () async {
            final changed = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MediaDetailScreen(item: item, eventTitle: widget.event.title),
              ),
            );
            if (changed == true) _loadFiles();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  isVideo ? (item.thumbnailUrl ?? item.url) : item.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF1E293B),
                    child: const Icon(Icons.broken_image, color: AppTheme.textMuted),
                  ),
                ),
                // Gradient Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 75,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                      ),
                    ),
                  ),
                ),
                // Top Status Badge (Curation Status GDrive Photography)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppTheme.getStatusLabel(item.curationStatus),
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                // Video Icon Indicator if video
                if (isVideo)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white54),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                // Top Right: File Size / EXIF indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.formattedSize,
                      style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Bottom Info (Photographer & Camera)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.filename,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '📷 ${item.photographer}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppTheme.accentGold, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (item.exif != null)
                            Text(
                              item.exif!.aperture,
                              style: const TextStyle(color: Colors.white60, fontSize: 10),
                            ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined, size: 54, color: AppTheme.textMuted.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text('Belum ada dokumentasi untuk filter ini', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text('Unggah Foto/Video Sekarang'),
            onPressed: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadScreen(events: [widget.event]),
                ),
              );
              if (res == true) _loadFiles();
            },
          )
        ],
      ),
    );
  }
}
