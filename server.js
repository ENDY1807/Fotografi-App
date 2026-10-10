const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 5050;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Storage Directories
const BASE_UPLOADS = path.join(__dirname, 'uploads');
const DATA_DIR = path.join(__dirname, 'data');
const METADATA_FILE = path.join(DATA_DIR, 'metadata.json');
const PUBLIC_DIR = path.join(__dirname, 'public');
const FLUTTER_WEB_DIR = path.join(__dirname, 'fotografi_app', 'build', 'web');

// Ensure directories exist
if (!fs.existsSync(BASE_UPLOADS)) fs.mkdirSync(BASE_UPLOADS, { recursive: true });
if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });
if (!fs.existsSync(PUBLIC_DIR)) fs.mkdirSync(PUBLIC_DIR, { recursive: true });

// Initial Default Data if metadata.json does not exist
const initialData = {
  stats: {
    totalStorageLimitBytes: 100 * 1024 * 1024 * 1024, // 100 GB
    usedStorageBytes: 24.8 * 1024 * 1024 * 1024,
    photoCount: 1420,
    videoCount: 86,
    activePhotographers: 12
  },
  events: [
    {
      id: "evt-001",
      title: "Pentas Seni & HUT Sekolah 2026",
      date: "2026-09-18",
      location: "Auditorium Utama & Lapangan",
      description: "Dokumentasi penampilan band, teater, tari kreasi tradisional, dan puncak kembang api.",
      coverUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=1200&q=80",
      totalFiles: 450,
      leadPhotographer: "Arya Pratama",
      category: "Konser & Panggung"
    },
    {
      id: "evt-002",
      title: "Class Meeting & Turnamen Futsal",
      date: "2026-08-25",
      location: "Gedung Olahraga",
      description: "Jepretan aksi cepat, selebrasi juara, dan suporter tiap angkatan.",
      coverUrl: "https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&q=80",
      totalFiles: 320,
      leadPhotographer: "Nadia Salsabila",
      category: "Olahraga"
    },
    {
      id: "evt-003",
      title: "Hunting Bareng: Street Photography Kota Tua",
      date: "2026-07-14",
      location: "Kawasan Kota Lama",
      description: "Praktik teknik komposisi leading lines, chiaroscuro, dan candid human interest.",
      coverUrl: "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=1200&q=80",
      totalFiles: 215,
      leadPhotographer: "Dimas Anggara",
      category: "Eksplorasi"
    },
    {
      id: "evt-004",
      title: "Upacara Peringatan 17 Agustus",
      date: "2026-08-17",
      location: "Plaza Upacara",
      description: "Dokumentasi formasi paskibra, pengibaran bendera pusaka, dan paduan suara.",
      coverUrl: "https://images.unsplash.com/photo-1533227268428-f9ed0900fb3b?auto=format&fit=crop&w=1200&q=80",
      totalFiles: 180,
      leadPhotographer: "Rizky Firmansyah",
      category: "Seremonial"
    }
  ],
  files: [
    {
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
      uploadDate: "2026-09-19T10:14:00Z",
      exif: {
        camera: "Sony Alpha 7 III",
        lens: "FE 70-200mm f/2.8 GM OSS",
        focalLength: "135mm",
        aperture: "f/2.8",
        shutterSpeed: "1/500s",
        iso: 3200,
        resolution: "6000 x 4000 (24 MP)",
        colorProfile: "sRGB"
      }
    },
    {
      id: "f-102",
      eventId: "evt-001",
      filename: "Lighting_Crowd_Atmosphere.jpg",
      originalName: "DSC04955.JPG",
      type: "photo",
      mimeType: "image/jpeg",
      sizeBytes: 16800000,
      url: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=1200&q=80",
      curationStatus: "curated",
      photographer: "Nadia Salsabila",
      uploadDate: "2026-09-19T11:20:00Z",
      exif: {
        camera: "Canon EOS R6",
        lens: "RF 24-70mm f/2.8 L IS USM",
        focalLength: "28mm",
        aperture: "f/3.2",
        shutterSpeed: "1/250s",
        iso: 6400,
        resolution: "5472 x 3648 (20 MP)",
        colorProfile: "sRGB"
      }
    },
    {
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
      uploadDate: "2026-09-20T08:30:00Z",
      videoMeta: {
        durationSeconds: 145,
        fps: 60,
        resolution: "3840 x 2160 (4K UHD)",
        codec: "H.264 / AAC",
        bitrate: "45 Mbps"
      }
    },
    {
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
      uploadDate: "2026-08-25T16:45:00Z",
      exif: {
        camera: "Nikon Z6 II",
        lens: "NIKKOR Z 70-200mm f/2.8 VR S",
        focalLength: "85mm",
        aperture: "f/2.8",
        shutterSpeed: "1/1000s",
        iso: 1600,
        resolution: "6048 x 4024 (24.5 MP)",
        colorProfile: "sRGB"
      }
    },
    {
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
      uploadDate: "2026-07-15T09:12:00Z",
      exif: {
        camera: "Fujifilm X-T4",
        lens: "XF 23mm f/1.4 R LM WR",
        focalLength: "23mm (35mm equiv)",
        aperture: "f/5.6",
        shutterSpeed: "1/800s",
        iso: 200,
        resolution: "6240 x 4160 (26 MP)",
        colorProfile: "Classic Chrome Sim"
      }
    }
  ]
};

// Database persistence helpers
function getDb() {
  if (!fs.existsSync(METADATA_FILE)) {
    fs.writeFileSync(METADATA_FILE, JSON.stringify(initialData, null, 2));
    return initialData;
  }
  try {
    const raw = fs.readFileSync(METADATA_FILE, 'utf8');
    return JSON.parse(raw);
  } catch (e) {
    return initialData;
  }
}

function saveDb(data) {
  // Recalculate storage stats automatically
  let totalBytes = 0;
  let photos = 0;
  let videos = 0;
  const photographers = new Set();

  data.files.forEach(f => {
    totalBytes += (f.sizeBytes || 0);
    if (f.type === 'video') videos += 1;
    else photos += 1;
    if (f.photographer) photographers.add(f.photographer.trim());
  });

  data.stats = {
    totalStorageLimitBytes: 100 * 1024 * 1024 * 1024, // 100 GB
    usedStorageBytes: totalBytes > 0 ? totalBytes : (24.8 * 1024 * 1024 * 1024),
    photoCount: photos > 0 ? photos : 1420,
    videoCount: videos > 0 ? videos : 86,
    activePhotographers: photographers.size > 0 ? photographers.size : 12
  };

  fs.writeFileSync(METADATA_FILE, JSON.stringify(data, null, 2));
}

// Multer Storage Configuration (Menyimpan file biner fisik)
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, BASE_UPLOADS);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const cleanName = file.originalname.replace(/[^a-zA-Z0-9.-]/g, '_');
    cb(null, `${uniqueSuffix}-${cleanName}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 500 * 1024 * 1024 } // 500 MB per file
});

// Static routes
app.use(express.static(PUBLIC_DIR));
app.use('/uploads', express.static(BASE_UPLOADS));

// Serve Flutter Web if build exists
if (fs.existsSync(FLUTTER_WEB_DIR)) {
  app.use('/flutter', express.static(FLUTTER_WEB_DIR));
}

// ----------------- REST API ROUTES ----------------- //

// 1. Get Storage Stats
app.get('/api/stats', (req, res) => {
  const db = getDb();
  res.json({ success: true, data: db.stats });
});

// 2. Get Events List
app.get('/api/events', (req, res) => {
  const db = getDb();
  res.json({ success: true, data: db.events });
});

// 3. Create Event (Real Persistence)
app.post('/api/events', (req, res) => {
  const db = getDb();
  const { title, date, location, description, leadPhotographer, category, coverUrl } = req.body;

  if (!title || !date) {
    return res.status(400).json({ success: false, message: "Judul dan Tanggal agenda wajib diisi." });
  }

  const newEvent = {
    id: "evt-" + Date.now().toString(36),
    title,
    date,
    location: location || "Sekolah",
    description: description || "Dokumentasi kegiatan ekskul fotografi",
    leadPhotographer: leadPhotographer || "Ekskul Fotografi",
    category: category || "Umum",
    coverUrl: coverUrl || "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80",
    totalFiles: 0
  };

  db.events.unshift(newEvent);
  saveDb(db);

  res.status(201).json({ success: true, message: "Agenda baru berhasil disimpan ke database!", data: newEvent });
});

// 4. Delete Event (Real Persistence)
app.delete('/api/events/:id', (req, res) => {
  const db = getDb();
  const { id } = req.params;

  db.events = db.events.filter(e => e.id !== id);
  // Also clean associated files
  db.files = db.files.filter(f => f.eventId !== id);

  saveDb(db);
  res.json({ success: true, message: "Agenda kegiatan berhasil dihapus." });
});

// 5. Get All Files with Filters
app.get('/api/files', (req, res) => {
  const db = getDb();
  const { status, type, photographer, eventId } = req.query;
  let files = [...db.files];

  if (status && status !== 'all') files = files.filter(f => f.curationStatus === status);
  if (type && type !== 'all') files = files.filter(f => f.type === type);
  if (eventId && eventId !== 'all') files = files.filter(f => f.eventId === eventId);
  if (photographer) files = files.filter(f => f.photographer.toLowerCase().includes(photographer.toLowerCase()));

  res.json({ success: true, total: files.length, data: files });
});

// 6. Get Files by Event ID
app.get('/api/events/:id/files', (req, res) => {
  const db = getDb();
  const { id } = req.params;
  const { status, type } = req.query;

  let files = db.files.filter(f => f.eventId === id);
  if (status && status !== 'all') files = files.filter(f => f.curationStatus === status);
  if (type && type !== 'all') files = files.filter(f => f.type === type);

  res.json({
    success: true,
    event: db.events.find(e => e.id === id),
    total: files.length,
    data: files
  });
});

// 7. Upload Media (Real File Saving & Metadata Persistence)
app.post('/api/upload', upload.single('mediaFile'), (req, res) => {
  const db = getDb();
  const { eventId, photographer, curationStatus, camera, lens, iso, shutterSpeed, aperture } = req.body;

  const file = req.file;
  const isVideo = file ? file.mimetype.startsWith('video') : (req.body.type === 'video');

  const fileUrl = file ? `/uploads/${file.filename}` : (req.body.url || 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80');

  const newDoc = {
    id: "f-" + Date.now().toString(36),
    eventId: eventId || (db.events[0] ? db.events[0].id : 'evt-001'),
    filename: file ? file.originalname : (req.body.filename || "IMG_" + Date.now() + ".JPG"),
    originalName: file ? file.originalname : "CAMERA_RAW.JPG",
    physicalPath: file ? file.path : null,
    type: isVideo ? "video" : "photo",
    mimeType: file ? file.mimetype : (isVideo ? "video/mp4" : "image/jpeg"),
    sizeBytes: file ? file.size : (isVideo ? 120000000 : 18500000),
    url: fileUrl,
    curationStatus: curationStatus || "raw",
    photographer: photographer || "Fotografer Anggota",
    uploadDate: new Date().toISOString(),
    exif: {
      camera: camera || "Sony Alpha 7 IV",
      lens: lens || "FE 24-70mm f/2.8 GM",
      focalLength: "50mm",
      aperture: aperture || "f/2.8",
      shutterSpeed: shutterSpeed || "1/500s",
      iso: Number(iso) || 400,
      resolution: isVideo ? "3840 x 2160 (4K)" : "6000 x 4000 (24 MP)",
      colorProfile: "sRGB"
    }
  };

  db.files.unshift(newDoc);

  // Update event total files
  const ev = db.events.find(e => e.id === newDoc.eventId);
  if (ev) ev.totalFiles = (ev.totalFiles || 0) + 1;

  saveDb(db);

  res.status(201).json({
    success: true,
    message: "Dokumentasi berhasil diunggah ke server dan metadata tersimpan!",
    data: newDoc
  });
});

// 8. Update Curation Status (RAW -> Curated -> Edited -> Final)
app.patch('/api/files/:id/status', (req, res) => {
  const db = getDb();
  const { id } = req.params;
  const { status } = req.body;

  const file = db.files.find(f => f.id === id);
  if (!file) return res.status(404).json({ success: false, message: "File tidak ditemukan." });

  file.curationStatus = status;
  saveDb(db);

  res.json({ success: true, message: `Status kurasi berhasil diubah ke ${status}`, data: file });
});

// 9. Delete File (Physical Disk Deletion + Metadata Removal)
app.delete('/api/files/:id', (req, res) => {
  const db = getDb();
  const { id } = req.params;

  const fileIndex = db.files.findIndex(f => f.id === id);
  if (fileIndex === -1) return res.status(404).json({ success: false, message: "File tidak ditemukan." });

  const targetFile = db.files[fileIndex];

  // Delete physical file from disk if exists
  if (targetFile.physicalPath && fs.existsSync(targetFile.physicalPath)) {
    try {
      fs.unlinkSync(targetFile.physicalPath);
    } catch (e) {
      console.warn('Gagal menghapus file fisik:', e.message);
    }
  }

  // Update event counter
  const ev = db.events.find(e => e.id === targetFile.eventId);
  if (ev && ev.totalFiles > 0) ev.totalFiles -= 1;

  db.files.splice(fileIndex, 1);
  saveDb(db);

  res.json({ success: true, message: "File dokumentasi dan data fisik berhasil dihapus." });
});

// Fallback to Studio UI on root
app.get('/', (req, res) => {
  res.sendFile(path.join(PUBLIC_DIR, 'index.html'));
});

// Start Server with Graceful Port Error Handling
const server = app.listen(PORT, () => {
  console.log(`\n======================================================`);
  console.log(`📸 [ShutterCloud] Photography Server Live!`);
  console.log(`🌐 Studio Web UI:  http://localhost:${PORT}`);
  console.log(`📱 Flutter Web UI: http://localhost:${PORT}/flutter/`);
  console.log(`🚀 REST API:       http://localhost:${PORT}/api/events`);
  console.log(`======================================================\n`);
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`\n[ERROR] Port ${PORT} sedang digunakan oleh proses lain.`);
    console.error(`Gunakan: Stop-Process -Id (Get-NetTCPConnection -LocalPort ${PORT}).OwningProcess -Force\n`);
  } else {
    console.error(err);
  }
});
