library particles_fly;

import 'dart:math';
import 'package:flutter/material.dart';

class ParticlesFly extends StatefulWidget {
  /// A Flutter package to create a particle animation like the one on the website https://vincentgarreau.com/particles.js/
  const ParticlesFly({
    Key? key,
    required this.height,
    required this.width,
    this.lineStrokeWidth = 0.5,
    this.onTapAnimation = true,
    this.numberOfParticles = 400,
    this.speedOfParticles = 2,
    this.awayRadius = 200,
    this.isRandomColor = false,
    this.particleColor = Colors.purple,
    this.awayAnimationDuration = const Duration(milliseconds: 100),
    this.maxParticleSize = 4,
    this.isRandSize = false,
    this.randColorList = const [
      Colors.orange,
      Colors.blue,
      Colors.teal,
      Colors.red,
      Colors.purple,
    ],
    this.awayAnimationCurve = Curves.easeIn,
    this.enableHover = false,
    this.hoverColor = Colors.orangeAccent,
    this.hoverRadius = 80,
    this.connectDots = false,
    this.lineColor = const Color.fromARGB(90, 155, 39, 176),
  }) : super(key: key);

  /// The radius of the circle from which the particles move away when the mouse is hovered over them
  final double awayRadius;

  /// The height of the widget
  final double height;

  /// The width of the widget
  final double width;

  /// If true, the particles will move away from the mouse when hovered over or tapped
  final bool onTapAnimation;

  /// The number of particles to be displayed
  final double numberOfParticles;

  /// The speed of the particles
  final double speedOfParticles;

  /// If true, the particles will have random colors
  final bool isRandomColor;

  /// The color of the particles
  final Color particleColor;

  /// The duration of the animation when the particles move away from the mouse
  final Duration awayAnimationDuration;

  /// The curve of the animation when the particles move away from the mouse
  final Curve awayAnimationCurve;

  /// The maximum size of the particles
  final double maxParticleSize;

  /// If true, the particles will have random sizes
  final bool isRandSize;

  /// The list of colors from which the particles will have random colors
  final List<Color> randColorList;

  /// If true, the particles will have a hover effect
  final bool enableHover;

  /// The color of the particles when hovered over
  final Color hoverColor;

  /// The radius of the circle from which the particles move away when the mouse is hovered over them
  final double hoverRadius;

  /// If true, the particles will be connected by lines
  final bool connectDots;

  /// The color of the lines
  final Color lineColor;

  /// The width of the lines
  final double lineStrokeWidth;

  @override
  ParticlesFlyState createState() => ParticlesFlyState();
}

class ParticlesFlyState extends State<ParticlesFly>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  late AnimationController awayAnimationController;
  late double dx;
  late double dy;
  List<Offset> offsets = [];
  List<bool> randDirection = [];
  double speedOfParticle = 0;
  var rng = Random();
  double randValue = 0;
  List<double> randomDouble = [];
  List<double> randomSize = [];
  List<int> hoverIndex = [];
  List<List> lineOffset = [];

  /// This function initializes the offsets of the particles
  void initializeOffsets(_) {
    for (int index = 0; index < widget.numberOfParticles; index++) {
      offsets.add(Offset(
          rng.nextDouble() * widget.width, rng.nextDouble() * widget.height));
      randomDouble.add(rng.nextDouble());
      randDirection.add(rng.nextBool());
      randomSize.add(rng.nextDouble());
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(initializeOffsets);
    controller =
        AnimationController(duration: const Duration(seconds: 10), vsync: this);
    animation = Tween<double>(begin: 0, end: 1).animate(controller)
      ..addListener(_myListener);
    controller.repeat();
    //changeDirection();
    super.initState();
  }

  /// This function is called every time the animation is updated
  void _myListener() {
    setState(
      () {
        speedOfParticle = widget.speedOfParticles;
        for (int index = 0; index < offsets.length; index++) {
          if (randDirection[index]) {
            randValue = -speedOfParticle;
          } else {
            randValue = speedOfParticle;
          }
          dx = offsets[index].dx + (randValue * randomDouble[index]);
          dy = offsets[index].dy + randomDouble[index] * speedOfParticle;
          if (dx > widget.width) {
            dx = dx - widget.width;
          } else if (dx < 0) {
            dx = dx + widget.width;
          }
          if (dy > widget.height) {
            dy = dy - widget.height;
          } else if (dy < 0) {
            dy = dy + widget.height;
          }
          offsets[index] = Offset(dx, dy);
        }
        if (widget.connectDots) connectLines(); //not recommended
      },
    );
  }

  @override
  void dispose() {
    animation.removeListener(_myListener);
    controller.dispose();
    super.dispose();
  }

  /// This function is called when the widget is built
  void changeDirection() async {
    Future.doWhile(
      () async {
        await Future.delayed(const Duration(milliseconds: 1000));
        for (int index = 0; index < widget.numberOfParticles; index++) {
          randDirection[index] = (rng.nextBool());
        }
        return true;
      },
    );
  }

  /// THis function help to connect the dots
  void connectLines() {
    lineOffset = [];
    double distanceBetween = 0;
    for (int point1 = 0; point1 < offsets.length; point1++) {
      for (int point2 = 0; point2 < offsets.length; point2++) {
        //    if(offsets)
        distanceBetween = sqrt(
            pow((offsets[point2].dx - offsets[point1].dx), 2) +
                pow((offsets[point2].dy - offsets[point1].dy), 2));
        if (distanceBetween < 150) {
          lineOffset.add([offsets[point1], offsets[point2], distanceBetween]);
        }
      }
    }
  }

  /// This function is called when the mouse is hovered over the widget
  void onTapGesture(double tapDx, double tapDy) {
    awayAnimationController = AnimationController(
        duration: widget.awayAnimationDuration, vsync: this);
    awayAnimationController.reset();
    double directionDx;
    double directionDy;
    List<double> distance = [];
    double noAnimationDistance = 0;

    if (widget.onTapAnimation) {
      List<Animation<Offset>> awayAnimation = [];
      awayAnimationController.forward();
      for (int index = 0; index < offsets.length; index++) {
        distance.add(sqrt(
            ((tapDx - offsets[index].dx) * (tapDx - offsets[index].dx)) +
                ((tapDy - offsets[index].dy) * (tapDy - offsets[index].dy))));
        directionDx = (tapDx - offsets[index].dx) / distance[index];
        directionDy = (tapDy - offsets[index].dy) / distance[index];
        Offset begin = offsets[index];
        awayAnimation.add(
          Tween<Offset>(
                  begin: begin,
                  end: Offset(
                    offsets[index].dx -
                        (widget.awayRadius - distance[index]) * directionDx,
                    offsets[index].dy -
                        (widget.awayRadius - distance[index]) * directionDy,
                  ))
              .animate(CurvedAnimation(
                  parent: awayAnimationController,
                  curve: widget.awayAnimationCurve))
            ..addListener(
              () {
                if (distance[index] < widget.awayRadius) {
                  setState(() => offsets[index] = awayAnimation[index].value);
                }
                if (awayAnimationController.isCompleted &&
                    index == offsets.length - 1) {
                  awayAnimationController.dispose();
                }
              },
            ),
        );
      }
    } else {
      for (int index = 0; index < offsets.length; index++) {
        noAnimationDistance = sqrt(
            ((tapDx - offsets[index].dx) * (tapDx - offsets[index].dx)) +
                ((tapDy - offsets[index].dy) * (tapDy - offsets[index].dy)));
        directionDx = (tapDx - offsets[index].dx) / noAnimationDistance;
        directionDy = (tapDy - offsets[index].dy) / noAnimationDistance;
        if (noAnimationDistance < widget.awayRadius) {
          setState(() {
            offsets[index] = Offset(
              offsets[index].dx -
                  (widget.awayRadius - noAnimationDistance) * directionDx,
              offsets[index].dy -
                  (widget.awayRadius - noAnimationDistance) * directionDy,
            );
          });
        }
      }
    }
  }

  /// called when the mouse is hovered over the widget
  void onHover(tapDx, tapDy) {
    {
      awayAnimationController = AnimationController(
          duration: widget.awayAnimationDuration, vsync: this);
      awayAnimationController.reset();

      double noAnimationDistance = 0;
      for (int index = 0; index < offsets.length; index++) {
        noAnimationDistance = sqrt(
            ((tapDx - offsets[index].dx) * (tapDx - offsets[index].dx)) +
                ((tapDy - offsets[index].dy) * (tapDy - offsets[index].dy)));

        if (noAnimationDistance < widget.hoverRadius) {
          setState(() {
            if (hoverIndex.length >
                (widget.numberOfParticles * 0.1).floor() + 1) {
              hoverIndex.removeAt(0);
            }
            hoverIndex.add(index);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        RenderBox getBox = context.findRenderObject() as RenderBox;
        onTapGesture(getBox.globalToLocal(details.globalPosition).dx,
            getBox.globalToLocal(details.globalPosition).dy);
      },
      onPanUpdate: (DragUpdateDetails details) {
        if (widget.enableHover) {
          RenderBox getBox = context.findRenderObject() as RenderBox;
          onHover(getBox.globalToLocal(details.globalPosition).dx,
              getBox.globalToLocal(details.globalPosition).dy);
        }
      },
      onPanEnd: (DragEndDetails details) {
        hoverIndex = [];
      },
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: CustomPaint(
          painter: _ParticlePainter(
              offsets: offsets,
              isRandomColor: widget.isRandomColor,
              particleColor: widget.particleColor,
              maxParticleSize: widget.maxParticleSize,
              randSize: randomSize,
              isRandSize: widget.isRandSize,
              randColorList: widget.randColorList,
              hoverIndex: hoverIndex,
              enableHover: widget.enableHover,
              hoverColor: widget.hoverColor,
              lineColor: widget.lineColor,
              lineStrokeWidth: widget.lineStrokeWidth,
              lineOffsets: lineOffset),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Offset> offsets;
  final bool isRandomColor;
  final Color particleColor;
  final Paint constColorPaint;
  final double maxParticleSize;
  static Color randomColor = Colors.blue;
  static Paint? randomColorPaint;
  final Paint hoverPaint;
  final List<double> randSize;
  final bool isRandSize;
  final List<Color> randColorList;
  final List<int> hoverIndex;
  final bool enableHover;
  final Color hoverColor;
  final List<List> lineOffsets;
  final Color lineColor;
  final double lineStrokeWidth;

  _ParticlePainter({
    required this.enableHover,
    required this.randColorList,
    required this.isRandSize,
    required this.maxParticleSize,
    required this.offsets,
    required this.isRandomColor,
    required this.particleColor,
    required this.randSize,
    required this.hoverIndex,
    required this.hoverColor,
    required this.lineOffsets,
    required this.lineColor,
    required this.lineStrokeWidth,
  })  : constColorPaint = Paint()..color = particleColor,
        hoverPaint = Paint()..color = hoverColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (int index = 0; index < offsets.length; index++) {
      if (isRandomColor) {
        randomColor = randColorList[index % randColorList.length];

        randomColorPaint = Paint()..color = randomColor;
        canvas.drawCircle(
            offsets[index],
            isRandSize ? maxParticleSize * (randSize[index]) : maxParticleSize,
            hoverIndex.contains(index) ? hoverPaint : randomColorPaint!);
      } else {
        randomColorPaint = Paint()..color = randomColor;
        canvas.drawCircle(
            offsets[index],
            isRandSize ? maxParticleSize * (randSize[index]) : maxParticleSize,
            hoverIndex.contains(index) ? hoverPaint : constColorPaint);
      }
    }
    for (var item in lineOffsets) {
      randomColorPaint = Paint()
        ..color = lineColor
        ..strokeWidth = (lineStrokeWidth * (1 - item[2] / 50)).toDouble();
      canvas.drawLine(item[0], item[1], randomColorPaint!);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
