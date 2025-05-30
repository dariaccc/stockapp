import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_service.dart';

class StockPage extends StatefulWidget {
  final String symbol;

  const StockPage({super.key, required this.symbol});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  Map<String, dynamic>? stockData;
  List<Map<String, String>> performanceData = [];
  List<Map<String, String>> newsArticles = [];
  List<Map<String, dynamic>> relatedStocks = [];
  bool isLoading = true;
  bool isFavorite = false;

  // Chart related variables
  String selectedPeriod = '1D';
  List<Map<String, dynamic>> chartData = [];
  bool isChartLoading = false;

  @override
  void initState() {
    super.initState();
    loadStockData();
    _testUserService();
    _checkIfFavorite();
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
        // Fallback to the existing historical data method
        try {
          final fallbackData = await ApiService.getHistoricalData(widget.symbol, selectedPeriod, limit: 30);
          if (fallbackData!.isNotEmpty) {
            // Convert the fallback data to the expected format
            historicalData = fallbackData.map((item) => {
              'timestamp': DateTime.parse(item['date']).millisecondsSinceEpoch,
              'price': item['close']?.toDouble() ?? 0.0,
              'date': item['date'],
              'open': item['open']?.toDouble() ?? 0.0,
              'high': item['high']?.toDouble() ?? 0.0,
              'low': item['low']?.toDouble() ?? 0.0,
              'close': item['close']?.toDouble() ?? 0.0,
              'volume': item['volume']?.toDouble() ?? 0.0,
            }).toList();
          }
        } catch (e2) {
          print('⚠️ Fallback historical data also failed: $e2');
        }
      }

      if (historicalData != null && historicalData.isNotEmpty) {
        print('✅ Received ${historicalData.length} data points from API');
        setState(() {
          chartData = historicalData!;
          isChartLoading = false;
        });
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
          } else {
            // Final fallback to generated data
            final fallbackData = await _generateRealisticFallbackChartData();
            setState(() {
              chartData = fallbackData;
              isChartLoading = false;
            });
          }
        } catch (e) {
          print('❌ Yahoo Finance also failed: $e');
          // Final fallback to generated data
          final fallbackData = await _generateRealisticFallbackChartData();
          setState(() {
            chartData = fallbackData;
            isChartLoading = false;
          });
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
    }
  }

  Future<List<Map<String, dynamic>>> _generateRealisticFallbackChartData() async {
    print('🔄 Generating realistic fallback chart data for $selectedPeriod');

    final basePrice = stockData != null
        ? double.tryParse(stockData!['price']) ?? 150.0
        : 150.0;

    List<Map<String, dynamic>> data = [];
    int dataPoints;
    Duration interval;
    double volatility;

    final now = DateTime.now();

    switch (selectedPeriod) {
      case '1H':
        dataPoints = 60;
        interval = const Duration(minutes: 1);
        volatility = 0.001;
        break;
      case '1D':
        dataPoints = 24;
        interval = const Duration(hours: 1);
        volatility = 0.005;
        break;
      case '1W':
        dataPoints = 7;
        interval = const Duration(days: 1);
        volatility = 0.02;
        break;
      case '1M':
        dataPoints = 30;
        interval = const Duration(days: 1);
        volatility = 0.03;
        break;
      case '1Y':
        dataPoints = 52;
        interval = const Duration(days: 7);
        volatility = 0.08;
        break;
      default:
        dataPoints = 24;
        interval = const Duration(hours: 1);
        volatility = 0.005;
    }

    double currentPrice = basePrice;

    for (int i = dataPoints - 1; i >= 0; i--) {
      final timestamp = now.subtract(interval * i);

      // Generate realistic price movement
      final random = (timestamp.millisecondsSinceEpoch % 1000) / 1000.0;
      final change = (random - 0.5) * volatility * basePrice;
      currentPrice += change;

      // Keep price within reasonable bounds
      currentPrice = currentPrice.clamp(basePrice * 0.85, basePrice * 1.15);

      data.add({
        'timestamp': timestamp.millisecondsSinceEpoch,
        'price': currentPrice,
        'date': timestamp.toIso8601String(),
      });
    }

    return data;
  }

  void _onPeriodSelected(String period) {
    setState(() {
      selectedPeriod = period;
    });
    _loadChartData();
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

  Widget _buildChart() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (isChartLoading) {
      return Container(
        height: 200,
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
        height: 200,
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
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart info
          Row(
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
                '${chartData.length} data points',
                style: TextStyle(
                  color: colorScheme.onSecondary.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Chart
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: RealDataChartPainter(
                data: chartData,
                color: lineColor,
                backgroundColor: lineColor.withOpacity(0.1),
                selectedPeriod: selectedPeriod,
                textColor: colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
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

          performanceData = [
            {'period': '1 Month Return', 'value': '3.64%', 'isPositive': 'true'},
            {'period': '3 Month Return', 'value': '-0.4%', 'isPositive': 'false'},
            {'period': 'Previous Close', 'value': '\$${(price - change).toStringAsFixed(2)}', 'isPositive': 'neutral'},
            {'period': '52 Week High', 'value': '\$${stockQuote['high']?.toStringAsFixed(2) ?? price.toStringAsFixed(2)}', 'isPositive': 'neutral'},
            {'period': '52 Week Low', 'value': '\$${stockQuote['low']?.toStringAsFixed(2) ?? (price * 0.8).toStringAsFixed(2)}', 'isPositive': 'neutral'},
          ];

          newsArticles = [
            {'title': '${stockData!['name']} Surpasses Q4 Earnings: Sets Promising...', 'time': '16h ago'},
            {'title': '${stockData!['name']} Development Team Gets Equity Payments', 'time': '18h ago'},
            {'title': '${stockData!['name']} Shows Strong Performance amid Volatility', 'time': '19h ago'},
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

      performanceData = [
        {'period': '1 Month Return', 'value': '3.64%', 'isPositive': 'true'},
        {'period': '3 Month Return', 'value': '-0.4%', 'isPositive': 'false'},
        {'period': 'Previous Close', 'value': '\$147.78', 'isPositive': 'neutral'},
        {'period': '52 Week High', 'value': '\$200.00', 'isPositive': 'neutral'},
        {'period': '52 Week Low', 'value': '\$120.00', 'isPositive': 'neutral'},
      ];

      newsArticles = [
        {'title': '${stockData!['name']} Surpasses Q4 Earnings: Sets Promising...', 'time': '16h ago'},
        {'title': '${stockData!['name']} Development Team Gets Equity Payments', 'time': '18h ago'},
        {'title': '${stockData!['name']} Shows Strong Performance amid Volatility', 'time': '19h ago'},
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
                  // Current Price and Change
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
                            '\$${stockData!['price']}',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                stockData!['isPositive'] ? Icons.trending_up : Icons.trending_down,
                                color: stockData!['isPositive'] ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                stockData!['changePercent'],
                                style: TextStyle(
                                  color: stockData!['isPositive'] ? Colors.green : Colors.red,
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

            // Latest Articles
            Text(
              'Latest Articles',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            ...newsArticles.map((article) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.onSecondary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title']!,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    article['time']!,
                    style: TextStyle(
                      color: colorScheme.onSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )),

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
                'Current Price: \$${stockData!['price']}',
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

// Enhanced chart painter for real API data
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

    // Avoid division by zero
    final effectiveRange = priceRange > 0 ? priceRange : 1.0;

    // Calculate chart area (leave space for labels)
    final chartArea = Rect.fromLTWH(30, 10, size.width - 60, size.height - 30);
    final stepX = chartArea.width / (data.length - 1);

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = chartArea.top + (chartArea.height / 4) * i;
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        gridPaint,
      );
    }

    // Draw price labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= 4; i++) {
      final priceValue = maxPrice - (effectiveRange / 4) * i;
      final y = chartArea.top + (chartArea.height / 4) * i;

      textPainter.text = TextSpan(
        text: '\${priceValue.toStringAsFixed(1)}',
        style: TextStyle(
          color: textColor.withOpacity(0.7),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }

    // Create chart paths
    bool firstPoint = true;
    for (int i = 0; i < data.length; i++) {
      final price = data[i]['price'] as double;
      final x = chartArea.left + i * stepX;
      final y = chartArea.top + ((maxPrice - price) / effectiveRange) * chartArea.height;

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

    // Draw data points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Only show points for shorter periods to avoid clutter
    final showPoints = selectedPeriod == '1H' || selectedPeriod == '1D';

    if (showPoints && data.length <= 50) {
      for (int i = 0; i < data.length; i++) {
        final price = data[i]['price'] as double;
        final x = chartArea.left + i * stepX;
        final y = chartArea.top + ((maxPrice - price) / effectiveRange) * chartArea.height;

        // Draw point border (white)
        canvas.drawCircle(Offset(x, y), 4, pointBorderPaint);
        // Draw point
        canvas.drawCircle(Offset(x, y), 2.5, pointPaint);
      }
    }

    // Draw time labels
    final timeLabels = _getTimeLabels();
    for (int i = 0; i < timeLabels.length && i < data.length; i++) {
      if (i % (data.length ~/ timeLabels.length + 1) == 0) {
        final x = chartArea.left + i * stepX;

        textPainter.text = TextSpan(
          text: timeLabels[i],
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 9,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, chartArea.bottom + 5),
        );
      }
    }

    // Draw current price indicator
    if (data.isNotEmpty) {
      final currentPrice = data.last['price'] as double;
      final currentY = chartArea.top + ((maxPrice - currentPrice) / effectiveRange) * chartArea.height;

      // Current price line
      final currentPricePaint = Paint()
        ..color = color.withOpacity(0.8)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(chartArea.left, currentY),
        Offset(chartArea.right, currentY),
        currentPricePaint,
      );

      // Current price label
      textPainter.text = TextSpan(
        text: '\${currentPrice.toStringAsFixed(2)}',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      // Draw label background
      final labelRect = Rect.fromLTWH(
        chartArea.right - textPainter.width - 8,
        currentY - textPainter.height / 2 - 2,
        textPainter.width + 6,
        textPainter.height + 4,
      );

      final labelPaint = Paint()
        ..color = color.withOpacity(0.1)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
        labelPaint,
      );

      textPainter.paint(
        canvas,
        Offset(chartArea.right - textPainter.width - 5, currentY - textPainter.height / 2),
      );
    }
  }

  List<String> _getTimeLabels() {
    if (data.isEmpty) return [];

    switch (selectedPeriod) {
      case '1H':
        return data.asMap().entries.map((entry) {
          final timestamp = entry.value['timestamp'] as int;
          final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
          return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        }).toList();
      case '1D':
        return data.asMap().entries.map((entry) {
          final timestamp = entry.value['timestamp'] as int;
          final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
          return '${time.hour}h';
        }).toList();
      case '1W':
        return data.asMap().entries.map((entry) {
          final timestamp = entry.value['timestamp'] as int;
          final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
          return '${time.day}/${time.month}';
        }).toList();
      case '1M':
        return data.asMap().entries.map((entry) {
          final timestamp = entry.value['timestamp'] as int;
          final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
          return '${time.day}/${time.month}';
        }).toList();
      case '1Y':
        return data.asMap().entries.map((entry) {
          final timestamp = entry.value['timestamp'] as int;
          final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
          return '${time.month}/${time.year.toString().substring(2)}';
        }).toList();
      default:
        return data.asMap().entries.map((entry) => entry.key.toString()).toList();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}