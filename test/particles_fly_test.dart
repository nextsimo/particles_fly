import 'package:flutter_test/flutter_test.dart';
import 'package:particles_fly/particles_fly.dart';

void main() {
  test('adds one to input values', () {
    const particles = ParticlesFly(
      height: 100,
      width: 100,
    );

    expect(particles.height, 100);
    expect(particles.width, 100);
  });
}
