import 'package:cpuq/utils/global_theme.dart';
import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Coming Soon',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'re working hard to bring you this feature.\nStay tuned for updates!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: textGray,
                        height: 1.6,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
