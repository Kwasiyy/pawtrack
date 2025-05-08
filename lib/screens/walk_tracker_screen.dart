// lib/screens/walk_tracker_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/walk_service.dart';
import '../models/walk.dart';

class WalkTrackerScreen extends StatefulWidget {
  final String petId;

  const WalkTrackerScreen({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  State<WalkTrackerScreen> createState() => _WalkTrackerScreenState();
}

class _WalkTrackerScreenState extends State<WalkTrackerScreen> {
  final _walkService = WalkService();
  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;
  double _totalDistance = 0;
  late DateTime _startTime;
  Duration _duration = Duration.zero;
  Timer? _timer;
  final List<WalkCoordinate> _coords = [];
  bool _isTracking = false;

  Future<bool> _ensurePermissions() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
      }
      return false;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services disabled')),
        );
      }
      return false;
    }

    return true;
  }

  void _startTracking() async {
    if (!await _ensurePermissions()) return;

    setState(() {
      _isTracking = true;
      _totalDistance = 0;
      _coords.clear();
      _lastPosition = null;
      _startTime = DateTime.now();
      _duration = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _duration = DateTime.now().difference(_startTime);
      });
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen((pos) {
      if (_lastPosition != null) {
        final delta = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          pos.latitude,
          pos.longitude,
        );
        setState(() {
          _totalDistance += delta;
        });
      }
      _lastPosition = pos;
      _coords.add(WalkCoordinate(
        latitude: pos.latitude,
        longitude: pos.longitude,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _stopTracking() async {
    _positionStream?.cancel();
    _timer?.cancel();
    setState(() {
      _isTracking = false;
    });

    final walk = Walk(
      id: null,
      petId: widget.petId,
      distance: _totalDistance,
      durationSeconds: _duration.inSeconds,
      coordinates: List.from(_coords),
      startTime: _startTime,
      endTime: DateTime.now(),
    );

    final success = await _walkService.saveWalk(walk);
    final message = success ? 'Walk saved successfully' : 'Failed to save walk';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formatDuration(Duration d) {
      String two(int n) => n.toString().padLeft(2, '0');
      final hh = two(d.inHours);
      final mm = two(d.inMinutes.remainder(60));
      final ss = two(d.inSeconds.remainder(60));
      return '$hh:$mm:$ss';
    }

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Your Walk'),
        actions: [
          if (_isTracking)
            IconButton(
              icon: const Icon(Icons.stop_circle),
              onPressed: _stopTracking,
              tooltip: 'End Walk',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stats Panel
            Container(
              padding: const EdgeInsets.all(24.0),
              color: cs.surfaceVariant,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Distance
                      Column(
                        children: [
                          const Icon(Icons.straighten, size: 24),
                          const SizedBox(height: 8),
                          Text(
                            '${_totalDistance.toStringAsFixed(0)} m',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text('Distance', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      // Duration
                      Column(
                        children: [
                          const Icon(Icons.timer, size: 24),
                          const SizedBox(height: 8),
                          Text(
                            formatDuration(_duration),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text('Duration', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      // Speed
                      if (_isTracking)
                        Column(
                          children: [
                            const Icon(Icons.speed, size: 24),
                            const SizedBox(height: 8),
                            Text(
                              _duration.inSeconds > 0
                                  ? '${(_totalDistance / (_duration.inSeconds / 3600)).toStringAsFixed(0)} m/h'
                                  : '0.0 km/h',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text('Speed', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Start/Stop Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  if (!_isTracking)
                    Text(
                      'Ready to start your walk?',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isTracking ? _stopTracking : _startTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTracking ? Colors.red : cs.primary,
                        foregroundColor: _isTracking ? Colors.white : cs.onPrimary,
                      ),
                      icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                      label: Text(
                        _isTracking ? 'End Walk' : 'Start Walking',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  if (_isTracking)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Tap to end your walk',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
