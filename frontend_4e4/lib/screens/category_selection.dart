// lib/screens/category_selection.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:http/http.dart' as http;
import '../api.dart';
import 'meme_preview.dart';
import '../app_strings.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});
  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<Map<String, dynamic>> categories = [];
  Set<int> selected = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final url = Uri.parse('$apiBase/categories/?lang=$apiLang');
    print('🔗 [Android] Fetching categories from $url');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List;
      setState(() => categories = data.cast<Map<String, dynamic>>());
    } else {
      print('❌ Failed to load categories: ${resp.statusCode}');
    }
  }

  void _onLangChanged(String? newLang) {
    if (newLang == null || newLang == apiLang) return;
    setState(() {
      apiLang = newLang;
      selected.clear();
      categories = [];
    });
    _loadCategories();
  }

  void _onCheckboxChanged(bool? value, int id) {
    setState(() {
      if (value == true && selected.length < 2) {
        selected.add(id);
      } else {
        selected.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),  // only for status bar
      body: BootstrapContainer(
        fluid: false,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          // Spacer
          BootstrapRow(height: 16, children: []),

          // Title + language selector
          BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-12 col-sm-10 col-md-8 col-lg-6 '
                    'offset-sm-1 offset-md-2 offset-lg-3',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.of('selectCategories'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    DropdownButton<String>(
                      value: apiLang,
                      underline: const SizedBox(),
                      onChanged: _onLangChanged,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('EN')),
                        DropdownMenuItem(value: 'fr', child: Text('FR')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Category list + forward arrow
          BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-12 col-sm-10 col-md-8 col-lg-6 '
                    'offset-sm-1 offset-md-2 offset-lg-3',
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (categories.isEmpty)
                          const Center(child: CircularProgressIndicator())
                        else
                          ...categories.map((cat) {
                            final id = cat['id'] as int;
                            final label = cat['label'] as String;
                            return CheckboxListTile(
                              title: Text(label),
                              value: selected.contains(id),
                              onChanged: (v) =>
                                  _onCheckboxChanged(v, id),
                            );
                          }),

                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: selected.isEmpty
                                ? null
                                : () {
                                    final keys = categories
                                        .where((c) =>
                                            selected.contains(c['id']))
                                        .map((c) => c['key']
                                            as String)
                                        .toList();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MemePreviewScreen(
                                          categoryKeys: keys,
                                          lang: apiLang,
                                        ),
                                      ),
                                    );
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
