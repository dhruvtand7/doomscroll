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

// Scroll Tracker Page: Displays the native scroll count sent via the EventChannel.
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
          ],
        ),
      ),
    );
  }
}

// A simple Dopamine Detox Page.
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