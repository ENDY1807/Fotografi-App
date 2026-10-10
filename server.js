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
    usedStorageBytes: 0,
    photoCount: 0,
    videoCount: 0,
    activePhotographers: 0
  },
  events: [
    {
      id: "evt-001",
      title: "Dokumentasi Utama",
      date: "2026-10-10",
      location: "Sekolah & Lapangan",
      description: "Folder dokumentasi kegiatan ekskul fotografi.",
      coverUrl: "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80",
      totalFiles: 0,
      leadPhotographer: "Ekskul Fotografi",
      category: "Dokumentasi"
    }
  ],
  files: []
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
  // Recalculate storage stats automatically based on REAL files
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
    usedStorageBytes: totalBytes,
    photoCount: photos,
    videoCount: videos,
    activePhotographers: photographers.size
  };

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
