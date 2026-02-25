import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/resq_widgets.dart';
import '../services/api_service.dart';
import '../widgets/resq_icon.dart';
import 'login_screen.dart';
import 'sos_active_screen.dart';
import 'report_who_screen.dart';
import 'ai_guidance_screen.dart';
import 'settings_screen.dart';
import 'emergency_contact_screen.dart';
import 'medical_profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0;

  // SOS hold state
  bool   _isHolding    = false;
  double _holdProgress = 0.0;
  Timer? _progressTimer;

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
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onSOSDown() {
    setState(() { _isHolding = true; _holdProgress = 0.0; });
    _pulseCtrl.repeat(reverse: true);
    const totalMs = 3000, tickMs = 50;
    int elapsed = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: tickMs), (t) {
      elapsed += tickMs;
      setState(() => _holdProgress = elapsed / totalMs);
      if (elapsed >= totalMs) { t.cancel(); _launchSOS(); }
    });
  }

  void _onSOSUp() {
    if (_holdProgress < 1.0) {
      _progressTimer?.cancel();
      _pulseCtrl.stop(); _pulseCtrl.reset();
      setState(() { _isHolding = false; _holdProgress = 0.0; });
    }
  }

  void _launchSOS() {
    _pulseCtrl.stop(); _pulseCtrl.reset();
    setState(() { _isHolding = false; _holdProgress = 0.0; });
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

  @override
  Widget build(BuildContext context) {
    final ringScale = _isHolding ? _pulseAnim.value : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      bottomNavigationBar: _BottomNav(
        selected: _selectedTab,
        onTap: (i) {
          if (i == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          } else {
            setState(() => _selectedTab = i);
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Top bar ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(
                    top: 16, left: 24, right: 24, bottom: 8),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 56, height: 56,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(64)),
                        image: const DecorationImage(
                          image: NetworkImage('https://placehold.co/56x56'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Greeting
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Good Evening, Ifeoluwa',
                            style: TextStyle(color: Color(0xFF232323),
                                fontSize: 16, fontFamily: 'Inter',
                                fontWeight: FontWeight.w400, height: 1.40)),
                        Text('Stay Safe',
                            style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.20),
                                fontSize: 24, fontFamily: 'Inter',
                                fontWeight: FontWeight.w600, height: 1.40)),
                      ],
                    )),

                    // Notification / settings icon
                    Container(
                      width: 48, height: 48,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF333399),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                        shadows: const [
                          BoxShadow(color: Color(0x19000000),
                              blurRadius: 4, offset: Offset(0, 2),
                              spreadRadius: -2),
                          BoxShadow(color: Color(0x19000000),
                              blurRadius: 6, offset: Offset(0, 4),
                              spreadRadius: -1),
                        ],
                      ),
                      child: Center(
                        child: ResQIcon(ResQIcons.notificationsOutline,
                            size: 24, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // ── SOS Button area ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 47, vertical: 9),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // SOS rings + button
                    Center(
                      child: GestureDetector(
                        onTapDown: (_) => _onSOSDown(),
                        onTapUp:   (_) => _onSOSUp(),
                        onTapCancel: _onSOSUp,
                        child: SizedBox(
                          width: 322, height: 322,
                          child: Stack(alignment: Alignment.center, children: [

                            // Outer ring (always visible from design)
                            Container(
                              width: 322, height: 322,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isHolding
                                      ? const Color(0xFFFAE5E5)
                                      : const Color(0xFFFAE5E5)
                                          .withValues(alpha: 0.5),
                                ),
                              ),
                            ),

                            // Mid ring
                            Container(
                              width: 295, height: 295,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2,
                                  color: _isHolding
                                      ? const Color(0xFFF6CCCC)
                                      : const Color(0xFFF6CCCC)
                                          .withValues(alpha: 0.5),
                                ),
                              ),
                            ),

                            // Progress arc while holding
                            if (_isHolding)
                              SizedBox(
                                width: 260, height: 260,
                                child: CircularProgressIndicator(
                                  value: _holdProgress,
                                  strokeWidth: 4,
                                  backgroundColor: Colors.transparent,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                      Color(0xFFF6CCCC)),
                                ),
                              ),

                            // Core red SOS circle
                            Transform.scale(
                              scale: _isHolding ? ringScale : 1.0,
                              child: Container(
                                width: 230, height: 230,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD00000),
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(
                                    color: Color(0x50D00000),
                                    blurRadius: 24, spreadRadius: 2,
                                    offset: Offset(0, 8),
                                  )],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ResQIcon(ResQIcons.sos, size: 68,
                                        color: Colors.white),
                                    const SizedBox(height: 4),
                                    Text('SOS',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Color(0xFFEFEFF1),
                                            fontSize: 64, fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                            height: 1.40)),
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
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Hold / release hints
                    Text(
                      _isHolding
                          ? 'Keep holding to send SOS...'
                          : 'Hold for 3 seconds to request help',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isHolding
                            ? const Color(0xFFD00000)
                            : const Color(0xFF7B7B7B),
                        fontSize: 16, fontFamily: 'Inter',
                        fontWeight: _isHolding
                            ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isHolding ? '' : 'Release to cancel',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFA7A7A7),
                          fontSize: 14, fontFamily: 'Inter',
                          fontWeight: FontWeight.w400, height: 1.40),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── AI / Not Sure card ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          width: 2, color: Color(0xFFF3F3F5)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFEEF2FF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1000)),
                            ),
                            child: Center(
                              child: ResQIcon(ResQIcons.bot,
                                  size: 24, color: AppColors.navy),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text('Not sure? Chat with AI',
                                    style: TextStyle(
                                        color: Color(0xFF000080),
                                        fontSize: 16, fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        height: 1.40)),
                              ),
                              const Text(
                                  "Describe what happened. I'll assess and help you.",
                                  style: TextStyle(
                                      color: Color(0xFF6666B3),
                                      fontSize: 14, fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40)),
                            ],
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const AiGuidanceScreen())),
                          child: Container(
                            height: 50,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xFF000080)),
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ResQIcon(ResQIcons.chat, size: 24,
                                    color: Colors.black.withValues(alpha: 0.20)),
                                const SizedBox(width: 8),
                                Text('Start Chat',
                                    style: TextStyle(
                                        color: Colors.black
                                            .withValues(alpha: 0.20),
                                        fontSize: 16, fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        height: 1.40)),
                              ],
                            ),
                          ),
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 50,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF000080),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ResQIcon(ResQIcons.microphone, size: 24,
                                    color: const Color(0xFFEFEFF1)),
                                const SizedBox(width: 8),
                                const Text('Voice Help',
                                    style: TextStyle(
                                        color: Color(0xFFEFEFF1),
                                        fontSize: 16, fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        height: 1.40)),
                              ],
                            ),
                          ),
                        )),
                      ]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Quick Actions ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quick Actions',
                        style: TextStyle(color: Color(0xFF000080),
                            fontSize: 16, fontFamily: 'Inter',
                            fontWeight: FontWeight.w600, height: 1.40)),
                    const SizedBox(height: 16),

                    // 2×2 grid
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, bottom: 24),
                      child: Row(children: [
                        Expanded(child: Column(children: [
                          _QuickCard(
                            iconAsset: ResQIcons.userMultiple,
                            label: 'Report for\nsomeone',
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const ReportWhoScreen())),
                          ),
                          const SizedBox(height: 16),
                          _QuickCard(
                            iconAsset: ResQIcons.phoneAdd,
                            label: 'Emergency\ncontacts',
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const EmergencyContactScreen())),
                          ),
                        ])),
                        const SizedBox(width: 16),
                        Expanded(child: Column(children: [
                          _QuickCard(
                            iconAsset: ResQIcons.firstAid,
                            label: 'First aid\nguide',
                            onTap: () {},
                          ),
                          const SizedBox(height: 16),
                          _QuickCard(
                            iconAsset: ResQIcons.healthMetrics,
                            label: 'Medical\nprofile',
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const MedicalProfileScreen())),
                          ),
                        ])),
                      ]),
                    ),
                  ],
                ),
              ),

              // ── Safety Tip ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 0, 23, 32),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEAEBF6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResQIcon(ResQIcons.bulb, size: 24,
                          color: const Color(0xFF00004D)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SAFETY TIP OF THE DAY',
                                style: TextStyle(color: Color(0xFF00004D),
                                    fontSize: 12, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                            SizedBox(height: 5),
                            Text(
                              'Keep a basic first aid kit in your vehicle at all times. Check expiration dates every six months.',
                              style: TextStyle(color: Color(0xFF4F4F4F),
                                  fontSize: 12, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400, height: 1.40),
                            ),
                          ],
                        ),
                      ),
                    ],
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

// ─── Quick Action Card ─────────────────────────────────────────────────────
class _QuickCard extends StatelessWidget {
  final String iconAsset, label;
  final VoidCallback onTap;
  const _QuickCard({required this.iconAsset, required this.label,
    required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 131,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
        shadows: const [BoxShadow(
            color: Color(0x0C000000), blurRadius: 2,
            offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: ShapeDecoration(
              color: const Color(0xFFEEF2FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Center(
              child: ResQIcon(iconAsset, size: 24,
                  color: AppColors.navy),
            ),
          ),
          const SizedBox(height: 11),
          Text(label,
              style: const TextStyle(color: Color(0xFF00004D),
                  fontSize: 14, fontFamily: 'Inter',
                  fontWeight: FontWeight.w600, height: 1.40)),
        ],
      ),
    ),
  );
}

// ─── Bottom Nav ────────────────────────────────────────────────────────────
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
        padding: const EdgeInsets.only(
            top: 20, left: 24, right: 24, bottom: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(iconAsset: ResQIcons.sos, label: 'SOS',
                  active: selected == 0, onTap: () => onTap(0)),
              _NavItem(iconAsset: ResQIcons.history, label: 'History',
                  active: selected == 1, onTap: () => onTap(1)),
              _NavItem(iconAsset: ResQIcons.settings, label: 'Settings',
                  active: selected == 2, onTap: () => onTap(2)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 224, height: 6,
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
      const SizedBox(height: 8),
      Text(label, style: TextStyle(
          color: active ? AppColors.navy : const Color(0xFF7B7B7B),
          fontSize: 16, fontFamily: 'Inter',
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          height: 1.40)),
    ]),
  );
}
