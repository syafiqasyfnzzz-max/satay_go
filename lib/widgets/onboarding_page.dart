// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';

import 'service_card.dart';

class OnboardingPage extends StatelessWidget {
  final bool isFirstPage;
  final String imagePath;
  final String title;
  final String tagline;
  final List<Widget>? serviceCards;

  const OnboardingPage({
    super.key,
    this.isFirstPage = false,
    required this.imagePath,
    required this.title,
    required this.tagline,
    this.serviceCards,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 170),
        child: isFirstPage ? _buildIntroPage() : _buildServicePage(),
      ),
    );
  }

  Widget _buildIntroPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Container(
            width: 340,
            height: 340,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF9800),
                  Color(0xFFFF5722),
                  Color(0xFFBF360C),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withOpacity(0.45),
                  blurRadius: 35,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
             child: imagePath.isNotEmpty
    ? ClipOval(
        child: Image.asset(
          imagePath,
          width: 300,
          height: 300,
          fit: BoxFit.cover,
        ),
      )
    : const Icon(
        Icons.restaurant_menu,
        size: 160,
        color: Colors.deepOrange,
      ),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            height: 1.4,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white24),
          ),
          child: const Text(
            "Swipe to explore our services",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          "SatayGo Services",
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          tagline,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 17,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: serviceCards ??
                const [
                  ServiceCard(
                    icon: Icons.storefront,
                    title: "Pickup Ordering",
                    description:
                        "Reserve your satay and collect fresh from our stall.",
                  ),
                  SizedBox(height: 18),
                  ServiceCard(
                    icon: Icons.qr_code_scanner,
                    title: "QR & Online Payment",
                    description:
                        "Fast and secure cashless payment supported.",
                  ),
                  SizedBox(height: 18),
                  ServiceCard(
                    icon: Icons.local_dining,
                    title: "Sauce Customization",
                    description:
                        "Choose your favourite sambal and peanut sauces.",
                  ),
                  SizedBox(height: 18),
                  ServiceCard(
                    icon: Icons.whatshot,
                    title: "Fresh Grilling Process",
                    description:
                        "Every satay set is freshly grilled upon order.",
                  ),
                ],
          ),
        ),
      ],
    );
  }
}