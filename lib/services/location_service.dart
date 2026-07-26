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
}
