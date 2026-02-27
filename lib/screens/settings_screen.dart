import 'package:flutter/material.dart';
import '../widgets/resq_widgets.dart';
import '../widgets/resq_icon.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'medical_profile_screen.dart';
import 'personal_profile_screen.dart';
import 'emergency_contact_screen.dart';
import 'privacy_data_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _muteNotifications = false;
  bool _liveLocation = true;
  bool _contactAutoAlert = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16, top: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFEFF1),
                border: Border(bottom: BorderSide(color: Color(0xFFD3D3D3))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD3D3D3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    child: ResQIcon(ResQIcons.settings, size: 24,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text('Settings',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24, fontFamily: 'Inter',
                          fontWeight: FontWeight.w600, height: 1.40)),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Account
                    _sectionLabel('Account'),
                    const SizedBox(height: 8),
                    _settingsGroup([
                      _SettingsTile(
                        iconAsset: ResQIcons.healthMetrics,
                        label: 'Medical profile',
                        trailing: _chevron,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MedicalProfileScreen())),
                      ),
                      _SettingsTile(
                        iconAsset: ResQIcons.userSolid,
                        label: 'Account profile',
                        trailing: _chevron,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const PersonalProfileScreen())),
                      ),
                      _SettingsTile(
                        iconAsset: ResQIcons.phoneAdd,
                        label: 'Emergency contact',
                        trailing: _chevron,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const EmergencyContactScreen())),
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Notification
                    _sectionLabel('Notification'),
                    const SizedBox(height: 8),
                    _settingsGroup([
                      _SettingsTile(
                        iconAsset: ResQIcons.notificationsOff,
                        label: 'Mute notifications',
                        subtitle: 'All notifications will be muted if turned on.',
                        trailing: Switch(
                          value: _muteNotifications,
                          onChanged: (v) => setState(() => _muteNotifications = v),
                          activeColor: AppColors.navy,
                        ),
                      ),
                      _SettingsTile(
                        iconAsset: ResQIcons.gps,
                        label: 'Live location sharing',
                        subtitle: 'Live location will be shared during emergency',
                        trailing: Switch(
                          value: _liveLocation,
                          onChanged: (v) => setState(() => _liveLocation = v),
                          activeColor: AppColors.navy,
                        ),
                      ),
                      _SettingsTile(
                        iconAsset: ResQIcons.phoneAdd,
                        label: 'Contact-auto alert',
                        subtitle: 'Your contact will automatically be alerted',
                        trailing: Switch(
                          value: _contactAutoAlert,
                          onChanged: (v) => setState(() => _contactAutoAlert = v),
                          activeColor: AppColors.navy,
                        ),
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // App preference
                    _sectionLabel('App preference'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF3F3F5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        shadows: const [BoxShadow(color: Color(0x19000000),
                            blurRadius: 10)],
                      ),
                      child: Row(children: [
                        _iconBox(ResQIcons.language),
                        const SizedBox(width: 24),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Language',
                                style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.20),
                                    fontSize: 16, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                            const Text('English',
                                style: TextStyle(color: Color(0xFFA7A7A7),
                                    fontSize: 12, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400, height: 1.40)),
                          ],
                        )),
                        _chevron,
                      ]),
                    ),

                    const SizedBox(height: 24),

                    // Privacy
                    _sectionLabel('Privacy'),
                    const SizedBox(height: 8),
                    _settingsGroup([
                      _SettingsTile(
                          iconAsset: ResQIcons.shieldLock,
                          label: 'Privacy & Data',
                          trailing: _chevron,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const PrivacyDataScreen()))),
                      _SettingsTile(
                          iconAsset: ResQIcons.shield,
                          label: 'Privacy Policy',
                          trailing: const SizedBox()),
                      _SettingsTile(
                          iconAsset: ResQIcons.note,
                          label: 'Terms of Service',
                          trailing: const SizedBox(),
                          isLast: true),
                    ]),

                    const SizedBox(height: 24),

                    // Support
                    _sectionLabel('Support'),
                    const SizedBox(height: 8),
                    _settingsGroup([
                      _SettingsTile(
                          iconAsset: ResQIcons.infoOutline,
                          label: 'About ResQMe',
                          trailing: const SizedBox()),
                      _SettingsTile(
                          iconAsset: ResQIcons.support,
                          label: 'Help center',
                          trailing: const SizedBox()),
                      _SettingsTile(
                          iconAsset: ResQIcons.headphones,
                          label: 'Contact Support',
                          trailing: const SizedBox(),
                          isLast: true),
                    ]),

                    const SizedBox(height: 24),

                    // Danger Zone
                    _sectionLabel('Danger Zone'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFAE5E5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        shadows: const [BoxShadow(
                            color: Color(0x19D00000), blurRadius: 10)],
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF6CCCC),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: ResQIcon(ResQIcons.delete, size: 24,
                              color: const Color(0xFFD00000)),
                        ),
                        const SizedBox(width: 24),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Delete Account',
                                style: TextStyle(color: Color(0xFFD00000),
                                    fontSize: 16, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                            Text('Permanently erase all your data',
                                style: TextStyle(color: Color(0xFFD00000),
                                    fontSize: 12, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400, height: 1.40)),
                          ],
                        )),
                      ]),
                    ),

                    const SizedBox(height: 32),

                    // Logout
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        onPressed: () async {
                          await ResQApiService.logout();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (_) => false,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ResQIcon(ResQIcons.logout, size: 24,
                                color: const Color(0xFFEFEFF1)),
                            const SizedBox(width: 8),
                            const Text('Logout',
                                style: TextStyle(color: Color(0xFFEFEFF1),
                                    fontSize: 16, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Center(
                      child: Text('Version 1.1 (MVP)',
                          style: TextStyle(color: Color(0xFF7B7B7B),
                              fontSize: 14, fontFamily: 'Inter',
                              fontWeight: FontWeight.w400, height: 1.40)),
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

  Widget _sectionLabel(String text) => Text(text,
      style: TextStyle(color: Colors.black.withValues(alpha: 0.20),
          fontSize: 14, fontFamily: 'Inter',
          fontWeight: FontWeight.w600, height: 1.40));

  Widget _settingsGroup(List<_SettingsTile> tiles) => Container(
    decoration: BoxDecoration(
      boxShadow: const [BoxShadow(color: Color(0x19000000),
          blurRadius: 10)],
    ),
    child: Column(children: tiles),
  );

  Widget _iconBox(String iconAsset) => Container(
    padding: const EdgeInsets.all(10),
    decoration: ShapeDecoration(
      color: const Color(0xFFCCCCE6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    child: ResQIcon(iconAsset, size: 24, color: AppColors.navy),
  );

  Widget get _chevron => ResQIcon(ResQIcons.chevronRight, size: 24,
      color: Colors.black.withValues(alpha: 0.20));
}

// ─── Settings Tile ────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String? subtitle;
  final Widget trailing;
  final bool isLast;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.iconAsset,
    required this.label,
    required this.trailing,
    this.subtitle,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: const Color(0xFFF3F3F5),
          shape: RoundedRectangleBorder(
            borderRadius: isLast
                ? const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16))
                : BorderRadius.zero,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: ShapeDecoration(
              color: const Color(0xFFCCCCE6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: ResQIcon(iconAsset, size: 24, color: AppColors.navy),
          ),
          const SizedBox(width: 24),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.20),
                      fontSize: 16, fontFamily: 'Inter',
                      fontWeight: FontWeight.w500, height: 1.40)),
              if (subtitle != null)
                Text(subtitle!,
                    style: const TextStyle(color: Color(0xFFA7A7A7),
                        fontSize: 12, fontFamily: 'Inter',
                        fontWeight: FontWeight.w400, height: 1.40)),
            ],
          )),
          trailing,
        ]),
      ),
    );
  }
}
