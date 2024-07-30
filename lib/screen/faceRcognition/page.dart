import 'dart:io';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var pathPhoto = '';
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // TODO: Ambil foto dari kamera atau galeri menggunakan plugin image_picker
        },
      ),
      body: buildWidgetBody(),
    );
  }

  Widget buildWidgetBody() {
    /// Tampilkan loading ditengah-tengah layar
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    /// Tampilkan info bahwa tidak ada foto yang diambil
    if (pathPhoto.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Silakan ambil foto dulu ya\n'
            'dengan cara tekan tombol tambah di bagian kanan bawah',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    /// Tampilkan foto yang kita ambil dari kamera atau galeri
    return Center(
      child: Image.file(
        File(
          pathPhoto,
        ),
      ),
    );
  }

  void showDialogMessage(String message) {
    // TODO: Tampilkan pesan dialog
  }
}