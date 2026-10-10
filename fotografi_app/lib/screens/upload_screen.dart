import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme.dart';

class UploadScreen extends StatefulWidget {
  final List<EventItem> events;

  const UploadScreen({super.key, required this.events});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late String _selectedEventId;
  String _selectedType = 'photo'; // photo or video
  String _curationStatus = 'raw';
  
  final _photographerController = TextEditingController(text: 'Arya Pratama');
  final _cameraController = TextEditingController(text: 'Sony Alpha 7 IV');
  final _lensController = TextEditingController(text: 'FE 24-70mm f/2.8 GM');
  final _apertureController = TextEditingController(text: 'f/2.8');
  final _shutterController = TextEditingController(text: '1/500s');
  final _isoController = TextEditingController(text: '800');
  final _filenameController = TextEditingController(text: 'DSC09214_Dokumentasi.JPG');
  final _imageUrlController = TextEditingController(text: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80');

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatusMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedEventId = widget.events.isNotEmpty ? widget.events[0].id : 'evt-001';
  }

  void _applyCameraPreset(String brand) {
    setState(() {
      if (brand == 'Sony') {
        _cameraController.text = 'Sony Alpha 7 IV';
        _lensController.text = 'FE 24-70mm f/2.8 GM';
        _apertureController.text = 'f/2.8';
        _shutterController.text = '1/500s';
        _isoController.text = '800';
      } else if (brand == 'Canon') {
        _cameraController.text = 'Canon EOS R6 Mark II';
        _lensController.text = 'RF 50mm f/1.2 L USM';
        _apertureController.text = 'f/1.8';
        _shutterController.text = '1/1000s';
        _isoController.text = '400';
      } else if (brand == 'Fujifilm') {
        _cameraController.text = 'Fujifilm X-T5';
        _lensController.text = 'XF 33mm f/1.4 R LM WR';
        _apertureController.text = 'f/2.0';
        _shutterController.text = '1/640s';
        _isoController.text = '250';
      } else if (brand == 'Nikon') {
        _cameraController.text = 'Nikon Z8';
        _lensController.text = 'NIKKOR Z 70-200mm f/2.8 VR S';
        _apertureController.text = 'f/2.8';
        _shutterController.text = '1/800s';
        _isoController.text = '1200';
      }
    });
  }

  Future<void> _startUpload() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatusMessage = 'Menginisialisasi Resumable Session GDrive...';
    });

    // Simulate Google Drive-style chunking progress
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _uploadProgress = 0.25;
      _uploadStatusMessage = 'Mengirim Chunk 1/4 (Header & EXIF Binary)...';
    });
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _uploadProgress = 0.50;
      _uploadStatusMessage = 'Mengirim Chunk 2/4 (High-Res Blob Data)...';
    });
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _uploadProgress = 0.75;
      _uploadStatusMessage = 'Mengirim Chunk 3/4 & 4/4 (Finishing Payload)...';
    });
    await Future.delayed(const Duration(milliseconds: 350));
    setState(() {
      _uploadProgress = 0.90;
      _uploadStatusMessage = 'Server memproses thumbnail & metadata database...';
    });

    try {
      await ApiService.uploadMedia(
        eventId: _selectedEventId,
        photographer: _photographerController.text.trim(),
        curationStatus: _curationStatus,
        camera: _cameraController.text.trim(),
        lens: _lensController.text.trim(),
        aperture: _apertureController.text.trim(),
        shutterSpeed: _shutterController.text.trim(),
        iso: int.tryParse(_isoController.text.trim()) ?? 400,
        type: _selectedType,
        filename: _filenameController.text.trim(),
        url: _imageUrlController.text.trim(),
      );

      setState(() {
        _uploadProgress = 1.0;
        _uploadStatusMessage = 'Selesai! Dokumentasi berhasil tersimpan di Cloud.';
      });

      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadStatusMessage = 'Gagal upload: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Dokumentasi Ekskul'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event Selection
          _buildSectionHeader('1. Pilih Agenda / Event Kegiatan'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedEventId,
                isExpanded: true,
                dropdownColor: AppTheme.surfaceDark,
                items: widget.events.map((e) {
                  return DropdownMenuItem(
                    value: e.id,
                    child: Text('${e.title} (${e.category})', style: const TextStyle(fontSize: 13, color: AppTheme.textLight)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedEventId = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Format Media (Foto atau Video)
          _buildSectionHeader('2. Format Media Dokumentasi'),
          Row(
            children: [
              Expanded(
                child: _buildTypeSelect(
                  'photo',
                  'Foto High-Res / RAW',
                  Icons.camera_alt_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTypeSelect(
                  'video',
                  'Video Teaser / Reel',
                  Icons.videocam_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Curation Stage
          _buildSectionHeader('3. Status Tahap Kurasi Awal'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCurationChip('raw', 'RAW / Burst'),
              _buildCurationChip('curated', 'Lolos Seleksi'),
              _buildCurationChip('edited', 'Color Graded'),
              _buildCurationChip('final', 'Dokumentasi Resmi'),
            ],
          ),
          const SizedBox(height: 18),

          // Photographer Attribution
          _buildSectionHeader('4. Atribusi Fotografer Anggota'),
          TextField(
            controller: _photographerController,
            decoration: _inputDecoration('Nama Fotografer (Siswa/Anggota)', Icons.person_outline),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _filenameController,
            decoration: _inputDecoration('Nama File Asli Kamera', Icons.file_present_outlined),
          ),
          const SizedBox(height: 18),

          // Camera Presets
          _buildSectionHeader('5. Preset Kamera & Pengaturan EXIF'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetBtn('Sony Alpha', () => _applyCameraPreset('Sony')),
                const SizedBox(width: 8),
                _buildPresetBtn('Canon EOS', () => _applyCameraPreset('Canon')),
                const SizedBox(width: 8),
                _buildPresetBtn('Fujifilm X', () => _applyCameraPreset('Fujifilm')),
                const SizedBox(width: 8),
                _buildPresetBtn('Nikon Z', () => _applyCameraPreset('Nikon')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _cameraController,
                  decoration: _inputDecoration('Body Kamera', Icons.camera),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _lensController,
                  decoration: _inputDecoration('Lensa', Icons.circle_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _apertureController,
                  decoration: _inputDecoration('Aperture (f/)', null),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _shutterController,
                  decoration: _inputDecoration('Shutter', null),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _isoController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('ISO', null),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Upload Progress Indicator
          if (_isUploading) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_uploadStatusMessage, style: const TextStyle(fontSize: 12, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                      Text('${(_uploadProgress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.accentGold,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text(
              'UNGGAH KE CLOUD G-DRIVE EKSKUL',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
            onPressed: _isUploading ? null : _startUpload,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.accentGold, letterSpacing: 0.3),
      ),
    );
  }

  Widget _buildTypeSelect(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGold.withOpacity(0.15) : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppTheme.accentGold : AppTheme.cardBorder, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppTheme.accentGold : AppTheme.textMuted, size: 24),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isSelected ? AppTheme.textLight : AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurationChip(String key, String label) {
    final isSelected = _curationStatus == key;
    final color = AppTheme.getStatusColor(key);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.3),
      backgroundColor: AppTheme.surfaceDark,
      side: BorderSide(color: isSelected ? color : AppTheme.cardBorder),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textMuted,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
        fontSize: 11,
      ),
      onSelected: (_) => setState(() => _curationStatus = key),
    );
  }

  Widget _buildPresetBtn(String name, VoidCallback onTap) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textLight,
        side: const BorderSide(color: AppTheme.cardBorder),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onTap,
      child: Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
      prefixIcon: icon != null ? Icon(icon, size: 16, color: AppTheme.textMuted) : null,
      filled: true,
      fillColor: AppTheme.surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.accentGold),
      ),
    );
  }
}
