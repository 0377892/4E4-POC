// lib/api.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// base URL logic (unchanged)
String get apiBase {
  if (kIsWeb) return 'http://localhost:8000/api';
  if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
  return 'http://localhost:8000/api';
}

// new: global language code, default to English
String apiLang = 'fr';
