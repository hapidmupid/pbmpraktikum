# Aplikasi Manajemen Produk - PBM Praktikum 2026

## Identitas Mahasiswa

| Keterangan | Isi |
|------------|-----|
| **Nama** | Hafidlul Hidayat |
| **NIM** | 242410102095 |
| **Kelas** | PBM Praktikum 2026 |

---

## Deskripsi Aplikasi

Aplikasi Flutter untuk tugas praktikum Pemrograman Berbasis Mobile 2026. Aplikasi ini digunakan untuk mengelola draft produk dan mengumpulkan tugas praktikum.

Aplikasi menggunakan REST API dan **Bearer Token Authentication** untuk keamanan setiap request API.

---

## Fitur Aplikasi

| No | Fitur | Keterangan |
|----|-------|-------------|
| 1 | **Login** | Autentikasi menggunakan NIM (username & password = NIM) |
| 2 | **Dashboard Produk** | Menampilkan daftar draft produk milik pengguna |
| 3 | **Tambah Produk** | Menyimpan draft produk baru (name, price, description) |
| 4 | **Detail Produk** | Menampilkan informasi lengkap produk |
| 5 | **Hapus Produk** | Menghapus produk dari tampilan (soft delete) |
| 6 | **Submit Tugas Final** | Mengumpulkan tugas dengan menyertakan GitHub URL |

---

## Screenshot Aplikasi

### Halaman Login
<img width="433" height="792" alt="image" src="https://github.com/user-attachments/assets/c5bc0317-fb18-44b1-9caa-465153c424d3" />


### Halaman Dashboard
<img width="473" height="799" alt="image" src="https://github.com/user-attachments/assets/7ac7d263-0edc-4d74-aeba-2d8af318aa6b" />


### Halaman Tambah Produk
<img width="431" height="800" alt="image" src="https://github.com/user-attachments/assets/c38e3284-4f9f-4eb5-a862-af901ebccf31" />
<img width="432" height="793" alt="image" src="https://github.com/user-attachments/assets/f0cfb4b0-c52b-4965-b562-8f0141f17318" />


### Halaman Detail Produk
<img width="428" height="800" alt="image" src="https://github.com/user-attachments/assets/24c554a7-99d7-4bec-b381-3a9bedc26cd4" />


### Halaman Submit Tugas
<img width="427" height="797" alt="image" src="https://github.com/user-attachments/assets/b84591c9-07c6-4cc9-97ee-2709da1996ff" />
<img width="404" height="801" alt="image" src="https://github.com/user-attachments/assets/09d9c3f2-0576-4376-ab8a-4b84509ec073" />


### Sidebar
<img width="433" height="791" alt="image" src="https://github.com/user-attachments/assets/906aac9b-ff32-4051-835b-70f3c88e32b9" />


---


## Struktur Project
lib/
│
├── models/
│   ├── login_response.dart
│   └── product_model.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── add_product_screen.dart
│   ├── product_detail_screen.dart
│   └── submit_task_screen.dart
│
├── services/
│   └── api_service.dart
│
├── widgets/
│   └── product_card.dart
│
└── main.dart

---

## API Endpoint

| No | Method | Endpoint | Fungsi | Header |
|----|--------|----------|--------|--------|
| 1 | POST | `/api/auth/login` | Login / Autentikasi | `Content-Type: application/json` |
| 2 | GET | `/api/products` | Mendapatkan semua draft produk | `Authorization: Bearer {token}` |
| 3 | POST | `/api/products` | Menyimpan draft produk baru | `Authorization: Bearer {token}` |
| 4 | DELETE | `/api/products/{id}` | Menghapus produk (soft delete) | `Authorization: Bearer {token}` |
| 5 | POST | `/api/products/submit` | Submit tugas final | `Authorization: Bearer {token}` |

**Base URL:** `https://task.itprojects.web.id`
