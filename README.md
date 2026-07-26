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

## YÖNTEM A: Hiçbir Şey Kurmadan (GitHub + Codemagic) — ÖNERİLEN

Bilgisayarına Flutter, Android Studio falan kurmana gerek yok. Kod bulutta
(Codemagic'in sunucularında) derlenecek.

### Adım 1 — GitHub'a hesap aç ve repo oluştur
1. https://github.com adresinden ücretsiz hesap aç (yoksa).
2. Sağ üstteki **+** işaretine tıkla → **New repository**.
3. İsim ver (örn. `namaz-kuran-app`), **Public** veya **Private** seç
   (ikisi de olur), **Create repository** butonuna bas.

### Adım 2 — Proje dosyalarını yükle
1. Bu paylaşımdaki zip dosyasını bilgisayarında bir klasöre çıkart (unzip).
2. GitHub'da yeni açtığın repo sayfasında **"uploading an existing file"**
   linkine tıkla (veya **Add file > Upload files**).
3. Çıkarttığın `namaz_kuran_app` klasörünün **içindeki** tüm dosya ve
   klasörleri (lib/, pubspec.yaml, codemagic.yaml, README.md) seçip
   tarayıcıya sürükle-bırak yap. (Chrome/Firefox klasör yapısını koruyarak
   yükler.)
4. Altta **Commit changes** butonuna bas.

### Adım 3 — Codemagic'e bağlan
1. https://codemagic.io adresine git, **"Sign up"** ile GitHub hesabınla
   giriş yap (ayrı şifre oluşturmana gerek yok).
2. İlk girişte GitHub reponu Codemagic'e bağlamanı isteyecek — az önce
   oluşturduğun `namaz-kuran-app` reposunu seç.
3. Codemagic, repo içindeki `codemagic.yaml` dosyasını otomatik algılayacak
   ve **"Android Test Build (APK)"** adında bir iş akışı (workflow)
   göreceksin.
4. O workflow'un yanındaki **Start new build** butonuna bas.
5. Derleme başlar (birkaç dakika sürer), bittiğinde **Artifacts** kısmında
   bir `.apk` dosyası göreceksin — indirebilirsin.

### Adım 4 — Telefonunda test et
1. İndirdiğin `.apk` dosyasını telefonuna aktar (Google Drive/WhatsApp'a
   kendine gönderme gibi basit bir yöntemle).
2. Telefonda dosyaya dokunup kur. Android "bilinmeyen kaynaklardan yükleme"
   izni isteyebilir, açman gerekir (sadece test amaçlı, güvenlidir çünkü
   kendi derlediğin dosya).
3. Uygulama açılınca konum izni isteyecek, izin ver — namaz vakitleri
   gelecek.

Kod üzerinde değişiklik yapmak istediğinde (örn. bir ekranın rengini
değiştirmek), bana söylersin, ben dosyayı güncellerim, sen güncellenen
dosyayı GitHub'a tekrar yüklersin (üzerine yazarak), Codemagic'te tekrar
**Start new build** dersin. Her build ücretsiz 500 dakikalık kotandan
düşer (bu boyuttaki bir uygulama için bir build ~3-5 dakika sürer, yani
ayda 100'den fazla build hakkın olur).

### Play Store'a yayınlarken (ileride)
`codemagic.yaml` içinde hazır bir **android-release-build** iş akışı da
var; imzalama anahtarı (keystore) oluşturup Codemagic paneline
yüklediğimizde bu workflow ile doğrudan Play Store'a yüklenebilir `.aab`
dosyası üretebileceğiz. Bu adımı, uygulama işlevsel olarak tamamlandığında
birlikte yapalım.

---

## YÖNTEM B: Bilgisayarına Kurarak (Flutter + Android Studio)

Bunu istersen, örneğin geliştirmeyi hızlandırmak için ileride tercih
edebilirsin (her değişiklikte anında telefonda görürsün, bulut derlemesi
beklemezsin). Şimdilik atlayabilirsin.

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
