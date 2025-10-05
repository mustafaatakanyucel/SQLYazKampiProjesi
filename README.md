# Bitirme Projesi: Online Alışveriş Platformu Veri Tabanı

Bu proje, gerçek bir e-ticaret platformunu modelleyen kapsamlı bir veri tabanı tasarımı ve uygulamasıdır. Microsoft SQL Server kullanılarak hazırlanmış olup, müşteri siparişlerinden stok yönetimine kadar tüm süreçleri kapsar.

## Proje Genel Bakış

Online alışveriş platformlarında (Trendyol, Hepsiburada benzeri) kullanılan temel veri yapılarını modelleyerek:
- Veri tabanı tasarımı ve normalizasyon
- Veri ekleme, güncelleme ve silme işlemleri
- Raporlama ve analiz sorguları
- Karmaşık SQL sorgularının uygulanması hedeflenmiştir.

## Veritabanı Tasarımı

### Ana Tablolar
- **Musteri**: Müşteri bilgileri (id, ad, soyad, email, sehir, kayit_tarihi)
- **Kategori**: Ürün kategorileri (id, ad)
- **Satici**: Satıcı bilgileri (id, ad, adres)
- **Urun**: Ürün detayları (id, ad, fiyat, stok, kategori_id, satici_id)
- **Siparis**: Sipariş bilgileri (id, musteri_id, tarih, toplam_tutar, odeme_turu)
- **Siparis_Detay**: Sipariş satır detayları (id, siparis_id, urun_id, adet, fiyat)

1. Projenin Amacı
-----------------
Öğrencilerden gerçek bir e-ticaret platformunu modelleyerek aşağıdaki yetkinlikleri edinmeleri beklenir:
- Veri tabanı tasarlama
- Veri ekleme ve güncelleme
- Raporlama ve analiz sorguları yazma
- Karmaşık SQL sorgularında ustalaşma

2. Senaryo
-----------
Bir online alışveriş platformunda müşteri, ürün, sipariş, kategori, ödeme ve satıcı bilgileri yönetilmelidir. Öğrencilerden bu sistemi sıfırdan tasarlamaları ve SQL ile yönetmeleri istenir.

3. Adım Adım Görevler
---------------------

A. Veri Tabanı Tasarımı
Tablolar:
- Musteri (id, ad, soyad, email, sehir, kayit_tarihi)
- Urun (id, ad, fiyat, stok, kategori_id, satici_id)
- Kategori (id, ad)
- Satici (id, ad, adres)
- Siparis (id, musteri_id, tarih, toplam_tutar, odeme_turu)
- Siparis_Detay (id, siparis_id, urun_id, adet, fiyat)

İlişkiler:
- Bir müşteri birden fazla sipariş verebilir.
- Bir sipariş birden fazla ürün içerebilir.
- Bir ürünün bir kategorisi vardır.
- Bir ürün bir satıcıya aittir.

B. Veri Ekleme ve Güncelleme
- Örnek müşteri, ürün ve sipariş verileri ekleyin.
- INSERT, UPDATE, DELETE, TRUNCATE komutlarını kullanın.
- Stok değişikliklerini uygun UPDATE sorguları ile yönetin.

C. Veri Sorgulama ve Raporlama
Temel Sorgular:
- En çok sipariş veren 5 müşteri
- En çok satılan ürünler
- En yüksek cirosu olan satıcılar

Aggregate & Group By:
- Şehirlere göre müşteri sayısı
- Kategori bazlı toplam satışlar
- Aylara göre sipariş sayısı

JOIN’ler:
- Siparişlerde müşteri bilgisi + ürün bilgisi + satıcı bilgisi
- Hiç satılmamış ürünler
- Hiç sipariş vermemiş müşteriler

### İleri Seviye Sorgular
- En çok gelir getiren ilk 3 kategori
- Ortalama sipariş tutarının üzerindeki siparişler
- Elektronik ürün satın almış müşteriler

## Teknik Detaylar

### Kullanılan SQL Özellikleri
- `IDENTITY` - Otomatik artan birincil anahtarlar
- `FOREIGN KEY` - İlişkisel bütünlük
- `CHECK` - Veri doğrulama kısıtları
- `TRIGGER` - Otomatik hesaplamalar
- `VIEW` - Sipariş satır detayları
- `INDEX` - Performans optimizasyonu
- `CTE` - Karmaşık sorgular için
- `JOIN` çeşitleri - Veri birleştirme
- `GROUP BY`/`HAVING` - Gruplama ve filtreleme

### Veri Bütünlüğü
- Email alanı UNIQUE kısıtlaması
- Fiyat ve stok negatif olamaz
- Sipariş miktarı pozitif olmalı
- Foreign key kısıtları ile referans bütünlüğü

## Test Verileri

Sistemde aşağıdaki örnek veriler bulunmaktadır:
- 4 müşteri (İstanbul, Ankara, İzmir)
- 4 kategori (Elektronik, Giyim, Ev & Yaşam, Kitap)
- 3 satıcı
- 5 ürün
- 1 örnek sipariş (2 farklı ürün içeren)

## Doğrulama Sorguları

Kurulum sonrası aşağıdaki sorgularla sistemin çalıştığını kontrol edebilirsiniz:

```sql
-- Temel kontroller
SELECT COUNT(*) AS musteri_sayisi FROM dbo.Musteri;
SELECT COUNT(*) AS urun_sayisi FROM dbo.Urun;
SELECT COUNT(*) AS siparis_sayisi FROM dbo.Siparis;

-- View kontrolü
SELECT * FROM dbo.vw_siparis_line;

-- Trigger testi
INSERT INTO dbo.Siparis_Detay (siparis_id, urun_id, adet, fiyat) 
VALUES (1, 2, 1, (SELECT fiyat FROM dbo.Urun WHERE id=2));

-- Toplam tutarın otomatik güncellendiğini kontrol edin
SELECT id, toplam_tutar FROM dbo.Siparis WHERE id = 1;
```

