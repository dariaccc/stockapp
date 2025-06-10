import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Yahoo Finance Configuration (No API key needed!)
  static const String yahooBaseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart';

  // Marketstack API Configuration (kept as fallback)
  static const String marketstackApiKey = 'c5df3cf158ff31fc13a17ac47a9828a7';
  static const String marketstackBaseUrl = 'http://api.marketstack.com/v1';

  // Get current stock price using Yahoo Finance
  static Future<Map<String, dynamic>?> getStockQuote(String symbol) async {
    try {
      print('📊 Fetching quote for $symbol from Yahoo Finance...');

      final url = '$yahooBaseUrl/$symbol';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Mozilla/5.0 (compatible; StockApp/1.0)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['chart'] != null &&
            data['chart']['result'] != null &&
            data['chart']['result'].isNotEmpty) {

          final result = data['chart']['result'][0];
          final meta = result['meta'];

          final currentPrice = meta['regularMarketPrice']?.toDouble() ?? 0.0;
          final previousClose = meta['previousClose']?.toDouble() ?? currentPrice;
          final change = currentPrice - previousClose;
          final changePercent = previousClose != 0 ? (change / previousClose) * 100 : 0;

          return {
            'symbol': meta['symbol'],
            'price': currentPrice,
            'change': change,
            'changePercent': changePercent.toStringAsFixed(2),
            'volume': meta['regularMarketVolume'] ?? 0,
            'lastUpdated': DateTime.now().toIso8601String(),
            'open': meta['regularMarketOpen']?.toDouble() ?? currentPrice,
            'high': meta['regularMarketDayHigh']?.toDouble() ?? currentPrice,
            'low': meta['regularMarketDayLow']?.toDouble() ?? currentPrice,
          };
        }
      }

      print('⚠️ Yahoo Finance failed for $symbol, status: ${response.statusCode}');
      return null;

    } catch (e) {
      print('❌ Error fetching stock quote from Yahoo Finance: $e');
      return null;
    }
  }

  // Get multiple stocks using Yahoo Finance
  static Future<List<Map<String, dynamic>>> getMultipleStocks(List<String> symbols) async {
    print('📊 Fetching ${symbols.length} stocks from Yahoo Finance...');

    List<Map<String, dynamic>> results = [];

    // Yahoo Finance doesn't support batch requests, so we call individually
    for (String symbol in symbols) {
      try {
        final stock = await getStockQuote(symbol);
        if (stock != null) {
          results.add(stock);
          print('✅ Successfully fetched: ${stock['symbol']} - \$${stock['price']}');
        } else {
          print('❌ Failed to fetch: $symbol');
        }

        // Small delay to be respectful to Yahoo's servers
        await Future.delayed(Duration(milliseconds: 100));

      } catch (e) {
        print('❌ Error fetching $symbol: $e');
      }
    }

    print('📈 Final result: ${results.length}/${symbols.length} stocks fetched');
    return results;
  }

  // Enhanced Yahoo Finance historical data (your existing method but improved)
  static Future<List<Map<String, dynamic>>?> getHistoricalData(
      String symbol,
      String period, {required int limit}
      ) async {
    try {
      print('📊 Fetching historical data for $symbol - Period: $period');
      return await getHistoricalDataYahoo(symbol, period);
    } catch (e) {
      print('💥 Exception in getHistoricalData: $e');
      return null;
    }
  }

  // Improved Yahoo Finance historical data method
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
      print('❌ Response body: ${response.body}');
      return null;
    } catch (e) {
      print('💥 Exception in Yahoo Finance API: $e');
      return null;
    }
  }

  // Alternative stock quote method using different Yahoo endpoint
  static Future<Map<String, dynamic>?> getStockQuoteAlternative(String symbol) async {
    try {
      print('📊 Trying alternative Yahoo Finance endpoint for $symbol...');

      final url = 'https://query1.finance.yahoo.com/v10/finance/quoteSummary/$symbol?modules=price';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Mozilla/5.0 (compatible; StockApp/1.0)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['quoteSummary'] != null &&
            data['quoteSummary']['result'] != null &&
            data['quoteSummary']['result'].isNotEmpty) {

          final priceData = data['quoteSummary']['result'][0]['price'];

          final currentPrice = priceData['regularMarketPrice']['raw']?.toDouble() ?? 0.0;
          final previousClose = priceData['regularMarketPreviousClose']['raw']?.toDouble() ?? currentPrice;
          final change = currentPrice - previousClose;
          final changePercent = previousClose != 0 ? (change / previousClose) * 100 : 0;

          return {
            'symbol': priceData['symbol'],
            'price': currentPrice,
            'change': change,
            'changePercent': changePercent.toStringAsFixed(2),
            'volume': priceData['regularMarketVolume']['raw'] ?? 0,
            'lastUpdated': DateTime.now().toIso8601String(),
            'open': priceData['regularMarketOpen']['raw']?.toDouble() ?? currentPrice,
            'high': priceData['regularMarketDayHigh']['raw']?.toDouble() ?? currentPrice,
            'low': priceData['regularMarketDayLow']['raw']?.toDouble() ?? currentPrice,
          };
        }
      }

      print('⚠️ Alternative Yahoo Finance failed for $symbol, status: ${response.statusCode}');
      return null;

    } catch (e) {
      print('❌ Error with alternative Yahoo Finance endpoint: $e');
      return null;
    }
  }

  // Robust stock quote with multiple fallbacks
  static Future<Map<String, dynamic>?> getStockQuoteRobust(String symbol) async {
    // Try primary Yahoo Finance method
    var result = await getStockQuote(symbol);
    if (result != null) return result;

    print('🔄 Primary method failed, trying alternative...');

    // Try alternative Yahoo Finance method
    result = await getStockQuoteAlternative(symbol);
    if (result != null) return result;

    print('🔄 Alternative method failed, trying Marketstack fallback...');

    // Try Marketstack as last resort (if you have API calls left)
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

          print('✅ Marketstack fallback successful for $symbol');
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
      print('❌ Marketstack fallback also failed: $e');
    }

    print('❌ All methods failed for $symbol');
    return null;
  }

  // Enhanced multiple stocks with robust fetching
  static Future<List<Map<String, dynamic>>> getMultipleStocksRobust(List<String> symbols) async {
    print('📊 Fetching ${symbols.length} stocks with robust method...');

    List<Map<String, dynamic>> results = [];

    for (String symbol in symbols) {
      try {
        final stock = await getStockQuoteRobust(symbol);
        if (stock != null) {
          results.add(stock);
          print('✅ Successfully fetched: ${stock['symbol']} - \$${stock['price']}');
        } else {
          print('❌ All methods failed for: $symbol');
        }

        // Small delay between requests
        await Future.delayed(Duration(milliseconds: 200));

      } catch (e) {
        print('❌ Error fetching $symbol: $e');
      }
    }

    print('📈 Final robust result: ${results.length}/${symbols.length} stocks fetched');
    return results;
  }

  // Keep all your existing methods below this point...
  // (getHistoricalDataBasic, getHistoricalDataAlphaVantage, getIntradayData, etc.)
  // Just replace the calls in your main methods above

  // Basic historical data method (keep as fallback)
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

// Keep your other existing methods unchanged...
// (getExchanges, getLocationBasedData, getTopMovers, getStockNews, etc.)
}