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
  String _selectedStatus = 'all';
  String _selectedType = 'all';

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
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(widget.event.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined, size: 20),
            tooltip: 'Unggah Media',
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
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                : _files.isEmpty
                    ? _buildEmptyState()
                    : _buildGridGallery(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final statuses = [
      {'id': 'all', 'label': 'Semua'},
      {'id': 'raw', 'label': 'RAW'},
      {'id': 'curated', 'label': 'Seleksi'},
      {'id': 'edited', 'label': 'Edited'},
      {'id': 'final', 'label': 'Resmi'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: statuses.map((s) {
                  final isSelected = _selectedStatus == s['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(s['label']!),
                      selected: isSelected,
                      selectedColor: AppTheme.accentGoldSoft,
                      backgroundColor: AppTheme.cardDark,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.accentGold : AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.accentGold : AppTheme.cardBorder,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onSelected: (_) {
                        setState(() => _selectedStatus = s['id']!);
                        _loadFiles();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded, size: 18, color: AppTheme.textMuted),
            color: AppTheme.cardDark,
            onSelected: (val) {
              setState(() => _selectedType = val);
              _loadFiles();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'all', child: Text('Semua Media', style: TextStyle(fontSize: 12))),
              const PopupMenuItem(value: 'photo', child: Text('Hanya Foto', style: TextStyle(fontSize: 12))),
              const PopupMenuItem(value: 'video', child: Text('Hanya Video', style: TextStyle(fontSize: 12))),
            ],
          ),
        ],
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
        childAspectRatio: 0.82,
      ),
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final item = _files[index];
        final isVideo = item.type == 'video';

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
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(8),
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
                    color: const Color(0xFF141720),
                    child: const Icon(Icons.broken_image_outlined, color: AppTheme.textDim),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.getStatusColor(item.curationStatus),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      AppTheme.getStatusLabel(item.curationStatus),
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (isVideo)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: AppTheme.accentGold, size: 22),
                    ),
                  ),
                Positioned(
                  bottom: 6,
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
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.photographer,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                            ),
                          ),
                          Text(
                            item.formattedSize,
                            style: const TextStyle(color: Colors.white54, fontSize: 9),
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

  // Pure Google Drive Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open_outlined, size: 48, color: AppTheme.textDim),
            const SizedBox(height: 14),
            const Text(
              'Penyimpanan Dokumentasi Kosong',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textLight),
            ),
            const SizedBox(height: 6),
            const Text(
              'Belum ada file foto atau video yang diunggah untuk agenda ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_upward_rounded, size: 16),
              label: const Text('Unggah File Pertama'),
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
      ),
    );
  }
}
