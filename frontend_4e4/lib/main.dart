import 'package:flutter/material.dart';
import 'screens/category_selection.dart';

void main() {
  runApp(const MemePocApp());
}

class MemePocApp extends StatelessWidget {
  const MemePocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meme POC',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CategorySelectionScreen(),
    );
  }
}
