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
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Icon(Icons.camera_alt_outlined, color: AppTheme.accentGold, size: 18),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ShutterCloud', style: TextStyle(letterSpacing: 0.5, fontWeight: FontWeight.w700, fontSize: 15)),
                Text('Vault Dokumentasi Fotografi', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, size: 20),
            tooltip: 'Sinkronisasi',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart_outline_rounded, size: 20),
            tooltip: 'Kapasitas Storage',
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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                children: [
                  _buildQuotaCard(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Agenda & Arsip Kegiatan',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textLight),
                      ),
                      Text(
                        '${_events.length} Agenda',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_events.isEmpty)
                    _buildEmptyEvents()
                  else
                    ..._events.map((event) => _buildEventCard(event)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.accentGold,
        foregroundColor: const Color(0xFF0E1015),
        icon: const Icon(Icons.file_upload_outlined, size: 20),
        label: const Text('UNGGAH MEDIA', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.5)),
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
    final usedGB = _stats!.usedGB.toStringAsFixed(2);
    final totalGB = _stats!.totalGB.toStringAsFixed(0);
    final percent = (_stats!.usagePercentage * 100).toStringAsFixed(1);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StorageAnalyticsScreen(stats: _stats!)),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.cloud_outlined, color: AppTheme.accentGold, size: 18),
                    SizedBox(width: 8),
                    Text('Kapasitas Cloud GDrive', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textLight)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGoldSoft,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.accentGold.withOpacity(0.25)),
                  ),
                  child: Text('$percent% Terpakai', style: const TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.w600)),
                )
              ],
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: '$usedGB GB ', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                  TextSpan(text: 'dari $totalGB GB', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: _stats!.usagePercentage,
                minHeight: 5,
                backgroundColor: const Color(0xFF222634),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat(Icons.image_outlined, '${_stats!.photoCount}', 'Foto'),
                _buildMiniStat(Icons.videocam_outlined, '${_stats!.videoCount}', 'Video'),
                _buildMiniStat(Icons.people_outline, '${_stats!.activePhotographers}', 'Fotografer'),
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
        Icon(icon, size: 15, color: AppTheme.textMuted),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textLight)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textDim)),
          ],
        )
      ],
    );
  }

  Widget _buildEmptyEvents() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.folder_open_outlined, size: 40, color: AppTheme.textDim),
            SizedBox(height: 12),
            Text('Belum Ada Agenda Kegiatan', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textLight)),
            SizedBox(height: 4),
            Text('Buat agenda pertama untuk mulai mengelompokkan foto dokumentasi.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(EventItem event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorder),
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
            AspectRatio(
              aspectRatio: 16 / 8,
              child: Image.network(
                event.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF141720),
                  child: const Center(child: Icon(Icons.broken_image_outlined, color: AppTheme.textDim)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 5),
                      Text(event.date, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PIC: ${event.leadPhotographer}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      Row(
                        children: [
                          Text('Buka (${event.totalFiles})', style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w600, fontSize: 11)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppTheme.accentGold),
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
