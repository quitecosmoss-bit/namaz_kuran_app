# Namaz Vakitleri & Kuran-ı Kerim Uygulaması

Konuma göre namaz vakitlerini gösteren (Diyanet hesaplama yöntemi) ve
Kuran'ı orijinal Arapça haliyle + seçilen dildeki mealiyle (TR/EN/DE/RU)
okumaya izin veren bir Flutter uygulaması.

## Kullanılan API'ler (ikisi de ücretsiz, API key gerekmez)
- **Namaz vakitleri:** `https://api.aladhan.com/v1/timings` — `method=13`
  parametresi Diyanet İşleri Başkanlığı'nın hesaplama yöntemini kullanır.
- **Kuran metni ve mealler:** `https://api.alquran.cloud/v1` — Arapça için
  `quran-uthmani`, Türkçe meal için `tr.diyanet` edition'ları kullanılıyor.

---

## 1. Ön Gereksinimler (bilgisayarına kur)

1. **Flutter SDK** kur: https://docs.flutter.dev/get-started/install
   Kurulumdan sonra terminalde şunu çalıştır ve her şeyin yeşil (✓)
   olduğundan emin ol:
   ```
   flutter doctor
   ```
2. **Android Studio** kur: https://developer.android.com/studio
   (Android SDK ve bir emülatör/telefon bağlamak için gerekiyor)
3. Gerçek bir Android telefonda test etmek istersen, telefonda
   **Ayarlar > Telefon Hakkında > Yapı Numarası**'na 7 kere dokunup
   Geliştirici Modu'nu aç, sonra **USB Hata Ayıklama**'yı etkinleştir.

## 2. Projeyi Oluşturma

Flutter projesinin Android/iOS klasörlerini senin bilgisayarındaki Flutter
sürümüne göre otomatik oluşturması için önce boş bir proje yarat:

```bash
flutter create namaz_kuran_app
cd namaz_kuran_app
```

Sonra bu paylaşımdaki **`lib/`** klasörünün tüm içeriğini ve
**`pubspec.yaml`** dosyasını, yeni oluşturduğun `namaz_kuran_app` klasörünün
üzerine kopyala (var olan `lib/main.dart` ve `pubspec.yaml`'ın üzerine
yazmaktan çekinme).

## 3. Android İzinleri

`android/app/src/main/AndroidManifest.xml` dosyasını aç, `<manifest ...>`
etiketinin hemen içine (application tag'inden önce) şu satırları ekle:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## 4. Paketleri Yükle ve Çalıştır

```bash
flutter pub get
flutter run
```

Telefonunu/emülatörünü bağlı tutup `flutter run` dedikten sonra uygulama
otomatik derlenip cihazında açılacak.

## 5. Play Store için Yayına Hazırlama (ileride)

Uygulama çalışır hale geldikten sonra sırasıyla:
1. Uygulama ikonu ekleme (`flutter_launcher_icons` paketi işini kolaylaştırır)
2. `android/app/build.gradle` içinde `applicationId`'yi kendi paket adınla
   değiştirme (örn: `com.senin_adin.namazkuran`)
3. İmzalama anahtarı (keystore) oluşturup release build alma:
   `flutter build appbundle --release`
4. Google Play Console'da geliştirici hesabı açma (tek seferlik ~25$ ücret)
   ve `.aab` dosyasını yükleme

Bu adımları uygulama işlevsel hale geldiğinde ayrıca detaylandırabilirim,
şu an istersen bunu bir sonraki adım olarak konuşalım.

## Notlar
- İlk açılışta konum izni istenecek; kullanıcı reddederse ekranda
  anlaşılır bir hata mesajı ve "Tekrar Dene" butonu gösteriliyor.
- Meal dili Ayarlar sekmesinden değiştirilip cihazda kalıcı olarak
  saklanıyor (`shared_preferences`).
- Sure detay ekranında Arapça metin sağdan sola (RTL) hizalanmış,
  altında seçilen dildeki meal gösteriliyor.
