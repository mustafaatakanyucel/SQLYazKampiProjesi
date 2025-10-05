-- Reporting and analysis queries for Online Shopping Platform

-- 1) Top 5 customers by number of orders
-- Returns customer id, name and order_count
SELECT m.id, m.ad, m.soyad, COUNT(s.id) AS order_count
FROM Musteri m
LEFT JOIN Siparis s ON s.musteri_id = m.id
GROUP BY m.id, m.ad, m.soyad
ORDER BY order_count DESC
LIMIT 5;

-- 2) Top selling products (by quantity sold)
-- Returns product id, name and total units sold
SELECT u.id, u.ad, COALESCE(SUM(sd.adet),0) AS units_sold
FROM Urun u
LEFT JOIN Siparis_Detay sd ON sd.urun_id = u.id
GROUP BY u.id, u.ad
ORDER BY units_sold DESC
LIMIT 10;

-- 3) Sellers with highest revenue (sum of order lines for their products)
-- Returns seller id, name and total_revenue
SELECT s.id, s.ad, COALESCE(SUM(sd.adet * sd.fiyat),0) AS total_revenue
FROM Satici s
LEFT JOIN Urun u ON u.satici_id = s.id
LEFT JOIN Siparis_Detay sd ON sd.urun_id = u.id
GROUP BY s.id, s.ad
ORDER BY total_revenue DESC
LIMIT 10;

-- Aggregate & Group By examples

-- A) Number of customers by city
SELECT sehir, COUNT(*) AS customer_count
FROM Musteri
GROUP BY sehir
ORDER BY customer_count DESC;

-- B) Total sales by category (revenue)
SELECT k.id, k.ad, COALESCE(SUM(sd.adet * sd.fiyat),0) AS total_sales
FROM Kategori k
LEFT JOIN Urun u ON u.kategori_id = k.id
LEFT JOIN Siparis_Detay sd ON sd.urun_id = u.id
GROUP BY k.id, k.ad
ORDER BY total_sales DESC;

-- C) Orders per month (use date_trunc to group by month)
SELECT to_char(date_trunc('month', tarih), 'YYYY-MM') AS month, COUNT(*) AS orders_count
FROM Siparis
GROUP BY 1
ORDER BY 1;

-- JOINS / Complex queries

-- 1) Orders with customer, product and seller info (expand order details)
SELECT s.id AS siparis_id,
       s.tarih,
       m.id AS musteri_id,
       m.ad || ' ' || m.soyad AS musteri_adi,
       u.id AS urun_id,
       u.ad AS urun_ad,
       sd.adet,
       sd.fiyat,
       sc.id AS satici_id,
       sc.ad AS satici_ad
FROM Siparis s
JOIN Musteri m ON m.id = s.musteri_id
JOIN Siparis_Detay sd ON sd.siparis_id = s.id
JOIN Urun u ON u.id = sd.urun_id
JOIN Satici sc ON sc.id = u.satici_id
ORDER BY s.id;

-- 2) Products never sold
SELECT u.id, u.ad
FROM Urun u
LEFT JOIN Siparis_Detay sd ON sd.urun_id = u.id
WHERE sd.id IS NULL;

-- 3) Customers who never placed an order
SELECT m.id, m.ad, m.soyad, m.email
FROM Musteri m
LEFT JOIN Siparis s ON s.musteri_id = m.id
WHERE s.id IS NULL;

-- HAVING example: Categories with more than X sales
SELECT k.ad, COUNT(sd.id) AS order_lines, SUM(sd.adet * sd.fiyat) AS revenue
FROM Kategori k
JOIN Urun u ON u.kategori_id = k.id
JOIN Siparis_Detay sd ON sd.urun_id = u.id
GROUP BY k.ad
HAVING COUNT(sd.id) > 5
ORDER BY revenue DESC;

-- Advanced (optional) queries

-- 1) Top 3 categories by revenue
SELECT k.id, k.ad, SUM(sd.adet * sd.fiyat) AS revenue
FROM Kategori k
JOIN Urun u ON u.kategori_id = k.id
JOIN Siparis_Detay sd ON sd.urun_id = u.id
GROUP BY k.id, k.ad
ORDER BY revenue DESC
LIMIT 3;

-- 2) Orders with total above average order value
WITH order_totals AS (
  SELECT id, toplam_tutar FROM Siparis
)
SELECT ot.id, ot.toplam_tutar
FROM order_totals ot
WHERE ot.toplam_tutar > (SELECT AVG(toplam_tutar) FROM order_totals)
ORDER BY ot.toplam_tutar DESC;

-- 3) Customers who purchased at least one electronic product (Kategori.ad = 'Elektronik')
SELECT DISTINCT m.id, m.ad, m.soyad, m.email
FROM Musteri m
JOIN Siparis s ON s.musteri_id = m.id
JOIN Siparis_Detay sd ON sd.siparis_id = s.id
JOIN Urun u ON u.id = sd.urun_id
JOIN Kategori k ON k.id = u.kategori_id
WHERE k.ad = 'Elektronik';
