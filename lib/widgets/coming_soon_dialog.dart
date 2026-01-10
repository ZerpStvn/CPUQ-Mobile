import 'package:cpuq/utils/global_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ComingSoonDialog extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;

  const ComingSoonDialog({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ComingSoonDialog(
        title: title,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: neutralWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (iconColor ?? primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  icon,
                  size: 48,
                  color: iconColor ?? primaryColor,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We\'re bringing the convenience for our students. Stay tuned for updates!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textGray,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: neutralWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Got it!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: neutralWhite,
                        fontWeight: FontWeight.w600,
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
