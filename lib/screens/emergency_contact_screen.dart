import 'package:flutter/material.dart';
import '../widgets/resq_widgets.dart';
import '../widgets/resq_icon.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});
  @override
  State<EmergencyContactScreen> createState() =>
      _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final List<_Contact> _contacts = [
    _Contact(name: 'John Smith', relationship: 'Spouse',
        email: 'johnsmith@gmail.com',
        tags: [_Tag('Primary', AppColors.navy, Colors.white),
          _Tag('Family', const Color(0xFFCCCCE6), AppColors.navy)]),
    _Contact(name: 'Mary Johnson', relationship: 'Parent',
        email: 'maryjohn@gmail.com',
        tags: [_Tag('Family', const Color(0xFFCCCCE6), AppColors.navy)]),
    _Contact(name: 'David Williams', relationship: 'Friend',
        email: 'davidwillie@gmail.com',
        tags: [_Tag('Friend', const Color(0xFFA7A7A7),
            const Color(0xFF232323))]),
  ];

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
              padding: const EdgeInsets.only(
                  left: 24, right: 24, bottom: 16, top: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Emergency Contacts',
                      style: const TextStyle(color: Color(0xFF0A0A0A),
                          fontSize: 24, fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400, height: 1.33)),
                  ResQIcon(ResQIcons.userPlus, size: 36,
                      color: AppColors.navy),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'People listed here will be notified in case of an SOS alert.',
                        style: TextStyle(color: Color(0xFF7B7B7B),
                            fontSize: 14, fontFamily: 'Inter',
                            fontWeight: FontWeight.w400, height: 1.40)),
                    const SizedBox(height: 8),
                    ..._contacts.map((c) => _contactCard(c)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // ── Bottom action bar ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                    top: BorderSide(color: Color(0xFFE5E7EB), width: 1.27)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 50, offset: const Offset(0, 25),
                      spreadRadius: -12),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9999CC),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                      ),
                      onPressed: () => _showAddContactSheet(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ResQIcon(ResQIcons.add, size: 24,
                              color: const Color(0xFFEFEFF1)),
                          const SizedBox(width: 8),
                          const Text('Add Contact',
                              style: TextStyle(color: Color(0xFFEFEFF1),
                                  fontSize: 16, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500, height: 1.40)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD00000),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ResQIcon(ResQIcons.emergency, size: 24,
                              color: const Color(0xFFEFEFF1)),
                          const SizedBox(width: 8),
                          const Text('SOS- Emergency Alert',
                              style: TextStyle(color: Color(0xFFEFEFF1),
                                  fontSize: 16, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500, height: 1.40)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard(_Contact c) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.fromLTRB(21, 21, 21, 4),
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1.27, color: Color(0xFFEFEFF1)),
        borderRadius: BorderRadius.circular(16),
      ),
      shadows: const [
        BoxShadow(color: Color(0x19000000), blurRadius: 4,
            offset: Offset(0, 2), spreadRadius: -2),
        BoxShadow(color: Color(0x19000000), blurRadius: 6,
            offset: Offset(0, 4), spreadRadius: -1),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Drag handle placeholder
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ResQIcon(ResQIcons.moreOutlined, size: 20,
                color: const Color(0xFFD3D3D3)),
          ),
          const SizedBox(width: 16),

          // Avatar
          Container(
            width: 56, height: 56,
            decoration: ShapeDecoration(
              color: const Color(0xFFCCCCE6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(64)),
            ),
            alignment: Alignment.center,
            child: Text(c.name.substring(0, 1),
                style: const TextStyle(color: AppColors.navy,
                    fontSize: 22, fontFamily: 'Inter',
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 24),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.20),
                        fontSize: 16, fontFamily: 'Inter',
                        fontWeight: FontWeight.w400, height: 1.40)),
                const SizedBox(height: 4),

                // Tags
                Wrap(spacing: 8, children: c.tags
                    .map((t) => _tagPill(t)).toList()),

                const SizedBox(height: 8),
                Text(c.relationship,
                    style: const TextStyle(color: Color(0xFF7B7B7B),
                        fontSize: 14, fontFamily: 'Inter',
                        fontWeight: FontWeight.w400, height: 1.40)),
                Text(c.email,
                    style: const TextStyle(color: Color(0xFF4F4F4F),
                        fontSize: 16, fontFamily: 'Inter',
                        fontWeight: FontWeight.w400, height: 1.40)),
              ],
            ),
          ),

          // Delete
          GestureDetector(
            onTap: () => setState(() => _contacts.remove(c)),
            child: Container(
              width: 48, height: 48,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              alignment: Alignment.center,
              child: ResQIcon(ResQIcons.delete, size: 24,
                  color: const Color(0xFFD00000)),
            ),
          ),
        ]),

        const SizedBox(height: 12),

        // Email button
        Container(
          width: double.infinity, height: 50,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFF9999CC)),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ResQIcon(ResQIcons.mail, size: 24,
                  color: Colors.black.withValues(alpha: 0.20)),
              const SizedBox(width: 8),
              Text('Email',
                  style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.20),
                      fontSize: 16, fontFamily: 'Inter',
                      fontWeight: FontWeight.w500, height: 1.40)),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    ),
  );

  Widget _tagPill(_Tag tag) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: ShapeDecoration(
      color: tag.bg,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)),
    ),
    child: Text(tag.label,
        style: TextStyle(color: tag.fg, fontSize: 12,
            fontFamily: 'Inter', fontWeight: FontWeight.w400,
            height: 1.40)),
  );

  void _showAddContactSheet() {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final relCtrl   = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24,
            MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Emergency Contact',
                style: TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: Color(0xFF00004D))),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: relCtrl,
                decoration: const InputDecoration(
                    labelText: 'Relationship',
                    border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40))),
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    setState(() => _contacts.add(_Contact(
                        name: nameCtrl.text,
                        relationship: relCtrl.text.isEmpty
                            ? 'Contact' : relCtrl.text,
                        email: emailCtrl.text,
                        tags: [])));
                  }
                  Navigator.pop(context);
                },
                child: const Text('Add Contact',
                    style: TextStyle(color: Colors.white,
                        fontFamily: 'Inter', fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Contact {
  final String name, relationship, email;
  final List<_Tag> tags;
  const _Contact({required this.name, required this.relationship,
    required this.email, required this.tags});
}

class _Tag {
  final String label;
  final Color bg, fg;
  const _Tag(this.label, this.bg, this.fg);
}
