import 'package:flutter/material.dart';
import 'radar.dart';
import 'home.dart';
import 'proversion.dart';
import 'dashboard.dart';
import 'menu.dart';
import 'user_service.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int screen_index = 0;
  String currentLocationCode = 'DE'; // Default to Germany

  // Create a GlobalKey to force rebuild of pages when location changes
  Key _homeKey = UniqueKey();
  Key _radarKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final user = await UserService.getCurrentUser();
      if (user != null && user['location'] != null) {
        setState(() {
          currentLocationCode = user['location']['countryCode'] ?? 'DE';
        });
      }
    } catch (e) {
      print('Error loading current location: $e');
    }
  }

  void _onLocationChanged(String newLocationCode) {
    setState(() {
      currentLocationCode = newLocationCode;
      // Force rebuild of Home and Radar pages with new location
      _homeKey = UniqueKey();
      _radarKey = UniqueKey();
    });

    // Trigger API refresh for stock data
    _refreshStockData(newLocationCode);
  }

  Future<void> _refreshStockData(String locationCode) async {
    try {
      print('Refreshing stock data for location: $locationCode');

      // You can add specific logic based on location:
      switch (locationCode) {
        case 'US':
        // Fetch US stocks (NYSE, NASDAQ)
          print('Loading US market data...');
          break;
        case 'DE':
        // Fetch German stocks (DAX, XETRA)
          print('Loading German market data...');
          break;
        case 'GB':
        // Fetch UK stocks (LSE)
          print('Loading UK market data...');
          break;
        case 'JP':
        // Fetch Japanese stocks (TSE)
          print('Loading Japanese market data...');
          break;
        case 'CN':
        // Fetch Chinese stocks
          print('Loading Chinese market data...');
          break;
        case 'IN':
        // Fetch Indian stocks
          print('Loading Indian market data...');
          break;
        case 'FR':
        // Fetch French stocks
          print('Loading French market data...');
          break;
        case 'IT':
        // Fetch Italian stocks
          print('Loading Italian market data...');
          break;
        case 'ES':
        // Fetch Spanish stocks
          print('Loading Spanish market data...');
          break;
        case 'CA':
        // Fetch Canadian stocks
          print('Loading Canadian market data...');
          break;
        case 'AU':
        // Fetch Australian stocks
          print('Loading Australian market data...');
          break;
        case 'KR':
        // Fetch South Korean stocks
          print('Loading South Korean market data...');
          break;
        case 'BR':
        // Fetch Brazilian stocks
          print('Loading Brazilian market data...');
          break;
        default:
        // Default to US stocks
          print('Loading default (US) market data...');
          break;
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock data updated for ${_getCountryName(locationCode)}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      print('Error refreshing stock data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update stock data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getCountryName(String countryCode) {
    switch (countryCode) {
      case 'US': return 'United States';
      case 'DE': return 'Germany';
      case 'GB': return 'United Kingdom';
      case 'JP': return 'Japan';
      case 'CN': return 'China';
      case 'IN': return 'India';
      case 'FR': return 'France';
      case 'IT': return 'Italy';
      case 'ES': return 'Spain';
      case 'CA': return 'Canada';
      case 'AU': return 'Australia';
      case 'KR': return 'South Korea';
      case 'BR': return 'Brazil';
      default: return 'Unknown';
    }
  }

  void _onNavigateFromMenu(int index) {
    setState(() {
      screen_index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: screen_index,
        children: [
          Home(key: _homeKey, locationCode: currentLocationCode),        // Index 0 - Home
          Radar(key: _radarKey, locationCode: currentLocationCode),       // Index 1 - Radar
          const Pro(),         // Index 2 - Pro
          const Dashboard(),   // Index 3 - Dashboard
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 4) {
            // Menu - show as overlay
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => Menu(
                  onNavigate: _onNavigateFromMenu,
                  onLocationChanged: _onLocationChanged,
                ),
              ),
            );
          } else {
            // Regular navigation
            setState(() {
              screen_index = index;
            });
          }
        },
        currentIndex: screen_index > 3 ? 0 : screen_index, // Prevent out of bounds
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF6366F1), // Match your design color
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radar),
            label: 'Radar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_upward),
            label: 'Pro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}