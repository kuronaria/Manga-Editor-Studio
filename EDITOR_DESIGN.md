# Manga Studio — Editor Mode (Rancangan)

Dokumen ini merangkum rancangan editor manual bergaya scanlate.io untuk
menggantikan/melengkapi UI web yang sekarang (drop → queue → result).
Tujuannya: dari batch translator menjadi **editor manual** yang memberi kontrol
penuh atas seleksi teks, pembersihan, dan typesetting.

## 1. Prinsip

- **Manual-first.** Tidak ada deteksi otomatis global. Pengguna memilih region
  sendiri (bubble maupun side text / teks di luar bubble).
- **Backend sebagai asisten, bukan pengambil keputusan.** Region yang dipilih
  boleh "di-scan" ke backend untuk mendapat OCR + terjemahan + background bersih,
  lalu pengguna mengoreksi. Boleh juga sepenuhnya manual (ketik sendiri).
- **Semua bisa dibatalkan (non-destruktif).** Gambar asli tidak pernah diubah;
  semua ada di layer terpisah.

## 2. Fondasi teknis (perlu dikonfirmasi)

| Keputusan | Rekomendasi | Alasan |
|---|---|---|
| Tempat | **Halaman editor baru** (`/editor`), terpisah dari `index.html` | UI editor beda total dari alur queue; jadi dasar UI baru |
| Library kanvas | **Konva.js** | Dukungan layer, transform (drag/scale/rotate), hit-test, dan export PNG bawaan — pas untuk editor berlapis |
| Framework UI | Tetap **petite-vue** (sudah dipakai) | Konsisten, ringan, tanpa build step |
| Brush | **Canvas 2D biasa** di dalam layer Konva | Cukup untuk blok putih/hitam/erase |

## 3. Lima pilar → fitur konkret

**1. Input (drag & drop)** — dipertahankan apa adanya. Drop gambar → langsung
masuk kanvas sebagai layer dasar. Tidak ada proses otomatis.

**2. Seleksi manual region** — pengguna menggambar kotak (klik sudut → sudut
diagonal, seperti scanlate) di atas bubble atau side text. Setiap region jadi
objek yang bisa:
- di-*scan* (opsional): crop dikirim ke backend → dapat OCR + terjemahan +
  warna + background bersih;
- diketik manual (tanpa backend);
- dipakai sebagai area untuk brush/typeset.
Region tidak harus di dalam bubble — bebas di mana saja.

**3. Brush (bersihkan)** — tiga mode persis scanlate, murni frontend, **bukan**
inpaint ML:
- **White** — cat blok putih (bersihkan teks di latar putih).
- **Black** — cat blok hitam (latar hitam / gutter).
- **Clear/Erase** — hapus sapuan brush → kembali ke gambar asli.
Ukuran brush diatur slider. Tidak ada redraw ML — sesuai keinginanmu.

**4. Layering** — minimal tiga layer, masing-masing bisa di-toggle show/hide:
- **Base** — gambar asli (read-only).
- **Clean** — sapuan brush + (opsional) background bersih dari backend.
- **Text** — kotak teks hasil typeset, satu objek per region.

**5. Export / download** — semua layer yang tampak di-*flatten* jadi satu PNG di
sisi klien (Konva `toDataURL` / `toCanvas`), tanpa perlu server. Opsi: simpan
"project" (JSON layer) agar bisa dilanjutkan nanti.

## 4. Interaksi backend (sudah diverifikasi)

Endpoint `POST /translate/json` mengembalikan array per-region:

```
{ minX, minY, maxX, maxY,      // bounding box
  angle, prob, is_bulleted_list,
  text_color: { fg:[r,g,b], bg:[r,g,b] },
  text: { <lang_sumber>: "...", <lang_target>: "..." },
  background: "data:image/png;base64,..."  // region SUDAH di-inpaint (teks hilang)
}
```

Alur "scan region" editor:
1. Pengguna gambar kotak seleksi.
2. Frontend meng-crop area itu dari gambar asli.
3. Crop dikirim ke `/translate/json` (config: detector ringan, translator pilihan
   pengguna).
4. Respons dipakai untuk mengisi: teks sumber (bisa diedit), terjemahan (bisa
   diedit), sudut, warna, dan **background bersih** (langsung jadi hasil clean
   tanpa brush manual).

Catatan: brush (pilar 3) tidak memanggil backend sama sekali. Inpaint ML tidak
diekspos sebagai mask endpoint, dan memang tidak dibutuhkan sesuai spesifikasimu.

## 5. Model data per-region (frontend)

```js
{
  id, x, y, w, h, angle,
  source: "日本語...",      // teks OCR (editable)
  target: "English...",     // terjemahan (editable)
  clean: <img|null>,        // background bersih dari backend (opsional)
  style: { font, fontSize, lineHeight, rotate, strokeWidth, fill, stroke },
  rasterized: false
}
```

## 6. Tahapan build (bertahap, tiap fase bisa dites)

- **Fase 1 — Kanvas & layer dasar.** Halaman `/editor`, drop gambar, Konva
  dengan 3 layer, zoom/pan (pakai ulang logika yang sudah kita buat), toggle
  layer, export PNG. *Belum ada teks/brush.*
- **Fase 2 — Brush.** White / black / erase + ukuran, di layer Clean.
- **Fase 3 — Seleksi manual + typeset manual.** Gambar kotak region, tambah
  kotak teks, atur font/size/line-height/rotate/stroke, drag & resize.
- **Fase 4 — Scan region ke backend.** Tombol "scan" per region → isi otomatis
  OCR + terjemahan + background bersih.
- **Fase 5 — Simpan/muat project + polish UI.**

## 7. Yang perlu kamu konfirmasi sebelum koding

1. Setuju **halaman baru `/editor`** (bukan menempel di UI sekarang)?
2. Setuju **Konva.js** sebagai library kanvas?
3. Mulai dari **Fase 1** (kanvas + layer + export)?
