import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

class StorageAnalyticsScreen extends StatelessWidget {
  final StorageStats stats;

  const StorageAnalyticsScreen({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final usedGB = stats.usedGB.toStringAsFixed(1);
    final totalGB = stats.totalGB.toStringAsFixed(0);
    final freeGB = (stats.totalGB - stats.usedGB).toStringAsFixed(1);
    final percent = (stats.usagePercentage * 100).toStringAsFixed(1);

    // Distribution estimates
    final videoEstGB = (stats.usedGB * 0.65).toStringAsFixed(1);
    final photoEstGB = (stats.usedGB * 0.32).toStringAsFixed(1);
    final metaEstMB = "450 MB";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kapasitas Cloud & Analisis GDrive'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Storage Overview Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
              gradient: const LinearGradient(
                colors: [Color(0xFF162035), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Kapasitas Cloud Ekskul', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$percent% Terpakai', style: const TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text('$usedGB GB / $totalGB GB', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textLight)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: stats.usagePercentage,
                    minHeight: 10,
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sisa Ruang: $freeGB GB Tersedia', style: const TextStyle(fontSize: 12, color: AppTheme.statusFinal, fontWeight: FontWeight.w600)),
                    Text('${stats.photoCount + stats.videoCount} Total File', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Breakdown by Media Type
          const Text('Distribusi Penggunaan File', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          _buildBreakdownItem(
            'Video Kegiatan (4K / 1080p)',
            '$videoEstGB GB',
            '${stats.videoCount} Video Clips & Reels',
            Icons.videocam_rounded,
            const Color(0xFFE11D48),
            0.65,
          ),
          const SizedBox(height: 8),
          _buildBreakdownItem(
            'Foto Dokumentasi (RAW & JPEG)',
            '$photoEstGB GB',
            '${stats.photoCount} Jepretan Acara',
            Icons.camera_alt_rounded,
            AppTheme.accentGold,
            0.32,
          ),
          const SizedBox(height: 8),
          _buildBreakdownItem(
            'EXIF & Thumbnail Cache',
            metaEstMB,
            'WebP Multi-resolution thumbnails',
            Icons.storage_rounded,
            const Color(0xFF0284C7),
            0.03,
          ),
          const SizedBox(height: 22),

          // Google Drive Architecture Comparison for Photography
          const Text('Bagaimana Sistem GDrive Bekerja Disini?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _buildInfoTile(
            'Resumable Chunk Upload',
            'File video dan foto RAW (100MB - 2GB) dipecah menjadi potongan chunk 8MB. Jika WiFi sekolah drop, upload langsung melanjutkan dari chunk terakhir tanpa mengulang dari 0%.',
            Icons.cloud_upload_outlined,
          ),
          const SizedBox(height: 8),
          _buildInfoTile(
            'Virtual Folder vs Blob Storage',
            'File disimpan di Blob Store dengan hash unik untuk mencegah duplikasi. Hubungan antar "Event / Agenda" diatur lewat tabel metadata virtual.',
            Icons.account_tree_outlined,
          ),
          const SizedBox(height: 8),
          _buildInfoTile(
            'Pipeline Transcoding Asinkron',
            'Thumbnail WebP dibuat otomatis dalam berbagai resolusi agar saat scrolling galeri tidak boros RAM dan hemat kuota.',
            Icons.auto_awesome_motion_outlined,
          ),
          const SizedBox(height: 26),

          // Top Photographers Leaderboard
          const Text('Kontributor Fotografer Teraktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _buildPhotographerItem('Arya Pratama', 'Ketua Ekskul', '420 Foto • 14 Video', '12.4 GB', 1),
          _buildPhotographerItem('Nadia Salsabila', 'Divisi Dokumentasi', '380 Foto • 28 Video', '8.6 GB', 2),
          _buildPhotographerItem('Dimas Anggara', 'Street & Hunting', '240 Foto • 9 Video', '5.1 GB', 3),
          _buildPhotographerItem('Rizky Firmansyah', 'Divisi Olahraga', '180 Foto • 5 Video', '3.2 GB', 4),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String title, String size, String desc, IconData icon, Color color, double ratio) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textLight)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Text(size, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101726),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.accentGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.accentGold)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPhotographerItem(String name, String role, String uploads, String size, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: rank == 1 ? AppTheme.accentGold : const Color(0xFF334155),
            child: Text('$rank', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: rank == 1 ? Colors.black : Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textLight)),
                Text('$role • $uploads', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Text(size, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textLight)),
        ],
      ),
    );
  }
}
