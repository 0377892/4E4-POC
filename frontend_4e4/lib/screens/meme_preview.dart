// lib/screens/meme_preview.dart

import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../api.dart';
import '../app_strings.dart';

class MemePreviewScreen extends StatefulWidget {
  final List<String> categoryKeys;
  final String lang;
  const MemePreviewScreen({
    super.key,
    required this.categoryKeys,
    required this.lang,
  });

  @override
  _MemePreviewScreenState createState() => _MemePreviewScreenState();
}

class _MemePreviewScreenState extends State<MemePreviewScreen> {
  Uint8List? imageBytes;
  String? overlayText;
  bool loading = false;
  final TextEditingController textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchImageAndText();
  }

  Future<void> _fetchImageAndText() async {
    setState(() => loading = true);
    final catsParam = widget.categoryKeys.join(',');

    // 1) Fetch image
    try {
      final imgResp = await http.get(
        Uri.parse('$apiBase/images/?cats=$catsParam'),
      );
      if (imgResp.statusCode == 200) {
        final imgJson = jsonDecode(imgResp.body);
        final b64img = imgJson['image'].split(',').last;
        imageBytes = base64Decode(b64img);
      } else {
        print('❌ Image API error: ${imgResp.statusCode}');
      }
    } catch (e) {
      print('🐛 Exception fetching image: $e');
    }

    // 2) Fetch suggested caption
    try {
      final txtResp = await http.post(
        Uri.parse('$apiBase/text/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cats': widget.categoryKeys,
          'lang': widget.lang,
        }),
      );
      if (txtResp.statusCode == 200) {
        final txtJson = jsonDecode(txtResp.body);
        textCtrl.text = txtJson['text'];
      } else {
        print('❌ Text API error: ${txtResp.statusCode}');
        textCtrl.text = '';
      }
    } catch (e) {
      print('🐛 Exception fetching text: $e');
      textCtrl.text = '';
    }

    setState(() => loading = false);
  }

  void _generateMeme() {
    if (textCtrl.text.trim().isEmpty) return;
    setState(() => overlayText = textCtrl.text.trim());
  }

  Future<void> _saveToDevice() async {
    if (imageBytes == null || overlayText == null || overlayText!.isEmpty) return;

    // Decode image to ui.Image
    final codec = await ui.instantiateImageCodec(imageBytes!);
    final frame = await codec.getNextFrame();
    final uiImage = frame.image;

    // Prepare canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, uiImage.width.toDouble(), uiImage.height.toDouble()));
    canvas.drawImage(uiImage, Offset.zero, Paint());

    // Draw overlay text at top center
    final paragraphStyle = ui.ParagraphStyle(textAlign: ui.TextAlign.center, maxLines: 1);
    final textStyle = ui.TextStyle(
      color: Colors.white,
      fontSize: uiImage.height * 0.1, // 10% of image height
      shadows: [ui.Shadow(blurRadius: 3, color: Colors.black)],
    );
    final builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(overlayText!);
    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: uiImage.width.toDouble()));
    final yOffset = uiImage.height * 0.05; // 5% down
    canvas.drawParagraph(paragraph, Offset(0, yOffset));

    // End recording and convert to bytes
    final picture = recorder.endRecording();
    final img = await picture.toImage(uiImage.width, uiImage.height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Save to file
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/meme_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(pngBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // only back arrow
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : BootstrapContainer(
              fluid: false,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              children: [
                BootstrapRow(height: 16, children: []),

                // Back + Title
                BootstrapRow(children: [
                  BootstrapCol(
                    sizes: 'col-12 col-md-8 col-lg-6 offset-md-2 offset-lg-3',
                    child: Row(children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.of('previewGenerate'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ]),
                  ),
                ]),

                const SizedBox(height: 16),

                // Image with overlay
                if (imageBytes != null)
                  BootstrapRow(children: [
                    BootstrapCol(
                      sizes: 'col-12 col-md-8 col-lg-6 offset-md-2 offset-lg-3',
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Stack(alignment: Alignment.topCenter, children: [
                            Image.memory(imageBytes!, fit: BoxFit.contain),
                            if (overlayText != null && overlayText!.isNotEmpty)
                              Positioned(
                                top: 16,
                                left: 8,
                                right: 8,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    overlayText!,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 64,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(blurRadius: 3, color: Colors.black)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ]),
                        ),
                      ),
                    ),
                  ]),

                const SizedBox(height: 16),

                // Caption input, generate & save
                BootstrapRow(children: [
                  BootstrapCol(
                    sizes: 'col-12 col-md-8 col-lg-6 offset-md-2 offset-lg-3',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: textCtrl,
                          maxLines: 1,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: AppStrings.of('caption'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _generateMeme,
                          child: Text(AppStrings.of('generateMeme')),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: (overlayText != null && overlayText!.isNotEmpty)
                              ? _saveToDevice
                              : null,
                          child: Text(AppStrings.of('saveToDevice')),
                        ),
                      ],
                    ),
                  ),
                ]),
              ],
            ),
    );
  }
}
