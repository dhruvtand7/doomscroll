import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/animation.dart';

void main() {
  runApp(DoomScrollApp());
}

class DoomScrollApp extends StatelessWidget {
  // Define custom colors
  static const inox = Color(0xFFEAEAEA);
  static const cinza = Color(0xFF121212);
  static const chumbo = Color(0xFF121212);
  static const preto = Color(0xFF121212);
  static const pretoEscuro = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoomScroll',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF75706F, {
          50: inox,
          100: cinza,
          200: cinza,
          300: chumbo,
          400: chumbo,
          500: chumbo,
          600: preto,
          700: preto,
          800: pretoEscuro,
          900: pretoEscuro,
        }),
        scaffoldBackgroundColor: inox,
        appBarTheme: AppBarTheme(
          backgroundColor: chumbo,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: chumbo,
            foregroundColor: inox,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: DoomScrollApp.cinza.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: DoomScrollApp.chumbo,
          unselectedItemColor: DoomScrollApp.cinza,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Tracker',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer),
              label: 'Detox',
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
        title: Text('DoomScroll', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to DoomScroll!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: DoomScrollApp.preto,
              ),
            ),
            SizedBox(height: 40),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScrollTrackerPage()),
                ),
                child: Text('Start Tracking', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DopamineDetoxPage()),
                ),
                child: Text('Start Dopamine Detox', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
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
        title: Text('Scroll Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Native Scroll Count',
                      style: TextStyle(
                        fontSize: 18,
                        color: DoomScrollApp.chumbo,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$nativeScrollCount',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: DoomScrollApp.preto,
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
                color: _isInstagramRunning ? DoomScrollApp.cinza : DoomScrollApp.inox,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_android,
                    color: _isInstagramRunning ? DoomScrollApp.chumbo : DoomScrollApp.cinza,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _isInstagramRunning ? "Instagram is running" : "Instagram is not running",
                    style: TextStyle(
                      fontSize: 16,
                      color: _isInstagramRunning ? DoomScrollApp.chumbo : DoomScrollApp.cinza,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressiveVisualizerPage(scrollCount: nativeScrollCount),
                  ),
                ),
                child: Text('View Progress', style: TextStyle(fontSize: 16)),
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
                color: DoomScrollApp.pretoEscuro,
                child: Center(
                  child: Text(
                    "${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}",
                    style: TextStyle(
                      fontSize: 48,
                      color: DoomScrollApp.inox,
                      fontWeight: FontWeight.bold,
                    ),
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
                IconButton(
                  icon: Icon(Icons.favorite_border, size: 40, color: DoomScrollApp.inox),
                  onPressed: () {},
                ),
                SizedBox(height: 16),
                IconButton(
                  icon: Icon(Icons.comment, size: 40, color: DoomScrollApp.inox),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class ProgressiveVisualizerPage extends StatelessWidget {
  final int scrollCount;

  ProgressiveVisualizerPage({required this.scrollCount});

  final List<Map<String, dynamic>> creatures = [
    {'name': 'Mouse', 'size': 6, 'clipart': 'assets/images/mouse.png'},
    {'name': 'Cat', 'size': 10, 'clipart': 'assets/images/cat.jpg'},
    {'name': 'Rabbit', 'size': 20, 'clipart': 'assets/images/rabbit.png'},
    {'name': 'Dog', 'size': 40, 'clipart': 'assets/images/dog.png'},
    {'name': 'Human', 'size': 70, 'clipart': 'assets/images/human.png'},
    {'name': 'Horse', 'size': 96, 'clipart': 'assets/images/horse.png'},
    {'name': 'Giraffe', 'size': 216, 'clipart': 'assets/images/giraffe.png'},
    {'name': 'T-Rex', 'size': 600, 'clipart': 'assets/images/trex.png'},
    {'name': 'Mammoth', 'size': 2500, 'clipart': 'assets/images/mammoth.png'},
    {'name': 'Dragon', 'size': 5000, 'clipart': 'assets/images/dragon.png'},
    {'name': 'Phoenix', 'size': 7000, 'clipart': 'assets/images/phoenix.png'},
    {'name': 'Kraken', 'size': 10000, 'clipart': 'assets/images/kraken.png'},
    {
      'name': 'Giant Squid',
      'size': 11000,
      'clipart': 'assets/images/giant_squid.png'
    },
    {'name': 'Unicorn', 'size': 15000, 'clipart': 'assets/images/unicorn.png'},
    {'name': 'Hydra', 'size': 20000, 'clipart': 'assets/images/hydra.png'},
    {
      'name': 'Godzilla',
      'size': 25000,
      'clipart': 'assets/images/godzilla.png'
    },
    {
      'name': 'Blue Whale',
      'size': 36000,
      'clipart': 'assets/images/blue_whale.png'
    },
    {
      'name': 'Skyscraper',
      'size': 100000,
      'clipart': 'assets/images/skyscraper.png'
    }, // Largest for reference
  ];

  @override
  Widget build(BuildContext context) {
    double totalDistanceInches = scrollCount * 6.0;
    double totalDistanceFeet = totalDistanceInches / 12.0;
    int unlockedIndex = creatures.indexWhere((creature) =>
    totalDistanceInches < creature['size'] * 12.0);
    if (unlockedIndex == -1) unlockedIndex = creatures.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Visualizer',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          SizedBox(height: 24),
          Text(
            'Reels Scrolled: $scrollCount',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DoomScrollApp.preto,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Distance Scrolled: ${totalDistanceFeet.toStringAsFixed(1)} ft',
            style: TextStyle(fontSize: 18, color: DoomScrollApp.chumbo),
          ),
          SizedBox(height: 32),
          Expanded(
            child: PageView.builder(
              itemCount: creatures.length,
              controller: PageController(initialPage: unlockedIndex),
              itemBuilder: (context, index) {
                bool isUnlocked = index <= unlockedIndex;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        creatures[index]['clipart'],
                        height: 100,
                        width: 100,

                        fit: BoxFit.cover,
                      ),
                      Text(
                        creatures[index]['name'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? DoomScrollApp.preto
                              : DoomScrollApp.cinza,
                        ),
                      ),
                    ],
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
