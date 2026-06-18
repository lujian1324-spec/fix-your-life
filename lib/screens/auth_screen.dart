import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/sierro_widgets.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static const routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _step = 0;
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _name = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _LoginStep(email: _email, onNext: () => setState(() => _step = 1)),
      _OtpStep(
        email: _email,
        code: _code,
        onNext: () => setState(() => _step = 2),
      ),
      _NameStep(
        name: _name,
        onNext: () =>
            Navigator.pushReplacementNamed(context, MainShell.routeName),
      ),
    ];
    return SierroPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 22),
          if (_step > 0) BackCircleButton() else const SizedBox(height: 42),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: pages[_step],
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _LoginStep extends StatelessWidget {
  const _LoginStep({required this.email, required this.onNext});

  final TextEditingController email;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sign up & Log in',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enter your email to continue with Sierro.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'name@example.com',
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onNext, child: const Text('Continue')),
      ],
    );
  }
}

class _OtpStep extends StatelessWidget {
  const _OtpStep({
    required this.email,
    required this.code,
    required this.onNext,
  });

  final TextEditingController email;
  final TextEditingController code;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Code',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          'We sent a verification code to ${email.text.isEmpty ? 'your email' : email.text}.',
          style: const TextStyle(color: AppColors.textMuted, height: 1.35),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: code,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'Verification Code',
            counterText: '',
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onNext, child: const Text('Verify')),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.name, required this.onNext});

  final TextEditingController name;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('name'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What should we call you?',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        const Text(
          'This name appears in your Sierro account.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onNext, child: const Text('Get Started')),
      ],
    );
  }
}
