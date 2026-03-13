import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

import 'package:provider/provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/score_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/tests_provider.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

/// Document Verify Screen — Upload or capture files for real threat analysis.
class DocumentVerifyScreen extends StatefulWidget {
  const DocumentVerifyScreen({super.key});

  @override
  State<DocumentVerifyScreen> createState() => _DocumentVerifyScreenState();
}

class _DocumentVerifyScreenState extends State<DocumentVerifyScreen> with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  bool _scanComplete = false;
  Map<String, dynamic>? _rawResult;
  bool _isBackendConnected = false;

  // File data
  String? _selectedFileName;
  String? _selectedFilePath;
  int? _selectedFileSize;
  bool _isImage = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_pulseController);
    _checkBackendStatus();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkBackendStatus() async {
    final connected = await ApiService.checkHealth();
    if (mounted) setState(() => _isBackendConnected = connected);
  }

  // ─── Camera Capture ─────────────────────────────────────────
  Future<void> _captureFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        final file = File(photo.path);
        final size = await file.length();
        setState(() {
          _selectedFileName = photo.name;
          _selectedFilePath = photo.path;
          _selectedFileSize = size;
          _isImage = true;
          _scanComplete = false;
          _rawResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  // ─── File Picker ────────────────────────────────────────────
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty && mounted) {
        final file = result.files.first;
        final ext = file.extension?.toLowerCase() ?? '';
        setState(() {
          _selectedFileName = file.name;
          _selectedFilePath = file.path;
          _selectedFileSize = file.size;
          _isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
          _scanComplete = false;
          _rawResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File picker error: $e')),
        );
      }
    }
  }

  // ─── Real Scan ──────────────────────────────────────────────
  Future<void> _startScan() async {
    if (_isScanning || _selectedFilePath == null) return;

    setState(() {
      _isScanning = true;
      _scanComplete = false;
      _rawResult = null;
    });

    try {
      final result = await ApiService.scanFile(File(_selectedFilePath!));
      if (!mounted) return;

      _rawResult = result;

      // Award XP
      final gp = context.read<GamificationProvider>();
      gp.addXp(GamificationProvider.xpTestPassed);
      gp.updateAchievementProgress('safe_browser', 1);
      context.read<ScoreProvider>().recalculate(context.read<AlertProvider>().alerts, gp, context.read<TestsProvider>());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('+20 XP: Document Scanned!')),
      );
    } catch (e) {
      if (!mounted) return;
      _rawResult = {
        'riskLevel': 'ERROR',
        'riskScore': 0,
        'checks': [
          {'source': 'Error', 'status': 'error', 'detail': 'Scan failed: $e'}
        ],
        'offline': true,
      };
    }

    if (mounted) {
      setState(() {
        _isScanning = false;
        _scanComplete = true;
      });
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Backend status
                    _buildBackendStatus(),
                    const SizedBox(height: 20),

                    Text(
                      'Document Verify',
                      style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload or capture any file to scan for malware and phishing threats using real threat databases.',
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(child: _buildActionButton(Icons.camera_alt_outlined, 'Take Photo', false, _captureFromCamera)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildActionButton(Icons.upload_file, 'Upload File', true, _pickFile)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // File Preview
                    if (_selectedFileName != null) ...[
                      _buildFilePreview(),
                      const SizedBox(height: 16),

                      if (!_isScanning && !_scanComplete)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _startScan,
                            icon: const Icon(Icons.security),
                            label: Text('Scan for Threats', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                    ],

                    if (_isScanning) _buildScanningIndicator(),
                    if (_scanComplete && _rawResult != null) _buildRealScanResult(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              Text('Document Verify', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (_isBackendConnected ? AppTheme.safe : AppTheme.accent).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: _isBackendConnected ? AppTheme.safe : AppTheme.accent, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(_isBackendConnected ? 'Online' : 'Offline', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _isBackendConnected ? AppTheme.safe : AppTheme.accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackendStatus() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (_isBackendConnected ? AppTheme.safe : AppTheme.accent).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (_isBackendConnected ? AppTheme.safe : AppTheme.accent).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(_isBackendConnected ? Icons.cloud_done : Icons.cloud_off, color: _isBackendConnected ? AppTheme.safe : AppTheme.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isBackendConnected
                  ? 'Connected — File hash check, URLhaus, file type analysis active'
                  : 'Offline mode — using built-in file type analysis',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
            ),
          ),
          if (!_isBackendConnected)
            IconButton(icon: const Icon(Icons.refresh, color: AppTheme.accent, size: 18), onPressed: _checkBackendStatus, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: _isImage && _selectedFilePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(_selectedFilePath!), fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.image, color: AppTheme.primary, size: 28)),
                  )
                : Icon(_getFileIcon(_selectedFileName ?? ''), color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedFileName ?? 'Unknown', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(_formatSize(_selectedFileSize ?? 0), style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 20),
            onPressed: () => setState(() {
              _selectedFileName = null;
              _selectedFilePath = null;
              _selectedFileSize = null;
              _scanComplete = false;
              _rawResult = null;
            }),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': case 'docx': return Icons.description;
      case 'xls': case 'xlsx': return Icons.table_chart;
      case 'zip': case 'rar': return Icons.folder_zip;
      case 'apk': return Icons.android;
      default: return Icons.insert_drive_file;
    }
  }

  Widget _buildActionButton(IconData icon, String label, bool isPrimary, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primary : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPrimary ? AppTheme.primary : Colors.white.withValues(alpha: 0.1)),
          boxShadow: isPrimary ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: isPrimary ? Colors.white : AppTheme.primary),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isPrimary ? Colors.white : AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.document_scanner, size: 40, color: AppTheme.accent),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppTheme.accent),
            const SizedBox(height: 16),
            Text('Uploading & analyzing "$_selectedFileName"...', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              _isBackendConnected
                  ? 'Computing SHA-256 hash → checking URLhaus database → file type analysis'
                  : 'Running local file type analysis...',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // REAL SCAN RESULT — Shows every engine's result separately
  // ═══════════════════════════════════════════════════════════
  Widget _buildRealScanResult() {
    final riskLevel = _rawResult!['riskLevel'] as String? ?? 'LOW';
    final riskScore = (_rawResult!['riskScore'] as num?)?.toInt() ?? 0;
    final checks = (_rawResult!['checks'] as List<dynamic>?) ?? [];
    final sha256 = _rawResult!['sha256'] as String?;
    final mimetype = _rawResult!['mimetype'] as String?;
    final isOffline = _rawResult!['offline'] == true;
    final isDanger = riskLevel == 'HIGH' || riskLevel == 'MEDIUM';
    final color = riskLevel == 'HIGH' ? AppTheme.riskHigh : riskLevel == 'MEDIUM' ? AppTheme.accent : AppTheme.safe;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Result Header ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                      child: Icon(isDanger ? Icons.gpp_bad : Icons.verified_user, color: color, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isDanger ? 'Threats Detected' : 'File Appears Safe', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                          const SizedBox(height: 4),
                          Text('Risk Score: $riskScore/100', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.8))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: riskScore / 100.0, backgroundColor: Colors.white.withValues(alpha: 0.1), valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 6),
                ),
                if (isOffline) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off, size: 12, color: AppTheme.accent),
                        SizedBox(width: 6),
                        Text('Scanned in offline mode', style: TextStyle(fontSize: 11, color: AppTheme.accent)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── File Details ──
          if (sha256 != null || mimetype != null) ...[
            Text('File Details', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (sha256 != null)
                    _detailRow('SHA-256', sha256),
                  if (mimetype != null)
                    _detailRow('MIME Type', mimetype),
                  _detailRow('Size', _formatSize(_selectedFileSize ?? 0)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Scan Sources — each engine shown separately ──
          if (checks.isNotEmpty) ...[
            Text('Scan Sources', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            for (final check in checks)
              _buildCheckCard(check as Map<String, dynamic>),
          ],

          const SizedBox(height: 20),

          // ── Scan Again ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() {
                _selectedFileName = null;
                _selectedFilePath = null;
                _selectedFileSize = null;
                _scanComplete = false;
                _rawResult = null;
              }),
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Another File'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontFamily: 'monospace'), maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckCard(Map<String, dynamic> check) {
    final source = check['source'] as String? ?? 'Unknown';
    final status = check['status'] as String? ?? 'unknown';
    final detail = check['detail'] as String? ?? '';

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'safe':
        statusColor = AppTheme.safe;
        statusIcon = Icons.check_circle;
        break;
      case 'warning':
      case 'suspicious':
        statusColor = AppTheme.accent;
        statusIcon = Icons.warning_amber;
        break;
      case 'dangerous':
        statusColor = AppTheme.riskHigh;
        statusIcon = Icons.dangerous;
        break;
      default:
        statusColor = AppTheme.textMuted;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(source, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: statusColor)),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(detail, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
