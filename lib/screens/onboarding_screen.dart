import 'package:flutter/material.dart';
import '../widgets/resq_widgets.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'report_who_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding page data — exact Figma content
// ─────────────────────────────────────────────────────────────────────────────
class _PageData {
  final String imagePath;
  final String title;
  final String body;
  final String nextLabel; // "Next" for 1&2, "Create Account" for 3
  const _PageData({
    required this.imagePath,
    required this.title,
    required this.body,
    required this.nextLabel,
  });
}

const _pages = [
  _PageData(
    imagePath: 'assets/onboarding_1.png',
    title: 'Instant help When You Need It',
    body: 'Summon help with a single tap and share your live location automatically with trusted contacts.',
    nextLabel: 'Next',
  ),
  _PageData(
    imagePath: 'assets/onboarding_2.png',
    title: 'Not sure? Chat with AI',
    body: 'Describe what happened. Our AI will assess severity, guide you and call for help if needed',
    nextLabel: 'Next',
  ),
  _PageData(
    imagePath: 'assets/onboarding_3.png',
    title: 'Help others. Stay protected',
    body: 'Report accidents for someone in need. Your data stays private, you\'re fully in control',
    nextLabel: 'Create Account',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Screen
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) => setState(() => _current = i);

  void _next() {
    if (_current < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _toSignUp();
    }
  }

  void _toSignUp() => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignUpScreen()),
      );

  void _toLogin() => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: _pages.length,
        itemBuilder: (_, i) => _OnboardingPage(
          data: _pages[i],
          pageIndex: i,
          totalPages: _pages.length,
          onSkip: _toSignUp,
          onNext: _next,
          onReportEmergency: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReportWhoScreen()),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single onboarding page — exact Figma layout
// Image fills top 60% with bottom rounded corners (radius 80)
// Text + dots + buttons in bottom 40%
// Skip top-right, no status bar
// ─────────────────────────────────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  final int pageIndex;
  final int totalPages;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onReportEmergency;

  const _OnboardingPage({
    required this.data,
    required this.pageIndex,
    required this.totalPages,
    required this.onSkip,
    required this.onNext,
    required this.onReportEmergency,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Figma: image is 574/956 ≈ 60% of screen height
    final imageHeight = size.height * 0.60;

    return Stack(
      children: [

        // ── Full page white background ──────────────────────────
        Positioned.fill(
          child: Container(color: Colors.white),
        ),

        // ── Image — top 60%, rounded bottom corners ─────────────
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: size.width,
            height: imageHeight,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(80),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              data.imagePath,
              width: size.width,
              height: imageHeight,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _ImagePlaceholder(index: pageIndex),
            ),
          ),
        ),

        // ── Skip button — top right (exact Figma position) ──────
        Positioned(
          right: 20,
          top: 52,
          child: GestureDetector(
            onTap: onSkip,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Color(0xFF9999CC),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.40,
                ),
              ),
            ),
          ),
        ),

        // ── Bottom content — below image ─────────────────────────
        Positioned(
          left: 0,
          top: imageHeight,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // ── Title + body ─────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.20),
                        fontSize: 32,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.40,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.body,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF7B7B7B),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.40,
                      ),
                    ),
                  ],
                ),

                // ── Dots + buttons ───────────────────────────────
                Column(
                  children: [

                    // Dots — exact Figma colors (#333399 active, #CCCCCE6 inactive)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(totalPages, (i) {
                        final isActive = i == pageIndex;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: isActive ? 40 : 12,
                          height: 12,
                          decoration: ShapeDecoration(
                            color: isActive
                                ? const Color(0xFF333399)
                                : const Color(0xFFCCCCE6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // Report Emergency Now — red button (same on all pages)
                    GestureDetector(
                      onTap: onReportEmergency,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFD00000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Center(
                          child: const Text(
                            'Report Emergency Now',
                            style: TextStyle(
                              color: Color(0xFFEFEFF1),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.40,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Next / Create Account — navy button
                    GestureDetector(
                      onTap: onNext,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF000080),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data.nextLabel,
                              style: const TextStyle(
                                color: Color(0xFFEFEFF1),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.40,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Arrow icon slot (Figma: 24x24 Stack placeholder)
                            const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Color(0xFFEFEFF1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Home indicator bar (Figma: bottom of screen) ─────────
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 224,
              height: 8,
              decoration: ShapeDecoration(
                color: const Color(0xFFD3D3D3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder shown until real images added to assets/
// ─────────────────────────────────────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  final int index;
  const _ImagePlaceholder({required this.index});

  static const _data = [
    (Icons.crisis_alert_rounded,      'onboarding_1.png'),
    (Icons.smart_toy_outlined,        'onboarding_2.png'),
    (Icons.people_outline_rounded,    'onboarding_3.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final (icon, file) = _data[index];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: AppColors.navy.withValues(alpha: 0.25)),
        const SizedBox(height: 16),
        Text(
          'Add assets/$file',
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.20),
            fontSize: 12,
            fontFamily: 'Inter',
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
