--- ZAROBKI (earnings)

--- selecting all earnings
SELECT * FROM "zarobki" ORDER BY "rok" DESC, "miesiac" DESC;

--- selecting all earnings from a given year
SELECT * FROM "zarobki" WHERE "rok" = 2024;

--- average earnings by year
SELECT "rok", ROUND(AVG("zarobki"), 2) AS "srednie zarobki" FROM "zarobki" GROUP BY "rok" ORDER BY "rok" DESC;

--- sum of earnings by year
SELECT "rok", printf('%.2f', SUM("zarobki")) AS "suma zarobkow" FROM "zarobki" GROUP BY "rok" ORDER BY "rok" DESC;

--- inserting monthly earnings into the table
INSERT INTO "zarobki" ("miesiac", "rok", "zarobki")
VALUES
(07, 2024, 2940.00), (08, 2024, 5520.20), (09, 2024, 7850.00), (10, 2024, 8298.40), (11, 2024, 7544.80), (12, 2024, 6804.40),
(01, 2025, 7023.00), (02, 2025, 7524.40), (03, 2025, 7385.00), (04, 2025, 7016.27), (05, 2025, 6749.50), (06, 2025, 10140.00), (7,2025,6000.00);


--- KATEGORIE (categories)

--- inserting categories into the 'kategorie' table
INSERT INTO "kategorie"("id", "kategoria")
VALUES
(1, 'Jedzenie'), (2, 'Ubrania'), (3, 'Higiena'), (4, 'Dom'), (5, 'AGD'), (6, 'Kosmetyki'),
(7, 'Rozrywka'), (8, 'Prezenty'), (9, 'Edukacja'), (10, 'Komunikacja'), (11, 'Różne'), (12, 'Naprawy'), (13, 'Oplaty');


--- WYDATKI (expenses)

--- selecting all the data about products from a given category
SELECT * FROM "wydatki" WHERE "kategoria_id" = (
    SELECT "id" FROM "kategorie" WHERE "kategoria" = 'Jedzenie'
);


--- selecting all of the spendings (opłaty) for the apartment
SELECT substr(data, 4, 2) AS miesiac,
       substr(data, 7, 4) AS rok,
       "produkt",
       "cena"
FROM "wydatki" WHERE "produkt" LIKE 'Opłaty%';

--- summing up all of the spendings (opłaty) for the apartment
SELECT substr(data, 7, 4) AS "rok",
       printf('%.2f', SUM("cena")) AS "suma opłat"
FROM "wydatki"
WHERE "produkt" LIKE 'Opłaty%'
GROUP BY "rok" ORDER BY "rok" DESC;

--- how much was saved on discounts
SELECT
    substr(data, 7, 4) AS rok,
    substr(data, 4, 2) AS miesiac,
    printf('%.2f', SUM(rabat)) AS suma_rabat
FROM wydatki
GROUP BY rok, miesiac
ORDER BY rok, miesiac;


--- INWESTYCJE (investments)

--- summing up all the investments
SELECT printf('%.2f', SUM("wartosc calkowita (PLN)")) AS "suma inwestycji" FROM "inwestycje";

--- summing up the investments and grouping by year
SELECT
  substr("data", 7, 4) AS "rok",
  printf('%.2f', SUM("wartosc calkowita (PLN)")) AS "suma inwestycji"
FROM "inwestycje"
GROUP BY "rok"
ORDER BY "rok" DESC;

--- selecting all the data from a certain month of a certain year
SELECT * FROM "inwestycje" WHERE substr("data", 4, 2) = '03' AND substr("data", 7, 4) = "2025";


--- SUMMARY

--- inserting data into the table summary

INSERT INTO "summary" ("miesiac", "rok", "zarobki (PLN)", "wydatki (PLN)", "inwestycje (PLN)", "oszczednosci (PLN)")
SELECT
    "zarobki"."miesiac",
    "zarobki"."rok",
    IFNULL("zarobki"."zarobki", 0),
    IFNULL("wydatki_suma_miesieczna"."suma miesieczna", 0),
    IFNULL("inwestycje_suma_miesieczna"."suma miesieczna", 0),
    "zarobki"."zarobki" - IFNULL("wydatki_suma_miesieczna"."suma miesieczna", 0) - IFNULL("inwestycje_suma_miesieczna"."suma miesieczna", 0)
FROM "zarobki"
LEFT JOIN "wydatki_suma_miesieczna" ON "wydatki_suma_miesieczna"."miesiac" = "zarobki"."miesiac"
LEFT JOIN "inwestycje_suma_miesieczna" ON "inwestycje_suma_miesieczna"."miesiac" = "zarobki"."miesiac"
ORDER BY "zarobki"."rok" DESC, "zarobki"."miesiac" DESC;


--- displaying data from summary table (for the numbers to have always 2 decimal places)

SELECT
    "miesiac",
    "rok",
    printf('%.2f', "zarobki (PLN)")      AS "zarobki (PLN)",
    printf('%.2f', "wydatki (PLN)")     AS "wydatki (PLN)",
    printf('%.2f', "inwestycje (PLN)")   AS "inwestycje (PLN)",
    printf('%.2f', "oszczednosci (PLN)") AS "oszczednosci (PLN)"
FROM "summary";
