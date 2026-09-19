import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MiniCricketApp());
}

class MiniCricketApp extends StatelessWidget {
  const MiniCricketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Cricket',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1E88E5),
        debugShowCheckedModeBanner: false,
      ),
      home: const CricketHomePage(),
    );
  }
}

class CricketHomePage extends StatefulWidget {
  const CricketHomePage({super.key});

  @override
  State<CricketHomePage> createState() => _CricketHomePageState();
}

class _CricketHomePageState extends State<CricketHomePage>
    with SingleTickerProviderStateMixin {
  int runs = 0;
  int balls = 6;
  String lastBallText = '';
  bool isPlaying = false;

  final Random random = Random();
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> playBall() async {
    if (balls == 0 || isPlaying) return;

    setState(() {
      isPlaying = true;
      lastBallText = '';
    });

    await _controller.forward(from: 0); // ball animation

    if (!mounted) return;

    int scored = random.nextInt(7); // 0 to 6

    setState(() {
      runs += scored;
      balls -= 1;
      lastBallText = scored == 0 ? 'No Runs' : '$scored Runs';
      isPlaying = false;
    });
  }

  void restart() {
    setState(() {
      runs = 0;
      balls = 6;
      lastBallText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOver = balls == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Cricket'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCard(
                    imagePath: 'assets/images/bat.png',
                    fallbackIcon: Icons.sports_cricket,
                    label: 'Runs',
                    value: runs,
                  ),
                  _statCard(
                    imagePath: 'assets/images/ball.png',
                    fallbackIcon: Icons.sports_baseball,
                    label: 'Balls',
                    value: balls,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                lastBallText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _ballLane(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOver ? Colors.red : const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isOver ? restart : playBall,
                child: Text(
                  isOver ? 'Restart' : 'Bat',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // The area where the ball falls towards the Bat button
  Widget _ballLane() {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              if (isPlaying)
                Positioned(
                  top: Curves.easeIn.transform(_controller.value) * 105,
                  child: Transform.rotate(
                    angle: _controller.value * 4 * pi,
                    child: _smallBall(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _smallBall() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Image.asset(
        'assets/images/ball.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.sports_baseball, size: 40, color: Colors.white),
      ),
    );
  }

  Widget _statCard({
    required String imagePath,
    required IconData fallbackIcon,
    required String label,
    required int value,
  }) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Icon(fallbackIcon, size: 60, color: const Color(0xFF0D47A1)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}