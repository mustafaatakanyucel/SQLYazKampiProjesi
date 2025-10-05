
SET NOCOUNT ON;

-- Drop view if exists
IF OBJECT_ID('dbo.vw_siparis_line', 'V') IS NOT NULL
  DROP VIEW dbo.vw_siparis_line;

-- Drop trigger if exists (DML trigger)
IF OBJECT_ID('dbo.trg_recalc_siparis_after_change', 'TR') IS NOT NULL
  DROP TRIGGER dbo.trg_recalc_siparis_after_change;

GO

-- Drop tables in order of FK dependencies
IF OBJECT_ID('dbo.Siparis_Detay', 'U') IS NOT NULL DROP TABLE dbo.Siparis_Detay;
IF OBJECT_ID('dbo.Siparis', 'U') IS NOT NULL DROP TABLE dbo.Siparis;
IF OBJECT_ID('dbo.Urun', 'U') IS NOT NULL DROP TABLE dbo.Urun;
IF OBJECT_ID('dbo.Satici', 'U') IS NOT NULL DROP TABLE dbo.Satici;
IF OBJECT_ID('dbo.Kategori', 'U') IS NOT NULL DROP TABLE dbo.Kategori;
IF OBJECT_ID('dbo.Musteri', 'U') IS NOT NULL DROP TABLE dbo.Musteri;

GO

-- Create tables (copied from schema_mssql.sql)
CREATE TABLE dbo.Musteri (
  id INT IDENTITY(1,1) PRIMARY KEY,
  ad NVARCHAR(100) NOT NULL,
  soyad NVARCHAR(100) NOT NULL,
  email NVARCHAR(150) NOT NULL UNIQUE,
  sehir NVARCHAR(100) NULL,
  kayit_tarihi DATE DEFAULT CAST(GETDATE() AS DATE)
);

CREATE TABLE dbo.Kategori (
  id INT IDENTITY(1,1) PRIMARY KEY,
  ad NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.Satici (
  id INT IDENTITY(1,1) PRIMARY KEY,
  ad NVARCHAR(150) NOT NULL,
  adres NVARCHAR(MAX) NULL
);

CREATE TABLE dbo.Urun (
  id INT IDENTITY(1,1) PRIMARY KEY,
  ad NVARCHAR(200) NOT NULL,
  fiyat DECIMAL(10,2) NOT NULL CHECK (fiyat >= 0),
  stok INT NOT NULL DEFAULT 0 CHECK (stok >= 0),
  kategori_id INT NOT NULL,
  satici_id INT NOT NULL
);

CREATE TABLE dbo.Siparis (
  id INT IDENTITY(1,1) PRIMARY KEY,
  musteri_id INT NOT NULL,
  tarih DATE DEFAULT CAST(GETDATE() AS DATE),
  toplam_tutar DECIMAL(12,2) DEFAULT 0 CHECK (toplam_tutar >= 0),
  odeme_turu NVARCHAR(50) NULL
);

CREATE TABLE dbo.Siparis_Detay (
  id INT IDENTITY(1,1) PRIMARY KEY,
  siparis_id INT NOT NULL,
  urun_id INT NOT NULL,
  adet INT NOT NULL CHECK (adet > 0),
  fiyat DECIMAL(10,2) NOT NULL CHECK (fiyat >= 0)
);

GO

-- Foreign keys
ALTER TABLE dbo.Urun ADD CONSTRAINT FK_Urun_Kategori FOREIGN KEY (kategori_id) REFERENCES dbo.Kategori(id);
ALTER TABLE dbo.Urun ADD CONSTRAINT FK_Urun_Satici FOREIGN KEY (satici_id) REFERENCES dbo.Satici(id);
ALTER TABLE dbo.Siparis ADD CONSTRAINT FK_Siparis_Musteri FOREIGN KEY (musteri_id) REFERENCES dbo.Musteri(id);
ALTER TABLE dbo.Siparis_Detay ADD CONSTRAINT FK_SiparisDetay_Siparis FOREIGN KEY (siparis_id) REFERENCES dbo.Siparis(id);
ALTER TABLE dbo.Siparis_Detay ADD CONSTRAINT FK_SiparisDetay_Urun FOREIGN KEY (urun_id) REFERENCES dbo.Urun(id);

GO

-- Indexes
CREATE INDEX idx_urun_kategori ON dbo.Urun(kategori_id);
CREATE INDEX idx_urun_satici ON dbo.Urun(satici_id);
CREATE INDEX idx_siparis_musteri ON dbo.Siparis(musteri_id);
CREATE INDEX idx_siparis_tarih ON dbo.Siparis(tarih);
CREATE INDEX idx_siparisdetay_urun ON dbo.Siparis_Detay(urun_id);

GO

-- View
CREATE VIEW dbo.vw_siparis_line AS
SELECT sd.id AS siparis_detay_id,
       sd.siparis_id,
       sd.urun_id,
       u.ad AS urun_ad,
       sd.adet,
       sd.fiyat,
       CAST(sd.adet * sd.fiyat AS DECIMAL(12,2)) AS line_total
FROM dbo.Siparis_Detay sd
JOIN dbo.Urun u ON u.id = sd.urun_id;

GO

-- Trigger
CREATE TRIGGER dbo.trg_recalc_siparis_after_change
ON dbo.Siparis_Detay
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
  SET NOCOUNT ON;

  IF EXISTS (SELECT 1 FROM inserted)
  BEGIN
    UPDATE s
    SET toplam_tutar = t.sum_total
    FROM dbo.Siparis s
    JOIN (
      SELECT sd.siparis_id, SUM(sd.adet * sd.fiyat) AS sum_total
      FROM dbo.Siparis_Detay sd
      WHERE sd.siparis_id IN (SELECT DISTINCT siparis_id FROM inserted)
      GROUP BY sd.siparis_id
    ) t ON t.siparis_id = s.id;
  END

  IF EXISTS (SELECT 1 FROM deleted)
  BEGIN
    UPDATE s
    SET toplam_tutar = ISNULL(t.sum_total, 0)
    FROM dbo.Siparis s
    LEFT JOIN (
      SELECT sd.siparis_id, SUM(sd.adet * sd.fiyat) AS sum_total
      FROM dbo.Siparis_Detay sd
      WHERE sd.siparis_id IN (SELECT DISTINCT siparis_id FROM deleted)
      GROUP BY sd.siparis_id
    ) t ON t.siparis_id = s.id
    WHERE s.id IN (SELECT DISTINCT siparis_id FROM deleted);
  END

END;

GO

-- Insert sample data
INSERT INTO dbo.Kategori (ad) VALUES (N'Elektronik'), (N'Giyim'), (N'Ev & Yaþam'), (N'Kitap');
INSERT INTO dbo.Satici (ad, adres) VALUES (N'TeknoSat', N'Istanbul, Turkey'), (N'ModaYeri', N'Ankara, Turkey'), (N'EvDekor', N'Izmir, Turkey');
INSERT INTO dbo.Musteri (ad, soyad, email, sehir, kayit_tarihi) VALUES
  (N'Ahmet', N'Yilmaz', N'ahmet@example.com', N'Istanbul', '2024-01-10'),
  (N'Ayse', N'Kara', N'ayse@example.com', N'Ankara', '2024-02-05'),
  (N'Mehmet', N'Demir', N'mehmet@example.com', N'Izmir', '2024-03-12'),
  (N'Elif', N'Sahin', N'elif@example.com', N'Istanbul', '2024-03-20');

INSERT INTO dbo.Urun (ad, fiyat, stok, kategori_id, satici_id) VALUES
  (N'USB-C Hýzlý Þarj Cihazý', 129.90, 100, 1, 1),
  (N'Bluetooth Kulaklýk', 349.00, 50, 1, 1),
  (N'Erkek T-Shirt', 79.90, 200, 2, 2),
  (N'Pirinç Tencere', 249.50, 30, 3, 3),
  (N'Roman: Yabancý', 39.90, 120, 4, 2);

-- Create one example order and details
DECLARE @orderId INT;
INSERT INTO dbo.Siparis (musteri_id, tarih, odeme_turu) VALUES (1, CAST(GETDATE() AS DATE), N'Kredi Kartý');
SET @orderId = SCOPE_IDENTITY();
INSERT INTO dbo.Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES (@orderId, 1, 2, 129.90), (@orderId, 5, 1, 39.90);
UPDATE dbo.Urun SET stok = stok - 2 WHERE id = 1;
UPDATE dbo.Urun SET stok = stok - 1 WHERE id = 5;
UPDATE dbo.Siparis SET toplam_tutar = (SELECT ISNULL(SUM(adet * fiyat),0) FROM dbo.Siparis_Detay WHERE siparis_id = @orderId) WHERE id = @orderId;

GO

-- Quick validation queries (optional): uncomment to run
-- SELECT TOP(10) * FROM dbo.Musteri;
-- SELECT * FROM dbo.Siparis;
-- SELECT * FROM dbo.vw_siparis_line;
