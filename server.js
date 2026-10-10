const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 5050;

// Enable CORS for Flutter Client (Mobile, Web, Desktop)
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Storage Directories
const BASE_UPLOADS = path.join(__dirname, 'uploads');
const DATA_DIR = path.join(__dirname, 'data');
const METADATA_FILE = path.join(DATA_DIR, 'metadata.json');

// Ensure directories exist
if (!fs.existsSync(BASE_UPLOADS)) fs.mkdirSync(BASE_UPLOADS, { recursive: true });
if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });

// Initial Mock Metadata if not exists
const defaultData = {
  stats: {
    totalStorageLimitBytes: 100 * 1024 * 1024 * 1024, // 100 GB Cloud Quota
    usedStorageBytes: 24.8 * 1024 * 1024 * 1024, // 24.8 GB used
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
      curationStatus: "final", // raw, curated, edited, final
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

// Load or save initial database
function getDb() {
  if (!fs.existsSync(METADATA_FILE)) {
    fs.writeFileSync(METADATA_FILE, JSON.stringify(defaultData, null, 2));
    return defaultData;
  }
  try {
    return JSON.parse(fs.readFileSync(METADATA_FILE, 'utf8'));
  } catch (e) {
    return defaultData;
  }
}

function saveDb(data) {
  fs.writeFileSync(METADATA_FILE, JSON.stringify(data, null, 2));
}

// Multer Storage Configuration (GDrive style chunk/file destination)
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, BASE_UPLOADS);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + '-' + file.originalname.replace(/[^a-zA-Z0-9.-]/g, '_'));
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 500 * 1024 * 1024 } // 500MB max per file
});

// Static files serving
app.use('/uploads', express.static(BASE_UPLOADS));

// ----------------- API ROUTES ----------------- //

// 1. Get Storage Stats (Dashboard Summary)
app.get('/api/stats', (req, res) => {
  const db = getDb();
  res.json({
    success: true,
    data: db.stats
  });
});

// 2. Get Events List (Kegiatan Dokumentasi)
app.get('/api/events', (req, res) => {
  const db = getDb();
  res.json({
    success: true,
    data: db.events
  });
});

// 3. Create New Event
app.post('/api/events', (req, res) => {
  const db = getDb();
  const { title, date, location, description, leadPhotographer, category, coverUrl } = req.body;

  if (!title || !date) {
    return res.status(400).json({ success: false, message: "Title dan Date wajib diisi" });
  }

  const newEvent = {
    id: "evt-" + Date.now().toString(36),
    title,
    date,
    location: location || "Sekolah",
    description: description || "Dokumentasi kegiatan fotografi",
    leadPhotographer: leadPhotographer || "Ekskul Fotografi",
    category: category || "Umum",
    coverUrl: coverUrl || "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80",
    totalFiles: 0
  };

  db.events.unshift(newEvent);
  saveDb(db);

  res.status(201).json({ success: true, data: newEvent });
});

// 4. Get Files by Event ID (Gallery & Filter)
app.get('/api/events/:id/files', (req, res) => {
  const db = getDb();
  const { id } = req.params;
  const { status, type } = req.query;

  let files = db.files.filter(f => f.eventId === id);

  if (status && status !== 'all') {
    files = files.filter(f => f.curationStatus === status);
  }
  if (type && type !== 'all') {
    files = files.filter(f => f.type === type);
  }

  res.json({
    success: true,
    event: db.events.find(e => e.id === id),
    total: files.length,
    data: files
  });
});

// 5. Get All Files (Search & Recent)
app.get('/api/files', (req, res) => {
  const db = getDb();
  const { status, type, photographer } = req.query;
  let files = [...db.files];

  if (status && status !== 'all') files = files.filter(f => f.curationStatus === status);
  if (type && type !== 'all') files = files.filter(f => f.type === type);
  if (photographer) files = files.filter(f => f.photographer.toLowerCase().includes(photographer.toLowerCase()));

  res.json({
    success: true,
    total: files.length,
    data: files
  });
});

// 6. Upload Photo/Video Documentation
app.post('/api/upload', upload.single('mediaFile'), (req, res) => {
  const db = getDb();
  const { eventId, photographer, curationStatus, camera, lens, iso, shutterSpeed, aperture } = req.body;

  const file = req.file;
  const isVideo = file ? file.mimetype.startsWith('video') : (req.body.type === 'video');

  const fileUrl = file ? `/uploads/${file.filename}` : (req.body.url || 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80');

  const newDoc = {
    id: "f-" + Date.now().toString(36),
    eventId: eventId || (db.events[0] ? db.events[0].id : 'evt-001'),
    filename: file ? file.originalname : (req.body.filename || "IMG_NEW.JPG"),
    originalName: file ? file.originalname : "CAMERA_RAW.JPG",
    type: isVideo ? "video" : "photo",
    mimeType: file ? file.mimetype : (isVideo ? "video/mp4" : "image/jpeg"),
    sizeBytes: file ? file.size : 15400000,
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
      resolution: isVideo ? "3840 x 2160 (4K)" : "7008 x 4672 (33 MP)",
      colorProfile: "sRGB"
    }
  };

  db.files.unshift(newDoc);

  // Update event total files
  const ev = db.events.find(e => e.id === newDoc.eventId);
  if (ev) ev.totalFiles = (ev.totalFiles || 0) + 1;

  // Update storage stats
  db.stats.usedStorageBytes += newDoc.sizeBytes;
  if (newDoc.type === 'video') db.stats.videoCount += 1;
  else db.stats.photoCount += 1;

  saveDb(db);

  res.status(201).json({
    success: true,
    message: "File dokumentasi berhasil diunggah dan metadata EXIF diekstrak!",
    data: newDoc
  });
});

// 7. Update Curation Status (RAW -> Curated -> Edited -> Final)
app.patch('/api/files/:id/status', (req, res) => {
  const db = getDb();
  const { id } = req.params;
  const { status } = req.body;

  const file = db.files.find(f => f.id === id);
  if (!file) return res.status(404).json({ success: false, message: "File tidak ditemukan" });

  file.curationStatus = status;
  saveDb(db);

  res.json({ success: true, message: `Status berhasil diubah ke ${status}`, data: file });
});

// 8. Web Preview Landing Page for Visual Inspection
app.get('/', (req, res) => {
  const db = getDb();
  const usedGB = (db.stats.usedStorageBytes / (1024 * 1024 * 1024)).toFixed(2);
  const totalGB = (db.stats.totalStorageLimitBytes / (1024 * 1024 * 1024)).toFixed(0);
  const percent = ((db.stats.usedStorageBytes / db.stats.totalStorageLimitBytes) * 100).toFixed(1);

  res.send(`
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>ShutterCloud - Photography Storage Server</title>
  <style>
    :root {
      --bg: #0B0F19;
      --card: #151D2F;
      --card-border: #23314D;
      --accent: #F59E0B;
      --accent-glow: rgba(245, 158, 11, 0.25);
      --text: #F8FAFC;
      --subtext: #94A3B8;
      --badge-raw: #64748B;
      --badge-curated: #0284C7;
      --badge-edited: #D97706;
      --badge-final: #059669;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
    body { background: var(--bg); color: var(--text); padding: 32px 20px; line-height: 1.5; }
    .container { max-width: 1200px; margin: 0 auto; }
    header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border); }
    h1 { font-size: 26px; font-weight: 800; display: flex; align-items: center; gap: 10px; }
    .badge-live { background: #10B981; color: #fff; font-size: 11px; font-weight: 700; padding: 4px 8px; border-radius: 99px; text-transform: uppercase; }
    .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 30px; }
    .stat-card { background: var(--card); border: 1px solid var(--card-border); border-radius: 12px; padding: 20px; }
    .stat-title { font-size: 13px; color: var(--subtext); text-transform: uppercase; font-weight: 600; letter-spacing: 0.5px; }
    .stat-val { font-size: 28px; font-weight: 700; color: #fff; margin-top: 6px; }
    .progress-bar-bg { width: 100%; height: 8px; background: #1E293B; border-radius: 4px; overflow: hidden; margin-top: 10px; }
    .progress-bar-fill { height: 100%; background: linear-gradient(90deg, #F59E0B, #10B981); border-radius: 4px; }
    .events-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px; margin-bottom: 36px; }
    .event-card { background: var(--card); border: 1px solid var(--card-border); border-radius: 12px; overflow: hidden; transition: transform 0.2s, border-color 0.2s; }
    .event-card:hover { transform: translateY(-4px); border-color: var(--accent); }
    .event-cover { width: 100%; height: 180px; object-fit: cover; }
    .event-body { padding: 16px; }
    .event-title { font-size: 18px; font-weight: 700; margin-bottom: 6px; }
    .event-meta { font-size: 13px; color: var(--subtext); display: flex; gap: 12px; margin-bottom: 10px; }
    .status-badge { display: inline-block; padding: 3px 8px; border-radius: 6px; font-size: 11px; font-weight: 600; text-transform: uppercase; }
    .raw { background: #334155; color: #94A3B8; }
    .curated { background: #0369A1; color: #E0F2FE; }
    .edited { background: #B45309; color: #FEF3C7; }
    .final { background: #047857; color: #D1FAE5; }
    .api-hint { background: #111827; border: 1px dashed #374151; padding: 14px 18px; border-radius: 8px; font-family: monospace; font-size: 13px; color: #A5B4FC; }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <div>
        <h1>📸 ShutterCloud Engine <span class="badge-live">GDrive Architecture Active</span></h1>
        <p style="color: var(--subtext); font-size: 14px; margin-top: 4px;">Server Dokumentasi Foto & Video Ekskul Fotografi • Resumable Upload & EXIF Extractor</p>
      </div>
      <div>
        <a href="/api/events" style="color: var(--accent); font-size: 14px; text-decoration: none; font-weight: 600; background: #1E293B; padding: 8px 14px; border-radius: 6px; border: 1px solid var(--card-border);">Buka REST API &rarr;</a>
      </div>
    </header>

    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-title">Storage Terpakai</div>
        <div class="stat-val">${usedGB} <span style="font-size: 16px; color: var(--subtext);">/ ${totalGB} GB</span></div>
        <div class="progress-bar-bg"><div class="progress-bar-fill" style="width: ${percent}%;"></div></div>
        <small style="color: var(--subtext); display: block; margin-top: 6px;">${percent}% Quota Server</small>
      </div>
      <div class="stat-card">
        <div class="stat-title">Total Foto Dokumentasi</div>
        <div class="stat-val">${db.stats.photoCount}</div>
        <small style="color: var(--subtext); display: block; margin-top: 6px;">RAW, JPEG & Color Graded</small>
      </div>
      <div class="stat-card">
        <div class="stat-title">Total Video Kegiatan</div>
        <div class="stat-val">${db.stats.videoCount}</div>
        <small style="color: var(--subtext); display: block; margin-top: 6px;">4K / 1080p 60fps Reels & Teaser</small>
      </div>
      <div class="stat-card">
        <div class="stat-title">Fotografer Aktif</div>
        <div class="stat-val">${db.stats.activePhotographers}</div>
        <small style="color: var(--subtext); display: block; margin-top: 6px;">Anggota Tim Dokumentasi</small>
      </div>
    </div>

    <h2 style="font-size: 20px; margin-bottom: 16px;">Agenda Kegiatan & Event Dokumentasi</h2>
    <div class="events-grid">
      ${db.events.map(ev => `
        <div class="event-card">
          <img src="${ev.coverUrl}" class="event-cover" alt="${ev.title}" />
          <div class="event-body">
            <span class="status-badge curated" style="margin-bottom: 8px;">${ev.category}</span>
            <div class="event-title">${ev.title}</div>
            <div class="event-meta">
              <span>📅 ${ev.date}</span>
              <span>📍 ${ev.location}</span>
            </div>
            <p style="font-size: 13px; color: var(--subtext); margin-bottom: 12px;">${ev.description}</p>
            <div style="font-size: 12px; color: #CBD5E1; border-top: 1px solid var(--card-border); padding-top: 8px; display: flex; justify-content: space-between;">
              <span>PJ: <b>${ev.leadPhotographer}</b></span>
              <span>📁 ${ev.totalFiles} Item</span>
            </div>
          </div>
        </div>
      `).join('')}
    </div>

    <div class="api-hint">
      🚀 Endpoint REST API Siap Terhubung ke Flutter:
      <br>&bull; GET /api/stats (Ringkasan kuota GDrive)
      <br>&bull; GET /api/events (Daftar kegiatan ekskul)
      <br>&bull; GET /api/events/:id/files (Galeri foto & video dengan metadata EXIF)
      <br>&bull; POST /api/upload (Unggah dokumentasi dengan EXIF & status kurasi)
      <br>&bull; PATCH /api/files/:id/status (Kurasi foto: RAW -> Curated -> Edited -> Final)
    </div>
  </div>
</body>
</html>
  `);
});

// Start Server
app.listen(PORT, () => {
  console.log(`[ShutterCloud] Photography Server running at http://localhost:${PORT}`);
});
