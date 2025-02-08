import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for MethodChannel

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

// Scroll Tracker Page
class ScrollTrackerPage extends StatefulWidget {
  @override
  _ScrollTrackerPageState createState() => _ScrollTrackerPageState();
}

class _ScrollTrackerPageState extends State<ScrollTrackerPage> {
  int upSwipeCount = 0;
  double _startPosition = 0.0;
  bool _isSwipe = false;
  bool _isInstagramRunning = false;

  static final platform = MethodChannel('doomscroll/foreground_app');

  @override
  void initState() {
    super.initState();
    _requestAccessibilityPermission();
    _checkIfInstagramIsRunning();
  }

  Future<void> _requestAccessibilityPermission() async {
    try {
      await platform.invokeMethod('requestAccessibilityPermission');
    } on PlatformException catch (e) {
      print("Failed to request accessibility permission: '${e.message}'.");
    }
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

  void _onVerticalDragStart(DragStartDetails details) {
    _startPosition = details.localPosition.dy;
    _isSwipe = false;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if ((_startPosition - details.localPosition.dy).abs() > 10) {
      _isSwipe = true;
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isSwipe) {
      double delta = _startPosition - (details.primaryVelocity ?? 0.0);
      if (delta > 100) {
        setState(() {
          upSwipeCount++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scroll Length Tracker')),
      body: GestureDetector(
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Swipe Count: $upSwipeCount', style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              Text(
                _isInstagramRunning ? "Instagram is running" : "Instagram is not running",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
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
      body: Center(child: Text('Dopamine Detox Page')),
    );
  }
}
