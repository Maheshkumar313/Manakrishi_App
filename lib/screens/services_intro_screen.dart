import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/colors.dart';
import 'farmer/create_booking_screen.dart';
import 'farmer/farmer_home_screen.dart';
import 'service_detail_screen.dart';

class ServicesIntroScreen extends StatefulWidget {
  const ServicesIntroScreen({super.key});

  @override
  State<ServicesIntroScreen> createState() => _ServicesIntroScreenState();
}

class _ServicesIntroScreenState extends State<ServicesIntroScreen> {
  final List<Map<String, dynamic>> _services = [
    {
      "title": "Service Delivery Model",
      "description":
          "Build your own service delivery model suited for your farm's unique needs.",
      "image": "assets/images/home_drone.png",
      "icon": Icons.build_circle_outlined,
    },
    {
      "title": "Finance & Insurance",
      "description":
          "Get access to finance, insurance, and beneficiary schemes effortlessly.",
      "image": "assets/images/service_finance_indian.png",
      "icon": Icons.account_balance_wallet_outlined,
    },
    {
      "title": "Market Linkage",
      "description":
          "Seamless market linkage and better price realization for your crops.",
      "image": "assets/images/service_market.png",
      "icon": Icons.storefront_outlined,
    },
    {
      "title": "Input & Technology",
      "description":
          "High-quality inputs and modern technology services at your fingertips.",
      "image": "assets/images/service_tech_indian.png",
      "icon": Icons.precision_manufacturing_outlined,
    },
    {
      "title": "Agronomy & Advisory",
      "description":
          "Expert agronomy support and advisory services for better yield.",
      "image": "assets/images/service_advisory_indian.png",
      "icon": Icons.eco_outlined,
    },
  ];

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const FarmerHomeScreen()),
    );
  }

  void _onServiceClick(Map<String, dynamic> service) {
    if (service['title'] == "Input & Technology") {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateBookingScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(serviceData: service),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Manakrishi Services",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    const Shadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/service_advisory.png', // Fallback/Ambient image
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color:
                        AppColors.primaryGreen.withOpacity(0.85), // Heavy Tint
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Our Offerings",
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Explore our comprehensive range of agricultural services designed for you.",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _services[index];
                  return _buildServiceCard(item);
                },
                childCount: _services.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToHome,
        backgroundColor: AppColors.accentYellow,
        elevation: 4,
        icon: const Icon(Icons.arrow_forward, color: Colors.black),
        label: Text(
          "Get Started",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onServiceClick(item),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section with Gradient Overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Hero(
                        tag: item['title'],
                        child: Image.asset(
                          item['image'],
                          fit: BoxFit.cover,
                          alignment: Alignment
                              .topCenter, // Ensure heads aren't cut off
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.6),
                          ],
                          stops: const [0.6, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    child: Row(
                      children: [
                        ClipOval(
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item['icon'],
                                  color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ],
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['title'],
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppColors.textGrey),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['description'],
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
