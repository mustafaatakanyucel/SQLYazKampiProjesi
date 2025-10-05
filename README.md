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

D. İleri Seviye Görevler (Opsiyonel)
- En çok kazanç sağlayan ilk 3 kategori
- Ortalama sipariş tutarını geçen siparişleri bulma
- En az bir kez elektronik ürün satın alan müşteriler

4. Teslim Beklentisi
-------------------
1. ER Diyagramı (tablolar ve ilişkiler)
2. SQL Script Dosyası (oluşturma, ekleme, güncelleme sorguları)
3. Raporlama Sorguları (JOIN, GROUP BY, HAVING örnekleri)
4. Dokümantasyon (kısa rapor: tasarım ve karşılaşılan sorunlar)

5. Değerlendirme Kriterleri
---------------------------
- Veri tabanı tasarımının kapsamlılığı — %25
- SQL komutlarının çeşitliliği ve doğruluğu — %35
- İleri raporlama ve JOIN sorgularının uygulanması — %25
- Dokümantasyon ve açıklama — %15

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
# EcomDB — Online Alışveriş Platformu (SQL Server / SSMS)

Kısa anlatım
-------------
Bu repo, öğrencilik projesi olarak hazırlanmış basit bir e-ticaret veri tabanını içerir. Veritabanı adı olarak `EcomDB` kullanıldı. Dosyalar hem MSSQL (T-SQL) hem PostgreSQL örnekleri içerir; SSMS ile çalıştırmak için MSSQL sürümlerini kullanabilirsiniz.

Önemli dosyalar
- `ER_Diagram/erd.puml` — ER diyagramı (PlantUML).
- `sql/mssql/EcomDB.sql` — MSSQL için tek dosyada kurulum (DROP/CREATE/INSERT). SSMS’de açıp çalıştırabilirsiniz.
- `sql/mssql/schema_mssql.sql` — MSSQL şema (tablolar, index, view, trigger).
- `sql/mssql/sample_data_mssql.sql` — MSSQL örnek veri ekleme.
- `sql/mssql/report_queries_mssql.sql` — MSSQL rapor sorguları (join, group by, having, advanced).
- `sql/schema.sql`, `sql/sample_data.sql`, `sql/report_queries.sql` — PostgreSQL sürümleri (yedek/karşılaştırma için).
- `README_SCHEMA.md` — Tasarım varsayımları ve kısa notlar.

Nasıl çalıştırılır (SSMS, adım adım)
----------------------------------
1. SSMS’i açın ve SQL Server instance’ınıza bağlanın.
2. Yeni bir veritabanı oluşturun (sağ tık Databases → New Database). Örnek isim: `EcomDB`.
3. `sql/mssql/EcomDB.sql` dosyasını SSMS’de açın. Üstteki veritabanı seçiminden `EcomDB`yi seçin.
4. F5 ile script'i çalıştırın. (Script içinde `GO` ayırıcıları vardır; bunları silmeyin.)

Hızlı doğrulama (SSMS içinde)
- `SELECT COUNT(*) FROM dbo.Musteri;` — müşteri sayısı.
- `SELECT TOP(5) m.ad, m.soyad, COUNT(s.id) AS siparis_sayisi FROM dbo.Musteri m LEFT JOIN dbo.Siparis s ON s.musteri_id=m.id GROUP BY m.id, m.ad, m.soyad ORDER BY siparis_sayisi DESC;`
- `SELECT * FROM dbo.vw_siparis_line;` — sipariş satırlarını gösteren view.

İleri seviye (rapor) sorgular — kısa not
- En çok gelir getiren ilk 3 kategori: kategori bazında `SUM(adet * fiyat)` ile hesaplanır (MSSQL: `TOP(3)`).
- Ortalama sipariş tutarını geçen siparişler: siparişlerin `toplam_tutar` ortalaması hesaplanıp üzerine çıkanlar listelenir.
- Elektronik ürün alan müşteriler: kategori adı `Elektronik` olan ürünleri almış müşteriler seçilir.
Bu sorguların hazır halleri `sql/mssql/report_queries_mssql.sql` içinde bulunuyor.

Teslimat için kısa kontrol listesi
- ER diyagramı: `ER_Diagram/erd.puml`
- MSSQL kurulum: `sql/mssql/run_all_mssql.sql` (SSMS ile çalıştırın)
- Rapor sorguları: `sql/mssql/report_queries_mssql.sql`
- Kısa proje raporu: `DOC_REPORT.md`

Dikkat edilmesi gerekenler / notlar
- `EcomDB.sql` test amaçlıdır; DROP komutları içerir. Gerçek (production) veritabanlarında çalıştırmayın.
- SSMS'de `GO` ayracının gereken yerlerde durduğuna dikkat edin; toplu çalıştırırken `GO`'yu silmeyin.
- NVARCHAR kullanıldı; Türkçe karakterler düzgün görünmelidir.
