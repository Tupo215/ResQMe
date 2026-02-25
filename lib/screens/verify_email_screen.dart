import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/resq_widgets.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isResending = false;
  int  _resendCooldown = 0;

  // ── Resend verification link ─────────────────────────────────────────────────
  Future<void> _resendLink() async {
    if (_resendCooldown > 0) return;

    setState(() => _isResending = true);

    final result = await ResQApiService.resendVerificationLink(
      email: widget.email,
    );

    if (!mounted) return;
    setState(() => _isResending = false);

    showResQSnackBar(context, result.message, isError: !result.success);

    if (result.success) {
      // Start a 60-second cooldown to prevent spam
      setState(() => _resendCooldown = 60);
      _startCooldown();
    }
  }

  void _startCooldown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _resendCooldown <= 0) return;
      setState(() => _resendCooldown--);
      if (_resendCooldown > 0) _startCooldown();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: 440,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: AppColors.background),
            child: Stack(
              children: [
                // ── Status bar ─────────────────────────────────────
                const Positioned(
                  left: 0, top: 0,
                  child: ResQStatusBar(),
                ),

                // ── Content ────────────────────────────────────────
                Positioned(
                  left: 24,
                  top: 52,
                  child: SizedBox(
                    width: 392,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        // Logo
                        const ResQHeader(),
                        const SizedBox(height: 48),

                        // Email icon illustration
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.navy.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_outlined,
                            size: 48,
                            color: AppColors.navy,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        const Text(
                          'Verify your email',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 22,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description
                        Text(
                          'We sent a verification link to',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.45),
                            fontSize: 15,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Email address (highlighted)
                        Text(
                          widget.email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 15,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Please click the link in the email to activate your account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.45),
                            fontSize: 15,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Steps ─────────────────────────────────
                        _buildStep(
                          icon: Icons.inbox_outlined,
                          text: 'Open your email inbox',
                        ),
                        const SizedBox(height: 16),
                        _buildStep(
                          icon: Icons.link,
                          text: 'Click the verification link',
                        ),
                        const SizedBox(height: 16),
                        _buildStep(
                          icon: Icons.check_circle_outline,
                          text: 'Come back and log in',
                        ),

                        const SizedBox(height: 48),

                        // ── Resend link button ─────────────────────
                        ResQButton(
                          label: _isResending
                              ? 'Sending...'
                              : _resendCooldown > 0
                                  ? 'Resend in ${_resendCooldown}s'
                                  : 'Resend Verification Link',
                          isLoading: _isResending,
                          onTap: _resendCooldown > 0 ? null : _resendLink,
                        ),

                        const SizedBox(height: 20),

                        // ── Go to Login ────────────────────────────
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: ShapeDecoration(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1.5,
                                  color: AppColors.navy,
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Go to Login',
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  height: 1.40,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Check spam note
                        Text(
                          "Didn't receive it? Check your spam folder.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.35),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.navy.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppColors.navy),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.60),
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
