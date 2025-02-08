import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For MethodChannel and EventChannel

void main() {
  runApp(DoomScrollApp());
}

class DoomScrollApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoomScroll',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DoomScroll')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to DoomScroll!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScrollTrackerPage()),
                );
              },
              child: Text('Start Tracking'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DopamineDetoxPage()),
                );
              },
              child: Text('Start Dopamine Detox'),
            ),
          ],
        ),
      ),
    );
  }
}

// Scroll Tracker Page
class ScrollTrackerPage extends StatefulWidget {
  @override
  _ScrollTrackerPageState createState() => _ScrollTrackerPageState();
}

class _ScrollTrackerPageState extends State<ScrollTrackerPage> {
  int nativeScrollCount = 0;
  bool _isInstagramRunning = false;

  // MethodChannel for permission and state checks.
  static final MethodChannel platform = MethodChannel('doomscroll/foreground_app');
  // EventChannel for receiving native scroll count updates.
  static final EventChannel scrollCountChannel = EventChannel('doomscroll/scroll_count');

  @override
  void initState() {
    super.initState();
    _checkIfInstagramIsRunning();
    _requestAccessibilityPermission();

    // Listen for native scroll count updates from the Android side.
    scrollCountChannel.receiveBroadcastStream().listen((event) {
      setState(() {
        nativeScrollCount = event as int;
      });
    }, onError: (error) {
      print("Error receiving scroll count: $error");
    });
  }

  Future<void> _checkIfInstagramIsRunning() async {
    try {
      final bool isRunning = await platform.invokeMethod('isInstagramRunning');
      setState(() {
        _isInstagramRunning = isRunning;
      });
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
      appBar: AppBar(title: Text('Scroll Length Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Native Scroll Count: $nativeScrollCount',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              _isInstagramRunning ? "Instagram is running" : "Instagram is not running",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressiveVisualizerPage(scrollCount: nativeScrollCount),
                  ),
                );
              },
              child: Text('View Progress'),
            ),
          ],
        ),
      ),
    );
  }
}

// Dopamine Detox Page
class DopamineDetoxPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dopamine Detox')),
      body: Center(
        child: Text('Dopamine Detox Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// Progressive Visualizer Page
class ProgressiveVisualizerPage extends StatelessWidget {
  final int scrollCount;

  ProgressiveVisualizerPage({required this.scrollCount});

  final List<Map<String, dynamic>> creatures = [
    {'name': 'Mouse', 'size': 6, 'clipart': Icons.mouse}, // Size in inches
    {'name': 'Rat', 'size': 10, 'clipart': Icons.pets},
    {'name': 'Rabbit', 'size': 20, 'clipart': Icons.grass},
    {'name': 'Dog', 'size': 40, 'clipart': Icons.directions_walk},
    {'name': 'Horse', 'size': 96, 'clipart': Icons.fence},
    {'name': 'Giraffe', 'size': 216, 'clipart': Icons.emoji_nature},
    {'name': 'T-Rex', 'size': 600, 'clipart': Icons.forest},
    {'name': 'Blue Whale', 'size': 1200, 'clipart': Icons.water},
    {'name': 'Skyscraper', 'size': 3600, 'clipart': Icons.location_city},
  ];

  @override
  Widget build(BuildContext context) {
    double totalDistanceInches = scrollCount * 6.0; // Ensure double
    double totalDistanceFeet = totalDistanceInches / 12.0; // Convert to double

    Map<String, dynamic> currentCreature = creatures[0];
    Map<String, dynamic>? nextCreature;
    double progressToNext = 0.0;

    // Determine current creature and progress to next
    for (int i = 0; i < creatures.length; i++) {
      double currentSizeInInches = creatures[i]['size'] * 12.0; // Ensure double

      if (totalDistanceInches < currentSizeInInches) {
        currentCreature = creatures[i];
        if (i + 1 < creatures.length) {
          nextCreature = creatures[i + 1];
          double nextSizeInInches = nextCreature['size'] * 12.0; // Ensure double

          progressToNext = (totalDistanceInches - currentSizeInInches) /
              (nextSizeInInches - currentSizeInInches);
        }
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Scroll Visualizer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Reels Scrolled: $scrollCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Distance Scrolled: ${totalDistanceFeet.toStringAsFixed(1)} ft', style: TextStyle(fontSize: 20)),
            SizedBox(height: 30),
            Column(
              children: [
                Icon(currentCreature['clipart'], size: 100, color: Colors.blue),
                SizedBox(height: 10),
                Text(currentCreature['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 20),
            if (nextCreature != null)
              Column(
                children: [
                  Text('${(progressToNext * 100).toStringAsFixed(1)}% unlocked', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
