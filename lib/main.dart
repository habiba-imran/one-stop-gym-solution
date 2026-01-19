import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
  url: 'https://lpidfsqqxgclqpxuekzw.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxwaWRmc3FxeGdjbHFweHVla3p3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg3MzMyMjEsImV4cCI6MjA4NDMwOTIyMX0.bmlz29GqrdtAcsMIuYiOF5EFITnyLpprM-AtL-bZ__Q',
);


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const midnight = Color(0xFF0D0D0D);
    const electricBlue = Color(0xFF007BFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'One Stop Gym Solution',
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: midnight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: electricBlue,
          brightness: Brightness.dark,
          background: midnight,
          surface: const Color(0xFF111111),
          surfaceContainerHighest: const Color(0xFF151515),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
          titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white70),
          bodyLarge: TextStyle(fontWeight: FontWeight.w300, color: Colors.white70),
          bodyMedium: TextStyle(fontWeight: FontWeight.w300, color: Colors.white60),
          labelLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1E1E1F), width: 0.6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: electricBlue, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          hintStyle: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w300),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF111111),
          contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: electricBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _joinWaitlist() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim().toLowerCase();
    try {
      await Supabase.instance.client.from('waitlist').insert({'email': email});
      if (!mounted) return;
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You’re in! Welcome to the squad.')),
      );
    } on PostgrestException catch (e) {
      if (!mounted) return;
      if (_isDuplicateError(e.code, e.message)) {
        _showDuplicateDialog();
      } else {
        _showErrorSnack('Something went wrong. Please try again.');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      if (_isDuplicateError(e.statusCode?.toString(), e.message)) {
        _showDuplicateDialog();
      } else {
        _showErrorSnack('Unable to join right now. Please retry.');
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();
      if (_isDuplicateError(null, message)) {
        _showDuplicateDialog();
      } else {
        _showErrorSnack('Unable to join right now. Please retry.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isDuplicateError(String? code, String message) {
    final lower = message.toLowerCase();
    return code == '23505' ||
        lower.contains('duplicate') ||
        lower.contains('already registered') ||
        lower.contains('already exists') ||
        lower.contains('user already registered');
  }

  void _showDuplicateDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.info, color: Color(0xFF007BFF)),
                  SizedBox(width: 12),
                  Text(
                    'Already a Member',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'This email is already part of the squad! Try another one.',
                style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Got it', style: TextStyle(color: Color(0xFF007BFF))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email can’t be empty';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    // Background circles scale relative to screen size
    final circleLarge = shortestSide * 0.7;
    final circleSmall = shortestSide * 0.55;

    return Scaffold(
      body: Stack(
        children: [
          // Atmospheric mesh background
          Positioned(
            top: -circleSmall * 0.35,
            left: -circleSmall * 0.25,
            child: Container(
              width: circleSmall,
              height: circleSmall,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF001F3F),
              ),
            ),
          ),
          Positioned(
            bottom: -circleLarge * 0.4,
            right: -circleLarge * 0.3,
            child: Container(
              width: circleLarge,
              height: circleLarge,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2B004F),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.black.withOpacity(0.45)),
            ),
          ),
          // Content with subtle entrance animation
          Positioned.fill(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width < 600 ? 16 : 20,
                      vertical: size.height < 700 ? 24 : 32,
                    ),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const HeroSection(),
                          SizedBox(height: size.height * 0.06),
                          const FeaturesSection(),
                          SizedBox(height: size.height * 0.06),
                          // Center CTA for tablets / large screens
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 640),
                              child: CtaSection(
                                emailController: _emailController,
                                formKey: _formKey,
                                validateEmail: _validateEmail,
                                onJoinWaitlist: _joinWaitlist,
                                isLoading: _isLoading,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.04),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final minHeroHeight = size.height * (isMobile ? 0.45 : 0.55);
    final targetHeroHeight = minHeroHeight.clamp(260.0, 520.0);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: targetHeroHeight,
        maxHeight: targetHeroHeight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.6, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: const Image(
                image: AssetImage('assets/images/gym_hero.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 20 : 32),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'One Stop Solution for Modern Gyms',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: isMobile ? 28 : 40,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'A premium platform built for trainers, owners, and athletes. '
                        'Manage members, programs, nutrition, and bookings with zero friction.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: isMobile ? 14 : 18,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withOpacity(0.7),
                            ),
                      ),
                    ],
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

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cards = [
      FeatureCard(
        title: 'Find Nearby Gyms',
        caption: 'Smart discovery, live capacity and trusted reviews.',
        icon: Icons.location_searching,
        accent: colorScheme.primary,
      ),
      FeatureCard(
        title: 'Track Your Diet',
        caption: 'Macro-aware plans synced with your wearables.',
        icon: Icons.restaurant_menu,
        accent: Colors.purpleAccent,
      ),
      FeatureCard(
        title: 'Personalized Workouts',
        caption: 'Adaptive programming tuned by your performance.',
        icon: Icons.flash_on,
        accent: Colors.tealAccent,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;
        return Wrap(
          spacing: 18,
          runSpacing: 18,
          children: cards
              .map(
                (card) => SizedBox(
                  width: isCompact
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 18 * 2) / 3,
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String caption;
  final IconData icon;
  final Color accent;

  const FeatureCard({
    super.key,
    required this.title,
    required this.caption,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                caption,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CtaSection extends StatelessWidget {
  final TextEditingController emailController;
  final GlobalKey<FormState> formKey;
  final String? Function(String?) validateEmail;
  final VoidCallback onJoinWaitlist;
  final bool isLoading;

  const CtaSection({
    super.key,
    required this.emailController,
    required this.formKey,
    required this.validateEmail,
    required this.onJoinWaitlist,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Claim your spot',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Join the waitlist and unlock the next era of gym operations.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Form(
            key: formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isStacked = constraints.maxWidth < 640;
              final field = TextFormField(
                controller: emailController,
                validator: validateEmail,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                ),
              );

                final button = DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6), // Only shows the shadow below the button
                      ),
                    ],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onJoinWaitlist,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Join Waitlist'),
                  ),
                );

                if (isStacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      field,
                      const SizedBox(height: 12),
                      button,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: field),
                    const SizedBox(width: 12),
                    button,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
