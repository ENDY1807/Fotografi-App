import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'event_gallery_screen.dart';
import 'upload_screen.dart';
import 'storage_analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StorageStats? _stats;
  List<EventItem> _events = [];
  bool _isLoading = true;
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Konser & Panggung',
    'Olahraga',
    'Eksplorasi',
    'Seremonial'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final statsFuture = ApiService.getStats();
    final eventsFuture = ApiService.getEvents();

    final results = await Future.wait([statsFuture, eventsFuture]);
    setState(() {
      _stats = results[0] as StorageStats;
      _events = results[1] as List<EventItem>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _selectedCategory == 'Semua'
        ? _events
        : _events.where((e) => e.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: AppTheme.accentGold, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SHUTTER DRIVE', style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w900, fontSize: 16)),
                Text('Ekskul Fotografi Cloud Server', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined, color: AppTheme.accentGold),
            tooltip: 'Sinkronisasi Server',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart_outline_rounded),
            tooltip: 'Kapasitas Storage GDrive',
            onPressed: () {
              if (_stats != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StorageAnalyticsScreen(stats: _stats!)),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
          : RefreshIndicator(
              color: AppTheme.accentGold,
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildQuotaCard(),
                  const SizedBox(height: 22),
                  _buildCategoryFilter(),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Agenda & Dokumentasi Kegiatan',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textLight),
                      ),
                      Text(
                        '${filteredEvents.length} Event',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...filteredEvents.map((event) => _buildEventCard(event)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.accentGold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_photo_alternate_rounded, weight: 700),
        label: const Text('UPLOAD DOKUMENTASI', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UploadScreen(events: _events),
            ),
          );
          if (res == true) _loadData();
        },
      ),
    );
  }

  Widget _buildQuotaCard() {
    if (_stats == null) return const SizedBox.shrink();
    final usedGB = _stats!.usedGB.toStringAsFixed(1);
    final totalGB = _stats!.totalGB.toStringAsFixed(0);
    final percent = (_stats!.usagePercentage * 100).toStringAsFixed(1);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StorageAnalyticsScreen(stats: _stats!)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
          gradient: const LinearGradient(
            colors: [Color(0xFF162035), Color(0xFF101726)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_queue_rounded, color: AppTheme.accentGold, size: 22),
                    const SizedBox(width: 8),
                    const Text('Cloud Storage GDrive Ekskul', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                  ),
                  child: Text('$percent% Terpakai', style: const TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.w700)),
                )
              ],
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: '$usedGB GB ', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textLight)),
                  TextSpan(text: 'dari $totalGB GB', style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _stats!.usagePercentage,
                minHeight: 7,
                backgroundColor: const Color(0xFF1E293B),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat(Icons.image_outlined, '${_stats!.photoCount}', 'Foto (RAW/JPG)'),
                _buildMiniStat(Icons.videocam_outlined, '${_stats!.videoCount}', 'Video Teaser'),
                _buildMiniStat(Icons.people_alt_outlined, '${_stats!.activePhotographers}', 'Fotografer'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String count, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textLight)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ],
        )
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            selectedColor: AppTheme.accentGold,
            backgroundColor: AppTheme.surfaceDark,
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : AppTheme.textLight,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              fontSize: 12,
            ),
            side: BorderSide(
              color: isSelected ? AppTheme.accentGold : AppTheme.cardBorder,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onSelected: (_) => setState(() => _selectedCategory = cat),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(EventItem event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventGalleryScreen(event: event),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    event.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1E293B),
                      child: const Center(child: Icon(Icons.broken_image, color: AppTheme.textMuted)),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.folder_open_rounded, size: 14, color: AppTheme.accentGold),
                        const SizedBox(width: 5),
                        Text(
                          '${event.totalFiles} Dokumentasi',
                          style: const TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 5),
                      Text(event.date, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      const SizedBox(width: 14),
                      const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1), height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppTheme.cardBorder, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 11,
                            backgroundColor: AppTheme.accentGold,
                            child: Icon(Icons.camera_alt, size: 12, color: Colors.black),
                          ),
                          const SizedBox(width: 7),
                          Text('PIC: ${event.leadPhotographer}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
                        ],
                      ),
                      const Row(
                        children: [
                          Text('Buka Galeri', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w700, fontSize: 12)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppTheme.accentGold),
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
