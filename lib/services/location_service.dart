import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/app_exception.dart';

class LocationService {
  /// Kullanıcının güncel konumunu döner. İzin yoksa ister,
  /// izin verilmezse AppException fırlatır (ekran, dile göre çevirir).
  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw AppException(AppErrorCode.locationServiceDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw AppException(AppErrorCode.locationPermissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw AppException(AppErrorCode.locationPermissionDeniedForever);
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  /// Koordinatları "İlçe/İl" gibi okunabilir bir yer adına çevirir.
  /// Bu özellik cihazın kendi konum servisine bağlı olduğundan
  /// başarısız olursa null döner (uygulamanın geri kalanını etkilemez).
  Future<String?> getPlaceLabel({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return null;
      final p = placemarks.first;

      final district = (p.subAdministrativeArea?.isNotEmpty ?? false)
          ? p.subAdministrativeArea!
          : (p.locality?.isNotEmpty ?? false)
              ? p.locality!
              : null;
      final province = (p.administrativeArea?.isNotEmpty ?? false)
          ? p.administrativeArea!
          : null;

      if (district != null && province != null && district != province) {
        return '$district/$province';
      }
      return province ?? district;
    } catch (_) {
      return null;
    }
  }
}
