-- PostgreSQL schema for Online Shopping Platform
-- Creates tables: Musteri, Kategori, Satici, Urun, Siparis, Siparis_Detay

BEGIN;

-- Customers
CREATE TABLE IF NOT EXISTS Musteri (
  id SERIAL PRIMARY KEY,
  ad VARCHAR(100) NOT NULL,
  soyad VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  sehir VARCHAR(100),
  kayit_tarihi DATE DEFAULT CURRENT_DATE
);

-- Categories
CREATE TABLE IF NOT EXISTS Kategori (
  id SERIAL PRIMARY KEY,
  ad VARCHAR(100) UNIQUE NOT NULL
);

-- Sellers
CREATE TABLE IF NOT EXISTS Satici (
  id SERIAL PRIMARY KEY,
  ad VARCHAR(150) NOT NULL,
  adres TEXT
);

-- Products
CREATE TABLE IF NOT EXISTS Urun (
  id SERIAL PRIMARY KEY,
  ad VARCHAR(200) NOT NULL,
  fiyat NUMERIC(10,2) NOT NULL CHECK (fiyat >= 0),
  stok INTEGER NOT NULL DEFAULT 0 CHECK (stok >= 0),
  kategori_id INTEGER NOT NULL REFERENCES Kategori(id) ON DELETE RESTRICT,
  satici_id INTEGER NOT NULL REFERENCES Satici(id) ON DELETE RESTRICT
);

-- Orders
CREATE TABLE IF NOT EXISTS Siparis (
  id SERIAL PRIMARY KEY,
  musteri_id INTEGER NOT NULL REFERENCES Musteri(id) ON DELETE CASCADE,
  tarih DATE DEFAULT CURRENT_DATE,
  toplam_tutar NUMERIC(12,2) DEFAULT 0 CHECK (toplam_tutar >= 0),
  odeme_turu VARCHAR(50)
);

-- Order details
CREATE TABLE IF NOT EXISTS Siparis_Detay (
  id SERIAL PRIMARY KEY,
  siparis_id INTEGER NOT NULL REFERENCES Siparis(id) ON DELETE CASCADE,
  urun_id INTEGER NOT NULL REFERENCES Urun(id) ON DELETE RESTRICT,
  adet INTEGER NOT NULL CHECK (adet > 0),
  fiyat NUMERIC(10,2) NOT NULL CHECK (fiyat >= 0)
);

-- Indexes for performance on common query columns
CREATE INDEX IF NOT EXISTS idx_urun_kategori ON Urun(kategori_id);
CREATE INDEX IF NOT EXISTS idx_urun_satici ON Urun(satici_id);
CREATE INDEX IF NOT EXISTS idx_siparis_musteri ON Siparis(musteri_id);
CREATE INDEX IF NOT EXISTS idx_siparis_tarih ON Siparis(tarih);
CREATE INDEX IF NOT EXISTS idx_siparisdetay_urun ON Siparis_Detay(urun_id);

COMMIT;

-- Optional: a view showing order line revenue
CREATE OR REPLACE VIEW vw_siparis_line AS
SELECT sd.id AS siparis_detay_id,
       sd.siparis_id,
       sd.urun_id,
       u.ad AS urun_ad,
       sd.adet,
       sd.fiyat,
       (sd.adet * sd.fiyat)::numeric(12,2) AS line_total
FROM Siparis_Detay sd
JOIN Urun u ON u.id = sd.urun_id;

-- Comment: To automatically keep Siparis.toplam_tutar consistent, use a trigger that
-- updates toplam_tutar whenever Siparis_Detay rows are inserted/updated/deleted.

-- Trigger function to recalculate order total
CREATE OR REPLACE FUNCTION fn_recalc_siparis_toplam()
RETURNS TRIGGER AS $$
BEGIN
  -- Recalculate toplam_tutar for the affected order
  UPDATE Siparis
  SET toplam_tutar = (
    SELECT COALESCE(SUM(adet * fiyat),0) FROM Siparis_Detay WHERE siparis_id = COALESCE(NEW.siparis_id, OLD.siparis_id)
  )
  WHERE id = COALESCE(NEW.siparis_id, OLD.siparis_id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for insert, update, delete on Siparis_Detay
DROP TRIGGER IF EXISTS trg_recalc_siparis_after_insert ON Siparis_Detay;
CREATE TRIGGER trg_recalc_siparis_after_insert
AFTER INSERT ON Siparis_Detay
FOR EACH ROW EXECUTE FUNCTION fn_recalc_siparis_toplam();

DROP TRIGGER IF EXISTS trg_recalc_siparis_after_update ON Siparis_Detay;
CREATE TRIGGER trg_recalc_siparis_after_update
AFTER UPDATE ON Siparis_Detay
FOR EACH ROW EXECUTE FUNCTION fn_recalc_siparis_toplam();

DROP TRIGGER IF EXISTS trg_recalc_siparis_after_delete ON Siparis_Detay;
CREATE TRIGGER trg_recalc_siparis_after_delete
AFTER DELETE ON Siparis_Detay
FOR EACH ROW EXECUTE FUNCTION fn_recalc_siparis_toplam();
