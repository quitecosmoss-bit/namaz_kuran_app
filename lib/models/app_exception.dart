enum AppErrorCode {
  locationServiceDisabled,
  locationPermissionDenied,
  locationPermissionDeniedForever,
  network,
  unknown,
}

/// Servislerin fırlattığı, ekranların dile göre çevirip gösterdiği hata tipi.
class AppException implements Exception {
  final AppErrorCode code;
  AppException(this.code);
}
