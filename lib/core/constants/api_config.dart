/// Backend base URL. Use 10.0.2.2 for Android emulator, localhost for iOS simulator, your PC IP for real device.
// const String kApiBaseUrl = 'http://10.0.2.2:5000';
const String kApiBaseUrl = 'http://192.168.1.15:5000';
String authUrl(String path) => '$kApiBaseUrl/api/auth$path';
