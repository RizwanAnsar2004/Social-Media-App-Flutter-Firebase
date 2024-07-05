import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moneyup/main.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _mController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _mSlideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _mFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _mController = AnimationController(
      duration:
          const Duration(milliseconds: 500), // Reduced duration to 0.5 seconds
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _mSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _mController,
      curve: Curves.easeIn, // Adjust the curve for motion coming in
      reverseCurve:
          Curves.fastOutSlowIn, // Adjust the reverse curve for motion going out
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _mFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_mController);

    _controller.forward();
    _mController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      _controller.reverse();
      _mController.reverse();
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _mController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black, // Set the background color if needed
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Arrow
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  final slideAnimation =
                      _controller.status == AnimationStatus.reverse
                          ? Tween<Offset>(
                              begin: const Offset(0.0, -0.2),
                              end: const Offset(0.0, 0.0),
                            ).animate(_controller)
                          : _slideAnimation;
                  return SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SvgPicture.asset(
                        'assets/arrow.svg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              // Letter M
              AnimatedBuilder(
                animation: _mController,
                builder: (BuildContext context, Widget? child) {
                  return SlideTransition(
                    position: _mSlideAnimation,
                    child: FadeTransition(
                      opacity: _mFadeAnimation,
                      child: SvgPicture.asset(
                        'assets/letterM.svg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
