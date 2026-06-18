import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/sierro_widgets.dart';

class SmartScheduleScreen extends StatefulWidget {
  const SmartScheduleScreen({super.key});

  static const routeName = '/smart-schedule';

  @override
  State<SmartScheduleScreen> createState() => _SmartScheduleScreenState();
}

class _SmartScheduleScreenState extends State<SmartScheduleScreen> {
  late SmartScheduleSettings _draft;
  late final TextEditingController _peak;
  late final TextEditingController _offPeak;
  late final TextEditingController _charge;
  late final TextEditingController _discharge;

  @override
  void initState() {
    super.initState();
    final scope =
        context.getElementForInheritedWidgetOfExactType<AppStateScope>()!.widget
            as AppStateScope;
    _draft = scope.notifier!.schedule;
    _peak = TextEditingController(text: _draft.peakPrice.toStringAsFixed(2));
    _offPeak = TextEditingController(
      text: _draft.offPeakPrice.toStringAsFixed(2),
    );
    _charge = TextEditingController(text: '${_draft.maxChargePowerW}');
    _discharge = TextEditingController(text: '${_draft.maxDischargePowerW}');
  }

  @override
  void dispose() {
    _peak.dispose();
    _offPeak.dispose();
    _charge.dispose();
    _discharge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SierroPage(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: 118,
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: SierroHeader(
              title: 'Smart Schedule',
              leading: const BackCircleButton(),
              centerTitle: true,
              actions: [
                CircleIconButton(
                  icon: Icons.info_outline_rounded,
                  onTap: _showInfo,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 34),
              physics: const BouncingScrollPhysics(),
              children: [
                SierroCard(
                  radius: 18,
                  padding: const EdgeInsets.fromLTRB(18, 24, 20, 24),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Smart Schedule',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Switch(
                        value: _draft.enabled,
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(enabled: value),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_draft.enabled) ...[
                  const SizedBox(height: 14),
                  SierroCard(
                    radius: 18,
                    padding: const EdgeInsets.fromLTRB(14, 26, 14, 18),
                    child: Column(
                      children: [
                        const ScheduleDial(size: 278),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Expanded(
                              child: _ScheduleInfo(
                                type: 'Peak',
                                time: _range(
                                  _draft.peakStartHour,
                                  _draft.peakEndHour,
                                ),
                                text:
                                    'Sierro discharging, powering your connected devices with stored energy.',
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ScheduleInfo(
                                type: 'Off-Peak',
                                time: _range(
                                  _draft.offPeakStartHour,
                                  _draft.offPeakEndHour,
                                ),
                                text:
                                    'Sierro charging, storing cheap grid electricity overnight.',
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SectionTitle('Schedule'),
                  Row(
                    children: [
                      Expanded(
                        child: _HourField(
                          label: 'Peak Start',
                          value: _draft.peakStartHour,
                          onChanged: (v) => setState(
                            () => _draft = _draft.copyWith(peakStartHour: v),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HourField(
                          label: 'Peak End',
                          value: _draft.peakEndHour,
                          onChanged: (v) => setState(
                            () => _draft = _draft.copyWith(peakEndHour: v),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _HourField(
                          label: 'Off-Peak Start',
                          value: _draft.offPeakStartHour,
                          onChanged: (v) => setState(
                            () => _draft = _draft.copyWith(offPeakStartHour: v),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HourField(
                          label: 'Off-Peak End',
                          value: _draft.offPeakEndHour,
                          onChanged: (v) => setState(
                            () => _draft = _draft.copyWith(offPeakEndHour: v),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SectionTitle(
                    'Price',
                    trailing: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        onPressed: () => _toast('Part-Peak price slot added'),
                        child: const Text('Add Part-Peak Price'),
                      ),
                    ),
                  ),
                  _PriceEditor(label: 'Peak Price *', controller: _peak),
                  const SizedBox(height: 12),
                  _PriceEditor(label: 'Off-Peak Price *', controller: _offPeak),
                  const SectionTitle('Parameters'),
                  Row(
                    children: [
                      Expanded(
                        child: _NumberEditor(
                          label: 'Max Charge Power',
                          suffix: 'W',
                          controller: _charge,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NumberEditor(
                          label: 'Max Discharge Power',
                          suffix: 'W',
                          controller: _discharge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SierroCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Savings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '\$${_previewSavings().toStringAsFixed(2)} / month',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Based on TOU spread, 95% charge efficiency, 90% usable depth, and 85% execution rate.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final next = _draft.copyWith(
      peakPrice: double.tryParse(_peak.text) ?? _draft.peakPrice,
      offPeakPrice: double.tryParse(_offPeak.text) ?? _draft.offPeakPrice,
      maxChargePowerW: int.tryParse(_charge.text) ?? _draft.maxChargePowerW,
      maxDischargePowerW:
          int.tryParse(_discharge.text) ?? _draft.maxDischargePowerW,
    );
    AppStateScope.of(context).updateSchedule(next);
    _toast('Smart Schedule updated');
    Navigator.pop(context);
  }

  double _previewSavings() {
    final next = _draft.copyWith(
      peakPrice: double.tryParse(_peak.text) ?? _draft.peakPrice,
      offPeakPrice: double.tryParse(_offPeak.text) ?? _draft.offPeakPrice,
    );
    return next.monthlySavings;
  }

  void _showInfo() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18, 18, 18, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How Smart Schedule works',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 12),
              Text(
                'Sierro charges during off-peak hours and discharges during peak hours. Savings are estimated from your TOU rate, battery capacity, efficiency, and execution rate.',
                style: TextStyle(color: AppColors.textMuted, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _range(int start, int end) => '${_hour(start)} - ${_hour(end)}';

  String _hour(int value) {
    final suffix = value >= 12 ? 'PM' : 'AM';
    final hour = value % 12 == 0 ? 12 : value % 12;
    return '$hour $suffix';
  }
}

class _ScheduleInfo extends StatelessWidget {
  const _ScheduleInfo({
    required this.type,
    required this.time,
    required this.text,
    required this.color,
  });

  final String type;
  final String time;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  type,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _HourField extends StatelessWidget {
  const _HourField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SierroCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          DropdownButton<int>(
            value: value,
            dropdownColor: AppColors.surface,
            isExpanded: true,
            items: [
              for (var i = 0; i < 24; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(
                    '${i % 12 == 0 ? 12 : i % 12} ${i >= 12 ? 'PM' : 'AM'}',
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class _PriceEditor extends StatelessWidget {
  const _PriceEditor({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixText: '\$ ',
        suffixText: '/kWh',
      ),
    );
  }
}

class _NumberEditor extends StatelessWidget {
  const _NumberEditor({
    required this.label,
    required this.suffix,
    required this.controller,
  });

  final String label;
  final String suffix;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
    );
  }
}
