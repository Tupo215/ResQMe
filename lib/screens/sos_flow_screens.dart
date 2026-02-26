import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../services/location_speech_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class SosRecord {
  final String id;
  final DateTime timestamp;
  final int durationMinutes;
  final List<_NotifiedContact> contacts;
  final bool locationShared;

  SosRecord({
    required this.id,
    required this.timestamp,
    required this.durationMinutes,
    required this.contacts,
    required this.locationShared,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'durationMinutes': durationMinutes,
        'contacts': contacts.map((c) => c.toJson()).toList(),
        'locationShared': locationShared,
      };

  factory SosRecord.fromJson(Map<String, dynamic> json) => SosRecord(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        durationMinutes: json['durationMinutes'],
        contacts: (json['contacts'] as List)
            .map((c) => _NotifiedContact.fromJson(c))
            .toList(),
        locationShared: json['locationShared'] ?? true,
      );
}

class _NotifiedContact {
  final String name;
  final String initials;
  final String time;
  final String status; // 'Delivered' | 'Pending' | 'Failed'

  _NotifiedContact({
    required this.name,
    required this.initials,
    required this.time,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'initials': initials,
        'time': time,
        'status': status,
      };

  factory _NotifiedContact.fromJson(Map<String, dynamic> json) =>
      _NotifiedContact(
        name: json['name'],
        initials: json['initials'],
        time: json['time'],
        status: json['status'],
      );
}

// Helper to save a new SOS record
Future<void> saveSosRecord(SosRecord record) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getStringList('sos_history') ?? [];
  raw.insert(0, jsonEncode(record.toJson()));
  await prefs.setStringList('sos_history', raw);
}

Future<List<SosRecord>> loadSosHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getStringList('sos_history') ?? [];
  return raw.map((e) => SosRecord.fromJson(jsonDecode(e))).toList();
}

// ─────────────────────────────────────────────
// SCREEN 1 — SOS ACTIVATED (5-min countdown)
// ─────────────────────────────────────────────
class SosActivatedScreen extends StatefulWidget {
  const SosActivatedScreen({super.key});

  @override
  State<SosActivatedScreen> createState() => _SosActivatedScreenState();
}

class _SosActivatedScreenState extends State<SosActivatedScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 5 * 60; // 5 minutes
  int _secondsLeft = _totalSeconds;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Live location
  String _locationText = 'Getting location...';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startLocationTracking();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 0) {
        _timer?.cancel();
        // Navigate to SMS-sending screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SosSendingScreen()),
        );
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    LocationService.removeListener(_onLocationUpdate);
    super.dispose();
  }

  void _onLocationUpdate(Position pos) {
    if (mounted) setState(() => _locationText = LocationService.formatPosition(pos));
  }

  Future<void> _startLocationTracking() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null && mounted) setState(() => _locationText = LocationService.formatPosition(pos));
    else if (mounted) setState(() => _locationText = 'Location unavailable');
    await LocationService.startLiveTracking(_onLocationUpdate);
  }

  String get _timeLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFEF2F2), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Pulsing SOS circle
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD00000),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD00000).withOpacity(0.4),
                        blurRadius: 50,
                        offset: const Offset(0, 25),
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.warning_rounded,
                      color: Colors.white, size: 60),
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                '🚨 SOS ACTIVATED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD00000),
                  fontSize: 28,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Notifying emergency contacts...',
                style: TextStyle(
                  color: Color(0xFF4F4F4F),
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),

              const SizedBox(height: 32),

              // Countdown card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Live Location Sharing',
                        style: TextStyle(
                          color: Color(0xFF4F4F4F),
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _timeLabel,
                        style: const TextStyle(
                          color: Color(0xFF6666B3),
                          fontSize: 40,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Countdown timer',
                        style: TextStyle(
                          color: Color(0xFF4F4F4F),
                          fontSize: 14,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Cancel button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: const Color(0xFFD00000)),
                    ),
                    child: const Center(
                      child: Text(
                        'Cancel SOS',
                        style: TextStyle(
                          color: Color(0xFFD00000),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SCREEN 2 — SMS SENDING (animated send state)
// ─────────────────────────────────────────────
class SosSendingScreen extends StatefulWidget {
  const SosSendingScreen({super.key});

  @override
  State<SosSendingScreen> createState() => _SosSendingScreenState();
}

class _SosSendingScreenState extends State<SosSendingScreen> {
  final List<Map<String, String>> _contacts = [
    {'name': 'John Smith', 'initials': 'JS'},
    {'name': 'Mary Johnson', 'initials': 'MJ'},
    {'name': 'David Williams', 'initials': 'DW'},
  ];

  int _deliveredCount = 0;
  Timer? _sendTimer;
  bool _allSent = false;

  @override
  void initState() {
    super.initState();
    _simulateSending();
  }

  void _simulateSending() {
    _sendTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (_deliveredCount < _contacts.length) {
        setState(() => _deliveredCount++);
      } else {
        timer.cancel();
        setState(() => _allSent = true);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SosNotifiedScreen()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _sendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFEF2F2), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: const Color(0xFFD00000),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD00000).withOpacity(0.4),
                      blurRadius: 50,
                      offset: const Offset(0, 25),
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child:
                    const Icon(Icons.warning_rounded, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 28),
              const Text(
                '🚨 SOS ACTIVATED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD00000),
                  fontSize: 28,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Notifying emergency contacts...',
                style: TextStyle(
                  color: Color(0xFF4F4F4F),
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 32),

              // Contact delivery cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 50,
                          offset: const Offset(0, 25),
                          spreadRadius: -12,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ..._contacts.asMap().entries.map((e) {
                          final idx = e.key;
                          final c = e.value;
                          final delivered = idx < _deliveredCount;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: delivered
                                    ? const Color(0xFFF0FDF4)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: delivered
                                          ? const Color(0xFF00A63E)
                                          : const Color(0xFFCCCCCC),
                                      shape: BoxShape.circle,
                                    ),
                                    child: delivered
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 28)
                                        : Center(
                                            child: SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'SMS Sent: ${c['name']}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          delivered ? 'Delivered' : 'Sending...',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            color: delivered
                                                ? const Color(0xFF2E7D32)
                                                : const Color(0xFF9E9E9E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        if (_allSent)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Color(0xFF2E7D32), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'All contacts notified successfully',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Live location countdown at bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Text('Live Location Sharing',
                          style: TextStyle(
                              color: Color(0xFF4F4F4F),
                              fontSize: 15,
                              fontFamily: 'Inter')),
                      SizedBox(height: 6),
                      Text('05:00',
                          style: TextStyle(
                            color: Color(0xFF6666B3),
                            fontSize: 32,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          )),
                      SizedBox(height: 2),
                      Text('Countdown timer',
                          style: TextStyle(
                              color: Color(0xFF4F4F4F),
                              fontSize: 13,
                              fontFamily: 'Arimo')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: const Color(0xFFD00000)),
                    ),
                    child: const Center(
                      child: Text('Cancel SOS',
                          style: TextStyle(
                              color: Color(0xFFD00000),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SCREEN 3 — CONTACTS NOTIFIED (confirmation)
// ─────────────────────────────────────────────
class SosNotifiedScreen extends StatefulWidget {
  const SosNotifiedScreen({super.key});

  @override
  State<SosNotifiedScreen> createState() => _SosNotifiedScreenState();
}

class _SosNotifiedScreenState extends State<SosNotifiedScreen> {
  final DateTime _alertTime = DateTime.now();

  // Live location
  String _locationText = 'Getting location...';

  final List<_NotifiedContact> _contacts = [
    _NotifiedContact(
        name: 'John Smith',
        initials: 'JS',
        time: _fmt(DateTime.now()),
        status: 'Delivered'),
    _NotifiedContact(
        name: 'Mary Johnson',
        initials: 'MJ',
        time: _fmt(DateTime.now()),
        status: 'Delivered'),
    _NotifiedContact(
        name: 'David Williams',
        initials: 'DW',
        time: _fmt(DateTime.now()),
        status: 'Pending'),
  ];

  static String _fmt(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  void initState() {
    super.initState();
    final record = SosRecord(
      id: _alertTime.millisecondsSinceEpoch.toString(),
      timestamp: _alertTime,
      durationMinutes: 15,
      contacts: _contacts,
      locationShared: true,
    );
    saveSosRecord(record);
    _startLocationTracking();
  }

  @override
  void dispose() {
    LocationService.removeListener(_onLocationUpdate);
    super.dispose();
  }

  void _onLocationUpdate(Position pos) {
    if (mounted) setState(() => _locationText = LocationService.formatPosition(pos));
  }

  Future<void> _startLocationTracking() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() => _locationText = LocationService.formatPosition(pos));
    } else if (mounted) {
      setState(() => _locationText = 'Location unavailable');
    }
    await LocationService.startLiveTracking(_onLocationUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.popUntil(context, (r) => r.isFirst),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3D3D3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Emergency Alert Sent',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Success banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: Color(0xFF2E7D32), size: 56),
                          SizedBox(height: 16),
                          Text(
                            'Alert Successfully Sent',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 22,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your emergency contacts have been notified',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 15,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Notified contacts card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                            child: Text(
                              'Notified:',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          ..._contacts.map((c) => _ContactRow(contact: c)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Live location card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCCCE6).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.black54, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Live Location Sharing',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Your location is being shared with emergency contacts',
                                      style: TextStyle(
                                          color: Color(0xFF4F4F4F),
                                          fontSize: 14,
                                          fontFamily: 'Inter'),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.schedule,
                                            color: Color(0xFF333399), size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Sharing until ${_sharingEndTime()}',
                                          style: const TextStyle(
                                            color: Color(0xFF333399),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.map_outlined,
                                    color: Color(0xFF9999CC), size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  _locationText,
                                  style: const TextStyle(
                                      color: Color(0xFF7B7B7B),
                                      fontSize: 14,
                                      fontFamily: 'Inter'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Stop Sharing button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border:
                              Border.all(color: const Color(0xFFD00000)),
                        ),
                        child: const Center(
                          child: Text(
                            'Stop Sharing',
                            style: TextStyle(
                                color: Color(0xFFD00000),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // View Notification History button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SosHistoryScreen()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border:
                              Border.all(color: const Color(0xFF333399)),
                        ),
                        child: const Center(
                          child: Text(
                            'View Notification History',
                            style: TextStyle(
                                color: Color(0xFF333399),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sharingEndTime() {
    final end = _alertTime.add(const Duration(minutes: 15));
    final h = end.hour % 12 == 0 ? 12 : end.hour % 12;
    final m = end.minute.toString().padLeft(2, '0');
    final ampm = end.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }
}

class _ContactRow extends StatelessWidget {
  final _NotifiedContact contact;
  const _ContactRow({required this.contact});

  @override
  Widget build(BuildContext context) {
    final delivered = contact.status == 'Delivered';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
                color: Color(0xFF000080), shape: BoxShape.circle),
            child: Center(
              child: Text(
                contact.initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500)),
                Text(contact.time,
                    style: const TextStyle(
                        color: Color(0xFF7B7B7B),
                        fontSize: 13,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                delivered ? Icons.check_circle : Icons.schedule,
                color:
                    delivered ? const Color(0xFF2E7D32) : const Color(0xFFFFC107),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                contact.status,
                style: TextStyle(
                  color: delivered
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFFFC107),
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SCREEN 4 — SOS HISTORY (live / persisted)
// ─────────────────────────────────────────────
class SosHistoryScreen extends StatefulWidget {
  const SosHistoryScreen({super.key});

  @override
  State<SosHistoryScreen> createState() => _SosHistoryScreenState();
}

class _SosHistoryScreenState extends State<SosHistoryScreen> {
  List<SosRecord> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await loadSosHistory();
    // If empty, seed with two sample entries so the UI isn't blank
    if (records.isEmpty) {
      records.addAll([
        SosRecord(
          id: '1',
          timestamp: DateTime(2026, 2, 13, 3, 33),
          durationMinutes: 15,
          contacts: [
            _NotifiedContact(
                name: 'John Smith',
                initials: 'JS',
                time: '3:57 AM',
                status: 'Delivered'),
            _NotifiedContact(
                name: 'Mary Johnson',
                initials: 'MJ',
                time: '3:57 AM',
                status: 'Delivered'),
            _NotifiedContact(
                name: 'David Williams',
                initials: 'DW',
                time: '3:57 AM',
                status: 'Delivered'),
          ],
          locationShared: true,
        ),
        SosRecord(
          id: '2',
          timestamp: DateTime(2026, 1, 25, 13, 0),
          durationMinutes: 15,
          contacts: [
            _NotifiedContact(
                name: 'John Smith',
                initials: 'JS',
                time: '1:00 PM',
                status: 'Delivered'),
            _NotifiedContact(
                name: 'Mary Johnson',
                initials: 'MJ',
                time: '1:00 PM',
                status: 'Delivered'),
            _NotifiedContact(
                name: 'David Williams',
                initials: 'DW',
                time: '1:00 PM',
                status: 'Delivered'),
          ],
          locationShared: true,
        ),
      ]);
    }
    setState(() {
      _history = records;
      _loading = false;
    });
  }

  String _formatDate(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3D3D3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'SOS History',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (_loading)
              const Expanded(
                  child: Center(child: CircularProgressIndicator()))
            else if (_history.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_toggle_off,
                          size: 64, color: Color(0xFFCCCCCC)),
                      SizedBox(height: 16),
                      Text('No SOS events yet',
                          style: TextStyle(
                              color: Color(0xFF7B7B7B),
                              fontSize: 16,
                              fontFamily: 'Inter')),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: _history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) {
                      final r = _history[i];
                      return _HistoryCard(
                        record: r,
                        dateLabel: _formatDate(r.timestamp),
                        timeLabel: _formatTime(r.timestamp),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final SosRecord record;
  final String dateLabel;
  final String timeLabel;

  const _HistoryCard({
    required this.record,
    required this.dateLabel,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F3F5), width: 1.3),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Date / meta header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFEFEFF1),
              border: Border(
                  bottom: BorderSide(color: Color(0xFF000080), width: 1.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateLabel,
                        style: const TextStyle(
                            color: Color(0xFF000080),
                            fontSize: 13,
                            fontFamily: 'Inter')),
                    const SizedBox(height: 2),
                    Text(timeLabel,
                        style: const TextStyle(
                            color: Color(0xFF000080),
                            fontSize: 17,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: Color(0xFF000080), size: 18),
                        const SizedBox(width: 6),
                        Text('${record.durationMinutes} min',
                            style: const TextStyle(
                                color: Color(0xFF000080),
                                fontSize: 15,
                                fontFamily: 'Inter')),
                      ],
                    ),
                    if (record.locationShared)
                      const Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Color(0xFF000080), size: 16),
                          SizedBox(width: 4),
                          Text('Location shared',
                              style: TextStyle(
                                  color: Color(0xFF000080),
                                  fontSize: 13,
                                  fontFamily: 'Inter')),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Contacts notified
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contacts Notified:',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const SizedBox(height: 8),
                ...record.contacts.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                                color: Color(0xFF000080),
                                shape: BoxShape.circle),
                            child: Center(
                              child: Text(c.initials,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Inter')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500)),
                                Text(c.time,
                                    style: const TextStyle(
                                        color: Color(0xFF7B7B7B),
                                        fontSize: 12,
                                        fontFamily: 'Inter')),
                              ],
                            ),
                          ),
                          Text(
                            c.status,
                            style: TextStyle(
                              color: c.status == 'Delivered'
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFFFC107),
                              fontSize: 13,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          // Footer
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: const Color(0xFFF3F3F5),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6666B3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Emergency alert completed',
                    style: TextStyle(
                        color: Color(0xFF7B7B7B),
                        fontSize: 13,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SCREEN 5 — PRIVACY & DATA
// ─────────────────────────────────────────────
class PrivacyDataScreen extends StatefulWidget {
  const PrivacyDataScreen({super.key});

  @override
  State<PrivacyDataScreen> createState() => _PrivacyDataScreenState();
}

class _PrivacyDataScreenState extends State<PrivacyDataScreen> {
  bool _sosTracking = true;
  bool _contacts = true;
  bool _responders = true;
  bool _bloodType = true;
  bool _allergies = true;
  bool _profileIdentity = true;

  Widget _section(String label, IconData icon) => Row(
        children: [
          Icon(icon, color: const Color(0xFF000080), size: 20),
          const SizedBox(width: 8),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  color: Color(0xFF000080),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5)),
        ],
      );

  Widget _toggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool hasBorder = false,
  }) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: hasBorder
            ? const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF8FAFC))))
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Inter',
                        color: Color(0xFF7B7B7B))),
              ],
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF000080),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFEFF1),
                border:
                    Border(bottom: BorderSide(color: Color(0xFFD3D3D3))),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3D3D3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Privacy & data',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero text
                    const Text(
                      'Your data.\nYour rules.',
                      style: TextStyle(
                        color: Color(0xFF000080),
                        fontSize: 32,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Control exactly what information is shared during\nemergency missions.',
                      style: TextStyle(
                          color: Color(0xFF7B7B7B),
                          fontSize: 14,
                          fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 36),

                    // LOCATION section
                    _section('Location', Icons.location_on_outlined),
                    const SizedBox(height: 12),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _toggle(
                            title: 'SOS Tracking',
                            subtitle: 'Allows responders to find you faster',
                            value: _sosTracking,
                            onChanged: (v) => setState(() => _sosTracking = v),
                          ),
                          _toggle(
                            title: 'Contacts',
                            subtitle: 'Notify your emergency contacts',
                            value: _contacts,
                            onChanged: (v) => setState(() => _contacts = v),
                            hasBorder: true,
                          ),
                          _toggle(
                            title: 'Responders',
                            subtitle: 'Share live coordinates with HQ',
                            value: _responders,
                            onChanged: (v) => setState(() => _responders = v),
                            hasBorder: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // MEDICAL INFO section
                    _section('Medical Info', Icons.medical_information_outlined),
                    const SizedBox(height: 12),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _toggle(
                            title: 'Blood type',
                            subtitle: 'Shared only during active mission',
                            value: _bloodType,
                            onChanged: (v) => setState(() => _bloodType = v),
                          ),
                          _toggle(
                            title: 'Allergies',
                            subtitle: 'Known allergies and conditions',
                            value: _allergies,
                            onChanged: (v) => setState(() => _allergies = v),
                            hasBorder: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // PERSONAL INFO section
                    _section('Personal Info', Icons.person_outline),
                    const SizedBox(height: 12),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: _toggle(
                        title: 'Profile Identity',
                        subtitle: 'Legal name and identification photo',
                        value: _profileIdentity,
                        onChanged: (v) =>
                            setState(() => _profileIdentity = v),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Preview button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF000080),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.visibility_outlined,
                                color: Color(0xFFEFEFF1), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Preview what responders see',
                              style: TextStyle(
                                  color: Color(0xFFEFEFF1),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Withdraw consents
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Withdraw all consents?'),
                              content: const Text(
                                  'This will stop sharing all data. Emergency features may not work correctly.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _sosTracking = false;
                                      _contacts = false;
                                      _responders = false;
                                      _bloodType = false;
                                      _allergies = false;
                                      _profileIdentity = false;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Withdraw',
                                      style:
                                          TextStyle(color: Color(0xFFD00000))),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          'Withdraw all consents',
                          style: TextStyle(
                              color: Color(0xFFD00000),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
