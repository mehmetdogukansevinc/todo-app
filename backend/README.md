# Authentication API for Flutter

This is a Node.js and MongoDB based authentication API that provides login and registration functionality for your Flutter application.

## Setup

1. Install dependencies:

```
npm install
```

2. Create a `.env` file in the root directory with the following variables:

```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/auth_db
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=7d
```

3. Start the server:

```
# Development mode
npm run dev

# Production mode
npm start
```

## API Endpoints

### Register a new user

```
POST /api/auth/register
```

Request body:

```json
{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123"
}
```

### Login

```
POST /api/auth/login
```

Request body:

```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

### Get current user profile

```
GET /api/auth/me
```

Headers:

```
Authorization: Bearer YOUR_JWT_TOKEN
```

## Flutter Integration

In your Flutter app, you can use the `http` package to make requests to these endpoints:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// Base URL for API
const String baseUrl = 'http://10.0.2.2:5000/api';  // Use this for Android Emulator
// const String baseUrl = 'http://localhost:5000/api';  // Use this for iOS Simulator

// Register a new user
Future<Map<String, dynamic>> register(String username, String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': username,
      'email': email,
      'password': password,
    }),
  );

  return jsonDecode(response.body);
}

// Login user
Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  return jsonDecode(response.body);
}

// Get current user
Future<Map<String, dynamic>> getCurrentUser(String token) async {
  final response = await http.get(
    Uri.parse('$baseUrl/auth/me'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```
