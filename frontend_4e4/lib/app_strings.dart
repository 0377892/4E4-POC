// lib/app_strings.dart

import 'api.dart';  // to read apiLang

class AppStrings {
  static const _values = <String, Map<String, String>>{
    'selectCategories': {
      'en': 'Select Categories',
      'fr': 'Sélectionner des catégories',
    },
    'previewGenerate': {
      'en': 'Preview & Generate',
      'fr': 'Aperçu et génération',
    },
    'generateMeme': {
      'en': 'Generate Meme',
      'fr': 'Générer le mème',
    },
    'saveToDevice': {
      'en': 'Save to Device',
      'fr': 'Enregistrer sur l’appareil',
    },
    'caption': {
      'en': 'Caption',
      'fr': 'Légende',
    },
  };

  static String of(String key) {
    final map = _values[key];
    if (map == null) return key;
    return map[apiLang] ?? map['en']!;
  }
}
