import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

class CreateAvatarScreen extends StatefulWidget {
  const CreateAvatarScreen({Key? key}) : super(key: key);

  @override
  _CreateAvatarScreenState createState() => _CreateAvatarScreenState();
}

class _CreateAvatarScreenState extends State<CreateAvatarScreen> {
  String? _token;
  String? _avatarId;
  List<dynamic> _templates = [];
  List<dynamic> _assets = [];
  String? _selectedTemplateId;
  String? _selectedAssetId;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _createAnonymousUser();
  }

  Future<void> _createAnonymousUser() async {
    final response = await http.post(
      Uri.parse('https://localhost.readyplayer.me/api/users'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        _token = data['token'];
      });
      _fetchTemplates();
    } else {
      // Handle error
    }
  }

  Future<void> _fetchTemplates() async {
    final response = await http.get(
      Uri.parse('https://api.readyplayer.me/v2/avatars/templates'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        _templates = data;
      });
    } else {
      // Handle error
    }
  }

  Future<void> _createDraftAvatar(String templateId) async {
    final response = await http.post(
      Uri.parse('https://api.readyplayer.me/v2/avatars/templates/$templateId'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'partner': 'localhost',
        'bodyType': 'fullbody',
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      setState(() {
        _avatarId = data['id'];
      });
      _fetchAssets();
    } else {
      // Handle error
    }
  }

  Future<void> _fetchAssets() async {
    final response = await http.get(
      Uri.parse(
          'https://api.readyplayer.me/v1/assets?filter=usable-by-user-and-app&filterApplicationId=[application-id]&filterUserId=[user-id]'),
      headers: {
        'Authorization': 'Bearer $_token',
        'X-APP-ID': '[application-id]',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        _assets = data;
      });
    } else {
      // Handle error
    }
  }

  Future<void> _equipAsset(String assetId) async {
    final response = await http.patch(
      Uri.parse('https://api.readyplayer.me/v2/avatars/$_avatarId'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'outfit': assetId,
      }),
    );

    if (response.statusCode == 200) {
      // Asset equipped successfully
    } else {
      // Handle error
    }
  }

  Future<void> _saveDraftAvatar() async {
    final response = await http.put(
      Uri.parse('https://api.readyplayer.me/v2/avatars/$_avatarId'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      // Avatar saved successfully
    } else {
      // Handle error
    }
  }

  Future<void> _fetchAvatar() async {
    final response = await http.get(
      Uri.parse('https://models.readyplayer.me/$_avatarId.glb'),
    );

    if (response.statusCode == 200) {
      // Handle the fetched avatar
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Avatar'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (int index) {
              // Handle navigation within the customization screen
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.face),
                label: Text('Face'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.color_lens),
                label: Text('Color'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.style),
                label: Text('Style'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Customize your avatar here'),
                  if (_templates.isNotEmpty)
                    DropdownButton<String>(
                      hint: const Text('Select a template'),
                      value: _selectedTemplateId,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTemplateId = newValue;
                        });
                      },
                      items:
                          _templates.map<DropdownMenuItem<String>>((template) {
                        return DropdownMenuItem<String>(
                          value: template['id'],
                          child: Text(template['gender']),
                        );
                      }).toList(),
                    ),
                  ElevatedButton(
                    onPressed: _selectedTemplateId != null
                        ? () => _createDraftAvatar(_selectedTemplateId!)
                        : null,
                    child: const Text('Create Avatar'),
                  ),
                  if (_assets.isNotEmpty)
                    DropdownButton<String>(
                      hint: const Text('Select an asset'),
                      value: _selectedAssetId,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAssetId = newValue;
                        });
                      },
                      items: _assets.map<DropdownMenuItem<String>>((asset) {
                        return DropdownMenuItem<String>(
                          value: asset['id'],
                          child: Text(asset['name']),
                        );
                      }).toList(),
                    ),
                  ElevatedButton(
                    onPressed: _selectedAssetId != null
                        ? () => _equipAsset(_selectedAssetId!)
                        : null,
                    child: const Text('Equip Asset'),
                  ),
                  ElevatedButton(
                    onPressed: _avatarId != null ? _saveDraftAvatar : null,
                    child: const Text('Save Avatar'),
                  ),
                  ElevatedButton(
                    onPressed: _avatarId != null ? _fetchAvatar : null,
                    child: const Text('Fetch Avatar'),
                  ),
                  Expanded(
                    child: WebView(
                      initialUrl: 'file:///assets/avatar_customizer.html',
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _webViewController = webViewController;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
