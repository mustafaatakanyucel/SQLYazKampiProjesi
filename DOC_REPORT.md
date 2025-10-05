# Online Alışveriş Platformu Veri Tabanı - Proje Raporu

Bu projede, gerçek bir e-ticaret platformunu modelleyen kapsamlı bir veri tabanı tasarlanmış ve Microsoft SQL Server üzerinde uygulanmıştır. Sistem, müşteri yönetiminden sipariş takibine, stok kontrolünden satış raporlarına kadar tüm temel e-ticaret süreçlerini desteklemektedir.

## Tasarım Süreci

### 1. Gereksinim Analizi
Proje başlangıcında, modern e-ticaret platformlarının temel işlevleri analiz edildi:
- Müşteri kaydı ve yönetimi
- Ürün kataloğu ve kategorizasyon
- Satıcı yönetimi
- Sipariş süreçleri
- Stok takibi
- Raporlama ihtiyaçları

### 2. Veri Modeli Tasarımı
Altı ana tablo belirlendi ve aralarındaki ilişkiler tanımlandı:
- **Musteri**: Müşteri bilgilerini tutar
- **Kategori**: Ürün kategorilerini organize eder
- **Satici**: Satıcı bilgilerini saklar
- **Urun**: Ürün detaylarını içerir
- **Siparis**: Sipariş başlık bilgilerini tutar
- **Siparis_Detay**: Sipariş satır detaylarını saklar

### 3. Normalizasyon
Veri modeli 3. Normal Form'a uygun olarak tasarlandı:
- Birincil anahtarlar tüm tablolarda IDENTITY ile otomatik oluşturuluyor
- Yabancı anahtar ilişkileri referans bütünlüğünü sağlıyor
- Tekrarlayan veriler ayrı tablolara çıkarıldı

## Karşılaşılan Zorluklar ve Çözümler

### 1. Sipariş Toplam Hesaplama
**Sorun**: Sipariş detayları değiştiğinde toplam tutarın otomatik güncellenmesi  
**Çözüm**: AFTER INSERT, UPDATE, DELETE trigger'ı oluşturuldu. Trigger, sipariş detayları her değiştiğinde ilgili siparişin toplam tutarını yeniden hesaplayıp günceller.

### 2. Veri Bütünlüğü  
**Sorun**: Geçersiz veri girişlerinin önlenmesi  
**Çözüm**: 
- CHECK kısıtları ile fiyat ve stok negatif değer alamaz
- Email alanı UNIQUE kısıt ile benzersizlik sağlandı
- Foreign key kısıtları ile referans bütünlüğü korundu

### 3. Performans Optimizasyonu
**Sorun**: Büyük veri setlerinde sorgu performansı  
**Çözüm**: Sık kullanılan alanlara index'ler eklendi:
- kategori_id, satici_id (Urun tablosunda)
- musteri_id (Siparis tablosunda)  
- tarih (Siparis tablosunda)
- urun_id (Siparis_Detay tablosunda)

### 4. Karmaşık Raporlama
**Sorun**: Çok tablolu karmaşık sorguların yazılması  
**Çözüm**: 
- CTE (Common Table Expression) kullanılarak okunabilir sorgular yazıldı
- View oluşturularak sık kullanılan join'ler basitleştirildi
- Çeşitli JOIN türleri kullanılarak farklı veri kombinasyonları elde edildi

## Test Sonuçları

### Fonksiyonel Testler
1. **Veri Ekleme**: Tüm tablolara başarılı veri eklendi
2. **Trigger Testi**: Sipariş detayı ekleme/güncelleme/silmede toplam tutar otomatik güncellendi
3. **Kısıt Testleri**: Negatif fiyat, boş email gibi geçersiz veriler reddedildi
4. **Foreign Key Testleri**: Mevcut olmayan ID'lere referans verilmesi engellendi

## Sonuç ve Değerlendirme

### Başarılar
- ✅ Tam normalize edilmiş veri modeli
- ✅ Otomatik hesaplamalar (trigger ile)
- ✅ Kapsamlı veri bütünlüğü kontrolü
- ✅ Yüksek performanslı sorgular
- ✅ Esnek raporlama altyapısı

### Öğrenilen Konular
- Veri tabanı tasarım prensipleri
- SQL Server'da trigger kullanımı
- Performans optimizasyonu teknikleri
- Karmaşık SQL sorgu yazımı
- İş kurallarının veri tabanı seviyesinde uygulanması

Bu proje, teorik bilgilerin pratikte uygulanması açısından oldukça değerli bir deneyim sunmuştur.
