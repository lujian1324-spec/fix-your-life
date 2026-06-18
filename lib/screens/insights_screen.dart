import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/sierro_widgets.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  var _range = 0;
  var _offset = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = ['Day', 'Week', 'Month', 'Range'];
    final state = AppStateScope.of(context);
    return SierroPage(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 106),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SierroHeader(
            title: 'Insights',
            actions: [
              CircleIconButton(
                icon: Icons.ios_share_rounded,
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: AppColors.surface,
                  builder: (_) => const _ShareSheet(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SegmentedTabs(
            tabs: tabs,
            selected: _range,
            onChanged: (value) => setState(() {
              _range = value;
              _offset = 0;
            }),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: state.devices.isEmpty
                ? const EmptyState(
                    title: 'No data available',
                    message:
                        'Connect a Sierro device to start tracking battery performance and power usage.',
                  )
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const _DaysCard(),
                      const SizedBox(height: 14),
                      _DateSwitcher(
                        title: _periodTitle(tabs[_range]),
                        canForward: _offset < 0,
                        onBack: () => setState(() => _offset--),
                        onForward: _offset < 0
                            ? () => setState(() => _offset++)
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _Co2Card(range: tabs[_range]),
                      const SizedBox(height: 14),
                      _InputOutputCard(range: tabs[_range]),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _periodTitle(String range) {
    if (range == 'Day') {
      return _offset == 0 ? 'May 27, 2026' : 'May ${27 + _offset}, 2026';
    }
    if (range == 'Week') {
      return _offset == 0
          ? 'May 24 - 30, 2026'
          : 'May ${24 + _offset * 7} - ${30 + _offset * 7}, 2026';
    }
    if (range == 'Month') {
      return _offset == 0 ? 'May 2026' : 'April 2026';
    }
    return 'Mar 1, 2026 - May 31, 2026';
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });

  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLift,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: selected == i ? Colors.black : AppColors.text,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DaysCard extends StatelessWidget {
  const _DaysCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt_rounded, color: AppColors.primary, size: 50),
            SizedBox(width: 8),
            Text(
              '128',
              style: TextStyle(
                fontSize: 66,
                height: .95,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Days',
              style: TextStyle(fontSize: 21, color: AppColors.textMuted),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          'Reliable backup power since Jan 2026',
          style: TextStyle(color: AppColors.textDim, fontSize: 16),
        ),
      ],
    );
  }
}

class _DateSwitcher extends StatelessWidget {
  const _DateSwitcher({
    required this.title,
    required this.canForward,
    required this.onBack,
    required this.onForward,
  });

  final String title;
  final bool canForward;
  final VoidCallback onBack;
  final VoidCallback? onForward;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleIconButton(icon: Icons.chevron_left_rounded, onTap: onBack),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
        ),
        CircleIconButton(
          icon: Icons.chevron_right_rounded,
          onTap: onForward,
          foreground: canForward ? AppColors.text : AppColors.textDim,
          background: canForward ? AppColors.surfaceHigh : AppColors.surface,
        ),
      ],
    );
  }
}

class _Co2Card extends StatelessWidget {
  const _Co2Card({required this.range});

  final String range;

  @override
  Widget build(BuildContext context) {
    final value = switch (range) {
      'Day' => '6.4',
      'Week' => '32.8',
      'Month' => '126',
      _ => '344',
    };
    return SierroCard(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 58,
              height: .9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'kg',
              style: TextStyle(color: AppColors.textMuted, fontSize: 18),
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'CO₂ Reduced',
              style: TextStyle(color: AppColors.textMuted, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputOutputCard extends StatelessWidget {
  const _InputOutputCard({required this.range});

  final String range;

  @override
  Widget build(BuildContext context) {
    return SierroCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Input vs. Output',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
              _Legend(color: AppColors.primary, label: 'Input'),
              SizedBox(width: 14),
              _Legend(color: AppColors.warning, label: 'Output'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            range == 'Week'
                ? 'Highest output on Friday'
                : 'Output peaked at 2pm',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 230,
            child: CustomPaint(painter: _InsightChartPainter(range)),
          ),
          const SizedBox(height: 6),
          DataSourceBadge(label: 'DEMO MODE'),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textMuted)),
      ],
    );
  }
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Share Insights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _ShareAction(
                    icon: Icons.image_outlined,
                    label: 'Image',
                    onTap: () => _share(context, 'Insight image generated'),
                  ),
                ),
                Expanded(
                  child: _ShareAction(
                    icon: Icons.insert_drive_file_outlined,
                    label: 'Report',
                    onTap: () => _share(context, 'Report ready to share'),
                  ),
                ),
                Expanded(
                  child: _ShareAction(
                    icon: Icons.link_rounded,
                    label: 'Link',
                    onTap: () => _share(context, 'Share link copied'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _share(BuildContext context, String message) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _ShareAction extends StatelessWidget {
  const _ShareAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleIconButton(icon: icon, background: AppColors.surfaceLift),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _InsightChartPainter extends CustomPainter {
  _InsightChartPainter(this.range);

  final String range;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.border.withValues(alpha: .5)
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = 12 + i * (size.height - 48) / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (range == 'Week') {
      _drawBars(canvas, size);
    } else {
      _drawLines(canvas, size);
    }
    final labels = range == 'Week'
        ? ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        : ['12am', '4am', '8am', '12pm', '4pm', '8pm', '12am'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < labels.length; i++) {
      final x = i * size.width / (labels.length - 1);
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (x - textPainter.width / 2).clamp(0, size.width - textPainter.width),
          size.height - 20,
        ),
      );
    }
  }

  void _drawLines(Canvas canvas, Size size) {
    const output = [.58, .64, .60, .61, .56, .52, .82, .58];
    const input = [.45, .58, .49, .52, .50, .46, .52, .50];
    _drawSmoothPath(canvas, size, output, AppColors.warning, true);
    _drawSmoothPath(canvas, size, input, AppColors.primary, false);
  }

  void _drawSmoothPath(
    Canvas canvas,
    Size size,
    List<double> points,
    Color color,
    bool fill,
  ) {
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i * size.width / (points.length - 1);
      final y = 15 + (1 - points[i]) * (size.height - 58);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * size.width / (points.length - 1);
        final prevY = 15 + (1 - points[i - 1]) * (size.height - 58);
        final midX = (prevX + x) / 2;
        path.cubicTo(midX, prevY, midX, y, x, y);
      }
    }
    if (fill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height - 32)
        ..lineTo(0, size.height - 32)
        ..close();
      canvas.drawPath(fillPath, Paint()..color = color.withValues(alpha: .25));
    }
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, line);
  }

  void _drawBars(Canvas canvas, Size size) {
    const input = [.45, .70, .52, .66, .58, .74, .50];
    const output = [.38, .55, .48, .62, .46, .88, .44];
    final bar = size.width / 24;
    for (var i = 0; i < input.length; i++) {
      final x = i * size.width / input.length + bar;
      final bottom = size.height - 32;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, bottom - input[i] * 150, bar, input[i] * 150),
          const Radius.circular(8),
        ),
        Paint()..color = AppColors.primary,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x + bar + 4,
            bottom - output[i] * 150,
            bar,
            output[i] * 150,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = AppColors.warning,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InsightChartPainter oldDelegate) =>
      oldDelegate.range != range;
}
