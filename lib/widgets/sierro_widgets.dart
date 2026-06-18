import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SierroPage extends StatelessWidget {
  const SierroPage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 22),
    this.bottom,
  });

  final Widget child;
  final EdgeInsets padding;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    Widget buildPhoneShell() {
      return SafeArea(
        top: !kIsWeb,
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  if (kIsWeb) const MockStatusBar(),
                  Expanded(
                    child: Padding(padding: padding, child: child),
                  ),
                ],
              ),
            ),
            if (bottom != null)
              Positioned(left: 0, right: 0, bottom: 0, child: bottom!),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final shell = buildPhoneShell();
          if (constraints.maxWidth <= 500) {
            return Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: math.min(constraints.maxWidth, 430),
                height: constraints.maxHeight,
                child: shell,
              ),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: shell,
            ),
          );
        },
      ),
    );
  }
}

class MockStatusBar extends StatelessWidget {
  const MockStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppColors.header,
      padding: const EdgeInsets.fromLTRB(34, 8, 31, 0),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          Spacer(),
          Icon(Icons.signal_cellular_alt_rounded, size: 22),
          SizedBox(width: 4),
          Icon(Icons.wifi_rounded, size: 22),
          SizedBox(width: 5),
          _BatteryStatusIcon(),
        ],
      ),
    );
  }
}

class _BatteryStatusIcon extends StatelessWidget {
  const _BatteryStatusIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 14,
      child: CustomPaint(painter: _BatteryStatusPainter()),
    );
  }
}

class _BatteryStatusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final fill = Paint()..color = Colors.white;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 1, size.width - 4, size.height - 2),
      const Radius.circular(4),
    );
    canvas.drawRRect(body, outline);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 4, size.width - 10, size.height - 8),
        const Radius.circular(2),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 3, 5, 3, size.height - 10),
        const Radius.circular(2),
      ),
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SierroHeader extends StatelessWidget {
  const SierroHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.centerTitle = false,
    this.onTitleTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final bool centerTitle;
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    final titleSize = centerTitle ? 25.0 : 30.0;
    final titleBlock = GestureDetector(
      onTap: onTitleTap,
      child: Column(
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: titleSize,
              height: 1.02,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.1,
              ),
            ),
          ],
        ],
      ),
    );

    return SizedBox(
      height: subtitle == null ? 72 : 86,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Align(
              alignment: centerTitle ? Alignment.center : Alignment.centerLeft,
              child: titleBlock,
            ),
          ),
          ...actions.map(
            (action) =>
                Padding(padding: const EdgeInsets.only(left: 8), child: action),
          ),
        ],
      ),
    );
  }
}

class DataSourceBadge extends StatelessWidget {
  const DataSourceBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDemo = label.contains('DEMO');
    final color = isDemo ? AppColors.warning : AppColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            color: isDemo ? AppColors.warning : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
    this.background = AppColors.surfaceHigh,
    this.foreground = AppColors.text,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color background;
  final Color foreground;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: size * .52, color: foreground),
              if (badge)
                Positioned(
                  right: size * .18,
                  top: size * .18,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackCircleButton extends StatelessWidget {
  const BackCircleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleIconButton(
      icon: Icons.chevron_left_rounded,
      onTap: () => Navigator.maybePop(context),
    );
  }
}

class SierroCard extends StatelessWidget {
  const SierroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.color = AppColors.surface,
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.compact = false,
  });

  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: compact ? 12 : 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class SierroBottomNav extends StatelessWidget {
  const SierroBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.home_outlined, Icons.home_rounded, 'Device'),
      (Icons.show_chart_rounded, Icons.insights_rounded, 'Insights'),
      (Icons.settings_outlined, Icons.settings_rounded, 'Setting'),
    ];

    return SafeArea(
      minimum: EdgeInsets.only(bottom: kIsWeb ? 10 : 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 186,
              height: 60,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFF00695F),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: .82),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .26),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < items.length; i++)
                    _BottomNavItem(
                      icon: selectedIndex == i ? items[i].$2 : items[i].$1,
                      label: items[i].$3,
                      selected: selectedIndex == i,
                      onTap: () => onChanged(i),
                    ),
                ],
              ),
            ),
          ),
          if (kIsWeb) ...[const SizedBox(height: 18), const HomeIndicator()],
        ],
      ),
    );
  }
}

class HomeIndicator extends StatelessWidget {
  const HomeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: .24)
            : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              size: 24,
              color: selected
                  ? AppColors.text
                  : AppColors.primary.withValues(alpha: .58),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onButtonPressed,
    this.imageAsset,
  });

  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageAsset == null)
            Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                color: AppColors.surfaceLift,
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            Image.asset(imageAsset!, width: 150, height: 150),
          const SizedBox(height: 28),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 260,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
          if (buttonLabel != null) ...[
            const SizedBox(height: 28),
            SizedBox(
              width: 134,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(buttonLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BatteryRing extends StatelessWidget {
  const BatteryRing({
    super.key,
    required this.percent,
    required this.subtitle,
    this.size = 170,
  });

  final int percent;
  final String subtitle;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: BatteryRingPainter(percent / 100),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  text: '$percent',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    height: .95,
                  ),
                  children: const [
                    TextSpan(
                      text: '%',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BatteryRingPainter extends CustomPainter {
  BatteryRingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * .075;
    final trackPaint = Paint()
      ..color = AppColors.surfaceLift
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [AppColors.primary, Color(0xFF58E4D4), AppColors.primary],
        stops: [0, .55, 1],
      ).createShader(rect)
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final inset = stroke / 2;
    final oval = Rect.fromLTWH(
      inset,
      inset,
      size.width - stroke,
      size.height - stroke,
    );
    canvas.drawArc(oval, -math.pi * .92, math.pi * 1.85, false, trackPaint);
    canvas.drawArc(
      oval,
      -math.pi * .92,
      math.pi * 1.85 * progress.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BatteryRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class PowerChip extends StatelessWidget {
  const PowerChip({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    this.width,
  });

  final String value;
  final String unit;
  final String label;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 66,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
        color: AppColors.surface.withValues(alpha: .2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
                fontSize: 21,
              ),
              children: [
                TextSpan(
                  text: unit,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class LineChart extends StatelessWidget {
  const LineChart({
    super.key,
    this.height = 206,
    this.points = const [
      .72,
      .55,
      .22,
      .18,
      .35,
      .48,
      .58,
      .73,
      .84,
      .82,
      .92,
      .88,
    ],
  });

  final double height;
  final List<double> points;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: LineChartPainter(points)),
    );
  }
}

class LineChartPainter extends CustomPainter {
  LineChartPainter(this.points);

  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: .45)
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = 10 + i * (size.height - 42) / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    final fill = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i * size.width / (points.length - 1);
      final y = 10 + (1 - points[i].clamp(.05, .98)) * (size.height - 52);
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, y);
      } else {
        final prevX = (i - 1) * size.width / (points.length - 1);
        final prevY =
            10 + (1 - points[i - 1].clamp(.05, .98)) * (size.height - 52);
        final midX = (prevX + x) / 2;
        path.cubicTo(midX, prevY, midX, y, x, y);
        fill.cubicTo(midX, prevY, midX, y, x, y);
      }
    }
    fill
      ..lineTo(size.width, size.height - 34)
      ..lineTo(0, size.height - 34)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: .35),
            Colors.white.withValues(alpha: .04),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    const labels = ['2am', '4am', '6am', '8am', '10am', '12pm', '2pm'];
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

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) =>
      oldDelegate.points != points;
}

class ScheduleDial extends StatelessWidget {
  const ScheduleDial({super.key, this.size = 260});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: ScheduleDialPainter()),
    );
  }
}

class ScheduleDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .38;
    final stroke = size.width * .17;

    final ring = Paint()
      ..color = Colors.black.withValues(alpha: .45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, ring);

    final peakPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFC86A), AppColors.warning],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final offPeakPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFBFFDF5), AppColors.primary],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, math.pi * .78, math.pi * .68, false, peakPaint);
    canvas.drawArc(rect, -math.pi * .42, math.pi * .78, false, offPeakPaint);

    final tickPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2;
    for (var i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / 12;
      final p1 =
          center +
          Offset(math.cos(angle), math.sin(angle)) * (radius - stroke * .7);
      final p2 =
          center +
          Offset(math.cos(angle), math.sin(angle)) * (radius - stroke * .54);
      canvas.drawLine(p1, p2, tickPaint);
    }

    void text(String label, Offset offset, double fontSize) {
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        offset - Offset(painter.width / 2, painter.height / 2),
      );
    }

    void moon(Offset offset) {
      final moonPaint = Paint()..color = Colors.white;
      final cutoutPaint = Paint()..color = AppColors.surface;
      canvas.drawCircle(offset, 13, moonPaint);
      canvas.drawCircle(offset + const Offset(7, -3), 13, cutoutPaint);
    }

    void sun(Offset offset) {
      final fill = Paint()..color = const Color(0xFFFFE36E);
      final ray = Paint()
        ..color = const Color(0xFFFFE36E)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(offset, 8, fill);
      for (var i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        final start = offset + Offset(math.cos(angle), math.sin(angle)) * 14;
        final end = offset + Offset(math.cos(angle), math.sin(angle)) * 20;
        canvas.drawLine(start, end, ray);
      }
    }

    text('12am', center + const Offset(0, -70), 18);
    text('6am', center + const Offset(70, 0), 18);
    text('12pm', center + const Offset(0, 72), 18);
    text('6pm', center + const Offset(-76, 0), 18);
    moon(center + const Offset(0, -36));
    sun(center + const Offset(0, 34));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 13),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLift,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.textMuted, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 26,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
