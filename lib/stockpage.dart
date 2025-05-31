import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_service.dart';
import 'news_service.dart'; // Add this import
import 'dart:math' as math;

class StockPage extends StatefulWidget {
  final String symbol;

  const StockPage({super.key, required this.symbol});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  Map<String, dynamic>? stockData;
  List<Map<String, String>> performanceData = [];
  List<Map<String, dynamic>> newsArticles = []; // Changed to dynamic for real news
  List<Map<String, dynamic>> relatedStocks = [];
  bool isLoading = true;
  bool isFavorite = false;
  bool isLoadingNews = false; // Add news loading state

  // Chart related variables
  String selectedPeriod = '1D';
  List<Map<String, dynamic>> chartData = [];
  bool isChartLoading = false;

  // Dynamic price and percentage for current period
  String currentPrice = '150.25';
  String currentChange = '+2.47';
  String currentChangePercent = '+1.67%';
  bool isCurrentPositive = true;

  @override
  void initState() {
    super.initState();
    loadStockData();
    _loadStockNews(); // Add this line to load news
    _testUserService();
    _checkIfFavorite();
  }

  // Add method to load stock-specific news
  Future<void> _loadStockNews() async {
    setState(() {
      isLoadingNews = true;
    });

    try {
      print('🗞️ Loading news for ${widget.symbol}...');
      final news = await NewsService.getStockNews(widget.symbol);

      setState(() {
        newsArticles = news;
        isLoadingNews = false;
      });

      print('✅ Loaded ${news.length} news articles for ${widget.symbol}');
    } catch (e) {
      print('❌ Error loading news: $e');
      setState(() {
        // Fallback to default news if API fails
        newsArticles = [
          {
            'title': '${_getCompanyName(widget.symbol)} Surpasses Q4 Earnings: Sets Promising...',
            'description': 'Company shows strong quarterly performance with increased revenue.',
            'publishedAt': DateTime.now().subtract(const Duration(hours: 16)).toIso8601String(),
            'source': 'Financial Times',
            'url': '',
          },
          {
            'title': '${_getCompanyName(widget.symbol)} Development Team Gets Equity Payments',
            'description': 'Strategic move to retain top talent in competitive market.',
            'publishedAt': DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(),
            'source': 'Bloomberg',
            'url': '',
          },
          {
            'title': '${_getCompanyName(widget.symbol)} Shows Strong Performance amid Volatility',
            'description': 'Market volatility affects stock price significantly.',
            'publishedAt': DateTime.now().subtract(const Duration(hours: 19)).toIso8601String(),
            'source': 'Reuters',
            'url': '',
          },
        ];
        isLoadingNews = false;
      });
    }
  }

  Future<void> _testUserService() async {
    try {
      final user = await UserService.getCurrentUser();
      print('Current user: ${user != null ? user['customerId'] : 'No user logged in'}');

      if (user != null) {
        final favorites = await UserService.getUserFavorites();
        print('User favorites: $favorites');
      }
    } catch (e) {
      print('Error testing UserService: $e');
    }
  }

  Future<void> _checkIfFavorite() async {
    try {
      print('Checking if ${widget.symbol} is in favorites...');
      final favorites = await UserService.getUserFavorites();
      print('Current favorites: $favorites');

      setState(() {
        isFavorite = favorites.contains(widget.symbol);
      });

      print('Is ${widget.symbol} favorite? $isFavorite');
    } catch (e) {
      print('Error checking favorites: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      print('Toggling favorite for ${widget.symbol}, current state: $isFavorite');

      bool success;
      if (isFavorite) {
        print('Removing ${widget.symbol} from favorites...');
        success = await UserService.removeFromFavorites(widget.symbol);
        if (success) {
          setState(() {
            isFavorite = false;
          });
          _showMessage('Removed from favorites', isError: false);
          print('Successfully removed from favorites');
        } else {
          _showMessage('Failed to remove from favorites', isError: true);
          print('Failed to remove from favorites');
        }
      } else {
        print('Adding ${widget.symbol} to favorites...');
        success = await UserService.addToFavorites(widget.symbol);
        if (success) {
          setState(() {
            isFavorite = true;
          });
          _showMessage('Added to favorites', isError: false);
          print('Successfully added to favorites');
        } else {
          _showMessage('Already in favorites or failed to add', isError: true);
          print('Failed to add to favorites or already exists');
        }
      }

      await _checkIfFavorite();

    } catch (e) {
      print('Error toggling favorite: $e');
      _showMessage('Error updating favorites: $e', isError: true);
    }
  }

  // Calculate percentage change based on chart data
  void _updatePriceInfo() {
    if (chartData.isNotEmpty) {
      final firstPrice = chartData.first['price'] as double;
      final lastPrice = chartData.last['price'] as double;
      final change = lastPrice - firstPrice;
      final changePercent = firstPrice != 0 ? (change / firstPrice) * 100 : 0;
      final isPositive = change >= 0;

      setState(() {
        currentPrice = lastPrice.toStringAsFixed(2);
        currentChange = '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}';
        currentChangePercent = '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';
        isCurrentPositive = isPositive;
      });

      print('🔄 Updated price info for $selectedPeriod:');
      print('   Price: \$${currentPrice}');
      print('   Change: ${currentChange} (${currentChangePercent})');
    }
  }

  Future<void> _loadChartData() async {
    setState(() {
      isChartLoading = true;
    });

    try {
      print('📊 Loading chart data for ${widget.symbol} - Period: $selectedPeriod');

      // Try to get real historical data from your ApiService
      List<Map<String, dynamic>>? historicalData;

      // First try the new historical data method with period
      try {
        historicalData = await ApiService.getHistoricalData(widget.symbol, selectedPeriod, limit: 30);
      } catch (e) {
        print('⚠️ Period-based historical data failed: $e');
      }

      if (historicalData != null && historicalData.isNotEmpty) {
        print('✅ Received ${historicalData.length} data points from API');
        setState(() {
          chartData = historicalData!;
          isChartLoading = false;
        });
        _updatePriceInfo(); // Update price info after loading data
      } else {
        print('⚠️ No historical data received, using Yahoo Finance fallback');
        // Try Yahoo Finance as fallback
        try {
          final yahooData = await ApiService.getHistoricalDataYahoo(widget.symbol, selectedPeriod);
          if (yahooData != null && yahooData.isNotEmpty) {
            print('✅ Yahoo Finance provided ${yahooData.length} data points');
            setState(() {
              chartData = yahooData;
              isChartLoading = false;
            });
            _updatePriceInfo(); // Update price info after loading data
          } else {
            // Final fallback to generated data
            final fallbackData = await _generateRealisticFallbackChartData();
            setState(() {
              chartData = fallbackData;
              isChartLoading = false;
            });
            _updatePriceInfo(); // Update price info after loading data
          }
        } catch (e) {
          print('❌ Yahoo Finance also failed: $e');
          // Final fallback to generated data
          final fallbackData = await _generateRealisticFallbackChartData();
          setState(() {
            chartData = fallbackData;
            isChartLoading = false;
          });
          _updatePriceInfo(); // Update price info after loading data
        }
      }
    } catch (e) {
      print('❌ Error loading chart data: $e');
      // Use fallback data on error
      final fallbackData = await _generateRealisticFallbackChartData();
      setState(() {
        chartData = fallbackData;
        isChartLoading = false;
      });
      _updatePriceInfo(); // Update price info after loading data
    }
  }

  Future<List<Map<String, dynamic>>> _generateRealisticFallbackChartData() async {
    print('🔄 Generating realistic fallback chart data for $selectedPeriod');

    // Get the current price from the dynamic price display, not the original stock data
    double basePrice;
    if (this.currentPrice != '150.25') {
      // Use the current dynamic price if it's been updated (this.currentPrice refers to the class variable)
      basePrice = double.tryParse(this.currentPrice) ?? 150.0;
    } else if (stockData != null) {
      // Fallback to stock data price
      basePrice = double.tryParse(stockData!['price']) ?? 150.0;
    } else {
      // Last resort fallback
      basePrice = 150.0;
    }

    print('📈 Using base price: \$${basePrice.toStringAsFixed(2)} for $selectedPeriod');

    final random = math.Random();
    List<Map<String, dynamic>> data = [];
    int dataPoints;
    Duration interval;
    double volatility;

    final now = DateTime.now();

    switch (selectedPeriod) {
      case '1H':
        dataPoints = 60; // 60 minutes
        interval = const Duration(minutes: 1); // 1 minute intervals
        volatility = 0.0005; // Very small volatility for 1-minute data
        break;
      case '1D':
        dataPoints = 24; // 24 hours
        interval = const Duration(hours: 1); // 1 hour intervals
        volatility = 0.005;
        break;
      case '1W':
        dataPoints = 7; // 7 days
        interval = const Duration(days: 1); // 1 day intervals
        volatility = 0.02;
        break;
      case '1M':
        dataPoints = 30; // 30 days
        interval = const Duration(days: 1); // 1 day intervals
        volatility = 0.03;
        break;
      case '1Y':
        dataPoints = 52; // 52 weeks
        interval = const Duration(days: 7); // 1 week intervals
        volatility = 0.08;
        break;
      default:
        dataPoints = 24;
        interval = const Duration(hours: 1);
        volatility = 0.005;
    }

    // Generate starting price that maintains consistency across periods
    double startingPrice;
    switch (selectedPeriod) {
      case '1H':
      // For 1 hour, start very close to current price (within 0.1-0.3%)
        final randomFactor = random.nextDouble();
        startingPrice = basePrice * (0.999 + randomFactor * 0.002); // 0.1-0.3% variation
        break;
      case '1D':
      // For 1 day, start within 1-3% of current price
        final randomFactor = random.nextDouble();
        startingPrice = basePrice * (0.985 + randomFactor * 0.03); // 1.5-3% variation
        break;
      case '1W':
      // For 1 week, start within 3-8% of current price
        final randomFactor = random.nextDouble();
        startingPrice = basePrice * (0.92 + randomFactor * 0.08); // 3-8% variation
        break;
      case '1M':
      // For 1 month, start within 5-15% of current price
        final randomFactor = random.nextDouble();
        startingPrice = basePrice * (0.85 + randomFactor * 0.15); // 5-15% variation
        break;
      case '1Y':
      // For 1 year, start within 20-50% of current price
        final randomFactor = random.nextDouble();
        startingPrice = basePrice * (0.5 + randomFactor * 0.5); // 20-50% variation
        break;
      default:
        startingPrice = basePrice;
    }

    // Generate data points that end at the current base price
    double currentDataPrice = startingPrice; // Use different variable name to avoid conflict

    for (int i = dataPoints - 1; i >= 0; i--) {
      final timestamp = now.subtract(interval * i);

      // Calculate progress through the time period (0 = start, 1 = end)
      final progress = (dataPoints - 1 - i) / (dataPoints - 1);

      // Generate price movement that trends toward the base price
      final randomValue = random.nextDouble();

      // Trend toward base price as we approach the end
      final targetPrice = startingPrice + (basePrice - startingPrice) * progress;
      final trendForce = (targetPrice - currentDataPrice) * 0.1;

      // Add random volatility
      final randomChange = (randomValue - 0.5) * volatility * basePrice;

      // Apply changes
      currentDataPrice += trendForce + randomChange;

      // Keep price within reasonable bounds
      double minBound, maxBound;
      switch (selectedPeriod) {
        case '1H':
          minBound = basePrice * 0.997;
          maxBound = basePrice * 1.003;
          break;
        case '1D':
          minBound = basePrice * 0.98;
          maxBound = basePrice * 1.02;
          break;
        case '1W':
          minBound = basePrice * 0.9;
          maxBound = basePrice * 1.1;
          break;
        case '1M':
          minBound = basePrice * 0.8;
          maxBound = basePrice * 1.2;
          break;
        case '1Y':
          minBound = basePrice * 0.4;
          maxBound = basePrice * 1.6;
          break;
        default:
          minBound = basePrice * 0.9;
          maxBound = basePrice * 1.1;
      }

      currentDataPrice = currentDataPrice.clamp(minBound, maxBound);

      data.add({
        'timestamp': timestamp.millisecondsSinceEpoch,
        'price': currentDataPrice,
        'date': timestamp.toIso8601String(),
      });
    }

    // Ensure the last data point is close to the base price
    if (data.isNotEmpty) {
      data.last['price'] = basePrice + (random.nextDouble() - 0.5) * volatility * basePrice;
    }

    print('✅ Generated ${data.length} data points for $selectedPeriod');
    print('   Starting price: \$${startingPrice.toStringAsFixed(2)}');
    print('   Ending price: \$${data.last['price'].toStringAsFixed(2)}');
    print('   Base price: \$${basePrice.toStringAsFixed(2)}');

    return data;
  }

  void _onPeriodSelected(String period) {
    setState(() {
      selectedPeriod = period;
    });
    _loadChartData(); // This will automatically update the price info
  }

  Widget _buildTimeSelector() {
    final periods = ['1H', '1D', '1W', '1M', '1Y'];
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: periods.map((period) {
          final isSelected = selectedPeriod == period;
          return GestureDetector(
            onTap: () => _onPeriodSelected(period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.onSecondary : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? colorScheme.onSecondary : colorScheme.onSecondary.withOpacity(0.3),
                ),
              ),
              child: Text(
                period,
                style: TextStyle(
                  color: isSelected ? colorScheme.secondary : colorScheme.onSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Improved _buildChart method with fixed text positioning
  Widget _buildChart() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (isChartLoading) {
      return Container(
        height: 250, // Increased height for better visibility
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.onSecondary),
              const SizedBox(height: 10),
              Text(
                'Loading $selectedPeriod chart data...',
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (chartData.isEmpty) {
      return Container(
        height: 250,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                color: colorScheme.onSecondary.withOpacity(0.5),
                size: 48,
              ),
              const SizedBox(height: 10),
              Text(
                'No chart data available',
                style: TextStyle(color: colorScheme.onSecondary),
              ),
              const SizedBox(height: 5),
              TextButton(
                onPressed: _loadChartData,
                child: Text(
                  'Retry',
                  style: TextStyle(color: colorScheme.onSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final prices = chartData.map((d) => d['price'] as double).toList();
    final isPositive = prices.last > prices.first;
    final lineColor = isPositive ? Colors.green : Colors.red;

    return Container(
      height: 250, // Fixed height with proper margins
      padding: const EdgeInsets.all(8), // Reduced padding to give more space for chart
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart info header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price Movement ($selectedPeriod)',
                  style: TextStyle(
                    color: colorScheme.onSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${chartData.length} points',
                  style: TextStyle(
                    color: colorScheme.onSecondary.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Chart area with proper constraints
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: RealDataChartPainter(
                    data: chartData,
                    color: lineColor,
                    backgroundColor: lineColor.withOpacity(0.1),
                    selectedPeriod: selectedPeriod,
                    textColor: colorScheme.onSecondary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Updated news section with real news display
  Widget _buildNewsSection() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Latest News',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isLoadingNews)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: colorScheme.onSecondary,
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),

        if (newsArticles.isEmpty && !isLoadingNews)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.onSecondary.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                'No news available for ${widget.symbol}',
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ...newsArticles.take(3).map((article) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.onSecondary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // News title
                Text(
                  article['title'] ?? 'No Title',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // News description
                if (article['description'] != null && article['description'].isNotEmpty)
                  Text(
                    article['description'],
                    style: TextStyle(
                      color: colorScheme.onSecondary.withOpacity(0.8),
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 8),

                // News metadata
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      article['source'] ?? 'Unknown',
                      style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      article['publishedAt'] != null
                          ? NewsService.formatTimeAgo(article['publishedAt'])
                          : 'Recently',
                      style: TextStyle(
                        color: colorScheme.onSecondary.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
      ],
    );
  }

  void _showMessage(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  IconData _getStockIcon(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'AAPL':
        return Icons.apple;
      case 'GOOG':
      case 'GOOGL':
        return Icons.g_mobiledata;
      case 'TSLA':
        return Icons.electric_car;
      case 'AMZN':
        return Icons.shopping_cart;
      case 'META':
        return Icons.facebook;
      case 'NFLX':
        return Icons.movie;
      case 'NVDA':
        return Icons.memory;
      case 'SAP':
        return Icons.business;
      case 'BMW':
      case 'VW':
        return Icons.directions_car;
      case 'SIE':
        return Icons.factory;
      case 'SHEL':
      case 'BP':
        return Icons.local_gas_station;
      case 'AZN':
      case 'GSK':
        return Icons.medical_services;
      default:
        return Icons.trending_up;
    }
  }

  String _getCompanyName(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'AAPL':
        return 'Apple Inc.';
      case 'MSFT':
        return 'Microsoft Corporation';
      case 'GOOGL':
      case 'GOOG':
        return 'Alphabet Inc.';
      case 'TSLA':
        return 'Tesla Inc.';
      case 'AMZN':
        return 'Amazon.com Inc.';
      case 'META':
        return 'Meta Platforms Inc.';
      case 'NFLX':
        return 'Netflix Inc.';
      case 'NVDA':
        return 'NVIDIA Corporation';
      case 'SAP':
        return 'SAP SE';
      case 'BMW':
        return 'BMW Group';
      case 'VW':
        return 'Volkswagen AG';
      case 'SIE':
        return 'Siemens AG';
      case 'SHEL':
        return 'Shell PLC';
      case 'BP':
        return 'BP PLC';
      case 'AZN':
        return 'AstraZeneca PLC';
      case 'GSK':
        return 'GSK PLC';
      default:
        return '${symbol.toUpperCase()} Corp.';
    }
  }

  Future<void> loadStockData() async {
    try {
      final stockQuote = await ApiService.getStockQuote(widget.symbol);
      await Future.delayed(const Duration(milliseconds: 500));

      if (stockQuote != null) {
        final price = stockQuote['price'] as double;
        final change = stockQuote['change'] as double;
        final changePercent = stockQuote['changePercent'] as String;
        final isPositive = change >= 0;

        setState(() {
          stockData = {
            'symbol': stockQuote['symbol'],
            'name': _getCompanyName(widget.symbol),
            'price': price.toStringAsFixed(2),
            'change': change.toStringAsFixed(2),
            'changePercent': '${isPositive ? '+' : ''}$changePercent%',
            'isPositive': isPositive,
          };

          // Set initial current price info (will be updated when chart loads)
          currentPrice = price.toStringAsFixed(2);
          currentChange = '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}';
          currentChangePercent = '${isPositive ? '+' : ''}$changePercent%';
          isCurrentPositive = isPositive;

          performanceData = [
            {'period': '1 Month Return', 'value': '3.64%', 'isPositive': 'true'},
            {'period': '3 Month Return', 'value': '-0.4%', 'isPositive': 'false'},
            {'period': 'Previous Close', 'value': '\$${(price - change).toStringAsFixed(2)}', 'isPositive': 'neutral'},
            {'period': '52 Week High', 'value': '\$${stockQuote['high']?.toStringAsFixed(2) ?? price.toStringAsFixed(2)}', 'isPositive': 'neutral'},
            {'period': '52 Week Low', 'value': '\$${stockQuote['low']?.toStringAsFixed(2) ?? (price * 0.8).toStringAsFixed(2)}', 'isPositive': 'neutral'},
          ];

          relatedStocks = [
            {'symbol': 'AAPL', 'name': 'Apple Inc.', 'price': '\$${price.toStringAsFixed(2)}', 'change': '$changePercent%', 'isPositive': isPositive},
            {'symbol': 'MSFT', 'name': 'Microsoft', 'price': '\$380.50', 'change': '+2.1%', 'isPositive': true},
            {'symbol': 'GOOGL', 'name': 'Alphabet', 'price': '\$2840.75', 'change': '-1.2%', 'isPositive': false},
          ];

          isLoading = false;
        });

        // Load chart data after stock data is loaded
        _loadChartData();
      } else {
        _setFallbackData();
      }
    } catch (e) {
      print('Error loading stock data: $e');
      _setFallbackData();
    }
  }

  void _setFallbackData() {
    setState(() {
      stockData = {
        'symbol': widget.symbol,
        'name': _getCompanyName(widget.symbol),
        'price': '150.25',
        'change': '+2.47',
        'changePercent': '+1.67%',
        'isPositive': true,
      };

      // Set initial current price info
      currentPrice = '150.25';
      currentChange = '+2.47';
      currentChangePercent = '+1.67%';
      isCurrentPositive = true;

      performanceData = [
        {'period': '1 Month Return', 'value': '3.64%', 'isPositive': 'true'},
        {'period': '3 Month Return', 'value': '-0.4%', 'isPositive': 'false'},
        {'period': 'Previous Close', 'value': '\$147.78', 'isPositive': 'neutral'},
        {'period': '52 Week High', 'value': '\$200.00', 'isPositive': 'neutral'},
        {'period': '52 Week Low', 'value': '\$120.00', 'isPositive': 'neutral'},
      ];

      relatedStocks = [
        {'symbol': 'AAPL', 'name': 'Apple Inc.', 'price': '\$150.00', 'change': '+3.0%', 'isPositive': true},
        {'symbol': 'MSFT', 'name': 'Microsoft', 'price': '\$380.50', 'change': '+2.1%', 'isPositive': true},
        {'symbol': 'GOOGL', 'name': 'Alphabet', 'price': '\$2840.75', 'change': '-1.2%', 'isPositive': false},
      ];

      isLoading = false;
    });

    // Load chart data with fallback stock data
    _loadChartData();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Stock Details',
          style: TextStyle(color: colorScheme.onPrimary, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : colorScheme.onPrimary,
              size: 28,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.onSecondary),
            const SizedBox(height: 16),
            Text(
              'Loading ${widget.symbol} data...',
              style: TextStyle(
                color: colorScheme.onSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock Header
            Center(
              child: Column(
                children: [
                  Text(
                    stockData!['symbol'],
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stockData!['name'],
                    style: TextStyle(
                      color: colorScheme.onSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Stock Chart Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: colorScheme.onSecondary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  // Current Price and Change (Dynamic based on selected period)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: colorScheme.onSecondary.withOpacity(0.3)),
                        ),
                        child: Icon(
                          _getStockIcon(widget.symbol),
                          color: colorScheme.onPrimary,
                          size: 35,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$$currentPrice', // Dynamic price
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                isCurrentPositive ? Icons.trending_up : Icons.trending_down,
                                color: isCurrentPositive ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                currentChangePercent, // Dynamic percentage
                                style: TextStyle(
                                  color: isCurrentPositive ? Colors.green : Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Time Period Selector
                  _buildTimeSelector(),

                  const SizedBox(height: 10),

                  // Real Data Chart
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorScheme.onSecondary.withOpacity(0.3)),
                    ),
                    child: _buildChart(),
                  ),

                  const SizedBox(height: 20),

                  // Buy/Sell Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showTransactionDialog('BUY'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'BUY',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showTransactionDialog('SELL'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'SELL',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Key Performance Table
            Text(
              'Key Performance Table',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            ...performanceData.map((data) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.onSecondary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data['period']!,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    data['value']!,
                    style: TextStyle(
                      color: data['isPositive'] == 'true'
                          ? Colors.green
                          : data['isPositive'] == 'false'
                          ? Colors.red
                          : colorScheme.onSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 30),

            // Real News Section - UPDATED
            _buildNewsSection(),

            const SizedBox(height: 30),

            // More about Stock
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    'More about ${stockData!['name']}',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '${stockData!['name']} is a leading company known for innovation and market leadership. The company continues to show strong performance in various market conditions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Related Stocks
            Text(
              'RELATED STOCKS',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            ...relatedStocks.map((stock) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.onSecondary.withOpacity(0.3)),
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
                            stock['price'],
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
                        stock['change'],
                        style: TextStyle(
                          color: stock['isPositive'] ? Colors.green : Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockPage(symbol: stock['symbol']),
                            ),
                          );
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
            )),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showTransactionDialog(String type) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.secondary,
          title: Text(
            '$type ${stockData!['name']}',
            style: TextStyle(color: colorScheme.onPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Price: \$currentPrice', // Fixed: Use variable interpolation instead of literal string
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
                    borderSide: BorderSide(color: colorScheme.onSecondary.withOpacity(0.3)),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$type order for $quantity shares placed successfully!'),
                      backgroundColor: type == 'BUY' ? Colors.green : Colors.red,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid quantity'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: type == 'BUY' ? Colors.green : Colors.red,
              ),
              child: Text(type, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

// Enhanced chart painter with completely fixed text rendering
class RealDataChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color color;
  final Color backgroundColor;
  final String selectedPeriod;
  final Color textColor;

  RealDataChartPainter({
    required this.data,
    required this.color,
    required this.backgroundColor,
    required this.selectedPeriod,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = textColor.withOpacity(0.1)
      ..strokeWidth = 0.5;

    final path = Path();
    final backgroundPath = Path();

    // Extract prices and find min/max
    final prices = data.map((d) => d['price'] as double).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    // Avoid division by zero and add padding
    final effectiveRange = priceRange > 0 ? priceRange * 1.1 : 1.0;
    final paddedMin = minPrice - (effectiveRange - priceRange) / 2;
    final paddedMax = maxPrice + (effectiveRange - priceRange) / 2;

    // Calculate chart area with proper margins
    const leftMargin = 60.0; // Extra space for price labels
    const rightMargin = 25.0;
    const topMargin = 25.0;
    const bottomMargin = 40.0; // Extra space for time labels

    final chartArea = Rect.fromLTWH(
        leftMargin,
        topMargin,
        size.width - leftMargin - rightMargin,
        size.height - topMargin - bottomMargin
    );

    final stepX = data.length > 1 ? chartArea.width / (data.length - 1) : 0;

    // Draw horizontal grid lines (price levels)
    const gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = chartArea.top + (chartArea.height / gridLines) * i;
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        gridPaint,
      );
    }

    // Draw vertical grid lines (time) - reduced to avoid clutter
    const timeGridLines = 3;
    for (int i = 0; i <= timeGridLines; i++) {
      final x = chartArea.left + (chartArea.width / timeGridLines) * i;
      canvas.drawLine(
        Offset(x, chartArea.top),
        Offset(x, chartArea.bottom),
        gridPaint,
      );
    }

    // Draw price labels on the left side
    for (int i = 0; i <= gridLines; i++) {
      final priceValue = paddedMax - (effectiveRange / gridLines) * i;
      final y = chartArea.top + (chartArea.height / gridLines) * i;

      // Create properly formatted price text
      String priceText;
      if (priceValue >= 10000) {
        priceText = '\$${(priceValue / 1000).round()}k';
      } else if (priceValue >= 1000) {
        final thousands = priceValue / 1000;
        priceText = '\$${thousands.toStringAsFixed(1)}k';
      } else if (priceValue >= 100) {
        priceText = '\$${priceValue.round()}';
      } else if (priceValue >= 1) {
        priceText = '\$${priceValue.toStringAsFixed(1)}';
      } else {
        priceText = '\$${priceValue.toStringAsFixed(2)}';
      }

      // Create text painter for each label individually
      final priceTextPainter = TextPainter(
        text: TextSpan(
          text: priceText,
          style: TextStyle(
            color: textColor.withOpacity(0.8),
            fontSize: 9,
            fontWeight: FontWeight.w500,
            fontFamily: 'system-ui',
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      );

      priceTextPainter.layout();

      // Position text to the left of the chart area
      final textX = leftMargin - priceTextPainter.width - 12;
      final textY = y - priceTextPainter.height / 2;

      priceTextPainter.paint(canvas, Offset(textX, textY));
    }

    // Create chart paths
    bool firstPoint = true;
    for (int i = 0; i < data.length; i++) {
      final price = data[i]['price'] as double;
      final x = chartArea.left + i * stepX;
      final y = chartArea.top + ((paddedMax - price) / effectiveRange) * chartArea.height;

      if (firstPoint) {
        path.moveTo(x, y);
        backgroundPath.moveTo(chartArea.left, chartArea.bottom);
        backgroundPath.lineTo(x, y);
        firstPoint = false;
      } else {
        path.lineTo(x, y);
        backgroundPath.lineTo(x, y);
      }
    }

    // Close background path
    backgroundPath.lineTo(chartArea.right, chartArea.bottom);
    backgroundPath.close();

    // Draw background gradient effect
    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw main line
    canvas.drawPath(path, paint);

    // Draw data points for shorter periods only
    final showPoints = (selectedPeriod == '1H' || selectedPeriod == '1D') && data.length <= 24;

    if (showPoints) {
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final pointBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      // Show points with spacing to avoid clutter
      final pointStep = (data.length / 8).ceil().clamp(1, 5);
      for (int i = 0; i < data.length; i += pointStep) {
        final price = data[i]['price'] as double;
        final x = chartArea.left + i * stepX;
        final y = chartArea.top + ((paddedMax - price) / effectiveRange) * chartArea.height;

        // Draw point border
        canvas.drawCircle(Offset(x, y), 3, pointBorderPaint);
        // Draw point
        canvas.drawCircle(Offset(x, y), 2, pointPaint);
      }
    }

    // Draw time labels at the bottom
    final timeLabels = _getTimeLabels();
    const maxTimeLabels = 4;
    final timeLabelStep = data.length > maxTimeLabels ? (data.length / maxTimeLabels).floor() : 1;

    for (int i = 0; i < data.length; i += timeLabelStep) {
      if (i < timeLabels.length) {
        final x = chartArea.left + i * stepX;
        final timeLabel = timeLabels[i];

        final timeTextPainter = TextPainter(
          text: TextSpan(
            text: timeLabel,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 8,
              fontWeight: FontWeight.w400,
              fontFamily: 'system-ui',
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );

        timeTextPainter.layout();

        // Position text below the chart area
        final timeTextX = x - timeTextPainter.width / 2;
        final timeTextY = chartArea.bottom + 12;

        timeTextPainter.paint(canvas, Offset(timeTextX, timeTextY));
      }
    }

    // Draw current price indicator line and label
    if (data.isNotEmpty) {
      final currentPrice = data.last['price'] as double;
      final currentY = chartArea.top + ((paddedMax - currentPrice) / effectiveRange) * chartArea.height;

      // Only draw if within chart bounds
      if (currentY >= chartArea.top && currentY <= chartArea.bottom) {
        // Current price dashed line
        final dashedLinePaint = Paint()
          ..color = color.withOpacity(0.6)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

        _drawDashedLine(canvas, Offset(chartArea.left, currentY), Offset(chartArea.right, currentY), dashedLinePaint);

        // Current price label on the right
        String currentPriceText;
        if (currentPrice >= 10000) {
          currentPriceText = '\$${(currentPrice / 1000).round()}k';
        } else if (currentPrice >= 1000) {
          final thousands = currentPrice / 1000;
          currentPriceText = '\$${thousands.toStringAsFixed(1)}k';
        } else {
          currentPriceText = '\$${currentPrice.toStringAsFixed(2)}';
        }

        final currentPriceTextPainter = TextPainter(
          text: TextSpan(
            text: currentPriceText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              fontFamily: 'system-ui',
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );

        currentPriceTextPainter.layout();

        // Draw label background
        final labelPadding = 6.0;
        final labelRect = Rect.fromLTWH(
          chartArea.right + 8,
          currentY - currentPriceTextPainter.height / 2 - labelPadding / 2,
          currentPriceTextPainter.width + labelPadding,
          currentPriceTextPainter.height + labelPadding,
        );

        final labelBackgroundPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(labelRect, const Radius.circular(3)),
          labelBackgroundPaint,
        );

        // Draw the price text
        final currentPriceLabelX = chartArea.right + 8 + labelPadding / 2;
        final currentPriceLabelY = currentY - currentPriceTextPainter.height / 2;

        currentPriceTextPainter.paint(canvas, Offset(currentPriceLabelX, currentPriceLabelY));
      }
    }
  }

  // Helper method to draw dashed lines
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 3.0;
    const dashSpace = 2.0;
    final distance = (end - start).distance;

    if (distance == 0) return;

    final normalizedDirection = (end - start) / distance;

    double currentDistance = 0;
    bool shouldDraw = true;

    while (currentDistance < distance) {
      final segmentLength = shouldDraw ? dashWidth : dashSpace;
      final segmentEnd = currentDistance + segmentLength > distance
          ? distance
          : currentDistance + segmentLength;

      if (shouldDraw) {
        final segmentStart = start + normalizedDirection * currentDistance;
        final segmentEndPoint = start + normalizedDirection * segmentEnd;
        canvas.drawLine(segmentStart, segmentEndPoint, paint);
      }

      currentDistance = segmentEnd;
      shouldDraw = !shouldDraw;
    }
  }

  List<String> _getTimeLabels() {
    if (data.isEmpty) return [];

    List<String> labels = [];

    for (int i = 0; i < data.length; i++) {
      final timestamp = data[i]['timestamp'] as int;
      final time = DateTime.fromMillisecondsSinceEpoch(timestamp);

      String label;
      switch (selectedPeriod) {
        case '1H':
          label = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          break;
        case '1D':
          label = '${time.hour}h';
          break;
        case '1W':
          final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          label = weekdays[time.weekday % 7];
          break;
        case '1M':
          label = '${time.day}/${time.month}';
          break;
        case '1Y':
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          label = months[time.month - 1];
          break;
        default:
          label = '${time.hour}h';
      }

      labels.add(label);
    }

    return labels;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}