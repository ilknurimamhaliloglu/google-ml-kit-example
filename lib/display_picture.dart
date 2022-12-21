import 'dart:io';

import 'package:flutter/material.dart';

class DisplayPictureView extends StatelessWidget {
  final String imagePath;

  const DisplayPictureView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}
