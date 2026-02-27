import 'package:flutter/material.dart';
import '../widgets/resq_icon.dart';

// ─── Data model ───────────────────────────────────────────────────────────────
class _SosEntry {
  final String date;
  final String time;
  final String duration;
  final List<_NotifiedContact> contacts;
  _SosEntry({required this.date, required this.time,
    required this.duration, required this.contacts});
}

class _NotifiedContact {
  final String initials;
  final String name;
  final String notifiedTime;
  final bool delivered;
  const _NotifiedContact({
    required this.initials, required this.name,
    required this.notifiedTime, this.delivered = true,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class SosHistoryScreen extends StatelessWidget {
  const SosHistoryScreen({super.key});

  static final _history = [
    _SosEntry(
      date: 'February 13, 2026', time: '3:33 AM', duration: '15 min',
      contacts: [
        _NotifiedContact(initials: 'JS', name: 'John Smith',    notifiedTime: '3:57 AM'),
        _NotifiedContact(initials: 'MJ', name: 'Mary Johnson',  notifiedTime: '3:57 AM'),
        _NotifiedContact(initials: 'DW', name: 'David Williams',notifiedTime: '3:57 AM'),
      ],
    ),
    _SosEntry(
      date: 'February 3, 2026', time: '12:58 AM', duration: '15 min',
      contacts: [
        _NotifiedContact(initials: 'JS', name: 'John Smith',    notifiedTime: '3:57 AM'),
        _NotifiedContact(initials: 'MJ', name: 'Mary Johnson',  notifiedTime: '3:57 AM'),
        _NotifiedContact(initials: 'DW', name: 'David Williams',notifiedTime: '3:57 AM'),
      ],
    ),
    _SosEntry(
      date: 'January 25, 2026', time: '1:00 PM', duration: '15 min',
      contacts: [
        _NotifiedContact(initials: 'JS', name: 'John Smith',    notifiedTime: '3:57 AM'),
        _NotifiedContact(initials: 'MJ', name: 'Mary Johnson',  notifiedTime: '3:57 AM'),
        _NotifiedContact(initials: 'DW', name: 'David Williams',notifiedTime: '3:57 AM'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16, top: 16),
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1.27, color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44, height: 44,
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFD3D3D3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      child: ResQIcon(ResQIcons.chevronLeft, size: 22, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('SOS History',
                      style: TextStyle(
                          color: Color(0xFF000080),
                          fontSize: 24, fontFamily: 'Inter',
                          fontWeight: FontWeight.w600, height: 1.40)),
                ],
              ),
            ),

            // ── History list ──────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                itemCount: _history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (_, i) => _SosCard(entry: _history[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Single SOS history card ─────────────────────────────────────────────────
class _SosCard extends StatelessWidget {
  final _SosEntry entry;
  const _SosCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.27, color: Color(0xFFF3F3F5)),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Timestamp row ─────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            decoration: const ShapeDecoration(
              color: Color(0xFFEFEFF1),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.27, color: Color(0xFF000080)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.date,
                        style: const TextStyle(color: Color(0xFF000080),
                            fontSize: 14, fontFamily: 'Inter',
                            fontWeight: FontWeight.w400, height: 1.40)),
                    Text(entry.time,
                        style: const TextStyle(color: Color(0xFF000080),
                            fontSize: 16, fontFamily: 'Inter',
                            fontWeight: FontWeight.w600, height: 1.40)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.timer_outlined,
                          size: 20, color: Color(0xFF000080)),
                      const SizedBox(width: 8),
                      Text(entry.duration,
                          style: const TextStyle(color: Color(0xFF000080),
                              fontSize: 16, fontFamily: 'Inter',
                              fontWeight: FontWeight.w400, height: 1.40)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 20, color: Color(0xFF000080)),
                      const SizedBox(width: 8),
                      const Text('Location shared',
                          style: TextStyle(color: Color(0xFF000080),
                              fontSize: 14, fontFamily: 'Inter',
                              fontWeight: FontWeight.w400, height: 1.40)),
                    ]),
                  ],
                ),
              ],
            ),
          ),

          // ── Contacts section ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contacts Notified:',
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.20),
                        fontSize: 16, fontFamily: 'Inter',
                        fontWeight: FontWeight.w600, height: 1.40)),
                const SizedBox(height: 16),
                ...entry.contacts.map((c) => _ContactRow(contact: c)),
              ],
            ),
          ),

          // ── Footer badge ─────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
            decoration: const ShapeDecoration(
              color: Color(0xFFF3F3F5),
              shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1.27, color: Color(0xFFF3F3F5))),
            ),
            child: Row(children: [
              Container(
                width: 10, height: 10,
                decoration: ShapeDecoration(
                  color: const Color(0xFF6666B3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Emergency alert completed',
                  style: TextStyle(color: Color(0xFF7B7B7B),
                      fontSize: 14, fontFamily: 'Inter',
                      fontWeight: FontWeight.w400, height: 1.40)),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Contact row in history card ─────────────────────────────────────────────
class _ContactRow extends StatelessWidget {
  final _NotifiedContact contact;
  const _ContactRow({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            // Avatar with initials
            Container(
              width: 48, height: 48,
              decoration: const ShapeDecoration(
                color: Color(0xFF000080),
                shape: CircleBorder(),
              ),
              child: Center(
                child: Text(contact.initials,
                    style: const TextStyle(color: Colors.white,
                        fontSize: 14, fontFamily: 'Inter',
                        fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name,
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.20),
                        fontSize: 15, fontFamily: 'Inter',
                        fontWeight: FontWeight.w400, height: 1.40)),
                Text(contact.notifiedTime,
                    style: const TextStyle(color: Color(0xFF7B7B7B),
                        fontSize: 13, fontFamily: 'Inter',
                        fontWeight: FontWeight.w400, height: 1.40)),
              ],
            ),
          ]),
          // Delivered status
          Row(children: [
            Icon(Icons.check_circle_outline,
                size: 18,
                color: contact.delivered ? const Color(0xFF2E7D32) : const Color(0xFF7B7B7B)),
            const SizedBox(width: 4),
            Text(contact.delivered ? 'Delivered' : 'Pending',
                style: TextStyle(
                    color: contact.delivered ? const Color(0xFF2E7D32) : const Color(0xFF7B7B7B),
                    fontSize: 13, fontFamily: 'Inter',
                    fontWeight: FontWeight.w400, height: 1.40)),
          ]),
        ],
      ),
    );
  }
}
