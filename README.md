# 🚴 Smart Bike Rental — Setup & Run Guide

## Prerequisites

| Tool | Version |
|------|---------|
| Node.js | v18+ |
| npm | v9+ |
| PostgreSQL | v14+ |
| Flutter SDK | v3.10+ |
| Dart SDK | v3.0+ |
| Android Studio / Emulator | Any recent |

---

## 1. PostgreSQL Database Setup

```bash
# Open PostgreSQL shell
psql -U postgres

# Create the database
CREATE DATABASE bike_rental_db;

# Exit shell
\q

# Run the schema to create all tables
psql -U postgres -d bike_rental_db -f backend/config/schema.sql
```

> **Seed sample data** (optional — paste in psql):
> ```sql
> INSERT INTO vendors (name, phone, address) VALUES ('BikePro Rentals', '9876543210', 'Pune, MH');
>
> INSERT INTO bikes (vendor_id, model, price_per_hour, price_per_day, location, availability, engine_cc, bike_type)
> VALUES
>   (1, 'Activa 6G',  80,  500,  'Pune',   TRUE, 110, 'scooter'),
>   (1, 'Royal Enfield Classic 350', 200, 1200, 'Mumbai', TRUE, 350, 'cruiser'),
>   (1, 'Ather 450X', 120, 700, 'Bangalore', TRUE, 0, 'electric'),
>   (1, 'Pulsar NS200', 150, 900, 'Delhi', TRUE, 200, 'sports');
> ```

---

## 2. Backend Setup

```bash
# Navigate to backend folder
cd backend

# Install all dependencies
npm install

# Copy the environment template and fill in your values
copy .env.example .env
```

### Edit `backend/.env`:

```env
PORT=5000

DB_HOST=localhost
DB_PORT=5432
DB_NAME=bike_rental_db
DB_USER=postgres
DB_PASSWORD=YOUR_POSTGRES_PASSWORD

JWT_SECRET=replace_with_a_long_random_string
JWT_EXPIRES_IN=7d

CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

### Start the backend server:

```bash
# Production
npm start

# Development (auto-restarts on file changes)
npm run dev
```

Backend will be available at: **http://localhost:5000**

---

## 3. Cloudinary Configuration

1. Sign up at [cloudinary.com](https://cloudinary.com) (free tier available)
2. Go to **Dashboard** → copy:
   - Cloud Name
   - API Key
   - API Secret
3. Paste these into your `backend/.env`

License images uploaded via `POST /api/upload-license` will be stored in the `bike_rental/licenses/` folder in your Cloudinary account.

---

## 4. Flutter App Setup

```bash
# Navigate to frontend folder
cd frontend

# Get all Flutter packages
flutter pub get

# For Android emulator — verify devices
flutter devices
```

### Configure API URL

Open `lib/services/api_service.dart` and update `baseUrl`:

```dart
// Android emulator (maps to your PC's localhost)
static const String baseUrl = 'http://10.0.2.2:5000/api';

// Physical Android device (use your PC's local IP)
// static const String baseUrl = 'http://192.168.x.x:5000/api';

// iOS simulator
// static const String baseUrl = 'http://127.0.0.1:5000/api';
```

### Run the Flutter app:

```bash
flutter run
```

---

## 5. API Reference (Quick Test with curl/Postman)

### Register
```
POST http://localhost:5000/api/auth/register
Content-Type: application/json

{ "name": "Ravi Kumar", "email": "ravi@test.com", "phone": "9999999999", "password": "test123" }
```

### Login
```
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{ "email": "ravi@test.com", "password": "test123" }
```
→ Copy the `token` from response.

### Get Bikes (requires token)
```
GET http://localhost:5000/api/bikes
Authorization: Bearer <YOUR_TOKEN>
```

### Create Booking (requires token)
```
POST http://localhost:5000/api/bookings
Authorization: Bearer <YOUR_TOKEN>
Content-Type: application/json

{ "bike_id": 1, "start_time": "2026-03-15T09:00:00", "end_time": "2026-03-15T13:00:00" }
```

### Get User Bookings (requires token)
```
GET http://localhost:5000/api/bookings/user/1
Authorization: Bearer <YOUR_TOKEN>
```

---

## 6. Project Structure Overview

```
Prototype/
├── backend/                  ← Node.js Express API
│   ├── config/
│   │   ├── db.js             ← PostgreSQL connection pool
│   │   └── schema.sql        ← Database schema (run once)
│   ├── controllers/          ← Business logic
│   ├── middleware/           ← JWT auth check
│   ├── models/               ← Database query functions
│   ├── routes/               ← API endpoint routing
│   ├── uploads/              ← Temp upload folder
│   ├── .env.example          ← Config template
│   └── server.js             ← App entry point
│
└── frontend/                 ← Flutter mobile app
    └── lib/
        ├── main.dart         ← App entry + routing
        ├── screens/          ← 6 UI screens
        └── services/         ← API + recommendation logic
```
