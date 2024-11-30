import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';

class TryOnAvatarScreen extends StatefulWidget {
  const TryOnAvatarScreen({Key? key}) : super(key: key);

  @override
  _TryOnAvatarScreenState createState() => _TryOnAvatarScreenState();
}

class _TryOnAvatarScreenState extends State<TryOnAvatarScreen> {
  File? _clothImage;
  final ImagePicker _picker = ImagePicker();
  Timer? _timer;
  StreamController<Image>? _videoFeedController;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _clothImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _tryOnMe() async {
    if (_clothImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a clothing image')),
      );
      return;
    }

    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('http://127.0.0.1:5000/try-on'));
      request.files.add(await http.MultipartFile.fromPath(
          'clothing_image', _clothImage!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clothing aligned successfully')),
        );
        _startVideoFeed();
        _showVideoPopup();
      } else {
        final responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to align clothing: $responseBody')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _stopVideo() async {
    try {
      final response = await http.post(Uri.parse('http://127.0.0.1:5000/stop'));
      if (response.statusCode == 200) {
        _timer?.cancel();
        _videoFeedController?.close();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stopped successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to stop video')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _takeScreenshot() async {
    try {
      final response =
          await http.post(Uri.parse('http://127.0.0.1:5000/screenshot'));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await Directory.systemTemp.createTemp();
        final screenshotFile = File('${tempDir.path}/screenshot.png');
        await screenshotFile.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screenshot taken successfully')),
        );

        // Display the screenshot
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Screenshot'),
              content: Image.file(screenshotFile),
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to take screenshot')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _startVideoFeed() {
    _videoFeedController = StreamController<Image>();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      try {
        final response =
            await http.get(Uri.parse('http://127.0.0.1:5000/frame'));
        if (response.statusCode == 200) {
          _videoFeedController?.add(Image.memory(response.bodyBytes));
        }
      } catch (e) {
        print('Error fetching video feed: $e');
      }
    });
  }

  void _showVideoPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Virtual Try-On'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 300,
                height: 300,
                child: StreamBuilder<Image>(
                  stream: _videoFeedController?.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error loading video feed'));
                    } else if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _takeScreenshot,
                    child: const Text('Take Screenshot'),
                  ),
                  TextButton(
                    onPressed: _stopVideo,
                    child: const Text('Stop Video'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoFeedController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Try-On Avatar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Clothing Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _tryOnMe,
              child: const Text('Try On Me'),
            ),
          ],
        ),
      ),
    );
  }
}