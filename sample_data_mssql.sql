-- Sample data for Microsoft SQL Server
SET NOCOUNT ON;

BEGIN TRANSACTION;

-- Insert categories
INSERT INTO dbo.Kategori (ad) VALUES
  (N'Elektronik'),
  (N'Giyim'),
  (N'Ev & Yaşam'),
  (N'Kitap');

-- Insert sellers
INSERT INTO dbo.Satici (ad, adres) VALUES
  (N'TeknoSat', N'Istanbul, Turkey'),
  (N'ModaYeri', N'Ankara, Turkey'),
  (N'EvDekor', N'Izmir, Turkey');

-- Insert products
INSERT INTO dbo.Urun (ad, fiyat, stok, kategori_id, satici_id) VALUES
  (N'USB-C Hızlı Şarj Cihazı', 129.90, 100, 1, 1),
  (N'Bluetooth Kulaklık', 349.00, 50, 1, 1),
  (N'Erkek T-Shirt', 79.90, 200, 2, 2),
  (N'Pirinç Tencere', 249.50, 30, 3, 3),
  (N'Roman: Yabancı', 39.90, 120, 4, 2);

-- Insert customers
INSERT INTO dbo.Musteri (ad, soyad, email, sehir, kayit_tarihi) VALUES
  (N'Ahmet', N'Yilmaz', N'ahmet@example.com', N'Istanbul', '2024-01-10'),
  (N'Ayse', N'Kara', N'ayse@example.com', N'Ankara', '2024-02-05'),
  (N'Mehmet', N'Demir', N'mehmet@example.com', N'Izmir', '2024-03-12'),
  (N'Elif', N'Sahin', N'elif@example.com', N'Istanbul', '2024-03-20');

-- Example: create an order for customer 1 and order details
DECLARE @orderId INT;

INSERT INTO dbo.Siparis (musteri_id, tarih, odeme_turu)
VALUES (1, CAST(GETDATE() AS DATE), N'Kredi Kartı');

SET @orderId = SCOPE_IDENTITY();

INSERT INTO dbo.Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
  (@orderId, 1, 2, 129.90),
  (@orderId, 5, 1, 39.90);

-- Update stocks
UPDATE dbo.Urun SET stok = stok - 2 WHERE id = 1;
UPDATE dbo.Urun SET stok = stok - 1 WHERE id = 5;

-- Update order total
UPDATE dbo.Siparis
SET toplam_tutar = (
  SELECT ISNULL(SUM(adet * fiyat),0) FROM dbo.Siparis_Detay WHERE siparis_id = @orderId
)
WHERE id = @orderId;

COMMIT TRANSACTION;

-- Example updates/deletes
UPDATE dbo.Musteri SET sehir = N'Bursa' WHERE id = 3;

-- Delete product if never sold (no order detail reference)
DELETE FROM dbo.Urun WHERE id = 4 AND NOT EXISTS (SELECT 1 FROM dbo.Siparis_Detay sd WHERE sd.urun_id = 4);

-- TRUNCATE example (be careful)
-- TRUNCATE TABLE dbo.Siparis_Detay;
