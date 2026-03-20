import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/resq_widgets.dart';
import '../services/api_service.dart';
import '../services/location_speech_service.dart';
import '../widgets/resq_icon.dart';
import 'login_screen.dart';
import 'sos_active_screen.dart';
import 'report_who_screen.dart';
import 'ai_guidance_screen.dart';
import 'voice_ai_screen.dart';
import 'settings_screen.dart';
import 'emergency_contact_screen.dart';
import 'medical_profile_screen.dart';
import 'sos_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  String _userName = '';

  // ── SOS hold state ──────────────────────────────────────────────────────────
  bool   _isHolding    = false;
  double _holdProgress = 0.0;   // 0.0 → 1.0 over first 3 s
  Timer? _progressTimer;

  // ── Voice-SOS state (triggered after 3 s) ──────────────────────────────────
  bool   _isRecording      = false;   // currently recording voice
  int    _recordSeconds    = 0;       // seconds recorded so far
  Timer? _recordTimer;
  String? _voicePath;                 // temp file path for the recording
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool   _recorderReady    = false;
  bool   _isSendingSOS     = false;   // spinner while uploading

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() => setState(() {}));
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _loadUserName();
    _initRecorder();
  }

  Future<void> _loadUserName() async {
    final name = await ResQApiService.getUserName();
    if (mounted && name != null && name.isNotEmpty) {
      setState(() => _userName = name.trim().split(' ').first);
    }
  }

  Future<void> _initRecorder() async {
    try {
      await _recorder.openRecorder();
      setState(() => _recorderReady = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _recordTimer?.cancel();
    _pulseCtrl.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ── PHASE 1: user presses down ──────────────────────────────────────────────
  void _onSOSDown() {
    setState(() { _isHolding = true; _holdProgress = 0.0; });
    _pulseCtrl.repeat(reverse: true);

    const totalMs = 3000, tickMs = 50;
    int elapsed = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: tickMs), (t) {
      elapsed += tickMs;
      setState(() => _holdProgress = (elapsed / totalMs).clamp(0.0, 1.0));
      if (elapsed >= totalMs) {
        t.cancel();
        // 3 s reached — switch to voice recording mode
        _startVoiceRecording();
      }
    });
  }

  // ── PHASE 2: user releases ──────────────────────────────────────────────────
  void _onSOSUp() async {
    _progressTimer?.cancel();

    if (_isRecording) {
      // Released while recording → stop mic and send SOS with voice
      await _stopRecordingAndSend();
    } else if (_holdProgress < 1.0) {
      // Released before 3 s → cancel
      _pulseCtrl.stop(); _pulseCtrl.reset();
      setState(() { _isHolding = false; _holdProgress = 0.0; });
    }
    // If holdProgress == 1.0 but _isRecording == false, recording is starting
    // — do nothing here, _startVoiceRecording handles it
  }

  // ── Start microphone recording (called after 3 s hold) ─────────────────────
  Future<void> _startVoiceRecording() async {
    if (!_recorderReady) {
      // Recorder not ready — fall back to plain SOS
      _launchSOS();
      return;
    }

    // Request mic permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _launchSOS(); // mic denied — fall back gracefully
      return;
    }

    try {
      final dir  = await getTemporaryDirectory();
      final path = '${dir.path}/sos_voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      _voicePath    = path;
      _recordSeconds = 0;

      await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);

      _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _recordSeconds++);
      });

      setState(() => _isRecording = true);
      // Keep pulsing
      _pulseCtrl.repeat(reverse: true);
    } catch (_) {
      _launchSOS(); // any error → plain SOS
    }
  }

  // ── Stop recording + send to backend ───────────────────────────────────────
  Future<void> _stopRecordingAndSend() async {
    _recordTimer?.cancel();
    _pulseCtrl.stop(); _pulseCtrl.reset();
    setState(() { _isRecording = false; _isHolding = false;
                  _holdProgress = 0.0; _isSendingSOS = true; });

    try {
      await _recorder.stopRecorder();
    } catch (_) {}

    // Get GPS
    final position = await LocationService.getCurrentPosition();

    // Send to backend
    final voiceFile = (_voicePath != null && File(_voicePath!).existsSync())
        ? File(_voicePath!)
        : null;

    await ResQApiService.reportEmergency(
      latitude:  position?.latitude  ?? 0.0,
      longitude: position?.longitude ?? 0.0,
      voiceNote: voiceFile,
      reportingFor: 'self',
    );

    if (!mounted) return;
    setState(() => _isSendingSOS = false);

    // Navigate to SOS active screen (same as plain SOS)
    _launchSOS();

    // Clean up temp file
    try { voiceFile?.deleteSync(); } catch (_) {}
    _voicePath = null;
  }

  // ── Launch the SOS active screen (both paths end here) ─────────────────────
  void _launchSOS() {
    _pulseCtrl.stop(); _pulseCtrl.reset();
    setState(() { _isHolding = false; _holdProgress = 0.0;
                  _isRecording = false; _recordSeconds = 0; });
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SosActiveScreen()),
    );
  }

  Future<void> _logout() async {
    await ResQApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // ── Hint text shown below the SOS button ───────────────────────────────────
  String get _hintText {
    if (_isSendingSOS)   return 'Sending SOS...';
    if (_isRecording)    return 'Recording... release to send SOS';
    if (_isHolding)      return 'Keep holding to send SOS...';
    return 'Hold 3s for SOS • Hold longer to record voice';
  }

  Color get _hintColor {
    if (_isSendingSOS)   return const Color(0xFF000080);
    if (_isRecording)    return const Color(0xFFD00000);
    if (_isHolding)      return const Color(0xFFD00000);
    return const Color(0xFF7B7B7B);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ringScale   = _isHolding ? _pulseAnim.value : 1.0;
    final sosSize     = (screenWidth * 0.72).clamp(220.0, 310.0);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: _buildPage(_selectedTab, sosSize, ringScale),
          ),
          _BottomNav(
            selected: _selectedTab,
            onTap: (i) {
              if (i == _selectedTab) return;
              setState(() => _selectedTab = i);
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildPage(int tab, double sosSize, double ringScale) {
    switch (tab) {
      case 1: return const SosHistoryScreen();
      case 2: return const SettingsScreen();
      default: return _buildHome(sosSize, ringScale);
    }
  }

  Widget _buildHome(double sosSize, double ringScale) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$_greeting${_userName.isNotEmpty ? ',' : ''}',
                      style: const TextStyle(color: Color(0xFF7B7B7B),
                          fontSize: 14, fontFamily: 'Inter',
                          fontWeight: FontWeight.w400)),
                  Text(_userName.isNotEmpty ? _userName : 'Stay Safe',
                      style: const TextStyle(color: Color(0xFF000080),
                          fontSize: 22, fontFamily: 'Inter',
                          fontWeight: FontWeight.w700)),
                ]),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  child: Container(
                    width: 44, height: 44,
                    decoration: const ShapeDecoration(
                        color: Color(0xFFEEF2FF), shape: CircleBorder()),
                    child: Center(
                      child: ResQIcon(ResQIcons.settings, size: 22,
                          color: AppColors.navy),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── SOS Button ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: GestureDetector(
                onTapDown: (_) => _onSOSDown(),
                onTapUp:   (_) => _onSOSUp(),
                onTapCancel: _onSOSUp,
                child: SizedBox(
                  width: sosSize,
                  height: sosSize,
                  child: Stack(alignment: Alignment.center, children: [

                    // Outer ring — only while holding
                    if (_isHolding || _isRecording)
                      Transform.scale(scale: ringScale,
                        child: Container(
                          width: sosSize, height: sosSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isRecording
                                  ? const Color(0xFFFFCCCC)
                                  : const Color(0xFFFAE5E5),
                              width: 1),
                          ),
                        ),
                      ),

                    // Mid ring
                    if (_isHolding || _isRecording)
                      Transform.scale(scale: ringScale,
                        child: Container(
                          width: sosSize * 0.918,
                          height: sosSize * 0.918,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isRecording
                                  ? const Color(0xFFFF9999)
                                  : const Color(0xFFF6CCCC),
                              width: 2),
                          ),
                        ),
                      ),

                    // Progress arc — first 3 s hold
                    if (_isHolding && !_isRecording)
                      SizedBox(
                        width: sosSize * 0.83,
                        height: sosSize * 0.83,
                        child: CircularProgressIndicator(
                          value: _holdProgress,
                          strokeWidth: 4,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFF6CCCC)),
                        ),
                      ),

                    // Recording pulse ring — replaces progress arc
                    if (_isRecording)
                      SizedBox(
                        width: sosSize * 0.83,
                        height: sosSize * 0.83,
                        child: CircularProgressIndicator(
                          value: null, // indeterminate spin
                          strokeWidth: 4,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFD00000)),
                        ),
                      ),

                    // Core red SOS circle
                    Transform.scale(
                      scale: (_isHolding || _isRecording) ? ringScale : 1.0,
                      child: Container(
                        width: sosSize * 0.715,
                        height: sosSize * 0.715,
                        decoration: BoxDecoration(
                          color: _isSendingSOS
                              ? const Color(0xFF9B0000)
                              : const Color(0xFFD00000),
                          shape: BoxShape.circle,
                          boxShadow: const [BoxShadow(
                            color: Color(0x50D00000),
                            blurRadius: 24, spreadRadius: 2,
                            offset: Offset(0, 8),
                          )],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSendingSOS) ...[
                              const SizedBox(
                                width: 36, height: 36,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 3),
                              ),
                              const SizedBox(height: 8),
                              const Text('Sending',
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 14, fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500)),
                            ] else if (_isRecording) ...[
                              // Mic icon + recording timer
                              ResQIcon(ResQIcons.microphone,
                                  size: 48, color: Colors.white),
                              const SizedBox(height: 4),
                              Text(
                                '${_recordSeconds}s',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 28,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700),
                              ),
                              const Text('Release to send',
                                  style: TextStyle(
                                      color: Color(0xCCEFEFF1),
                                      fontSize: 11, fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500)),
                            ] else ...[
                              ResQIcon(ResQIcons.emergency,
                                  size: 56, color: Colors.white),
                              const SizedBox(height: 4),
                              const Text('SOS',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFFEFEFF1),
                                      fontSize: 52, fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.2)),
                              if (_isHolding) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '${(3 - (_holdProgress * 3)).ceil()}s',
                                  style: const TextStyle(
                                      color: Color(0xCCEFEFF1),
                                      fontSize: 14, fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500)),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),

          // Hold hint text
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(children: [
              Center(child: Text(
                _hintText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _hintColor,
                  fontSize: 15, fontFamily: 'Inter',
                  fontWeight: (_isHolding || _isRecording || _isSendingSOS)
                      ? FontWeight.w600 : FontWeight.w400,
                ),
              )),
              const SizedBox(height: 4),
              Center(child: Text(
                _isRecording ? '🎙 Microphone active' : 'Release to cancel',
                style: TextStyle(
                    color: (_isHolding || _isRecording)
                        ? const Color(0xFFA7A7A7)
                        : Colors.transparent,
                    fontSize: 13, fontFamily: 'Inter',
                    fontWeight: FontWeight.w400, height: 1.40),
              )),
            ]),
          ),

          const SizedBox(height: 16),

          // ── AI / Not Sure card ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 2, color: Color(0xFFF3F3F5)),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 40, height: 40,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFEEF2FF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1000)),
                      ),
                      child: Center(child: ResQIcon(ResQIcons.bot,
                          size: 22, color: AppColors.navy)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Not sure? Chat with AI',
                            style: TextStyle(color: Color(0xFF000080),
                                fontSize: 15, fontFamily: 'Inter',
                                fontWeight: FontWeight.w600, height: 1.40)),
                        SizedBox(height: 2),
                        Text("Describe what happened. I'll assess and help you.",
                            style: TextStyle(color: Color(0xFF6666B3),
                                fontSize: 13, fontFamily: 'Inter',
                                fontWeight: FontWeight.w400, height: 1.40)),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const AiGuidanceScreen())),
                      child: Container(height: 46,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Color(0xFF000080)),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ResQIcon(ResQIcons.chat, size: 20,
                                color: Colors.black.withValues(alpha: 0.25)),
                            const SizedBox(width: 8),
                            Text('Start Chat', style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.25),
                                fontSize: 15, fontFamily: 'Inter',
                                fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const VoiceAiScreen())),
                      child: Container(height: 46,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF000080),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ResQIcon(ResQIcons.microphone, size: 20,
                                color: const Color(0xFFEFEFF1)),
                            const SizedBox(width: 8),
                            const Text('Voice Help', style: TextStyle(
                                color: Color(0xFFEFEFF1), fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    )),
                  ]),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Quick Actions ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quick Actions',
                    style: TextStyle(color: Color(0xFF000080), fontSize: 16,
                        fontFamily: 'Inter', fontWeight: FontWeight.w600,
                        height: 1.40)),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    _QuickCard(
                      iconAsset: ResQIcons.userMultiple,
                      label: 'Report for someone',
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const ReportWhoScreen())),
                    ),
                    _QuickCard(
                      iconAsset: ResQIcons.firstAid,
                      label: 'First aid guide',
                      onTap: () {},
                    ),
                    _QuickCard(
                      iconAsset: ResQIcons.phoneAdd,
                      label: 'Emergency contacts',
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const EmergencyContactScreen())),
                    ),
                    _QuickCard(
                      iconAsset: ResQIcons.healthMetrics,
                      label: 'Medical profile',
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const MedicalProfileScreen())),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Safety Tip ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: const Color(0xFFEAEBF6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResQIcon(ResQIcons.bulb, size: 22,
                      color: const Color(0xFF00004D)),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SAFETY TIP OF THE DAY',
                          style: TextStyle(color: Color(0xFF00004D),
                              fontSize: 11, fontFamily: 'Inter',
                              fontWeight: FontWeight.w600, height: 1.40,
                              letterSpacing: 0.5)),
                      SizedBox(height: 4),
                      Text(
                        'Keep a basic first aid kit in your vehicle at all times. Check expiration dates every six months.',
                        style: TextStyle(color: Color(0xFF4F4F4F),
                            fontSize: 13, fontFamily: 'Inter',
                            fontWeight: FontWeight.w400, height: 1.50),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Card ────────────────────────────────────────────────────────
class _QuickCard extends StatelessWidget {
  final String iconAsset, label;
  final VoidCallback onTap;
  const _QuickCard({required this.iconAsset, required this.label,
    required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadows: const [BoxShadow(
            color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40, height: 40,
            decoration: ShapeDecoration(
              color: const Color(0xFFEEF2FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Center(child: ResQIcon(iconAsset, size: 22,
                color: AppColors.navy)),
          ),
          const SizedBox(height: 10),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Color(0xFF00004D), fontSize: 13,
                  fontFamily: 'Inter', fontWeight: FontWeight.w600,
                  height: 1.35)),
        ],
      ),
    ),
  );
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selected;
  final void Function(int) onTap;
  const _BottomNav({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Color(0xFFEFEFF1),
      border: Border(top: BorderSide(color: Color(0xFFD3D3D3), width: 1)),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(iconAsset: ResQIcons.home, label: 'SOS',
                  active: selected == 0, onTap: () => onTap(0)),
              _NavItem(iconAsset: ResQIcons.history, label: 'History',
                  active: selected == 1, onTap: () => onTap(1)),
              _NavItem(iconAsset: ResQIcons.settings, label: 'Settings',
                  active: selected == 2, onTap: () => onTap(2)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 224, height: 5,
            decoration: ShapeDecoration(
              color: const Color(0xFFA7A7A7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
          ),
        ]),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final String iconAsset, label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.iconAsset, required this.label,
    required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      ResQIcon(iconAsset, size: 24,
          color: active ? AppColors.navy : const Color(0xFF7B7B7B)),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(
          color: active ? AppColors.navy : const Color(0xFF7B7B7B),
          fontSize: 14, fontFamily: 'Inter',
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          height: 1.40)),
    ]),
  );
}
