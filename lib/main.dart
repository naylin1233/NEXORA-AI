import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

const String workerUrl = String.fromEnvironment('WORKER_URL');

void main() {
  runApp(const NexoraAI());
}

class NexoraAI extends StatelessWidget {
  const NexoraAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NEXORA AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090914),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final pages = const [
    HomePage(),
    ToolPage(title: 'Video Recap', action: 'recap'),
    ToolPage(title: 'Translate', action: 'translate'),
    VoicePage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF11111F),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            label: 'Recap',
          ),
          NavigationDestination(
            icon: Icon(Icons.translate),
            label: 'Translate',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_none),
            label: 'Voice',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'NEXORA AI',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Your World. Your AI.',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6D28D9),
                  Color(0xFF312E81),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to NEXORA',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Your all-in-one AI workspace.',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 20),
                Icon(Icons.auto_awesome, size: 45),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'AI TOOLS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          const FeatureCard(
            icon: Icons.movie,
            title: 'Video Recap',
            subtitle: 'Create story summaries',
          ),
          const FeatureCard(
            icon: Icons.translate,
            title: 'Myanmar Translate',
            subtitle: 'Translate text into Myanmar',
          ),
          const FeatureCard(
            icon: Icons.subtitles,
            title: 'SRT Subtitle',
            subtitle: 'Subtitle tools',
          ),
          const FeatureCard(
            icon: Icons.image,
            title: 'Thumbnail',
            subtitle: 'Thumbnail generation tools',
          ),
          const FeatureCard(
            icon: Icons.mic,
            title: 'AI Voice',
            subtitle: 'Voice generation tools',
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF17172A),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFB794F6), size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class ToolPage extends StatefulWidget {
  final String title;
  final String action;

  const ToolPage({
    super.key,
    required this.title,
    required this.action,
  });

  @override
  State<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  final controller = TextEditingController();

  String result = '';
  String fileName = '';
  bool loading = false;

  Future<void> pickFile() async {
    final file = await FilePicker.platform.pickFiles();

    if (file != null) {
      setState(() {
        fileName = file.files.single.name;
      });
    }
  }

  Future<void> sendRequest() async {
    if (controller.text.trim().isEmpty) {
      setState(() => result = 'စာသားအရင်ထည့်ပေးပါ။');
      return;
    }

    if (workerUrl.isEmpty) {
      setState(() => result = 'Worker URL မထည့်ရသေးပါ။');
      return;
    }

    setState(() {
      loading = true;
      result = '';
    });

    try {
      final response = await http.post(
        Uri.parse(workerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': widget.action,
          'input': controller.text.trim(),
        }),
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = jsonDecode(response.body);

        setState(() {
          result = data is Map
              ? (data['result'] ?? data['text'] ?? response.body).toString()
              : response.body;
        });
      } else {
        setState(() {
          result = 'Server Error: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        result = 'ချိတ်ဆက်မှု မအောင်မြင်ပါ။\n$e';
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            minLines: 5,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'ဒီမှာ စာသားထည့်ပါ...',
              filled: true,
              fillColor: const Color(0xFF17172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: pickFile,
            icon: const Icon(Icons.attach_file),
            label: const Text('Choose File'),
          ),
          if (fileName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Selected: $fileName'),
            ),
          const SizedBox(height: 15),
          FilledButton.icon(
            onPressed: loading ? null : sendRequest,
            icon: const Icon(Icons.auto_awesome),
            label: Text(loading ? 'Processing...' : 'Generate'),
          ),
          const SizedBox(height: 25),
          if (result.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF17172A),
                borderRadius: BorderRadius.circular(18),
              ),
              child: SelectableText(result),
            ),
        ],
      ),
    );
  }
}

class VoicePage extends StatelessWidget {
  const VoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic, size: 65, color: Color(0xFFB794F6)),
              SizedBox(height: 20),
              Text(
                'AI Voice',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Voice generation feature is not connected yet.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'More',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
          ListTile(
            leading: Icon(Icons.workspace_premium),
            title: Text('Premium'),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About NEXORA AI'),
            subtitle: Text('Your World. Your AI.'),
          ),
        ],
      ),
    );
  }
}
