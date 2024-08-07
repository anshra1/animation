import 'dart:math';

import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blueGrey,
          indicatorColor: Colors.blueGrey,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController counterClockwiseRotationController;
  late Animation<double> counterClockwiseRotationAnimation;

  late AnimationController flipController;
  late Animation<double> flipAnimation;

  @override
  void initState() {
    super.initState();
    counterClockwiseRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    counterClockwiseRotationAnimation = Tween<double>(
      begin: 0,
      end: -(pi / 2),
    ).animate(
      CurvedAnimation(
        parent: counterClockwiseRotationController,
        curve: Curves.bounceOut,
      ),
    );

    // flip animation
    flipController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 3,
      ),
    );

    flipAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(
      CurvedAnimation(
        parent: flipController,
        curve: Curves.bounceOut,
      ),
    );

    // status listener

    counterClockwiseRotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        flipAnimation = Tween<double>(
          begin: flipAnimation.value,
          end: flipAnimation.value + pi,
        ).animate(
          CurvedAnimation(
            parent: flipController,
            curve: Curves.bounceOut,
          ),
        );

        // reset the flip controller and start the animation

        flipController
          ..reset()
          ..forward();
      }
    });

    flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        counterClockwiseRotationAnimation = Tween<double>(
          begin: counterClockwiseRotationAnimation.value,
          end: counterClockwiseRotationAnimation.value + (-(pi / 2)),
        ).animate(
          CurvedAnimation(
            parent: counterClockwiseRotationController,
            curve: Curves.bounceOut,
          ),
        );

        counterClockwiseRotationController
          ..reset()
          ..forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    counterClockwiseRotationController
      ..reset()
      ..forward.deley(const Duration(seconds: 1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: counterClockwiseRotationAnimation,
          builder: (BuildContext context, Widget? child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(counterClockwiseRotationAnimation.value),
              child: FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: flipController,
                      builder: (BuildContext context, Widget? child) {
                        return Transform(
                          alignment: Alignment.centerRight,
                          transform: Matrix4.identity()
                            ..rotateY(flipAnimation.value),
                          child: ClipPath(
                            clipper: const HalfCircleClipper(CircleSide.left),
                            child: Container(
                              height: 200,
                              width: 200,
                              color: const Color(0xff0057b7),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: flipAnimation,
                      builder: (BuildContext context, Widget? child) {
                        return Transform(
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.identity()
                            ..rotateY(flipAnimation.value),
                          child: ClipPath(
                            clipper: const HalfCircleClipper(CircleSide.right),
                            child: Container(
                              height: 200,
                              width: 200,
                              color: const Color(0xffffd700),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  const HalfCircleClipper(this.side);

  final CircleSide side;

  @override
  Path getClip(Size size) => side.toPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

enum CircleSide {
  left,
  right,
}

extension ToPath on CircleSide {
  Path toPath(Size size) {
    final path = Path();
    late Offset offset;
    late bool clockwise;

    switch (this) {
      case CircleSide.left:
        path.moveTo(size.width, 0);
        offset = Offset(size.width, size.height);
        clockwise = false;
        break;
      case CircleSide.right:
        offset = Offset(0, size.height);
        clockwise = true;
        break;
    }

    path.arcToPoint(
      offset,
      radius: Radius.elliptical(size.width / 2, size.height / 2),
      clockwise: clockwise,
    );

    path.close();
    return path;
  }
}

extension on VoidCallback {
  void deley(Duration duration) {
    Future.delayed(duration, this);
  }
}
