import 'package:flutter/material.dart';
import 'user_service.dart';
import 'stockpage.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic>? currentUser;
  List<String> userFavorites = [];
  List<Map<String, dynamic>> favoriteStocksData = [];
  Map<String, dynamic> portfolioStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      print('Loading user data...');
      // Get current user
      final user = await UserService.getCurrentUser();
      if (user == null) {
        print('No user logged in, staying on dashboard with login prompt');
        setState(() {
          isLoading = false;
        });
        return;
      }

      print('User found: ${user['customerId']}');

      // Get user favorites
      final favorites = await UserService.getUserFavorites();
      print('User favorites: $favorites');

      // Get portfolio stats
      final stats = await _calculatePortfolioStats(user);

      // Get favorite stocks data
      final favoriteStocks = await _getFavoriteStocksData(favorites);
      print('Favorite stocks data: $favoriteStocks');

      setState(() {
        currentUser = user;
        userFavorites = favorites;
        favoriteStocksData = favoriteStocks;
        portfolioStats = stats;
        isLoading = false;
      });

      print('Dashboard loaded successfully');
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _calculatePortfolioStats(Map<String, dynamic> user) async {
    final portfolio = Map<String, dynamic>.from(user['portfolio'] ?? {});
    final cashBalance = (user['cashBalance'] ?? 10000.0).toDouble();

    // Calculate portfolio value (mock calculation)
    double totalInvestmentValue = 0;
    double currentValue = cashBalance;

    for (String symbol in portfolio.keys) {
      final quantity = (portfolio[symbol] ?? 0.0).toDouble();
      final mockPrice = 150.0; // In real app, get from API
      totalInvestmentValue += quantity * mockPrice;
      currentValue += quantity * mockPrice;
    }

    final totalGainLoss = currentValue - 10000.0; // Starting balance
    final returnPercent = totalGainLoss / 10000.0 * 100;

    return {
      'investmentValue': totalInvestmentValue,
      'currentValue': currentValue,
      'cashBalance': cashBalance,
      'totalGainLoss': totalGainLoss,
      'returnPercent': returnPercent,
      'shortTermGain': totalGainLoss * 0.3,
      'longTermGain': totalGainLoss * 0.7,
      'monthlySip': 100.0,
    };
  }

  Future<List<Map<String, dynamic>>> _getFavoriteStocksData(List<String> favorites) async {
    print('Getting favorite stocks data for: $favorites');

    if (favorites.isEmpty) {
      print('No favorites found');
      return [];
    }

    // Enhanced mock data with better variety
    return favorites.map((symbol) {
      final data = _getStockMockData(symbol);
      print('Generated data for $symbol: $data');
      return data;
    }).toList();
  }

  Map<String, dynamic> _getStockMockData(String symbol) {
    // More realistic mock data based on actual stock symbols
    switch (symbol.toUpperCase()) {
      case 'AAPL':
        return {
          'symbol': 'AAPL',
          'company': 'Apple Inc.',
          'name': 'Apple Inc.',
          'value': 17500,
          'return': 2.5,
          'isPositive': true,
          'price': '\$175.00',
          'change': '+2.5%',
        };
      case 'MSFT':
        return {
          'symbol': 'MSFT',
          'company': 'Microsoft Corp.',
          'name': 'Microsoft Corporation',
          'value': 38000,
          'return': 1.8,
          'isPositive': true,
          'price': '\$380.00',
          'change': '+1.8%',
        };
      case 'GOOGL':
        return {
          'symbol': 'GOOGL',
          'company': 'Alphabet Inc.',
          'name': 'Alphabet Inc.',
          'value': 14200,
          'return': -0.5,
          'isPositive': false,
          'price': '\$142.00',
          'change': '-0.5%',
        };
      case 'TSLA':
        return {
          'symbol': 'TSLA',
          'company': 'Tesla Inc.',
          'name': 'Tesla Inc.',
          'value': 24800,
          'return': 3.2,
          'isPositive': true,
          'price': '\$248.00',
          'change': '+3.2%',
        };
      case 'SAP':
        return {
          'symbol': 'SAP',
          'company': 'SAP SE',
          'name': 'SAP SE',
          'value': 14200,
          'return': 1.5,
          'isPositive': true,
          'price': '€142.00',
          'change': '+1.5%',
        };
      case 'BMW':
        return {
          'symbol': 'BMW',
          'company': 'BMW Group',
          'name': 'BMW Group',
          'value': 8900,
          'return': 0.8,
          'isPositive': true,
          'price': '€89.00',
          'change': '+0.8%',
        };
      case 'AZN':
        return {
          'symbol': 'AZN',
          'company': 'AstraZeneca PLC',
          'name': 'AstraZeneca PLC',
          'value': 12250,
          'return': 2.1,
          'isPositive': true,
          'price': '£122.50',
          'change': '+2.1%',
        };
      default:
      // Fallback for any other symbol
        return {
          'symbol': symbol,
          'company': _getCompanyType(symbol),
          'name': '${symbol.toUpperCase()} Corp.',
          'value': 10000 + (symbol.hashCode % 15000),
          'return': (symbol.hashCode % 20) - 10.0, // Range from -10 to +10
          'isPositive': (symbol.hashCode % 20) > 10,
          'price': '\$${(100 + (symbol.hashCode % 200)).toStringAsFixed(2)}',
          'change': '${(symbol.hashCode % 20) > 10 ? '+' : ''}${((symbol.hashCode % 20) - 10).toStringAsFixed(1)}%',
        };
    }
  }

  String _getCompanyType(String symbol) {
    if (symbol.contains('.')) return 'International';
    switch (symbol.toUpperCase()) {
      case 'AAPL': return 'Large Cap Tech';
      case 'MSFT': return 'Large Cap Tech';
      case 'GOOGL': return 'Large Cap Tech';
      case 'TSLA': return 'Growth Stock';
      case 'AMZN': return 'Large Cap Tech';
      case 'SAP': return 'European Tech';
      case 'BMW': return 'European Auto';
      case 'AZN': return 'Healthcare';
      default: return 'Mid Cap';
    }
  }

  double _getProfileCompletion() {
    if (currentUser == null) return 0.0;

    int filledFields = 0;
    int totalFields = 8;

    if (currentUser!['fullName']?.isNotEmpty == true) filledFields++;
    if (currentUser!['emailId']?.isNotEmpty == true) filledFields++;
    if (currentUser!['phoneNumber']?.isNotEmpty == true) filledFields++;
    if (currentUser!['dateOfBirth']?.isNotEmpty == true) filledFields++;
    if (currentUser!['location'] != null) filledFields++;
    if (userFavorites.isNotEmpty) filledFields++;
    if (currentUser!['portfolio']?.isNotEmpty == true) filledFields++;
    if (currentUser!['cardDetails']?.isNotEmpty == true) filledFields++;

    return filledFields / totalFields;
  }

  String _getUserType() {
    final portfolioValue = portfolioStats['investmentValue'] ?? 0.0;
    if (portfolioValue > 50000) return 'Premium Investor';
    if (portfolioValue > 20000) return 'Active Trader';
    if (portfolioValue > 5000) return 'Growth Investor';
    return 'New Investor';
  }

  Widget _buildSummaryRow(String label, String value, String type) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    Color valueColor = colorScheme.onPrimary;
    if (type == 'positive') {
      valueColor = Colors.green;
    } else if (type == 'negative') {
      valueColor = Colors.red;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentCard(String title, IconData icon, String amount) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.onSecondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: colorScheme.onSecondary,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            amount,
            style: TextStyle(
              color: colorScheme.onSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
// Part 2: Add this to the Dashboard class after Part 1

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.onSecondary),
              const SizedBox(height: 16),
              Text(
                'Loading Dashboard...',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ],
          ),
        ),
      );
    }

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: colorScheme.onSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Please login to view dashboard',
                style: TextStyle(color: colorScheme.onPrimary, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onSecondary,
                ),
                child: const Text('Go to Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final profileCompletion = _getProfileCompletion();
    final location = currentUser!['location'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Welcome back, ${currentUser!['fullName']?.split(' ').first ?? 'User'}!',
                        style: TextStyle(
                          color: colorScheme.onSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  // Location button
                  GestureDetector(
                    onTap: _showLocationDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.onSecondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: colorScheme.onSecondary, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            location?['country'] ?? 'Unknown',
                            style: TextStyle(
                              color: colorScheme.onSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.onSecondary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Profile Picture
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colorScheme.onSecondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.person,
                            color: colorScheme.onSecondary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser!['fullName'] ?? 'Unknown User',
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${location?['city'] ?? 'Unknown'}, ${location?['country'] ?? 'Unknown'}',
                                style: TextStyle(
                                  color: colorScheme.onSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _getUserType(),
                                style: TextStyle(
                                  color: colorScheme.onSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Progress Circle
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Stack(
                            children: [
                              CircularProgressIndicator(
                                value: profileCompletion,
                                strokeWidth: 4,
                                backgroundColor: colorScheme.onSecondary.withValues(alpha: 0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                              Center(
                                child: Text(
                                  '${(profileCompletion * 100).toInt()}%',
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Investment Summary
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Investment Value', '\$${portfolioStats['investmentValue']?.toStringAsFixed(2) ?? '0.00'}', 'neutral'),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Return', '${portfolioStats['returnPercent']?.toStringAsFixed(2) ?? '0.00'}%', portfolioStats['returnPercent'] != null && portfolioStats['returnPercent'] >= 0 ? 'positive' : 'negative'),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Current Value', '\$${portfolioStats['currentValue']?.toStringAsFixed(2) ?? '0.00'}', 'neutral'),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Cash Balance', '\$${portfolioStats['cashBalance']?.toStringAsFixed(2) ?? '0.00'}', 'neutral'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Investment Options Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildInvestmentCard('Stocks', Icons.trending_up, '\$${portfolioStats['investmentValue']?.toStringAsFixed(0) ?? '0'}'),
                  _buildInvestmentCard('Mutual Funds', Icons.pie_chart, '\$750'),
                  _buildInvestmentCard('Cash', Icons.account_balance_wallet, '\$${portfolioStats['cashBalance']?.toStringAsFixed(0) ?? '0'}'),
                  _buildInvestmentCard('Monthly SIP', Icons.schedule, '\$${portfolioStats['monthlySip']?.toStringAsFixed(0) ?? '0'}'),
                ],
              ),

              const SizedBox(height: 30),

              // Favourites Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: colorScheme.onSecondary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Favourites (${userFavorites.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _showManageFavoritesDialog,
                        child: Text(
                          'Manage',
                          style: TextStyle(
                            color: colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          print('Refreshing favorites...');
                          _loadUserData();
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Debug info
              if (userFavorites.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Debug: Found ${userFavorites.length} favorites: ${userFavorites.join(', ')}',
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),

              // Favorites List
              if (favoriteStocksData.isEmpty && userFavorites.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.onSecondary.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 48,
                          color: colorScheme.onSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No favorites yet',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add stocks to your favorites to see them here',
                          style: TextStyle(
                            color: colorScheme.onSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: _showManageFavoritesDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: colorScheme.onSecondary),
                          child: const Text('Add Favorites', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              else if (favoriteStocksData.isNotEmpty)
                ...favoriteStocksData.map((stock) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.onSecondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockPage(symbol: stock['symbol']),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stock['symbol'],
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                stock['company'],
                                style: TextStyle(
                                  color: colorScheme.onSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                stock['price'] ?? '\$${stock['value']}',
                                style: TextStyle(
                                  color: colorScheme.onSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${stock['isPositive'] ? '+' : ''}${stock['return'].toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: stock['isPositive'] ? Colors.green : Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              _showTransactionDialog(stock);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: stock['isPositive'] ? Colors.green : Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              stock['isPositive'] ? 'BUY' : 'SELL',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ))
              else
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Loading favorites data...',
                    style: TextStyle(color: colorScheme.onPrimary),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationDialog() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final countries = UserService.getAvailableCountries();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.secondary,
        title: Text('Change Location', style: TextStyle(color: colorScheme.onPrimary)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final country = countries[index];
              final isSelected = currentUser!['location']?['countryCode'] == country['code'];

              return ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: isSelected ? Colors.green : colorScheme.onSecondary,
                ),
                title: Text(
                  country['name']!,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  country['currency']!,
                  style: TextStyle(color: colorScheme.onSecondary),
                ),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () async {
                  final success = await UserService.updateUserLocation(
                    country: country['name']!,
                    countryCode: country['code']!,
                    city: 'Unknown',
                    currency: country['currency']!,
                  );

                  Navigator.pop(context);

                  if (success) {
                    _showMessage('Location updated successfully!', isError: false);
                    _loadUserData();
                  } else {
                    _showMessage('Failed to update location', isError: true);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colorScheme.onSecondary)),
          ),
        ],
      ),
    );
  }

  void _showManageFavoritesDialog() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextEditingController symbolController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.secondary,
        title: Text('Manage Favorites', style: TextStyle(color: colorScheme.onPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: symbolController,
              style: TextStyle(color: colorScheme.onPrimary),
              decoration: InputDecoration(
                labelText: 'Stock Symbol (e.g., AAPL)',
                labelStyle: TextStyle(color: colorScheme.onSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.onSecondary.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.onSecondary),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final symbol = symbolController.text.trim().toUpperCase();
                      if (symbol.isNotEmpty) {
                        print('Adding $symbol to favorites...');
                        final success = await UserService.addToFavorites(symbol);
                        Navigator.pop(context);
                        if (success) {
                          _showMessage('Added $symbol to favorites!', isError: false);
                          _loadUserData();
                        } else {
                          _showMessage('$symbol is already in favorites', isError: true);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Add', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            if (userFavorites.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Current Favorites:', style: TextStyle(color: colorScheme.onPrimary)),
              const SizedBox(height: 10),
              ...userFavorites.map((symbol) => ListTile(
                dense: true,
                title: Text(symbol, style: TextStyle(color: colorScheme.onPrimary)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    print('Removing $symbol from favorites...');
                    final success = await UserService.removeFromFavorites(symbol);
                    if (success) {
                      _showMessage('Removed $symbol from favorites', isError: false);
                      _loadUserData();
                      Navigator.pop(context);
                    } else {
                      _showMessage('Failed to remove $symbol', isError: true);
                    }
                  },
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: colorScheme.onSecondary)),
          ),
        ],
      ),
    );
  }

  void _showTransactionDialog(Map<String, dynamic> stock) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.secondary,
          title: Text(
            '${stock['isPositive'] ? 'Buy' : 'Sell'} ${stock['symbol']}',
            style: TextStyle(color: colorScheme.onPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Price: ${stock['price'] ?? '\$${stock['value']}'}',
                style: TextStyle(color: colorScheme.onSecondary),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                style: TextStyle(color: colorScheme.onPrimary),
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: TextStyle(color: colorScheme.onSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.onSecondary.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.onSecondary),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colorScheme.onPrimary)),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                if (quantity > 0) {
                  Navigator.pop(context);
                  final action = stock['isPositive'] ? 'Buy' : 'Sell';
                  _showMessage('$action order for $quantity shares of ${stock['symbol']} placed successfully!', isError: false);
                } else {
                  _showMessage('Please enter a valid quantity', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: stock['isPositive'] ? Colors.green : Colors.red,
              ),
              child: Text(
                stock['isPositive'] ? 'BUY' : 'SELL',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

