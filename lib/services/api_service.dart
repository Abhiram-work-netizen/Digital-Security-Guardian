import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// API Service — connects the Flutter app to the DLG backend server.
/// Auto-discovers the backend by trying multiple addresses.
class ApiService {
  // Candidate URLs to try (order: cloud, emulator, local WiFi)
  static const List<String> _candidateUrls = [
    'https://dlg-backend.onrender.com',  // ☁️ Cloud (always available)
    'http://10.0.2.2:3000',              // Android Emulator
    'http://192.168.5.14:3000',          // Physical device on WiFi
  ];

  static String? _activeBaseUrl;
  static bool _isBackendAvailable = false;
  static DateTime? _lastHealthCheck;

  /// Check if backend is running (tries all candidate URLs)
  static Future<bool> checkHealth() async {
    // Cache health check for 30 seconds
    if (_lastHealthCheck != null && DateTime.now().difference(_lastHealthCheck!).inSeconds < 30) {
      return _isBackendAvailable;
    }

    // If we already found a working URL, try it first
    if (_activeBaseUrl != null) {
      try {
        final response = await http.get(
          Uri.parse('$_activeBaseUrl/health'),
        ).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          _isBackendAvailable = true;
          _lastHealthCheck = DateTime.now();
          return true;
        }
      } catch (_) {}
    }

    // Try all candidate URLs
    for (final url in _candidateUrls) {
      try {
        final response = await http.get(
          Uri.parse('$url/health'),
        ).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          _activeBaseUrl = url;
          _isBackendAvailable = true;
          _lastHealthCheck = DateTime.now();
          return true;
        }
      } catch (_) {
        continue;
      }
    }

    _isBackendAvailable = false;
    _lastHealthCheck = DateTime.now();
    return false;
  }

  /// Get the active base URL (or first candidate as fallback)
  static String get _baseUrl => _activeBaseUrl ?? _candidateUrls.first;

  /// Scan a URL for threats
  static Future<Map<String, dynamic>> scanLink(String url) async {
    try {
      final isAvailable = await checkHealth();
      if (!isAvailable) {
        return _fallbackLinkScan(url);
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/scan/link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return _fallbackLinkScan(url);
    } catch (e) {
      return _fallbackLinkScan(url);
    }
  }

  /// Scan a file for threats
  static Future<Map<String, dynamic>> scanFile(File file) async {
    try {
      final isAvailable = await checkHealth();
      if (!isAvailable) {
        return _fallbackFileScan(file);
      }

      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/scan/file'));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return _fallbackFileScan(file);
    } catch (e) {
      return _fallbackFileScan(file);
    }
  }

  /// Analyze text for phishing patterns
  static Future<Map<String, dynamic>> scanText(String text) async {
    try {
      final isAvailable = await checkHealth();
      if (!isAvailable) {
        return _fallbackTextScan(text);
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/scan/text'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return _fallbackTextScan(text);
    } catch (e) {
      return _fallbackTextScan(text);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FALLBACK LOCAL SCANNING (when backend is unavailable)
  // ═══════════════════════════════════════════════════════════

  static Map<String, dynamic> _fallbackLinkScan(String url) {
    final domain = url.toLowerCase().replaceAll(RegExp(r'^https?://'), '').split('/')[0];
    final warnings = <String>[];
    int score = 0;

    // Typosquatting
    final brands = ['google', 'facebook', 'amazon', 'apple', 'microsoft', 'paypal', 'netflix'];
    for (final brand in brands) {
      if (domain.contains(brand) && !domain.endsWith('$brand.com')) {
        warnings.add('Possible typosquatting of $brand');
        score += 40;
      }
    }

    // Suspicious TLDs
    final suspiciousTlds = ['.xyz', '.top', '.club', '.buzz', '.click', '.tk', '.ml'];
    if (suspiciousTlds.any((tld) => domain.endsWith(tld))) {
      warnings.add('Suspicious top-level domain');
      score += 25;
    }

    String riskLevel = 'LOW';
    if (score >= 70) {
      riskLevel = 'HIGH';
    } else if (score >= 40) {
      riskLevel = 'MEDIUM';
    }

    return {
      'url': url,
      'riskLevel': riskLevel,
      'riskScore': score.clamp(0, 100),
      'checks': [
        {'source': 'Local Heuristics (Offline)', 'status': warnings.isNotEmpty ? 'warning' : 'safe', 'warnings': warnings}
      ],
      'offline': true,
    };
  }

  static Map<String, dynamic> _fallbackFileScan(File file) {
    final name = file.path.split(Platform.pathSeparator).last.toLowerCase();
    final ext = name.split('.').last;
    final dangerousExts = ['exe', 'bat', 'cmd', 'scr', 'msi', 'vbs', 'jar', 'apk'];
    final isDangerous = dangerousExts.contains(ext);

    return {
      'filename': name,
      'riskLevel': isDangerous ? 'HIGH' : 'LOW',
      'riskScore': isDangerous ? 80 : 0,
      'checks': [
        {
          'source': 'File Type Analysis (Offline)',
          'status': isDangerous ? 'warning' : 'safe',
          'detail': isDangerous ? 'Potentially dangerous file type: .$ext' : 'File type appears safe',
        }
      ],
      'offline': true,
    };
  }

  static Map<String, dynamic> _fallbackTextScan(String text) {
    final patterns = [
      {'regex': RegExp(r'urgent|immediately|act now', caseSensitive: false), 'label': 'Urgency Tactics', 'score': 30},
      {'regex': RegExp(r'verify your|confirm your', caseSensitive: false), 'label': 'Credential Phishing', 'score': 40},
      {'regex': RegExp(r'won|winner|congratulations|prize', caseSensitive: false), 'label': 'Fake Reward Scam', 'score': 35},
      {'regex': RegExp(r'password|ssn|credit card', caseSensitive: false), 'label': 'Sensitive Data Request', 'score': 50},
    ];

    final findings = <Map<String, dynamic>>[];
    int totalScore = 0;

    for (final p in patterns) {
      if ((p['regex'] as RegExp).hasMatch(text)) {
        findings.add({'pattern': p['label'], 'score': p['score']});
        totalScore += p['score'] as int;
      }
    }

    String riskLevel = 'LOW';
    if (totalScore >= 70) {
      riskLevel = 'HIGH';
    } else if (totalScore >= 40) {
      riskLevel = 'MEDIUM';
    }

    return {
      'riskLevel': riskLevel,
      'riskScore': totalScore.clamp(0, 100),
      'findings': findings,
      'offline': true,
    };
  }
}
