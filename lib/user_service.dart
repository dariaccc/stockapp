import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _favoritesKey = 'user_favorites';
  static const String _locationKey = 'user_location';

  // User Registration
  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String dateOfBirth,
    required String nationalCardNumber,
    required String phoneNumber,
    required String emailId,
    required String cardDetails,
    required String expiry,
    required String cvv,
    required String pin,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing users
      final existingUsersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> existingUsers = json.decode(existingUsersJson);

      // Generate incremental Customer ID
      final customerId = _generateCustomerId(existingUsers.length);

      // Check if user already exists by email
      final userExists = existingUsers.any((user) => user['emailId'] == emailId);

      if (userExists) {
        return {'success': false, 'message': 'User already exists with this Email'};
      }

      // Get user's location
      final locationData = await _detectUserLocation();

      // Create new user
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'fullName': fullName,
        'customerId': customerId,
        'dateOfBirth': dateOfBirth,
        'nationalCardNumber': nationalCardNumber,
        'phoneNumber': phoneNumber,
        'emailId': emailId,
        'cardDetails': cardDetails,
        'expiry': expiry,
        'cvv': cvv,
        'pin': pin,
        'location': locationData,
        'registrationDate': DateTime.now().toIso8601String(),
        'favorites': <String>[],
        'portfolio': <String, dynamic>{},
        'cashBalance': 10000.0, // Starting balance
      };

      // Add to users list
      existingUsers.add(newUser);

      // Save users
      await prefs.setString(_usersKey, json.encode(existingUsers));

      return {
        'success': true,
        'message': 'Registration successful! Your Customer ID is: $customerId',
        'user': newUser,
        'customerId': customerId,
      };
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  // Generate incremental Customer ID
  static String _generateCustomerId(int userCount) {
    // Format: VTX + 6-digit number (e.g., VTX000001, VTX000002, etc.)
    final number = (userCount + 1).toString().padLeft(6, '0');
    return 'VTX$number';
  }

  // User Login
  static Future<Map<String, dynamic>> loginUser({
    required String customerId,
    required String pin,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing users
      final existingUsersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> existingUsers = json.decode(existingUsersJson);

      // Find user
      final userIndex = existingUsers.indexWhere((user) =>
      user['customerId'] == customerId && user['pin'] == pin);

      if (userIndex == -1) {
        return {'success': false, 'message': 'Invalid Customer ID or PIN'};
      }

      final user = existingUsers[userIndex];

      // Update last login
      user['lastLogin'] = DateTime.now().toIso8601String();
      existingUsers[userIndex] = user;
      await prefs.setString(_usersKey, json.encode(existingUsers));

      // Set current user
      await prefs.setString(_currentUserKey, json.encode(user));

      return {'success': true, 'message': 'Login successful!', 'user': user};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // Get Current User
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);

      if (userJson != null) {
        return json.decode(userJson);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Update User Location
  static Future<bool> updateUserLocation({
    required String country,
    required String countryCode,
    required String city,
    required String currency,
  }) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      final prefs = await SharedPreferences.getInstance();

      // Update user's location
      user['location'] = {
        'country': country,
        'countryCode': countryCode,
        'city': city,
        'currency': currency,
        'lastUpdated': DateTime.now().toIso8601String(),
        'isManuallySet': true,
      };

      // Update current user
      await prefs.setString(_currentUserKey, json.encode(user));

      // Update in users list
      final existingUsersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> existingUsers = json.decode(existingUsersJson);

      final userIndex = existingUsers.indexWhere((u) => u['id'] == user['id']);
      if (userIndex != -1) {
        existingUsers[userIndex] = user;
        await prefs.setString(_usersKey, json.encode(existingUsers));
      }

      return true;
    } catch (e) {
      print('Error updating location: $e');
      return false;
    }
  }

  // Add to Favorites
  static Future<bool> addToFavorites(String stockSymbol) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      final List<String> favorites = List<String>.from(user['favorites'] ?? []);

      if (!favorites.contains(stockSymbol)) {
        favorites.add(stockSymbol);
        user['favorites'] = favorites;

        await _updateCurrentUser(user);
        return true;
      }
      return false; // Already in favorites
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove from Favorites
  static Future<bool> removeFromFavorites(String stockSymbol) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      final List<String> favorites = List<String>.from(user['favorites'] ?? []);

      if (favorites.contains(stockSymbol)) {
        favorites.remove(stockSymbol);
        user['favorites'] = favorites;

        await _updateCurrentUser(user);
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Get User Favorites
  static Future<List<String>> getUserFavorites() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return [];

      return List<String>.from(user['favorites'] ?? []);
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  // Get Location-based Stock Recommendations
  static Future<List<String>> getLocationBasedStocks() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return ['AAPL', 'MSFT', 'GOOGL']; // Default stocks

      final location = user['location'];
      if (location == null) return ['AAPL', 'MSFT', 'GOOGL'];

      final countryCode = location['countryCode'] ?? 'US';

      return _getStocksByCountry(countryCode.toLowerCase());
    } catch (e) {
      print('Error getting location-based stocks: $e');
      return ['AAPL', 'MSFT', 'GOOGL'];
    }
  }

  // Detect User Location (using IP)
  static Future<Map<String, dynamic>> _detectUserLocation() async {
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'country': data['country_name'] ?? 'United States',
          'countryCode': data['country_code'] ?? 'US',
          'city': data['city'] ?? 'Unknown',
          'currency': data['currency'] ?? 'USD',
          'timezone': data['timezone'] ?? 'UTC',
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'lastUpdated': DateTime.now().toIso8601String(),
          'isManuallySet': false,
        };
      }
    } catch (e) {
      print('Error detecting location: $e');
    }

    // Fallback location
    return {
      'country': 'United States',
      'countryCode': 'US',
      'city': 'Unknown',
      'currency': 'USD',
      'timezone': 'UTC',
      'lastUpdated': DateTime.now().toIso8601String(),
      'isManuallySet': false,
    };
  }

  // Get stocks by country
  static List<String> _getStocksByCountry(String countryCode) {
    switch (countryCode) {
      case 'us':
        return ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA', 'META', 'NVDA', 'JPM', 'V', 'JNJ'];
      case 'gb':
        return ['LLOY.L', 'BARC.L', 'BP.L', 'SHEL.L', 'VOD.L', 'ULVR.L', 'AZN.L', 'RIO.L'];
      case 'de':
        return ['SAP.DE', 'ALV.DE', 'SIE.DE', 'ASML.DE', 'BMW.DE', 'MBG.DE', 'BAS.DE', 'DTE.DE'];
      case 'fr':
        return ['MC.PA', 'OR.PA', 'SAN.PA', 'AIR.PA', 'BNP.PA', 'TTE.PA', 'EL.PA', 'CAP.PA'];
      case 'jp':
        return ['7203.T', '6758.T', '9984.T', '6861.T', '8306.T', '9432.T', '4063.T', '6954.T'];
      case 'in':
        return ['RELIANCE.BO', 'TCS.BO', 'HDFCBANK.BO', 'BHARTIARTL.BO', 'ICICIBANK.BO', 'SBIN.BO'];
      case 'ca':
        return ['SHOP.TO', 'RY.TO', 'TD.TO', 'CNR.TO', 'SU.TO', 'WCN.TO', 'BAM.TO', 'CNQ.TO'];
      case 'au':
        return ['CBA.AX', 'BHP.AX', 'ANZ.AX', 'WBC.AX', 'NAB.AX', 'CSL.AX', 'MQG.AX', 'WOW.AX'];
      case 'br':
        return ['PETR4.SA', 'VALE3.SA', 'ITUB4.SA', 'BBDC4.SA', 'ABEV3.SA', 'B3SA3.SA'];
      case 'mx':
        return ['WALMEX.MX', 'AMXL.MX', 'GFNORTEO.MX', 'CEMEXCPO.MX', 'TLEVISACPO.MX'];
      default:
        return ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA']; // Default to US stocks
    }
  }

  // Update current user helper
  static Future<void> _updateCurrentUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();

    // Update current user
    await prefs.setString(_currentUserKey, json.encode(user));

    // Update in users list
    final existingUsersJson = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> existingUsers = json.decode(existingUsersJson);

    final userIndex = existingUsers.indexWhere((u) => u['id'] == user['id']);
    if (userIndex != -1) {
      existingUsers[userIndex] = user;
      await prefs.setString(_usersKey, json.encode(existingUsers));
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Get all registered users (admin function)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingUsersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> existingUsers = json.decode(existingUsersJson);

      return existingUsers.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Update User Portfolio (for transactions)
  static Future<bool> updateUserPortfolio({
    required String symbol,
    required double quantity,
    required double price,
    required String type, // 'BUY' or 'SELL'
  }) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      final Map<String, dynamic> portfolio = Map<String, dynamic>.from(user['portfolio'] ?? {});
      double cashBalance = (user['cashBalance'] ?? 10000.0).toDouble();

      final total = quantity * price;

      if (type == 'BUY') {
        if (cashBalance >= total) {
          cashBalance -= total;
          portfolio[symbol] = (portfolio[symbol] ?? 0.0) + quantity;
        } else {
          return false; // Insufficient funds
        }
      } else if (type == 'SELL') {
        final currentQuantity = (portfolio[symbol] ?? 0.0).toDouble();
        if (currentQuantity >= quantity) {
          cashBalance += total;
          portfolio[symbol] = currentQuantity - quantity;

          if (portfolio[symbol] == 0) {
            portfolio.remove(symbol);
          }
        } else {
          return false; // Insufficient shares
        }
      }

      user['portfolio'] = portfolio;
      user['cashBalance'] = cashBalance;

      await _updateCurrentUser(user);
      return true;
    } catch (e) {
      print('Error updating portfolio: $e');
      return false;
    }
  }

  // Get available countries for location selection
  static List<Map<String, String>> getAvailableCountries() {
    return [
      {'name': 'United States', 'code': 'US', 'currency': 'USD'},
      {'name': 'United Kingdom', 'code': 'GB', 'currency': 'GBP'},
      {'name': 'Germany', 'code': 'DE', 'currency': 'EUR'},
      {'name': 'France', 'code': 'FR', 'currency': 'EUR'},
      {'name': 'Japan', 'code': 'JP', 'currency': 'JPY'},
      {'name': 'India', 'code': 'IN', 'currency': 'INR'},
      {'name': 'Canada', 'code': 'CA', 'currency': 'CAD'},
      {'name': 'Australia', 'code': 'AU', 'currency': 'AUD'},
      {'name': 'Brazil', 'code': 'BR', 'currency': 'BRL'},
      {'name': 'Mexico', 'code': 'MX', 'currency': 'MXN'},
    ];
  }
}