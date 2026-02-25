import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/resq_widgets.dart';
import 'signup_screen.dart';
import 'verify_email_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey            = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading       = false;

  // Button is active only when both email and password have text
  bool get _isButtonActive =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Listen to field changes to update button state
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_isButtonActive) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await ResQApiService.login(
      email:    _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } else {
      final reason = result.data?['reason'] ?? '';
      if (reason == 'Email not verified') {
        _showEmailNotVerifiedDialog();
      } else {
        showResQSnackBar(context, result.message, isError: true);
      }
    }
  }

  void _showEmailNotVerifiedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.background,
        title: const Text('Email Not Verified',
            style: TextStyle(color: AppColors.navy, fontSize: 18,
                fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: Text(
          'Your email has not been verified yet.\n\n'
          'Resend the verification link to:\n${_emailController.text.trim()}',
          style: TextStyle(color: Colors.black.withValues(alpha: 0.60),
              fontSize: 14, fontFamily: 'Inter',
              fontWeight: FontWeight.w400, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.inputBorder, fontFamily: 'Inter')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => VerifyEmailScreen(email: _emailController.text.trim()),
              ));
            },
            child: const Text('Verify Email',
                style: TextStyle(color: AppColors.navy,
                    fontFamily: 'Inter', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 24),

                // ── Logo + tagline ──────────────────────────────────
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 100, height: 100,
                        child: Image.asset('assets/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(color: AppColors.navy,
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Center(child: Text('R',
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 40, fontWeight: FontWeight.w800))),
                            )),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 239,
                        child: Text('Emergency help. One tap away.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.20),
                                fontSize: 16, fontFamily: 'Inter',
                                fontWeight: FontWeight.w400, height: 1.40)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ── Tabs ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        ),
                        child: SizedBox(
                          height: 42,
                          child: Center(
                            child: Text('Sign Up',
                                style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.20),
                                    fontSize: 16, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text('Login',
                                style: TextStyle(color: AppColors.navy,
                                    fontSize: 16, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                            Positioned.fill(
                              child: Container(
                                decoration: const ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(width: 2,
                                        strokeAlign: BorderSide.strokeAlignCenter,
                                        color: AppColors.navy),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Email ───────────────────────────────────────────
                ResQInputField(
                  controller: _emailController,
                  hint: 'Email address',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim()))
                      return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Password ────────────────────────────────────────
                ResQInputField(
                  controller: _passwordController,
                  hint: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(_obscurePassword
                        ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20, color: AppColors.inputBorder),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your password';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // ── Forgot password ─────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text('Forgot password?',
                        style: TextStyle(color: AppColors.navy,
                            fontSize: 16, fontFamily: 'Inter',
                            fontWeight: FontWeight.w400, height: 1.40)),
                  ),
                ),

                const SizedBox(height: 56),

                // ── Login button ────────────────────────────────────
                // Inactive (#9999CC) until email+password entered, Active (#000080) after
                GestureDetector(
                  onTap: _isLoading ? null : _handleLogin,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: ShapeDecoration(
                      color: _isButtonActive
                          ? const Color(0xFF000080)   // active — navy
                          : const Color(0xFF9999CC),  // inactive — light navy
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEFEFF1))))
                          : const Text('Login',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFFEFEFF1),
                                  fontSize: 16, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500, height: 1.40)),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
