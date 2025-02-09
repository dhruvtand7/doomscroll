import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(DoomScrollApp());
}

class ChatPersona {
  final String id;
  final String name;
  final String description;
  final String avatarIcon;
  final String systemPrompt;
  final String apiKey; // NEW: API Key for this persona
  final String apiUrl; // NEW: API URL for this persona

  ChatPersona({
    required this.id,
    required this.name,
    required this.description,
    required this.avatarIcon,
    required this.systemPrompt,
    required this.apiKey,
    required this.apiUrl,
  });
}

// Message model
class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
  });
}

// OpenAI service
class OpenAIService {
  final String apiKey;
  final String apiUrl;

  OpenAIService({required this.apiKey, required this.apiUrl});

  Future<String> getCompletion(String prompt, String systemPrompt) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      return 'Sorry, I encountered an error. Please try again.';
    }
  }
}


class DoomScrollApp extends StatelessWidget {
  // Define custom colors for dark theme
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const primary = Color(0xFF6200EE);
  static const accent = Color(0xFF03DAC6);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF); // 70% white

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoomScroll',
      theme: ThemeData.dark().copyWith(
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        cardTheme: CardTheme(
          color: surface,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: textPrimary,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
      ),
      home: MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    ScrollTrackerPage(),
    DopamineDetoxPage(),
    ChatbotPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: DoomScrollApp.surface,
          indicatorColor: DoomScrollApp.primary.withOpacity(0.2),
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Tracker',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Detox',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DoomScroll'),
      ),
      body: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to DoomScroll!',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: DoomScrollApp.textPrimary,
              ),
            ),
            SizedBox(height: 40),
            _buildActionButton(
              context: context,
              label: 'Start Tracking',
              icon: Icons.track_changes,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScrollTrackerPage()),
              ),
            ),
            SizedBox(height: 20),
            _buildActionButton(
              context: context,
              label: 'Start Dopamine Detox',
              icon: Icons.timer,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DopamineDetoxPage()),
              ),
            ),
            SizedBox(height: 20),
            _buildActionButton(
              context: context,
              label: 'Chat with Assistant',
              icon: Icons.chat,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatbotPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}

class ScrollTrackerPage extends StatefulWidget {
  @override
  _ScrollTrackerPageState createState() => _ScrollTrackerPageState();
}

class _ScrollTrackerPageState extends State<ScrollTrackerPage> {
  int nativeScrollCount = 0;
  bool _isInstagramRunning = false;
  static final MethodChannel platform = MethodChannel('doomscroll/foreground_app');
  static final EventChannel scrollCountChannel = EventChannel('doomscroll/scroll_count');

  @override
  void initState() {
    super.initState();
    _checkIfInstagramIsRunning();
    _requestAccessibilityPermission();
    scrollCountChannel.receiveBroadcastStream().listen(
          (event) => setState(() => nativeScrollCount = event as int),
      onError: (error) => print("Error receiving scroll count: $error"),
    );
  }

  Future<void> _checkIfInstagramIsRunning() async {
    try {
      final bool isRunning = await platform.invokeMethod('isInstagramRunning');
      setState(() => _isInstagramRunning = isRunning);
    } on PlatformException catch (e) {
      print("Failed to check app state: '${e.message}'.");
    }
  }

  Future<void> _requestAccessibilityPermission() async {
    try {
      await platform.invokeMethod('requestAccessibilityPermission');
    } on PlatformException catch (e) {
      print("Failed to request accessibility permission: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scroll Tracker'),
      ),
      body: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Native Scroll Count',
                      style: TextStyle(
                        fontSize: 18,
                        color: DoomScrollApp.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$nativeScrollCount',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: DoomScrollApp.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isInstagramRunning ? DoomScrollApp.primary.withOpacity(0.1) : DoomScrollApp.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_android,
                    color: _isInstagramRunning ? DoomScrollApp.accent : DoomScrollApp.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _isInstagramRunning ? "Instagram is running" : "Instagram is not running",
                    style: TextStyle(
                      fontSize: 16,
                      color: _isInstagramRunning ? DoomScrollApp.textPrimary : DoomScrollApp.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressiveVisualizerPage(scrollCount: nativeScrollCount),
                  ),
                ),
                icon: Icon(Icons.visibility),
                label: Text('View Progress', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DopamineDetoxPage extends StatefulWidget {
  @override
  _DopamineDetoxPageState createState() => _DopamineDetoxPageState();
}

class _DopamineDetoxPageState extends State<DopamineDetoxPage> {
  int _secondsLeft = 300;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer.cancel();
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return Container(
                color: DoomScrollApp.background,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Time Remaining',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: DoomScrollApp.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}",
                        style: GoogleFonts.poppins(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: DoomScrollApp.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 170,
            child: Column(
              children: [
                _buildDetoxActionButton(Icons.favorite_border),
                SizedBox(height: 16),
                _buildDetoxActionButton(Icons.comment),
              ],
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildDetoxActionButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: DoomScrollApp.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 40, color: DoomScrollApp.textPrimary),
        onPressed: () {},
      ),
    );
  }
}

class ProgressiveVisualizerPage extends StatelessWidget {
  final int scrollCount;
  final List<Map<String, dynamic>> creatures = [
    {'name': 'Mouse', 'size': 6, 'clipart': 'assets/images/mouse.png'},
    {'name': 'Cat', 'size': 10, 'clipart': 'assets/images/cat.jpg'},
    // ... (rest of the creatures list remains the same)
  ];

  ProgressiveVisualizerPage({required this.scrollCount});

  @override
  Widget build(BuildContext context) {
    double totalDistanceInches = scrollCount * 6.0;
    double totalDistanceFeet = totalDistanceInches / 12.0;
    int unlockedIndex = creatures.indexWhere((creature) =>
    totalDistanceInches < creature['size'] * 12.0);
    if (unlockedIndex == -1) unlockedIndex = creatures.length - 1;

    return Scaffold(
        appBar: AppBar(
        title: Text('Progress Visualizer'),
    ),
    body: Column(
    children: [
    SizedBox(height: 24),
    Text(
    'Reels Scrolled: $scrollCount',
    style: GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: DoomScrollApp.textPrimary,
    ),
    ),
    SizedBox(height: 8),
    Text(
    'Distance Scrolled: ${totalDistanceFeet.toStringAsFixed(1)} ft',
    style: TextStyle(
    fontSize: 18,
    color: DoomScrollApp.textSecondary,
    ),
    ),
    SizedBox(height: 32),
    Expanded(
    child: PageView.builder(
    itemCount: creatures.length,
    controller: PageController(initialPage: unlockedIndex),
    itemBuilder: (context, index) {
    bool isUnlocked = index <= unlockedIndex;
    return Card(
    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    child: Container(
    padding: EdgeInsets.all(24),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Image.asset(
    creatures[index]['clipart'],
    height: 120,
    width: 120,
    fit: BoxFit.contain,
    color: isUnlocked ? null : Colors.black38,
    colorBlendMode: isUnlocked ? null : BlendMode.saturation,
    ),
    SizedBox(height: 16),
    Text(
    creatures[index]['name'],
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isUnlocked ? DoomScrollApp.textPrimary : DoomScrollApp.textSecondary,
      ),
    ),
      SizedBox(height: 8),
      Text(
        'Size: ${creatures[index]['size']} ft',
        style: TextStyle(
          fontSize: 16,
          color: isUnlocked ? DoomScrollApp.textSecondary : DoomScrollApp.textSecondary.withOpacity(0.5),
        ),
      ),
      if (!isUnlocked) ...[
        SizedBox(height: 16),
        Icon(
          Icons.lock,
          color: DoomScrollApp.textSecondary.withOpacity(0.5),
          size: 32,
        ),
      ],
    ],
    ),
    ),
    );
    },
    ),
    ),
    ],
    ),
    );
  }
}

// New Chatbot Page
class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  late OpenAIService _openAIService;
  String? _selectedPersonaId;

  // Map to store conversations for each persona
  final Map<String, List<ChatMessage>> _personaMessages = {};

  // Define personas
  final List<ChatPersona> personas = [
    ChatPersona(
      id: 'wellness_coach',
      name: 'Wellness Coach',
      description: 'Helps you develop healthy digital habits',
      avatarIcon: '🧘‍♀',
      systemPrompt: 'You are a wellness coach focused on digital wellbeing.',
      apiKey: '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', // Replace with persona 1's API key
      apiUrl: 'https://chatgpt.com/g/g-67a74121367081919a72a5c5d2c5354c-frank', // Replace with persona 1's API URL
    ),
    ChatPersona(
      id: 'productivity_expert',
      name: 'Productivity Expert',
      description: 'Helps you stay focused and efficient',
      avatarIcon: '⚡',
      systemPrompt: 'You are a productivity expert helping users stay efficient.',
      apiKey: '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', // Replace with persona 2's API key
      apiUrl: 'https://chatgpt.com/g/g-67a778715bb48191b45ffcf3f4f4abe3-dr-dexter', // Replace with persona 2's API URL
    ),
    ChatPersona(
      id: 'mindfulness_guide',
      name: 'Mindfulness Guide',
      description: 'Helps you practice digital mindfulness',
      avatarIcon: '🎯',
      systemPrompt: 'You are a mindfulness guide helping users build awareness.',
      apiKey: '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', // Replace with persona 3's API key
      apiUrl: 'https://chatgpt.com/g/g-67a7766987a48191a6950c980bcc9701-yogi', // Replace with persona 3's API URL
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize OpenAI service with your API key


    // Initialize empty conversation lists for each persona
    for (var persona in personas) {
      _personaMessages[persona.id] = [
        ChatMessage(
          sender: 'bot',
          message: 'Hello! I\'m your ${persona.name}. ${persona.description}',
          timestamp: DateTime.now(),
        ),
      ];
    }
  }

  Future<void> _sendMessage(String message) async {
    if (_selectedPersonaId == null) return;

    // Get the currently selected persona
    final currentPersona = personas.firstWhere((p) => p.id == _selectedPersonaId);

    // Create OpenAIService using the persona's API key and URL
    final openAIService = OpenAIService(
      apiKey: currentPersona.apiKey,
      apiUrl: currentPersona.apiUrl,
    );

    setState(() {
      _personaMessages[_selectedPersonaId]!.add(ChatMessage(
        sender: 'user',
        message: message,
        timestamp: DateTime.now(),
      ));
    });

    // Fetch response from GPT
    final response = await openAIService.getCompletion(
      message,
      currentPersona.systemPrompt,
    );

    setState(() {
      _personaMessages[_selectedPersonaId]!.add(ChatMessage(
        sender: 'bot',
        message: response,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedPersonaId == null
            ? 'Choose Your Guide'
            : personas.firstWhere((p) => p.id == _selectedPersonaId).name
        ),
        actions: _selectedPersonaId != null ? [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => setState(() => _selectedPersonaId = null),
          ),
        ] : null,
      ),
      body: _selectedPersonaId == null
          ? _buildPersonaSelection()
          : _buildChat(),
    );
  }

  Widget _buildPersonaSelection() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: personas.length,
      itemBuilder: (context, index) {
        final persona = personas[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: DoomScrollApp.primary,
              child: Text(persona.avatarIcon),
            ),
            title: Text(
              persona.name,
              style: TextStyle(
                color: DoomScrollApp.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ), // Fixed: Properly closed the title Text widget here.
            subtitle: Text(
              persona.description,
              style: TextStyle(color: DoomScrollApp.textSecondary),
            ), // Added subtitle outside of the title Text widget.
            onTap: () => setState(() => _selectedPersonaId = persona.id),
          ),
        );
      },
    );
  }

  Widget _buildChat() {
    final messages = _personaMessages[_selectedPersonaId] ?? [];

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isBot = message.sender == 'bot';

              return Align(
                alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 8,
                    left: isBot ? 0 : 50,
                    right: isBot ? 50 : 0,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isBot ? DoomScrollApp.surface : DoomScrollApp.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: TextStyle(
                          color: isBot ? DoomScrollApp.textPrimary : Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: isBot ? DoomScrollApp.textSecondary : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DoomScrollApp.surface,
            border: Border(
              top: BorderSide(
                color: Colors.grey[800]!,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: DoomScrollApp.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: DoomScrollApp.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: DoomScrollApp.background,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: DoomScrollApp.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}