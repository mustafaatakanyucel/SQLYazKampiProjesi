-- Microsoft SQL Server (T-SQL) schema for Online Shopping Platform
-- Creates tables: Musteri, Kategori, Satici, Urun, Siparis, Siparis_Detay

SET NOCOUNT ON;

BEGIN TRANSACTION;

-- Customers
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Musteri]') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Musteri (
  id INT IDENTITY(1,1) PRIMARY KEY,
  ad NVARCHAR(100) NOT NULL,
  soyad NVARCHAR(100) NOT NULL,
  email NVARCHAR(150) NOT NULL UNIQUE,
  sehir NVARCHAR(100) NULL,
  kayit_tarihi DATE DEFAULT CAST(GETDATE() AS DATE)
);
END

-- Categories
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Kategori]') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Kategori (
  id INT IDENTITY(1,1) PRIMARY KEY,
  ad NVARCHAR(100) NOT NULL UNIQUE
);
END

-- Sellers
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Satici]') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Satici (
  id INT IDENTITY(1,1) PRIMARY KEY,
  ad NVARCHAR(150) NOT NULL,
  adres NVARCHAR(MAX) NULL
);
END

-- Products
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Urun]') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Urun (
  id INT IDENTITY(1,1) PRIMARY KEY,
  ad NVARCHAR(200) NOT NULL,
  fiyat DECIMAL(10,2) NOT NULL CHECK (fiyat >= 0),
  stok INT NOT NULL DEFAULT 0 CHECK (stok >= 0),
  kategori_id INT NOT NULL,
  satici_id INT NOT NULL,
  CONSTRAINT FK_Urun_Kategori FOREIGN KEY (kategori_id) REFERENCES dbo.Kategori(id),
  CONSTRAINT FK_Urun_Satici FOREIGN KEY (satici_id) REFERENCES dbo.Satici(id)
);
END

-- Orders
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Siparis]') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Siparis (
  id INT IDENTITY(1,1) PRIMARY KEY,
  musteri_id INT NOT NULL,
  tarih DATE DEFAULT CAST(GETDATE() AS DATE),
  toplam_tutar DECIMAL(12,2) DEFAULT 0 CHECK (toplam_tutar >= 0),
  odeme_turu NVARCHAR(50) NULL,
  CONSTRAINT FK_Siparis_Musteri FOREIGN KEY (musteri_id) REFERENCES dbo.Musteri(id)
);
END

-- Order details
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Siparis_Detay]') AND type in (N'U'))
BEGIN
CREATE TABLE dbo.Siparis_Detay (
  id INT IDENTITY(1,1) PRIMARY KEY,
  siparis_id INT NOT NULL,
  urun_id INT NOT NULL,
  adet INT NOT NULL CHECK (adet > 0),
  fiyat DECIMAL(10,2) NOT NULL CHECK (fiyat >= 0),
  CONSTRAINT FK_SiparisDetay_Siparis FOREIGN KEY (siparis_id) REFERENCES dbo.Siparis(id),
  CONSTRAINT FK_SiparisDetay_Urun FOREIGN KEY (urun_id) REFERENCES dbo.Urun(id)
);
END

-- Indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_urun_kategori' AND object_id = OBJECT_ID('dbo.Urun'))
CREATE INDEX idx_urun_kategori ON dbo.Urun(kategori_id);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_urun_satici' AND object_id = OBJECT_ID('dbo.Urun'))
CREATE INDEX idx_urun_satici ON dbo.Urun(satici_id);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_siparis_musteri' AND object_id = OBJECT_ID('dbo.Siparis'))
CREATE INDEX idx_siparis_musteri ON dbo.Siparis(musteri_id);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_siparis_tarih' AND object_id = OBJECT_ID('dbo.Siparis'))
CREATE INDEX idx_siparis_tarih ON dbo.Siparis(tarih);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_siparisdetay_urun' AND object_id = OBJECT_ID('dbo.Siparis_Detay'))
CREATE INDEX idx_siparisdetay_urun ON dbo.Siparis_Detay(urun_id);

COMMIT TRANSACTION;

-- View for order lines
IF OBJECT_ID('dbo.vw_siparis_line', 'V') IS NOT NULL
  DROP VIEW dbo.vw_siparis_line;

GO

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

-- Trigger to recalc Siparis.toplam_tutar after insert/update/delete on Siparis_Detay
IF OBJECT_ID('dbo.trg_recalc_siparis_after_change', 'TR') IS NOT NULL
  DROP TRIGGER dbo.trg_recalc_siparis_after_change ON dbo.Siparis_Detay;

GO

CREATE TRIGGER dbo.trg_recalc_siparis_after_change
ON dbo.Siparis_Detay
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @siparis_id INT;

  -- Handle INSERTED and DELETED sets; update totals for affected orders
  -- First, update totals for inserted rows
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

  -- Then handle deleted rows (if any orders lost all lines, set toplam_tutar to 0)
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
