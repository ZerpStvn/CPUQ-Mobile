import 'dart:async';
import 'package:cpuq/utils/global_theme.dart';
import 'package:cpuq/view/homepge.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimationLogo;

  // Typewriter animation variables
  String _centralText = '';
  String _philippineText = '';
  String _universityText = '';

  final String _centralFull = 'Central';
  final String _philippineFull = 'Philippine';
  final String _universityFull = 'University';

  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimationLogo =
        Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();

    // Start typewriter animation after initial fade
    Future.delayed(const Duration(milliseconds: 800), () {
      _startTypewriterAnimation();
    });

    // Navigate to home after delay
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  void _startTypewriterAnimation() {
    int totalIndex = 0;
    const typingSpeed = Duration(milliseconds: 80);

    _typewriterTimer = Timer.periodic(typingSpeed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (totalIndex < _centralFull.length) {
          // Typing "Central"
          _centralText = _centralFull.substring(0, totalIndex + 1);
        } else if (totalIndex < _centralFull.length + _philippineFull.length) {
          // Typing "Philippine"
          int philippineIndex = totalIndex - _centralFull.length;
          _philippineText = _philippineFull.substring(0, philippineIndex + 1);
        } else if (totalIndex <
            _centralFull.length +
                _philippineFull.length +
                _universityFull.length) {
          // Typing "University"
          int universityIndex =
              totalIndex - _centralFull.length - _philippineFull.length;
          _universityText = _universityFull.substring(0, universityIndex + 1);
        } else {
          timer.cancel();
        }
      });

      totalIndex++;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Section
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/png/cpu_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.school,
                        size: 60,
                        color: primaryColor,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Vertical Divider
              Container(
                height: 140,
                width: 2,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: secondaryColor.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Text Section with Typewriter Effect
              SizedBox(
                width: 160,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Central
                    SizedBox(
                      height: 36,
                      child: Text(
                        _centralText,
                        style: const TextStyle(
                          color: neutralWhite,
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                          height: 1.2,
                        ),
                      ),
                    ),
                    // Philippine
                    SizedBox(
                      height: 36,
                      child: Text(
                        _philippineText,
                        style: const TextStyle(
                          color: neutralWhite,
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                          height: 1.2,
                        ),
                      ),
                    ),
                    // University
                    SizedBox(
                      height: 36,
                      child: Text(
                        _universityText,
                        style: const TextStyle(
                          color: secondaryColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
