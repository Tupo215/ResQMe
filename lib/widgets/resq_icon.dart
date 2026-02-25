import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─── ResQ Icon Widget ─────────────────────────────────────────────────────────
// Usage: ResQIcon(ResQIcons.sos, size: 24, color: Colors.white)
class ResQIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;

  const ResQIcon(this.asset, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/icons/$asset',
    width: size,
    height: size,
    colorFilter: color != null
        ? ColorFilter.mode(color!, BlendMode.srcIn)
        : null,
  );
}

// ─── Icon name constants ──────────────────────────────────────────────────────
class ResQIcons {
  // Navigation
  static const String sos         = 'streamline-flex_sos-help-emergency-sign-remix.svg';
  static const String history     = 'material-symbols_history-rounded.svg';
  static const String settings    = 'eva_settings-2-fill.svg';
  static const String home        = 'line-md_home-twotone.svg';
  static const String menu        = 'tabler_menu-3.svg';

  // SOS & Emergency
  static const String emergency   = 'material-symbols_emergency.svg';
  static const String emergencyHome = 'material-symbols_emergency-home.svg';
  static const String emergencyShare = 'material-symbols-light_emergency-share.svg';
  static const String alertFill   = 'Drop down body/ri_alert-fill.svg';
  static const String alert       = 'jam_alert.svg';

  // Emergency categories
  static const String carAccident = 'la_car-side.svg';
  static const String medical     = 'material-symbols_monitor-heart-outline.svg';
  static const String injury      = 'mdi_account-injury-outline.svg';
  static const String fire        = 'mdi_fire.svg';
  static const String violence    = 'material-symbols_warning-outline.svg';
  static const String other       = 'basil_other-1-outline.svg';

  // Quick actions
  static const String hospital    = 'healthicons_emergency-post-outline.svg';
  static const String firstAid    = 'bxs_first-aid.svg';
  static const String ambulance   = 'uil_ambulance.svg';
  static const String phone       = 'ic_baseline-phone.svg';
  static const String phoneOutline = 'ic_outline-phone.svg';

  // User / Profile
  static const String user        = 'tabler_user.svg';
  static const String userSolid   = 'flowbite_user-solid.svg';
  static const String userPlus    = 'bxs_user-plus.svg';
  static const String userMultiple = 'carbon_user-multiple.svg';
  static const String userDoctor  = 'fa7-solid_user-doctor.svg';

  // Location / Map
  static const String locationPin = 'streamline-plump_location-pin-solid.svg';
  static const String locationPinOutline = 'streamline-plump_location-pin.svg';
  static const String gps         = 'solar_gps-bold.svg';
  static const String gpsLinear   = 'solar_gps-linear.svg';
  static const String gpsThin     = 'ph_gps-thin.svg';
  static const String map         = 'material-symbols_map.svg';
  static const String mapOutline  = 'material-symbols_map-outline.svg';

  // AI / Bot
  static const String bot         = 'bx_bot.svg';
  static const String aiLine      = 'si_ai-line.svg';
  static const String voiceAI     = 'ri_voice-ai-line.svg';
  static const String stars       = 'mdi_stars.svg';

  // Actions
  static const String arrowRight  = 'mdi-light_arrow-right.svg';
  static const String chevronRight = 'akar-icons_chevron-right.svg';
  static const String chevronLeft = 'akar-icons_chevron-left.svg';
  static const String chevronDown = 'akar-icons_chevron-down.svg';
  static const String chevronUp   = 'meteor-icons_chevron-up.svg';
  static const String arrowUp     = 'mingcute_arrow-up-line.svg';
  static const String close       = 'material-symbols_close-rounded.svg';
  static const String closeCircle = 'line-md_close-circle-filled.svg';
  static const String cancel      = 'proicons_cancel.svg';
  static const String checkCircle = 'material-symbols_check-circle-rounded.svg';
  static const String check       = 'material-symbols_check-rounded.svg';
  static const String add         = 'basil_add-solid.svg';
  static const String addOutline  = 'basil_add-outline.svg';
  static const String minus       = 'ic_round-minus.svg';
  static const String delete      = 'tdesign_delete-1-filled.svg';
  static const String share       = 'mynaui_share.svg';
  static const String upload      = 'prime_upload.svg';
  static const String send        = 'mynaui_send-solid.svg';
  static const String sendOutline = 'mynaui_send.svg';
  static const String filter      = 'mage_filter.svg';
  static const String filterFill  = 'mage_filter-fill.svg';
  static const String search      = 'ep_search.svg';

  // Security / Auth
  static const String lock        = 'material-symbols_lock.svg';
  static const String lockOutline = 'material-symbols_lock-outline.svg';
  static const String shieldLock  = 'material-symbols_shield-lock.svg';
  static const String shield      = 'material-symbols_shield-rounded.svg';
  static const String shieldOutline = 'material-symbols_shield-outline-rounded.svg';
  static const String shieldHeart = 'material-symbols-light_shield-with-heart-rounded.svg';
  static const String shieldPlus  = 'jam_shield-plus-f.svg';
  static const String faceId      = 'mynaui_face-id-solid.svg';
  static const String fingerprint = 'material-symbols_fingerprint.svg';
  static const String eyeOff      = 'mdi-light_eye-off.svg';
  static const String eye         = 'lets-icons_eye-light.svg';

  // Communication
  static const String message     = 'uiw_message.svg';
  static const String chat        = 'fluent_chat-12-regular.svg';
  static const String mail        = 'material-symbols-light_mail.svg';
  static const String mailOutline = 'material-symbols-light_mail-outline.svg';
  static const String volume      = 'uil_volume.svg';
  static const String microphone  = 'mdi_microphone.svg';
  static const String microphoneLight = 'mdi-light_microphone.svg';
  static const String voice       = 'mingcute_voice-line.svg';
  static const String support     = 'streamline-flex_customer-support-7-solid.svg';
  static const String headphones  = 'streamline-freehand_help-headphones-customer-support-human.svg';
  static const String phoneAdd    = 'mage_phone-plus-fill.svg';

  // Media
  static const String play        = 'gridicons_play.svg';
  static const String pause       = 'gridicons_pause.svg';
  static const String camera      = 'mdi_camera.svg';
  static const String cameraOutline = 'mdi_camera-outline.svg';
  static const String image       = 'ri_image-fill.svg';
  static const String imageOutline = 'ri_image-line.svg';

  // Info / Status
  static const String info        = 'material-symbols_info.svg';
  static const String infoOutline = 'material-symbols_info-outline.svg';
  static const String question    = 'ep_question-filled.svg';
  static const String bulb        = 'ion_bulb-outline.svg';
  static const String healthMetrics = 'material-symbols_health-metrics.svg';
  static const String bloodtype   = 'material-symbols_bloodtype-rounded.svg';

  // Settings / Profile
  static const String settingsLine = 'ri_settings-5-line.svg';
  static const String edit        = 'ri_edit-line.svg';
  static const String editFill    = 'ri_edit-fill.svg';
  static const String logout      = 'material-symbols_logout.svg';
  static const String language    = 'ion_language-outline.svg';
  static const String globe       = 'uil_globe.svg';
  static const String contact     = 'mdi_contact.svg';
  static const String contactOutline = 'mdi_contact-outline.svg';
  static const String note        = 'proicons_note.svg';
  static const String noteText    = 'majesticons_note-text.svg';
  static const String pen         = 'solar_pen-line-duotone.svg';
  static const String keypad      = 'mdi_keypad.svg';
  static const String notifications = 'material-symbols-light_notifications.svg';
  static const String notificationsOutline = 'material-symbols-light_notifications-outline-rounded.svg';
  static const String notificationsOff = 'material-symbols-light_notifications-off-outline.svg';
  static const String toggle      = 'fa-solid_toggle-on.svg';

  // Misc
  static const String radioOn     = 'ion_radio-button-on-sharp.svg';
  static const String radioOff    = 'ion_radio-button-off.svg';
  static const String radioFill   = 'ph_radio-button-fill.svg';
  static const String checkboxChecked = 'fluent_checkbox-checked-20-filled.svg';
  static const String checkboxUnchecked = 'fluent_checkbox-unchecked-20-filled.svg';
  static const String moreOutlined = 'ant-design_more-outlined.svg';
  static const String flagNigeria = 'twemoji_flag-nigeria.svg';
  static const String vector      = 'Vector.svg';
  static const String emergencyExit = 'mdi_emergency-exit.svg';
  static const String carEmergency = 'mdi_car-emergency.svg';
  static const String time        = 'mingcute_time-fill.svg';
  static const String timeOutline = 'mingcute_time-line.svg';
}
