import 'package:flutter/material.dart';
import 'package:particles_fly/particles_fly.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Particles Fly Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: ParticlesFly(
          height: size.height,
          width: size.width,
          connectDots: true,
          numberOfParticles: 100,
        ),
      ),
    );
  }
}
