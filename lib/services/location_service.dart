import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Kullanıcının güncel konumunu döner. İzin yoksa ister,
  /// izin verilmezse anlamlı bir hata fırlatır.
  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Konum servisleri kapalı. Lütfen telefonunuzun konum ayarını açın.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni verilmedi.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Konum izni kalıcı olarak reddedilmiş. Telefon ayarlarından '
        'uygulamaya konum izni vermeniz gerekiyor.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }
}
