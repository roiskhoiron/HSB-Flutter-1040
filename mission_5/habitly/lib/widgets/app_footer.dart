import 'package:flutter/material.dart';

class AppFooter extends StatefulWidget {
  const AppFooter({super.key});

  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  bool isExpanded = false;

  void toggleFooter() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: MouseRegion(
        onEnter: (_) {
          if (!isExpanded) {
            setState(() => isExpanded = true);
          }
        },
        onExit: (_) {
          setState(() => isExpanded = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: isExpanded ? null : 80,
          padding: EdgeInsets.all(isExpanded ? 20 : 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2FB969),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isExpanded ? 20 : 0),
              topRight: Radius.circular(isExpanded ? 20 : 0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isExpanded ? _buildExpandedContent() : _buildCollapsedContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Center(
      key: const ValueKey('collapsed'),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.info_outline,
          color: Color(0xFF2FB969),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      key: const ValueKey('expanded'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Habitly",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: toggleFooter,
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white,
              ),
              tooltip: 'Tutup',
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Contact Info
        _buildInfoRow("📍", "Batam, Kepulauan Riau, Indonesia"),
        const SizedBox(height: 6),
        _buildInfoRow("📞", "+62 812-3456-7890"),
        const SizedBox(height: 12),

        // Company Info
        _buildInfoRow("🏢", "PT Habitly Sehat Teknologi"),
        const SizedBox(height: 6),
        _buildInfoRow("👥", "Komunitas: Flutter Dev Indonesia"),
        const SizedBox(height: 6),
        _buildInfoRow("👨‍💻", "Creator: Randy"),
        const SizedBox(height: 12),

        const Divider(color: Colors.white54, thickness: 1),
        const SizedBox(height: 8),

        const Center(
          child: Text(
            "© 2026 Habitly - All Rights Reserved",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String icon, String text) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}