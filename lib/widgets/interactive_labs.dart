import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

// ─── Password Strength Lab ─────────────────────────────────────

class PasswordStrengthLab extends StatefulWidget {
  const PasswordStrengthLab({super.key});

  @override
  State<PasswordStrengthLab> createState() => _PasswordStrengthLabState();
}

class _PasswordStrengthLabState extends State<PasswordStrengthLab> {
  final TextEditingController _controller = TextEditingController();
  double _strength = 0.0;
  String _feedback = 'Waiting for input...';
  Color _color = Colors.grey;

  void _checkStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _strength = 0.0;
        _feedback = 'Waiting for input...';
        _color = Colors.grey;
      });
      return;
    }

    double score = 0;
    if (password.length > 8) score += 0.25;
    if (password.length > 12) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.15;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score += 0.20;

    setState(() {
      _strength = score.clamp(0.0, 1.0);
      if (_strength < 0.3) {
        _feedback = 'Weak (Easily guessed)';
        _color = AppTheme.riskHigh;
      } else if (_strength < 0.7) {
        _feedback = 'Moderate (Add symbols/numbers)';
        _color = AppTheme.accent;
      } else {
        _feedback = 'Strong! (Like a fortress)';
        _color = AppTheme.safe;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _controller,
            onChanged: _checkStrength,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Type a test password...',
              hintStyle: const TextStyle(color: AppTheme.textMuted),
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _strength,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(_color),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _feedback,
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }
}

// ─── Scam Swiper Lab ───────────────────────────────────────────

class ScamSwiperLab extends StatefulWidget {
  const ScamSwiperLab({super.key});

  @override
  State<ScamSwiperLab> createState() => _ScamSwiperLabState();
}

class _ScamSwiperLabState extends State<ScamSwiperLab> {
  bool _swiped = false;
  bool _isCorrect = false;

  void _handleSwipe(bool isSafe) {
    setState(() {
      _swiped = true;
      _isCorrect = !isSafe; // Assuming the example shown is always the scam one for this lab
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_swiped) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isCorrect ? Icons.check_circle : Icons.error,
              color: _isCorrect ? AppTheme.safe : AppTheme.riskHigh,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _isCorrect ? 'Correct! It was a scam.' : 'Oops! That was a scam.',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isCorrect ? AppTheme.safe : AppTheme.riskHigh,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Never trust links from unknown senders asking for money or urgent action.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() { _swiped = false; _isCorrect = false; }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Dismissible(
            key: const Key('scam_msg'),
            onDismissed: (direction) {
               _handleSwipe(direction == DismissDirection.endToStart);
            },
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(color: AppTheme.riskHigh.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.thumb_down, color: AppTheme.riskHigh, size: 32),
            ),
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(color: AppTheme.safe.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.thumb_up, color: AppTheme.safe, size: 32),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.message, color: AppTheme.textMuted, size: 16),
                      SizedBox(width: 8),
                      Text('Message from Unknown', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'POSTAL SERVICE: We could not deliver your package today due to unpaid fees. Click here to pay \$2.99: http://usps-update-track.info/pay',
                    style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(Icons.keyboard_arrow_left, color: AppTheme.riskHigh), Text(' Scam', style: TextStyle(color: AppTheme.riskHigh))]),
              Row(children: [Text('Safe ', style: TextStyle(color: AppTheme.safe)), Icon(Icons.keyboard_arrow_right, color: AppTheme.safe)]),
            ],
          )
        ],
      ),
    );
  }
}
