class SierroEnvironment {
  const SierroEnvironment._();

  static const baseUrl = String.fromEnvironment(
    'SIERRO_BASE_URL',
    defaultValue: 'https://solar.siseli.com/openapis',
  );

  static const appId = String.fromEnvironment(
    'SIERRO_APP_ID',
    defaultValue: 'rYGQpmYU5k',
  );

  static const appSecret = String.fromEnvironment(
    'SIERRO_APP_SECRET',
    defaultValue: '',
  );

  static const demoDtuId = String.fromEnvironment(
    'SIERRO_DEMO_DTU_ID',
    defaultValue: '30340387838800344455',
  );

  static const demoSerialNumber = String.fromEnvironment(
    'SIERRO_DEMO_SERIAL_NUMBER',
    defaultValue: '2412315001',
  );

  static const testAccount = String.fromEnvironment(
    'SIERRO_TEST_ACCOUNT',
    defaultValue: '',
  );

  static const testPassword = String.fromEnvironment(
    'SIERRO_TEST_PASSWORD',
    defaultValue: '',
  );

  static bool get hasOpenApiSecret => appSecret.trim().isNotEmpty;

  static bool get canAutoSync =>
      hasOpenApiSecret &&
      testAccount.trim().isNotEmpty &&
      testPassword.trim().isNotEmpty;
}
