import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/device_identifier.dart';
import '../widgets/resq_widgets.dart';
import 'verify_email_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey             = GlobalKey<FormState>();
  final _fullnameController  = TextEditingController();
  final _emailController     = TextEditingController();
  final _passwordController  = TextEditingController();
  final _confirmController   = TextEditingController();
  final _birthDateController = TextEditingController();

  bool      _obscurePassword = true;
  bool      _obscureConfirm  = true;
  bool      _agreedToTerms   = false;
  bool      _isLoading       = false;
  DateTime? _selectedBirthDate;

  // Button is active only when terms are accepted
  bool get _isButtonActive => _agreedToTerms;

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.navy,
            onPrimary: Colors.white,
            surface: AppColors.background,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (!_isButtonActive) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final deviceId = await DeviceIdentifier.get();
    final birthDate = _selectedBirthDate != null
        ? '${_selectedBirthDate!.year}-'
          '${_selectedBirthDate!.month.toString().padLeft(2, '0')}-'
          '${_selectedBirthDate!.day.toString().padLeft(2, '0')}'
        : '';

    final result = await ResQApiService.signUp(
      email:            _emailController.text.trim(),
      password:         _passwordController.text,
      fullname:         _fullnameController.text.trim(),
      birthDate:        birthDate,
      deviceIdentifier: deviceId,
      role:             'user',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(email: _emailController.text.trim()),
        ),
      );
    } else {
      showResQSnackBar(context, result.message, isError: true);
    }
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
                      child: SizedBox(
                        height: 42,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text('Sign Up',
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        child: SizedBox(
                          height: 42,
                          child: Center(
                            child: Text('Login',
                                style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.20),
                                    fontSize: 16, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Full Name ───────────────────────────────────────
                ResQInputField(
                  controller: _fullnameController,
                  hint: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your full name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                    if (v == null || v.isEmpty) return 'Please enter a password';
                    if (v.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Confirm Password ────────────────────────────────
                ResQInputField(
                  controller: _confirmController,
                  hint: 'Confirm password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirm,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    child: Icon(_obscureConfirm
                        ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20, color: AppColors.inputBorder),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Birth Date ──────────────────────────────────────
                ResQInputField(
                  controller: _birthDateController,
                  hint: 'Date of Birth (DD/MM/YYYY)',
                  prefixIcon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _pickBirthDate,
                  validator: (v) {
                    if (_selectedBirthDate == null) return 'Please select your date of birth';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // ── Terms row ───────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                      child: Icon(
                        _agreedToTerms ? Icons.check_box : Icons.check_box_outline_blank,
                        color: _agreedToTerms
                            ? AppColors.navy
                            : Colors.black.withValues(alpha: 0.30),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text: 'I agree to the ',
                          style: TextStyle(color: Colors.black.withValues(alpha: 0.20),
                              fontSize: 16, fontFamily: 'Inter',
                              fontWeight: FontWeight.w400, height: 1.40),
                        ),
                        const TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(color: AppColors.linkBlue,
                              fontSize: 16, fontFamily: 'Inter',
                              fontWeight: FontWeight.w500, height: 1.40),
                        ),
                        TextSpan(
                          text: ' and ',
                          style: TextStyle(color: Colors.black.withValues(alpha: 0.20),
                              fontSize: 16, fontFamily: 'Inter',
                              fontWeight: FontWeight.w400, height: 1.40),
                        ),
                        const TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: AppColors.linkBlue,
                              fontSize: 16, fontFamily: 'Inter',
                              fontWeight: FontWeight.w500, height: 1.40),
                        ),
                      ])),
                    ),
                  ],
                ),

                const SizedBox(height: 56),

                // ── Create Account button ───────────────────────────
                // Inactive (#9999CC) until terms accepted, Active (#000080) after
                GestureDetector(
                  onTap: _isLoading ? null : _handleSignUp,
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
                          : const Text('Create Account',
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
