/// Backend base URL. Use 10.0.2.2 for Android emulator, localhost for iOS simulator, your PC IP for real device.
// const String kApiBaseUrl = 'http://10.0.2.2:5000';
const String kApiBaseUrl = 'http://192.168.1.15:5000';
String authUrl(String path) => '$kApiBaseUrl/api/auth$path';
String listingsUrl(String path) => '$kApiBaseUrl/api/listings$path';
String favoritesUrl(String path) => '$kApiBaseUrl/api/favorites$path';
String uploadsUrl(String path) => '$kApiBaseUrl/uploads$path';

/// Google Maps/Places API key (for Place Autocomplete & Place Details in map picker).
const String kGoogleMapsApiKey = 'AIzaSyBpGKLtD0L4QvFfWSUqlcmtys7GhVolRiI';
