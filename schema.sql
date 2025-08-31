
CREATE TABLE "kategorie"(
    "id" INTEGER,
    "kategoria" TEXT NOT NULL UNIQUE,
    PRIMARY KEY ("id")
);


CREATE TABLE "zarobki"(
    "miesiac" INTEGER NOT NULL,
    "rok" INTEGER NOT NULL,
    "zarobki" REAL NOT NULL
);


CREATE TABLE "inwestycje" (
    "data" NUMERIC,
    "aktywa" TEXT,
    "ilosc" REAL,
    "wartosc (za jednostke, PLN)" REAL,
    "wartosc calkowita" REAL
);


CREATE TABLE "wydatki"(
    "id" INTEGER,
    "produkt" TEXT,
    "kategoria_id" INTEGER,
    "ilosc" REAL,
    "cena" REAL,
    "rabat" REAL,
    "data" NUMERIC,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("kategoria_id") REFERENCES "kategorie"("id")
);


CREATE TABLE summary (
    "miesiac" INTEGER,
    "rok" INTEGER,
    "zarobki (PLN)" REAL,
    "wydatki (PLN)" REAL,
    "inwestycje (PLN)" REAL,
    "oszczednosci (PLN)" REAL
);

--- importing data into wydatki and inwestycje tables

.import --csv --skip 1 sql_project_expenses.csv "wydatki"

.import --csv --skip 1 sql_investments.csv "inwestycje"



--- summing up the investments and grouping by month and year
CREATE VIEW "inwestycje_suma_miesieczna" AS
SELECT
    substr("data", 4, 2) AS "miesiac",
    substr("data", 7, 4) AS "rok",
    printf('%.2f', SUM("wartosc calkowita (PLN)")) AS "suma miesieczna"
FROM "inwestycje"
GROUP BY "rok", "miesiac"
ORDER BY "rok" DESC, "miesiac" DESC;



--- expense per month on a given year
CREATE VIEW "wydatki_suma_miesieczna" AS
SELECT
    substr(data, 7, 4) AS "rok",
    substr(data, 4, 2) AS "miesiac",
    printf('%.2f', SUM(cena)) AS "suma miesieczna"
FROM "wydatki"
GROUP BY "rok", "miesiac"
ORDER BY "rok" DESC, "miesiac" DESC;


--- a ratio of investments to earnings
CREATE VIEW inwestycje_vs_zarobki AS
SELECT
    z.miesiac,
    z.rok,
    printf('%.2f', z.suma_zarobkow) AS "zarobki (PLN)",
    printf('%.2f', IFNULL(i.suma_inwestycji, 0)) AS "inwestycje (PLN)",
    printf('%.2f', IFNULL(i.suma_inwestycji, 0) / z.suma_zarobkow) AS "inwestycje/zarobki"
FROM (
    SELECT
        substr("data", 4, 2) AS miesiac,
        substr("data", 7, 4) AS rok,
        SUM("wartosc calkowita (PLN)") AS suma_inwestycji
    FROM inwestycje
    GROUP BY rok, miesiac
) i
RIGHT JOIN (
    SELECT
        printf('%02d', miesiac) AS miesiac,
        rok,
        SUM("zarobki") AS suma_zarobkow
    FROM zarobki
    GROUP BY rok, miesiac
) z
ON z.rok = i.rok AND z.miesiac = i.miesiac
ORDER BY z.rok DESC, z.miesiac DESC;


--- a ratio of expenses to earnings
CREATE VIEW wydatki_vs_zarobki AS
SELECT
    z.miesiac,
    z.rok,
    printf('%.2f', z.suma_zarobkow) AS "zarobki (PLN)",
    printf('%.2f', IFNULL(w.suma_wydatki, 0)) AS "wydatki (PLN)",
    printf('%.2f', IFNULL(w.suma_wydatki, 0) / z.suma_zarobkow) AS "wydatki/zarobki"
FROM (
    SELECT
        substr("data", 4, 2) AS miesiac,
        substr("data", 7, 4) AS rok,
        SUM("cena") AS suma_wydatki
    FROM wydatki
    GROUP BY rok, miesiac
) w
RIGHT JOIN (
    SELECT
        printf('%02d', miesiac) AS miesiac,
        rok,
        SUM("zarobki") AS suma_zarobkow
    FROM zarobki
    GROUP BY rok, miesiac
) z
ON z.rok = w.rok AND z.miesiac = w.miesiac
ORDER BY z.rok DESC, z.miesiac DESC;
