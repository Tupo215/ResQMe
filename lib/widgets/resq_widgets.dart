import 'package:flutter/material.dart';

// ─── Brand Colors (Figma exact) ───────────────────────────────────────────────
class AppColors {
  static const Color background  = Color(0xFFEFEFF1);
  static const Color navy        = Color(0xFF000080);
  static const Color navyLight   = Color(0xFF9999CC);
  static const Color inputBg     = Color(0xFFF3F3F5);
  static const Color inputBorder = Color(0xFFA7A7A7);
  static const Color hintText    = Color(0xFF7B7B7B);
  static const Color linkBlue    = Color(0xFF1E40AF);
  static const Color errorRed    = Color(0xFFDC2626);
  static const Color successGreen= Color(0xFF16A34A);
  static const Color divider     = Color(0xFF232323);
}

// ─── Shared Input Field ───────────────────────────────────────────────────────
class ResQInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  const ResQInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.hintText,
          fontSize: 16,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.inputBorder, size: 20),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 24, minHeight: 24),
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding: const EdgeInsets.all(16),
        border: _border(AppColors.inputBorder, 1),
        enabledBorder: _border(AppColors.inputBorder, 1),
        focusedBorder: _border(AppColors.navy, 1.5),
        errorBorder: _border(AppColors.errorRed, 1.5),
        focusedErrorBorder: _border(AppColors.errorRed, 1.5),
        errorStyle: const TextStyle(
          color: AppColors.errorRed,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
}

// ─── Primary CTA Button ───────────────────────────────────────────────────────
class ResQButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const ResQButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: ShapeDecoration(
          color: isLoading ? AppColors.navyLight : AppColors.navyLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFEFEFF1)),
                  ),
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFEFEFF1),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.40,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Status Bar (Figma accurate) ──────────────────────────────────────────────
class ResQStatusBar extends StatelessWidget {
  const ResQStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      padding: const EdgeInsets.only(top: 16, left: 35, right: 20, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('9:41',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500)),
          Row(
            children: const [
              Icon(Icons.signal_cellular_alt, size: 16, color: Colors.black),
              SizedBox(width: 4),
              Icon(Icons.wifi, size: 16, color: Colors.black),
              SizedBox(width: 4),
              Icon(Icons.battery_full, size: 18, color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Logo + Tagline header (shared across screens) ────────────────────────────
class ResQHeader extends StatelessWidget {
  const ResQHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 239,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Image.asset(
              'assets/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Emergency help. One tap away.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.20),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.40,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Row (Sign Up | Login) ────────────────────────────────────────────────
class ResQTabRow extends StatelessWidget {
  /// 0 = Sign Up active, 1 = Login active
  final int activeIndex;
  final VoidCallback onSignUpTap;
  final VoidCallback onLoginTap;

  const ResQTabRow({
    super.key,
    required this.activeIndex,
    required this.onSignUpTap,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          _buildTab('Sign Up', 0, onSignUpTap),
          _buildTab('Login',   1, onLoginTap),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, VoidCallback onTap) {
    final isActive = activeIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 196,
        height: 42,
        child: Stack(
          children: [
            Positioned(
              left: 0, top: 0,
              child: Container(
                width: 196,
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isActive
                            ? AppColors.navy
                            : Colors.black.withValues(alpha: 0.20),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isActive)
              Container(
                width: 196,
                height: 42,
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Phone field (static display, Figma design) ───────────────────────────────
class ResQPhoneField extends StatelessWidget {
  const ResQPhoneField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppColors.inputBg,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, size: 20, color: AppColors.inputBorder),
          const SizedBox(width: 8),
          Text(
            '+234',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.20),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 24, color: AppColors.divider),
          const SizedBox(width: 10),
          const Text(
            'e.g. 00 0000 0000',
            style: TextStyle(
              color: AppColors.inputBorder,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── OR Divider ───────────────────────────────────────────────────────────────
class ResQOrDivider extends StatelessWidget {
  const ResQOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 153, height: 1, color: AppColors.inputBorder),
        const SizedBox(width: 12),
        Text(
          'Or',
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.20),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.40,
          ),
        ),
        const SizedBox(width: 12),
        Container(width: 153, height: 1, color: AppColors.inputBorder),
      ],
    );
  }
}

// ─── SnackBar helper ──────────────────────────────────────────────────────────
void showResQSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.errorRed : AppColors.successGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ),
  );
}
