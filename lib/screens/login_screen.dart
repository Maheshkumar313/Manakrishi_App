import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../models/user.dart';
import 'admin/admin_dashboard.dart';
import 'farmer/farmer_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool returnOnSuccess;

  const LoginScreen({super.key, this.returnOnSuccess = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _otpSent = false;
  final _otpController = TextEditingController();
  late AnimationController _droneController;
  late Animation<double> _droneAnimation;

  @override
  void initState() {
    super.initState();
    _droneController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _droneAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _droneController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _droneController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();

      if (!_otpSent) {
        try {
          await auth.sendOTP(_phoneController.text, name: _nameController.text);
          if (mounted) {
            setState(() {
              _otpSent = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      } else {
        try {
          await auth.verifyOTP(_otpController.text);

          if (mounted) {
            // Need a tiny delay to ensure auth stream populates currentUser
            await Future.delayed(const Duration(milliseconds: 100));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Your registration is successfully confirmed! 🎉'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );

            if (widget.returnOnSuccess) {
              Navigator.of(context).pop(true);
            } else {
              if (auth.currentUser?.role == UserRole.admin) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const AdminDashboardScreen()),
                  (route) => false,
                );
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const FarmerHomeScreen()),
                  (route) => false,
                );
              }
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid OTP or error: $e')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image (New Cinematic Drone Shot)
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_drone.png',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay - Gradient from bottom to top to make text readable
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.3),
                    AppColors.primaryGreen.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Language Toggle (Top Right)
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.language,
                                  color: Colors.white),
                              tooltip: l10n.changeLanguage,
                              onPressed: () {
                                context
                                    .read<LanguageProvider>()
                                    .toggleLanguage();
                              },
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Animated Drone Icon (or keep simpler)
                        // Ideally we just rely on the background now as it is high quality

                        // App Title & tagline
                        Text(
                          l10n.appTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            shadows: [
                              const Shadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Future of Farming", // Localize ideally
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white70,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                        const SizedBox(height: 48),

                        // Glass Login Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      l10n.loginTitle,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Customized text fields for dark background
                                    _buildDarkTextField(
                                      controller: _nameController,
                                      label: l10n.enterName,
                                      icon: Icons.person_outline,
                                      readOnly: _otpSent,
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                              ? l10n.requiredField
                                              : null,
                                    ),

                                    const SizedBox(height: 16),

                                    _buildDarkTextField(
                                      controller: _phoneController,
                                      label: l10n.enterPhone,
                                      icon: Icons.phone_android_outlined,
                                      isNumber: true,
                                      readOnly: _otpSent,
                                      length: 10,
                                      validator: (value) =>
                                          (value == null || value.length != 10)
                                              ? l10n.phoneValidation
                                              : null,
                                    ),

                                    if (_otpSent) ...[
                                      const SizedBox(height: 16),
                                      _buildDarkTextField(
                                        controller: _otpController,
                                        label: "OTP",
                                        icon: Icons.lock_outline,
                                        isNumber: true,
                                        length: 6,
                                        validator: (value) =>
                                            (value == null || value.length != 6)
                                                ? l10n.requiredField
                                                : null,
                                      ),
                                    ],

                                    const SizedBox(height: 32),

                                    Consumer<AuthProvider>(
                                      builder: (context, auth, _) {
                                        return SizedBox(
                                          height: 56,
                                          child: ElevatedButton(
                                            onPressed: auth.isLoading
                                                ? null
                                                : _handleLogin,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.accentYellow,
                                              foregroundColor:
                                                  AppColors.textBlack,
                                              elevation: 8,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: auth.isLoading
                                                ? const SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color:
                                                          AppColors.textBlack,
                                                    ),
                                                  )
                                                : Text(
                                                    _otpSent
                                                        ? l10n.loginButton
                                                        : l10n.sendOtp,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        );
                                      },
                                    ),

                                    if (_otpSent)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 16.0),
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _otpSent = false;
                                              _otpController.clear();
                                            });
                                          },
                                          child: const Text(
                                            "Change Phone Number",
                                            style: TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ),
                                      ),

                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Divider(
                                                color: Colors.white
                                                    .withOpacity(0.5))),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Text(
                                            "OR",
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.7)),
                                          ),
                                        ),
                                        Expanded(
                                            child: Divider(
                                                color: Colors.white
                                                    .withOpacity(0.5))),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Google Sign-In coming soon')),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.5)),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color:
                                                Colors.white.withOpacity(0.1),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/images/google_logo.png',
                                                height: 24,
                                                width: 24,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Icon(
                                                        Icons.g_mobiledata,
                                                        color: Colors.white,
                                                        size: 36),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                "Continue with Google",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
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
                            ),
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    bool readOnly = false,
    int? length,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? [
              FilteringTextInputFormatter.digitsOnly,
              if (length != null) LengthLimitingTextInputFormatter(length),
            ]
          : null,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: AppColors.accentYellow),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accentYellow),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
