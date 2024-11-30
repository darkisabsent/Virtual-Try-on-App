import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class TryOnImageScreen extends StatefulWidget {
  const TryOnImageScreen({Key? key}) : super(key: key);

  @override
  _TryOnImageScreenState createState() => _TryOnImageScreenState();
}

class _TryOnImageScreenState extends State<TryOnImageScreen> {
  File? _userImage;
  File? _clothImage;
  File? _resultImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, bool isUserImage) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isUserImage) {
          _userImage = File(pickedFile.path);
        } else {
          _clothImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _tryOn() async {
    if (_userImage == null || _clothImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both images')),
      );
      return;
    }

    final request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:5000/try-on'));
    request.files.add(
        await http.MultipartFile.fromPath('person_image', _userImage!.path));
    request.files.add(
        await http.MultipartFile.fromPath('clothing_image', _clothImage!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();
      final tempDir = await Directory.systemTemp.createTemp();
      final resultFile = File('${tempDir.path}/result.png');
      await resultFile.writeAsBytes(bytes);

      setState(() {
        _resultImage = resultFile;
      });

      _showResultDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to process images')),
      );
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Try-On Result'),
          content: _resultImage != null
              ? Image.file(_resultImage!)
              : const Text('No result image available'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Try-On Image'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Your Photo and Clothing Image',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _userImage == null
                          ? Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text('No image selected.'),
                              ),
                            )
                          : Image.file(_userImage!, height: 200),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _pickImage(ImageSource.gallery, true),
                        child: const Text('Select Your Photo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _clothImage == null
                          ? Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text('No image selected.'),
                              ),
                            )
                          : Image.file(_clothImage!, height: 200),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _pickImage(ImageSource.gallery, false),
                        child: const Text('Select Clothing Image'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _tryOn,
                child: const Text('Try On'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}