import 'package:flutter/material.dart';
import 'package:satay_master_pro/main.dart';
import 'package:satay_master_pro/widgets/animated_gradient_background.dart';
import 'package:satay_master_pro/widgets/glowing_button.dart';
import 'package:satay_master_pro/widgets/onboarding_page.dart';
import 'package:satay_master_pro/widgets/service_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  void _onGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RoleGate()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> onboardingPages = [
      const OnboardingPage(
        isFirstPage: true,
        imagePath: 'assets/images/satay_onboarding_1.png', // Placeholder
        title: 'Satay Go! 🍢🔥',
        tagline: 'Authentic Malaysian satay grilled fresh daily.',
        
      ),
      const OnboardingPage(
        imagePath: '', // Placeholder
        title: 'Our Promise',
        tagline: 'Freshly prepared, just for you.',

        serviceCards: [
          ServiceCard(
            icon: Icons.store,
            title: 'Pickup Ordering',
            description:
                'Reserve your satay and collect fresh from our stall.',
          ),
          SizedBox(height: 24),
          ServiceCard(
            icon: Icons.qr_code_scanner,
            title: 'QR & Online Payment',
            description: 'Fast and secure cashless payment supported.',
          ),
          SizedBox(height: 24),
          ServiceCard(
            icon: Icons.blender,
            title: 'Sauce Customization',
            description: 'Choose your favourite sambal and peanut sauces.',
          ),
          SizedBox(height: 24),
          ServiceCard(
            icon: Icons.whatshot,
            title: 'Fresh Grilling Process',
            description: 'Every satay set is freshly grilled upon order.',
          ),
        ],
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: onboardingPages,
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: onboardingPages.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.deepOrange,
                  dotColor: Colors.grey,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 6,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: _currentPage == onboardingPages.length - 1
                ? GlowingButton(
                    text: 'Get Started',
                    onPressed: _onGetStarted,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlowingButton(
                        text: 'Skip',
                        onPressed: _onGetStarted,
                        isSkipButton: true,
                      ),
                      GlowingButton(
                        text: 'Next',
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
