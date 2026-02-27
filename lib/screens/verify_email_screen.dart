import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/resq_widgets.dart';
import '../widgets/resq_icon.dart';
import 'dashboard_screen.dart';

// =============================================================================
// VerifyEmailScreen
// Shown after signup. User must click the verification link in their email.
// When they do, the backend redirects to:
//   mycoolapp://verification-success?accessToken=...&refreshToken=...
// main.dart listens for that deep link, saves tokens, then navigates here
// (or directly to Dashboard). This screen also lets them resend the link.
// =============================================================================

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _resending = false;
  bool _resentSuccess = false;

  Future<void> _resend() async {
    setState(() { _resending = true; _resentSuccess = false; });
    final result = await ResQApiService.resendVerificationEmail(email: widget.email);
    if (!mounted) return;
    setState(() {
      _resending = false;
      _resentSuccess = result.success;
    });
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: const Color(0xFFD00000)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ── Back button ───────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 56, height: 56,
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD3D3D3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    child: ResQIcon(ResQIcons.chevronLeft, size: 24,
                        color: Colors.white),
                  ),
                ),
              ),

              const Spacer(),

              // ── Email icon ────────────────────────────────────────────
              Container(
                width: 96, height: 96,
                decoration: ShapeDecoration(
                  color: const Color(0xFFE8E8F5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                child: Center(
                  child: ResQIcon(ResQIcons.mail, size: 44,
                      color: AppColors.navy),
                ),
              ),

              const SizedBox(height: 32),

              // ── Title ─────────────────────────────────────────────────
              const Text('Check your email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontSize: 28, fontFamily: 'Inter',
                      fontWeight: FontWeight.w700, height: 1.30)),

              const SizedBox(height: 12),

              // ── Subtitle ──────────────────────────────────────────────
              Text(
                'We sent a verification link to\n${widget.email}\n\n'
                'Click the link in the email to activate your account. '
                'You\'ll be brought straight into the app.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF4F4F4F), fontSize: 15,
                    fontFamily: 'Inter', fontWeight: FontWeight.w400,
                    height: 1.50),
              ),

              const SizedBox(height: 40),

              // ── Resent success banner ─────────────────────────────────
              if (_resentSuccess) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF0FDF4),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFF86EFAC)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(children: [
                    ResQIcon(ResQIcons.checkCircle, size: 20,
                        color: const Color(0xFF2E7D32)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Verification email resent! Check your inbox.',
                          style: TextStyle(color: Color(0xFF2E7D32),
                              fontSize: 14, fontFamily: 'Inter',
                              fontWeight: FontWeight.w500)),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
              ],

              // ── Resend button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                  ),
                  onPressed: _resending ? null : _resend,
                  child: _resending
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Resend verification email',
                          style: TextStyle(color: Color(0xFFEFEFF1),
                              fontSize: 16, fontFamily: 'Inter',
                              fontWeight: FontWeight.w500, height: 1.40)),
                ),
              ),

              const SizedBox(height: 16),

              // ── Already verified? hint ────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DashboardScreen()),
                  (r) => false,
                ),
                child: const Text(
                  'Already verified? Open the app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.navy, fontSize: 14,
                      fontFamily: 'Inter', fontWeight: FontWeight.w600),
                ),
              ),

              const Spacer(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
