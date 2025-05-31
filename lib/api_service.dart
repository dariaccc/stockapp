import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Marketstack API Configuration
  // Sign up at: https://marketstack.com/
  // Free plan: 1,000 API requests per month
  static const String marketstackApiKey = 'c5df3cf158ff31fc13a17ac47a9828a7';
  static const String marketstackBaseUrl = 'http://api.marketstack.com/v1';

  // For location-based data
  static const String locationApiKey = 'YOUR_LOCATION_API_KEY'; // ipapi.co or similar

  // Get current stock price (End of Day data)
  static Future<Map<String, dynamic>?> getStockQuote(String symbol) async {
    try {
      final url = '$marketstackBaseUrl/eod/latest?access_key=$marketstackApiKey&symbols=$symbol';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stockData = data['data'];

        if (stockData != null && stockData.isNotEmpty) {
          final quote = stockData[0];
          final open = quote['open'] ?? quote['close'];
          final close = quote['close'];
          final change = close - open;
          final changePercent = open != 0 ? (change / open) * 100 : 0;

          return {
            'symbol': quote['symbol'],
            'price': close.toDouble(),
            'change': change.toDouble(),
            'changePercent': changePercent.toStringAsFixed(2),
            'volume': quote['volume']?.toInt() ?? 0,
            'lastUpdated': quote['date'],
            'open': open.toDouble(),
            'high': quote['high']?.toDouble() ?? close.toDouble(),
            'low': quote['low']?.toDouble() ?? close.toDouble(),
          };
        }
      }
    } catch (e) {
      print('Error fetching stock quote: $e');
    }
    return null;
  }

  // Get historical stock data with period support for charts
  static Future<List<Map<String, dynamic>>?> getHistoricalData(
      String symbol,
      String period, {required int limit}
      ) async {
    try {
      print('📊 Fetching historical data for $symbol - Period: $period');

      // For Marketstack free plan, we'll use the existing historical data method
      // and adapt it for different periods
      int dataLimit;
      switch (period) {
        case '1H':
          dataLimit = 1; // Very limited for free plan
          break;
        case '1D':
          dataLimit = 2; // Current + previous day
          break;
        case '1W':
          dataLimit = 7;
          break;
        case '1M':
          dataLimit = 30;
          break;
        case '1Y':
          dataLimit = 100; // Max reasonable for free plan
          break;
        default:
          dataLimit = 30;
      }

      // Use the basic historical data method
      final historicalData = await getHistoricalDataBasic(symbol, limit: dataLimit);

      if (historicalData.isNotEmpty) {
        // Convert to chart format
        List<Map<String, dynamic>> chartData = historicalData.map((item) {
          final date = DateTime.parse(item['date']);
          final price = item['close']?.toDouble() ?? 0.0;

          return {
            'timestamp': date.millisecondsSinceEpoch,
            'price': price,
            'date': item['date'],
            'open': item['open']?.toDouble() ?? price,
            'high': item['high']?.toDouble() ?? price,
            'low': item['low']?.toDouble() ?? price,
            'close': item['close']?.toDouble() ?? price,
            'volume': item['volume']?.toDouble() ?? 0.0,
          };
        }).toList();

        // Sort by timestamp (oldest first)
        chartData.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

        print('✅ Processed ${chartData.length} historical data points');
        return chartData;
      } else {
        print('⚠️ No historical data found, trying Yahoo Finance fallback');
        return await getHistoricalDataYahoo(symbol, period);
      }
    } catch (e) {
      print('💥 Exception in getHistoricalData: $e');
      // Try Yahoo Finance as fallback
      try {
        return await getHistoricalDataYahoo(symbol, period);
      } catch (e2) {
        print('💥 Yahoo Finance also failed: $e2');
        return null;
      }
    }
  }

  // Basic historical data method (renamed to avoid conflicts)
  static Future<List<Map<String, dynamic>>> getHistoricalDataBasic(String symbol, {int limit = 30}) async {
    try {
      final url = '$marketstackBaseUrl/eod?access_key=$marketstackApiKey&symbols=$symbol&limit=$limit&sort=DESC';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stockData = data['data'] as List?;

        if (stockData != null) {
          return stockData.map((dayData) => {
            'date': dayData['date'],
            'open': dayData['open']?.toDouble() ?? 0.0,
            'high': dayData['high']?.toDouble() ?? 0.0,
            'low': dayData['low']?.toDouble() ?? 0.0,
            'close': dayData['close']?.toDouble() ?? 0.0,
            'volume': dayData['volume']?.toInt() ?? 0,
          }).toList();
        }
      }
    } catch (e) {
      print('Error fetching historical data: $e');
    }
    return [];
  }

  // Fallback method using Yahoo Finance (free but unofficial)
  static Future<List<Map<String, dynamic>>?> getHistoricalDataYahoo(
      String symbol,
      String period
      ) async {
    try {
      // Determine period parameters
      int periodSeconds;
      String interval;

      switch (period) {
        case '1H':
          periodSeconds = 3600; // 1 hour
          interval = '1m';
          break;
        case '1D':
          periodSeconds = 86400; // 1 day
          interval = '5m';
          break;
        case '1W':
          periodSeconds = 604800; // 1 week
          interval = '1h';
          break;
        case '1M':
          periodSeconds = 2592000; // 30 days
          interval = '1d';
          break;
        case '1Y':
          periodSeconds = 31536000; // 1 year
          interval = '1wk';
          break;
        default:
          periodSeconds = 86400;
          interval = '1h';
      }

      final endTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final startTime = endTime - periodSeconds;

      final url = Uri.parse(
          'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?'
              'period1=$startTime&'
              'period2=$endTime&'
              'interval=$interval&'
              'includePrePost=false'
      );

      print('🔗 Yahoo Finance URL: $url');

      final response = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['chart'] != null &&
            data['chart']['result'] != null &&
            data['chart']['result'].isNotEmpty) {

          final result = data['chart']['result'][0];
          final timestamps = List<int>.from(result['timestamp'] ?? []);
          final quotes = result['indicators']['quote'][0];
          final closes = List<double>.from(
              (quotes['close'] as List).map((e) => e?.toDouble() ?? 0.0)
          );

          List<Map<String, dynamic>> chartData = [];

          for (int i = 0; i < timestamps.length && i < closes.length; i++) {
            if (closes[i] > 0) { // Filter out null/zero values
              chartData.add({
                'timestamp': timestamps[i] * 1000, // Convert to milliseconds
                'price': closes[i],
                'date': DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000).toIso8601String(),
              });
            }
          }

          print('✅ Yahoo Finance: Processed ${chartData.length} data points');
          return chartData;
        }
      }

      print('❌ Yahoo Finance API error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('💥 Exception in Yahoo Finance API: $e');
      return null;
    }
  }

  // Alternative method using Alpha Vantage (if you have API key)
  static Future<List<Map<String, dynamic>>?> getHistoricalDataAlphaVantage(
      String symbol,
      String period
      ) async {
    try {
      const alphaVantageKey = 'YOUR_ALPHA_VANTAGE_API_KEY'; // Replace with your key
      String function;
      String interval = '';

      switch (period) {
        case '1H':
          function = 'TIME_SERIES_INTRADAY';
          interval = '&interval=5min';
          break;
        case '1D':
          function = 'TIME_SERIES_INTRADAY';
          interval = '&interval=60min';
          break;
        case '1W':
        case '1M':
          function = 'TIME_SERIES_DAILY';
          break;
        case '1Y':
          function = 'TIME_SERIES_WEEKLY';
          break;
        default:
          function = 'TIME_SERIES_DAILY';
      }

      final url = Uri.parse(
          'https://www.alphavantage.co/query?'
              'function=$function&'
              'symbol=$symbol'
              '$interval&'
              'apikey=$alphaVantageKey'
      );

      print('🔗 Alpha Vantage URL: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract time series data
        String timeSeriesKey = '';
        if (function == 'TIME_SERIES_INTRADAY') {
          timeSeriesKey = interval.contains('5min')
              ? 'Time Series (5min)'
              : 'Time Series (60min)';
        } else if (function == 'TIME_SERIES_DAILY') {
          timeSeriesKey = 'Time Series (Daily)';
        } else if (function == 'TIME_SERIES_WEEKLY') {
          timeSeriesKey = 'Weekly Time Series';
        }

        if (data[timeSeriesKey] != null) {
          final Map<String, dynamic> timeSeries = data[timeSeriesKey];

          List<Map<String, dynamic>> chartData = [];

          timeSeries.forEach((dateStr, values) {
            final date = DateTime.parse(dateStr);
            final close = double.parse(values['4. close']);

            chartData.add({
              'timestamp': date.millisecondsSinceEpoch,
              'price': close,
              'date': dateStr,
              'open': double.parse(values['1. open']),
              'high': double.parse(values['2. high']),
              'low': double.parse(values['3. low']),
              'close': close,
              'volume': double.parse(values['5. volume']),
            });
          });

          // Sort by timestamp (oldest first)
          chartData.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

          // Limit data points based on period
          int maxPoints;
          switch (period) {
            case '1H':
              maxPoints = 60;
              break;
            case '1D':
              maxPoints = 24;
              break;
            case '1W':
              maxPoints = 7;
              break;
            case '1M':
              maxPoints = 30;
              break;
            case '1Y':
              maxPoints = 52;
              break;
            default:
              maxPoints = 30;
          }

          if (chartData.length > maxPoints) {
            // Take evenly spaced points
            final step = chartData.length / maxPoints;
            List<Map<String, dynamic>> sampledData = [];
            for (int i = 0; i < maxPoints; i++) {
              final index = (i * step).round();
              if (index < chartData.length) {
                sampledData.add(chartData[index]);
              }
            }
            chartData = sampledData;
          }

          print('✅ Alpha Vantage: Processed ${chartData.length} data points');
          return chartData;
        }
      }

      print('❌ Alpha Vantage API error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('💥 Exception in Alpha Vantage API: $e');
      return null;
    }
  }

  // Get multiple stocks data (for portfolio or watchlist)
  static Future<List<Map<String, dynamic>>> getMultipleStocks(List<String> symbols) async {
    try {
      final symbolsString = symbols.join(',');
      final url = '$marketstackBaseUrl/eod/latest?access_key=$marketstackApiKey&symbols=$symbolsString';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stocksData = data['data'] as List?;

        if (stocksData != null) {
          return stocksData.map((stock) {
            final open = stock['open'] ?? stock['close'];
            final close = stock['close'];
            final change = close - open;
            final changePercent = open != 0 ? (change / open) * 100 : 0;

            return {
              'symbol': stock['symbol'],
              'price': close.toDouble(),
              'change': change.toDouble(),
              'changePercent': changePercent.toStringAsFixed(2),
              'volume': stock['volume']?.toInt() ?? 0,
              'lastUpdated': stock['date'],
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error fetching multiple stocks: $e');
    }
    return [];
  }

  // Get intraday data (if available with paid plan)
  static Future<List<Map<String, dynamic>>> getIntradayData(String symbol) async {
    try {
      // Note: Intraday data requires paid Marketstack plan
      final url = '$marketstackBaseUrl/intraday/latest?access_key=$marketstackApiKey&symbols=$symbol&interval=1hour&limit=24';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final intradayData = data['data'] as List?;

        if (intradayData != null) {
          return intradayData.map((hourData) => {
            'date': hourData['date'],
            'open': hourData['open']?.toDouble() ?? 0.0,
            'high': hourData['high']?.toDouble() ?? 0.0,
            'low': hourData['low']?.toDouble() ?? 0.0,
            'close': hourData['close']?.toDouble() ?? 0.0,
            'volume': hourData['volume']?.toInt() ?? 0,
          }).toList();
        }
      }
    } catch (e) {
      print('Error fetching intraday data: $e');
      // Fallback to historical data if intraday not available
      return await getHistoricalDataBasic(symbol, limit: 7);
    }
    return [];
  }

  // Get stock exchanges
  static Future<List<Map<String, dynamic>>> getExchanges() async {
    try {
      final url = '$marketstackBaseUrl/exchanges?access_key=$marketstackApiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final exchanges = data['data'] as List?;

        if (exchanges != null) {
          return exchanges.map((exchange) => {
            'name': exchange['name'],
            'acronym': exchange['acronym'],
            'mic': exchange['mic'],
            'country': exchange['country'],
            'country_code': exchange['country_code'],
            'city': exchange['city'],
            'website': exchange['website'],
          }).toList();
        }
      }
    } catch (e) {
      print('Error fetching exchanges: $e');
    }
    return [];
  }

  // Get stocks by exchange (useful for location-based recommendations)
  static Future<List<Map<String, dynamic>>> getStocksByExchange(String exchange, {int limit = 20}) async {
    try {
      final url = '$marketstackBaseUrl/tickers?access_key=$marketstackApiKey&exchange=$exchange&limit=$limit';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tickers = data['data'] as List?;

        if (tickers != null) {
          return tickers.map((ticker) => {
            'symbol': ticker['symbol'],
            'name': ticker['name'],
            'stock_exchange': ticker['stock_exchange'],
          }).toList();
        }
      }
    } catch (e) {
      print('Error fetching stocks by exchange: $e');
    }
    return [];
  }

  // Get user's location-based market data
  static Future<Map<String, dynamic>?> getLocationBasedData() async {
    try {
      // Get user's location
      final locationResponse = await http.get(Uri.parse('https://ipapi.co/json/'));

      if (locationResponse.statusCode == 200) {
        final locationData = json.decode(locationResponse.body);
        final country = locationData['country_name'];
        final countryCode = locationData['country_code'];
        final currency = locationData['currency'];

        // Map countries to their main stock exchanges
        Map<String, dynamic> exchangeInfo = _getExchangeByCountry(countryCode);

        // Get recommended stocks based on location
        List<String> recommendedSymbols = await _getRecommendedStocksByCountry(countryCode);

        return {
          'country': country,
          'countryCode': countryCode,
          'currency': currency,
          'exchange': exchangeInfo['exchange'],
          'exchangeName': exchangeInfo['name'],
          'recommendedStocks': recommendedSymbols,
          'timezone': locationData['timezone'],
        };
      }
    } catch (e) {
      print('Error fetching location data: $e');
    }
    return null;
  }

  // Helper method to map countries to exchanges
  static Map<String, dynamic> _getExchangeByCountry(String countryCode) {
    switch (countryCode.toLowerCase()) {
      case 'us':
        return {'exchange': 'NASDAQ', 'name': 'NASDAQ Stock Market'};
      case 'gb':
        return {'exchange': 'LSE', 'name': 'London Stock Exchange'};
      case 'de':
        return {'exchange': 'XETR', 'name': 'Deutsche Börse XETRA'};
      case 'fr':
        return {'exchange': 'EURONEXT', 'name': 'Euronext Paris'};
      case 'jp':
        return {'exchange': 'TSE', 'name': 'Tokyo Stock Exchange'};
      case 'in':
        return {'exchange': 'BSE', 'name': 'Bombay Stock Exchange'};
      case 'ca':
        return {'exchange': 'TSX', 'name': 'Toronto Stock Exchange'};
      case 'au':
        return {'exchange': 'ASX', 'name': 'Australian Securities Exchange'};
      default:
        return {'exchange': 'NYSE', 'name': 'New York Stock Exchange'};
    }
  }

  // Helper method to get recommended stocks by country
  static Future<List<String>> _getRecommendedStocksByCountry(String countryCode) async {
    switch (countryCode.toLowerCase()) {
      case 'us':
        return ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA', 'META', 'NVDA'];
      case 'gb':
        return ['LLOY.LON', 'BARC.LON', 'BP.LON', 'SHEL.LON', 'VOD.LON'];
      case 'de':
        return ['SAP.DEX', 'ALV.DEX', 'SIE.DEX', 'ASME.DEX', 'BMW.DEX'];
      case 'fr':
        return ['MC.PAR', 'OR.PAR', 'SAN.PAR', 'AIR.PAR', 'BNP.PAR'];
      case 'jp':
        return ['7203.TYO', '6758.TYO', '9984.TYO', '6861.TYO', '8306.TYO'];
      case 'in':
        return ['RELIANCE.BSE', 'TCS.BSE', 'HDFCBANK.BSE', 'BHARTIARTL.BSE'];
      case 'ca':
        return ['SHOP.TOR', 'RY.TOR', 'TD.TOR', 'CNR.TOR', 'SU.TOR'];
      case 'au':
        return ['CBA.ASX', 'BHP.ASX', 'ANZ.ASX', 'WBC.ASX', 'NAB.ASX'];
      default:
        return ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA']; // Default to US stocks
    }
  }

  // Calculate top gainers and losers from a list of stocks
  static Future<Map<String, List<Map<String, dynamic>>>> getTopMovers(List<String> symbols) async {
    try {
      final stocksData = await getMultipleStocks(symbols);

      if (stocksData.isNotEmpty) {
        // Sort by change percentage
        stocksData.sort((a, b) => double.parse(b['changePercent']).compareTo(double.parse(a['changePercent'])));

        final topGainers = stocksData.where((stock) => double.parse(stock['changePercent']) > 0).take(5).toList();
        final topLosers = stocksData.where((stock) => double.parse(stock['changePercent']) < 0).take(5).toList();

        return {
          'top_gainers': topGainers,
          'top_losers': topLosers,
        };
      }
    } catch (e) {
      print('Error calculating top movers: $e');
    }
    return {'top_gainers': [], 'top_losers': []};
  }

  // Get news (you might need to integrate with a news API like NewsAPI)
  static Future<List<Map<String, dynamic>>> getStockNews(String symbol) async {
    try {
      // Note: Marketstack doesn't provide news data
      // You can integrate with NewsAPI.org for news
      // For demo purposes, returning mock news data

      return [
        {
          'title': '$symbol Surpasses Q4 Earnings in Out-performance: Sets Promising...',
          'summary': 'Company shows strong quarterly performance with increased revenue.',
          'time_published': DateTime.now().subtract(const Duration(hours: 16)).toIso8601String(),
          'source': 'Financial Times',
          'sentiment_score': 0.7,
        },
        {
          'title': '$symbol Development Team Compensated with Equity Payments',
          'summary': 'Strategic move to retain top talent in competitive market.',
          'time_published': DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(),
          'source': 'Bloomberg',
          'sentiment_score': 0.5,
        },
        {
          'title': '$symbol Plunges from Peak to 52-Week LOW amid Volatility',
          'summary': 'Market volatility affects stock price significantly.',
          'time_published': DateTime.now().subtract(const Duration(hours: 19)).toIso8601String(),
          'source': 'Reuters',
          'sentiment_score': -0.3,
        },
      ];
    } catch (e) {
      print('Error fetching news: $e');
    }
    return [];
  }
}

// User Data Storage Service (for buy/sell transactions)
class UserDataService {
  // In a real app, you'd use a database or secure storage
  // For demo purposes, we'll use a simple in-memory storage

  static List<Map<String, dynamic>> _transactions = [];
  static Map<String, double> _portfolio = {}; // symbol -> quantity
  static double _cashBalance = 10000.0; // Starting balance

  // Add a transaction (buy/sell)
  static bool addTransaction({
    required String type, // 'BUY' or 'SELL'
    required String symbol,
    required double price,
    required int quantity,
  }) {
    final total = price * quantity;

    if (type == 'BUY') {
      if (_cashBalance >= total) {
        _cashBalance -= total;
        _portfolio[symbol] = (_portfolio[symbol] ?? 0) + quantity;

        _transactions.add({
          'type': type,
          'symbol': symbol,
          'price': price,
          'quantity': quantity,
          'total': total,
          'timestamp': DateTime.now().toIso8601String(),
        });
        return true;
      }
      return false; // Insufficient funds
    } else if (type == 'SELL') {
      if ((_portfolio[symbol] ?? 0) >= quantity) {
        _cashBalance += total;
        _portfolio[symbol] = (_portfolio[symbol] ?? 0) - quantity;

        if (_portfolio[symbol] == 0) {
          _portfolio.remove(symbol);
        }

        _transactions.add({
          'type': type,
          'symbol': symbol,
          'price': price,
          'quantity': quantity,
          'total': total,
          'timestamp': DateTime.now().toIso8601String(),
        });
        return true;
      }
      return false; // Insufficient shares
    }
    return false;
  }

  // Get user's portfolio
  static Map<String, double> getPortfolio() {
    return Map.from(_portfolio);
  }

  // Get transaction history
  static List<Map<String, dynamic>> getTransactions() {
    return List.from(_transactions.reversed); // Most recent first
  }

  // Get cash balance
  static double getCashBalance() {
    return _cashBalance;
  }

  // Calculate portfolio value (you'd need current prices)
  static Future<double> getPortfolioValue() async {
    double totalValue = _cashBalance;

    if (_portfolio.isNotEmpty) {
      final symbols = _portfolio.keys.toList();
      final stocksData = await ApiService.getMultipleStocks(symbols);

      for (var stockData in stocksData) {
        final symbol = stockData['symbol'];
        final price = stockData['price'];
        final quantity = _portfolio[symbol] ?? 0;
        totalValue += price * quantity;
      }
    }

    return totalValue;
  }

  // Get portfolio performance
  static Future<Map<String, dynamic>> getPortfolioPerformance() async {
    final currentValue = await getPortfolioValue();
    const initialValue = 10000.0; // Starting balance

    final totalGainLoss = currentValue - initialValue;
    final percentageChange = ((totalGainLoss / initialValue) * 100);

    return {
      'currentValue': currentValue,
      'initialValue': initialValue,
      'totalGainLoss': totalGainLoss,
      'percentageChange': percentageChange,
      'cashBalance': _cashBalance,
      'investedAmount': initialValue - _cashBalance,
    };
  }
}