import '../models/hadith.dart';

/// Kütüb-i Sitte (Buhârî, Müslim, Tirmizî, Ebû Dâvûd, Nesâî, İbn Mâce) ve
/// diğer temel hadis kaynaklarında yer alan, üzerinde geniş ittifak
/// bulunan 50 sahih/hasen hadis-i şeriften oluşan derleme.
///
/// NOT: Bu metinler, Diyanet İşleri Başkanlığı'nın hadis veritabanı
/// (hadis.diyanet.gov.tr / hadislerleislam.diyanet.gov.tr) otomatik
/// erişime kapalı olduğu için doğrudan oradan alınamamıştır. Bunun
/// yerine, aynı hadislerin yaygın ve güvenilir kaynaklardaki anlamı
/// esas alınarak özenle Türkçeleştirilmiştir. Yayına almadan önce
/// Diyanet'in "Hadislerle İslam" kaynağıyla karşılaştırılması önerilir.
const List<Hadith> hadithList = [
  Hadith(
    text:
        'Ameller ancak niyetlere göredir. Herkese ancak niyet ettiği şey vardır.',
    source: 'Buhârî, Bedü\'l-Vahy, 1; Müslim, İmâre, 155',
  ),
  Hadith(
    text:
        'Müslüman, elinden ve dilinden diğer Müslümanların güvende olduğu kimsedir.',
    source: 'Buhârî, İman, 4-5; Müslim, İman, 64-65',
  ),
  Hadith(
    text:
        'Sizden biriniz, kendisi için istediğini din kardeşi için de istemedikçe gerçek anlamda iman etmiş olmaz.',
    source: 'Buhârî, İman, 7; Müslim, İman, 71',
  ),
  Hadith(
    text: 'Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.',
    source: 'Buhârî, İlim, 11; Müslim, Cihâd, 6',
  ),
  Hadith(
    text: 'Din, samimiyet ve öğüttür.',
    source: 'Müslim, İman, 95',
  ),
  Hadith(
    text:
        'İslam beş esas üzerine kurulmuştur: Allah\'tan başka ilah olmadığına ve Muhammed\'in O\'nun elçisi olduğuna şehadet etmek, namaz kılmak, zekât vermek, hacca gitmek ve ramazan orucunu tutmak.',
    source: 'Buhârî, İman, 1; Müslim, İman, 21-22',
  ),
  Hadith(
    text:
        'Helal bellidir, haram da bellidir; ikisi arasında ise bazı insanların bilmediği şüpheli şeyler vardır. Şüphelilerden sakınan, dinini ve namusunu korumuş olur.',
    source: 'Buhârî, İman, 39; Müslim, Müsâkât, 107',
  ),
  Hadith(
    text: 'Size neyi yasakladıysam ondan kaçının, neyi emrettiysem gücünüz yettiğince yapın.',
    source: 'Buhârî, İ\'tisâm, 2; Müslim, Hac, 412',
  ),
  Hadith(
    text: 'Allah güzeldir, güzelliği sever.',
    source: 'Müslim, İman, 147',
  ),
  Hadith(
    text: 'Kişinin, kendisini ilgilendirmeyen şeyi terk etmesi, iyi bir Müslüman oluşunun alametidir.',
    source: 'Tirmizî, Zühd, 11 (hasen)',
  ),
  Hadith(
    text: 'Müslümanın kanı, ancak üç durumdan biriyle helal olur: cana karşılık can, evli iken zina eden, dinden çıkıp cemaatten ayrılan.',
    source: 'Buhârî, Diyât, 6; Müslim, Kasâme, 25-26',
  ),
  Hadith(
    text:
        'Kim Allah\'a ve ahiret gününe inanıyorsa ya hayır söylesin ya da sussun; kim Allah\'a ve ahiret gününe inanıyorsa komşusuna ikram etsin; kim Allah\'a ve ahiret gününe inanıyorsa misafirine ikram etsin.',
    source: 'Buhârî, Edeb, 31; Müslim, İman, 74-77',
  ),
  Hadith(
    text: 'Kızma!',
    source: 'Buhârî, Edeb, 76',
  ),
  Hadith(
    text: 'Allah, her işte iyi ve güzel davranmayı (ihsanı) emretmiştir.',
    source: 'Müslim, Sayd, 57',
  ),
  Hadith(
    text:
        'Nerede olursan ol Allah\'tan kork; kötülüğün ardından bir iyilik yap ki onu silsin; insanlara güzel ahlakla davran.',
    source: 'Tirmizî, Birr, 55 (hasen)',
  ),
  Hadith(
    text: 'Allah\'ı gözet ki O da seni gözetsin; Allah\'ı gözet ki O\'nu hep yanında bulasın.',
    source: 'Tirmizî, Sıfatü\'l-Kıyâme, 59 (hasen sahih)',
  ),
  Hadith(
    text: 'Haya, imandandır.',
    source: 'Buhârî, İman, 16; Müslim, İman, 57-58',
  ),
  Hadith(
    text: 'Ben güzel ahlakı tamamlamak üzere gönderildim.',
    source: 'Ahmed b. Hanbel, Müsned',
  ),
  Hadith(
    text: 'Sizin en hayırlınız, Kur\'an\'ı öğrenen ve öğretendir.',
    source: 'Buhârî, Fedâilü\'l-Kur\'ân, 21',
  ),
  Hadith(
    text: 'Mümin, mümin kardeşinin aynasıdır.',
    source: 'Ebû Dâvûd, Edeb, 49 (hasen)',
  ),
  Hadith(
    text: 'Kuvvetli mümin, zayıf müminden daha hayırlı ve Allah katında daha sevgilidir.',
    source: 'Müslim, Kader, 34',
  ),
  Hadith(
    text: 'Din kolaylıktır. Kim dini zorlaştırırsa dine yenilir.',
    source: 'Buhârî, İman, 29',
  ),
  Hadith(
    text: 'Bir Müslümanın, din kardeşine üç günden fazla küs durması helal değildir.',
    source: 'Buhârî, Edeb, 62; Müslim, Birr, 23-25',
  ),
  Hadith(
    text: 'Kul zulmü kendine haram kıldığım gibi, sizin aranızda da haram kıldım; artık birbirinize zulmetmeyin.',
    source: 'Müslim, Birr, 55 (Kudsî hadis)',
  ),
  Hadith(
    text: 'Kim bir mümini dünya sıkıntılarından birinden kurtarırsa, Allah da kıyamet günü onu sıkıntılarından birinden kurtarır.',
    source: 'Müslim, Zikr, 38',
  ),
  Hadith(
    text: 'Allah, sizin bedenlerinize ve suretlerinize değil, kalplerinize ve amellerinize bakar.',
    source: 'Müslim, Birr, 33',
  ),
  Hadith(
    text: 'Münafığın alameti üçtür: Konuşunca yalan söyler, söz verince sözünde durmaz, kendisine bir şey emanet edilince ihanet eder.',
    source: 'Buhârî, İman, 24; Müslim, İman, 106',
  ),
  Hadith(
    text: 'Ademoğlunun kalbi, kaynayan bir tencere gibi durmadan hâlden hâle döner.',
    source: 'Ahmed b. Hanbel, Müsned (hasen)',
  ),
  Hadith(
    text: 'İyilik güzel ahlaktır; günah ise kalbini rahatsız eden ve insanların bilmesinden hoşlanmadığın şeydir.',
    source: 'Müslim, Birr, 14-15',
  ),
  Hadith(
    text: 'Veren el, alan elden hayırlıdır.',
    source: 'Buhârî, Zekât, 18; Müslim, Zekât, 94-97',
  ),
  Hadith(
    text: 'Sadaka, malı asla eksiltmez.',
    source: 'Müslim, Birr, 69',
  ),
  Hadith(
    text: 'Cemaatle kılınan namaz, tek başına kılınan namazdan yirmi yedi derece daha üstündür.',
    source: 'Buhârî, Ezân, 30; Müslim, Mesâcid, 249',
  ),
  Hadith(
    text: 'Oruç bir kalkandır.',
    source: 'Buhârî, Savm, 2; Müslim, Sıyâm, 163',
  ),
  Hadith(
    text: 'Kim inanarak ve karşılığını Allah\'tan bekleyerek ramazan orucunu tutarsa, geçmiş günahları bağışlanır.',
    source: 'Buhârî, İman, 28; Müslim, Müsâfirîn, 175',
  ),
  Hadith(
    text: 'İki nimet vardır ki insanların çoğu bu ikisi hakkında aldanmıştır: sağlık ve boş vakit.',
    source: 'Buhârî, Rikâk, 1',
  ),
  Hadith(
    text: 'Allah katında amellerin en sevimlisi, az da olsa devamlı olanıdır.',
    source: 'Buhârî, Rikâk, 18; Müslim, Müsâfirîn, 216',
  ),
  Hadith(
    text: 'Kardeşine tebessüm etmen bile senin için bir sadakadır.',
    source: 'Tirmizî, Birr, 36 (hasen)',
  ),
  Hadith(
    text: 'Kim bir hayra vesile olursa, o hayrı bizzat işleyen kimsenin sevabı gibi sevap alır.',
    source: 'Müslim, İmâre, 133',
  ),
  Hadith(
    text: 'İnsanlara teşekkür etmeyen, Allah\'a da şükretmemiş sayılır.',
    source: 'Tirmizî, Birr, 35; Ebû Dâvûd, Edeb, 12 (hasen)',
  ),
  Hadith(
    text: 'Büyüklerimize saygı göstermeyen, küçüklerimize merhamet etmeyen bizden değildir.',
    source: 'Tirmizî, Birr, 15; Ebû Dâvûd, Edeb, 66 (hasen)',
  ),
  Hadith(
    text: 'Merhamet etmeyene merhamet olunmaz.',
    source: 'Buhârî, Edeb, 27; Müslim, Fedâil, 65',
  ),
  Hadith(
    text: 'Yeryüzündekilere merhamet edin ki göktekiler de size merhamet etsin.',
    source: 'Tirmizî, Birr, 16 (hasen)',
  ),
  Hadith(
    text: 'Sizden biriniz kendisi için sevdiğini kardeşi için de sevmedikçe gerçek anlamda iman etmiş olmaz.',
    source: 'Buhârî, İman, 7; Müslim, İman, 71',
  ),
  Hadith(
    text: 'Gençliğini ihtiyarlığından, sağlığını hastalığından, zenginliğini fakirliğinden, boş vaktini meşguliyetinden, hayatını ölümünden önce değerlendir.',
    source: 'Hâkim, Müstedrek; Tirmizî, Zühd (hasen)',
  ),
  Hadith(
    text: 'Sözlerin en güzeli Allah\'ın kitabı, yolların en hayırlısı Muhammed\'in yoludur.',
    source: 'Müslim, Cum\'a, 43; Nesâî, Îdeyn, 22',
  ),
  Hadith(
    text: 'Kim Allah için sever, Allah için buğz eder, Allah için verir ve Allah için men ederse imanını kemale erdirmiş olur.',
    source: 'Ebû Dâvûd, Sünnet, 15 (hasen)',
  ),
  Hadith(
    text: 'Şaka bile olsa yalan söylemeyi bırakana cennetin ortasında bir köşk verilir.',
    source: 'Ebû Dâvûd, Edeb, 5 (hasen)',
  ),
  Hadith(
    text: 'Namaz, kıyamet gününde kulun hesaba çekileceği ilk ameldir.',
    source: 'Tirmizî, Salât, 188; Nesâî, Salât, 9 (hasen)',
  ),
  Hadith(
    text: 'Allah\'tan hakkıyla hayâ edin. Baş ve onun barındırdıklarını, karın ve onun kapsadıklarını korumak, dünya hayatının süsünü bırakıp ahireti tercih etmek de hayânın bir parçasıdır.',
    source: 'Tirmizî, Sıfatü\'l-Kıyâme, 24 (hasen)',
  ),
  Hadith(
    text: 'Kişi, sevdiği ile beraberdir.',
    source: 'Buhârî, Edeb, 96; Müslim, Birr, 165',
  ),
];
