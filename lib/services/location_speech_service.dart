import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

// =============================================================================
// LOCATION SERVICE
// No API key needed — uses device GPS via geolocator package
// =============================================================================
class LocationService {
  static Position? _lastPosition;
  static StreamSubscription<Position>? _positionStream;
  static final List<void Function(Position)> _listeners = [];

  /// Returns current GPS position. Requests permission if needed.
  static Future<Position?> getCurrentPosition() async {
    try {
      final permission = await _ensurePermission();
      if (!permission) return null;
      _lastPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return _lastPosition;
    } catch (e) {
      debugPrint('LocationService.getCurrentPosition error: $e');
      return null;
    }
  }

  /// Starts streaming live location updates every 5 seconds
  static Future<bool> startLiveTracking(void Function(Position) onUpdate) async {
    final permission = await _ensurePermission();
    if (!permission) return false;

    _listeners.add(onUpdate);

    // Only create one stream regardless of how many listeners
    if (_positionStream == null) {
      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // update every 10 metres
      );
      _positionStream = Geolocator.getPositionStream(locationSettings: settings)
          .listen((pos) {
        _lastPosition = pos;
        for (final l in _listeners) {
          l(pos);
        }
      });
    }
    return true;
  }

  /// Stop live tracking
  static void stopLiveTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _listeners.clear();
  }

  /// Remove a single listener without stopping the stream
  static void removeListener(void Function(Position) listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) stopLiveTracking();
  }

  static Position? get lastPosition => _lastPosition;

  /// Formats a Position as a readable string
  static String formatPosition(Position pos) {
    final lat = pos.latitude.toStringAsFixed(5);
    final lng = pos.longitude.toStringAsFixed(5);
    return '$lat, $lng';
  }

  /// Returns a Google Maps URL for a position
  static String mapsUrl(Position pos) =>
      'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';

  // ── Permission helper ──────────────────────────────────────────────────────
  static Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }
}

// =============================================================================
// SPEECH SERVICE
// No API key needed — uses on-device speech recognition
// Works offline on Android (limited) and online for better accuracy
// =============================================================================
class SpeechService {
  static final SpeechToText _speech = SpeechToText();
  static bool _initialized = false;
  static bool _isListening = false;

  static bool get isListening => _isListening;

  /// Initialize once. Returns true if device supports speech recognition.
  static Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      _initialized = await _speech.initialize(
        onError: (e) => debugPrint('SpeechService error: $e'),
        onStatus: (s) => debugPrint('SpeechService status: $s'),
      );
    } catch (e) {
      debugPrint('SpeechService.initialize error: $e');
      _initialized = false;
    }
    return _initialized;
  }

  /// Start listening. Calls [onResult] with each partial/final transcript.
  /// Calls [onDone] when listening stops (silence or timeout).
  static Future<bool> startListening({
    required void Function(String text, bool isFinal) onResult,
    VoidCallback? onDone,
    String localeId = 'en_US',
  }) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return false;
    }
    if (_isListening) return false;

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      localeId: localeId,
      listenMode: ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
      onSoundLevelChange: null,
    );
    _isListening = true;

    // Auto-stop after 30 seconds max
    Future.delayed(const Duration(seconds: 30), () {
      if (_isListening) stopListening();
    });

    // Listen for completion
    _speech.statusListener = (status) {
      if (status == 'done' || status == 'notListening') {
        _isListening = false;
        onDone?.call();
      }
    };

    return true;
  }

  /// Stop listening manually
  static Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  /// Cancel without getting a result
  static Future<void> cancel() async {
    await _speech.cancel();
    _isListening = false;
  }

  static bool get isAvailable => _initialized && _speech.isAvailable;
}
