import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

const purple = Color(0xFF9B5CFF);
const bg = Color(0xFF090711);
const card = Color(0xFF171322);

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
        scaffoldBackgroundColor: bg,
        colorSchemeSeed: purple,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  final pages = const [
    HomePage(),
    ToolPage(type: 'Video Recap'),
    ToolPage(type: 'Translate'),
    VoicePage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: card,
        indicatorColor: purple.withValues(alpha: 0.25),
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.movie_outlined), label: 'Recap'),
          NavigationDestination(icon: Icon(Icons.translate), label: 'Translate'),
          NavigationDestination(icon: Icon(Icons.record_voice_over), label: 'Voice'),
          NavigationDestination(icon: Icon(Icons.apps), label: 'More'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: purple, size: 35),
              SizedBox(width: 10),
              Text('NEXORA AI',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              Spacer(),
              Icon(Icons.notifications_none, color: purple),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF472078), Color(0xFF171126)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: purple.withValues(alpha: 0.4)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WELCOME TO',
                    style: TextStyle(color: Colors.white70, letterSpacing: 3)),
                SizedBox(height: 8),
                Text('NEXORA AI',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Your World. Your AI.',
                    style: TextStyle(color: Colors.white70)),
                SizedBox(height: 15),
                Icon(Icons.smart_toy, size: 65, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text('AI TOOLS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              FeatureCard(icon: Icons.movie, title: 'Video Recap',
                  onTap: () => openTool(context, 'Video Recap')),
              FeatureCard(icon: Icons.translate, title: 'Translator',
                  onTap: () => openTool(context, 'Translate')),
              FeatureCard(icon: Icons.subtitles, title: 'SRT Subtitle',
                  onTap: () => openTool(context, 'SRT')),
              FeatureCard(icon: Icons.image, title: 'Thumbnail',
                  onTap: () => openTool(context, 'Thumbnail')),
              FeatureCard(icon: Icons.title, title: 'Title & Hashtags',
                  onTap: () => openTool(context, 'Title')),
              FeatureCard(icon: Icons.record_voice_over, title: 'Voice',
                  onTap: () => openTool(context, 'Voice')),
            ],
          ),
        ],
      ),
    );
  }

  void openTool(BuildContext context, String type) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => ToolPage(type: type)));
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: purple.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: purple, size: 34),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ToolPage extends StatefulWidget {
  final String type;
  const ToolPage({super.key, required this.type});

  @override
  State<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  final controller = TextEditingController();
  String result = '';
  String selectedFile = '';
  bool loading = false;

  Future<void> pickVideo() async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (file != null && mounted) {
      setState(() {
        selectedFile = file.files.single.name;
      });
    }
  }

  Future<void> runAI() async {
    if (controller.text.trim().isEmpty && selectedFile.isEmpty) {
      setState(() => result = 'စာသား သို့မဟုတ် Video ကို ရွေးပေးပါ။');
      return;
    }

    setState(() {
      loading = true;
      result = '';
    });

    try {
      const workerUrl = String.fromEnvironment('WORKER_URL');

      if (workerUrl.isEmpty) {
        throw Exception('Worker URL မသတ်မှတ်ရသေးပါ။');
      }

      final response = await http.post(
        Uri.parse(workerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': widget.type.toLowerCase(),
          'input': controller.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        result = data['reply']?.toString() ?? 'အဖြေမရရှိပါ။';
      } else {
        result = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      result = 'ချိတ်ဆက်မှု မအောင်မြင်ပါ။ $e';
    }

    if (mounted) {
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.type)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.type,
              style: const TextStyle(fontSize: 25,
                  fontWeight: FontWeight.bold, color: purple)),
          const SizedBox(height: 18),
          TextField(
            controller: controller,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'ဒီနေရာမှာ စာသားထည့်ပါ...',
              filled: true,
              fillColor: card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: pickVideo,
            icon: const Icon(Icons.video_library),
            label: const Text('Select Video'),
          ),
          if (selectedFile.isNotEmpty)
            Text('ရွေးထားသောဖိုင်: $selectedFile'),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: loading ? null : runAI,
            icon: const Icon(Icons.auto_awesome),
            label: Text(loading ? 'Processing...' : 'Generate with AI'),
          ),
          const SizedBox(height: 20),
          if (result.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SelectableText(result),
            ),
          const SizedBox(height: 12),
          const Text(
            'မှတ်ချက် - Video ကိုရွေးချယ်ရုံသာဖြစ်ပြီး '
            'လက်ရှိတွင် Video Upload နှင့် Analysis မပါဝင်သေးပါ။',
            style: TextStyle(color: Colors.white54),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.record_voice_over, size: 75, color: purple),
          SizedBox(height: 15),
          Text('NEXORA AI VOICE',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Narrator & Character Voice'),
          SizedBox(height: 8),
          Text('Voice generation ကို နောက်ပိုင်း Backend ချိတ်ဆက်မည်။',
              style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text('MORE FEATURES',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        ListTile(
          leading: Icon(Icons.info_outline, color: purple),
          title: Text('About NEXORA AI'),
          subtitle: Text('Your World. Your AI.'),
        ),
        ListTile(
          leading: Icon(Icons.settings, color: purple),
          title: Text('Settings'),
        ),
        ListTile(
          leading: Icon(Icons.workspace_premium, color: purple),
          title: Text('Premium'),
        ),
      ],
    );
  }
}
