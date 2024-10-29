CREATE TABLE RIVENDITORI (
CodR varchar(25) NOT NULL PRIMARY KEY,
Citta varchar(25) NOT NULL
);

CREATE TABLE MODELLI (
Modello varchar(25) NOT NULL PRIMARY KEY,
Marca varchar(25) NOT NULL,
Cilindrata int NOT NULL,
Alimentazione varchar(25) NOT NULL,
VelMax int NOT NULL,
PrezzoListino dec(8,2) NOT NULL
);

CREATE TABLE AUTO (
Targa varchar(25) NOT NULL PRIMaRY KEY,
Modello varchar(25) NOT NULL,
CodR varchar(25) NOT NULL,
PrezzoVendita dec(8,2) NOT NULL,
Km int NOT NULL,
Anno int NOT NULL,
Venduta varchar(2),
CHECK (Venduta='SI' OR Venduta IS NULL),
FOREIGN KEY (Modello) REFERENCES MODELLI(Modello) ON DELETE CASCADE,
FOREIGN KEY (CodR) REFERENCES RIVENDITORI(CodR) ON DELETE CASCADE
);

--
-- Script SQL: Dati per l'esercitazione 2 (L02)
--

--
-- Si ringrazia Andrea Masini per il contributo
--

INSERT INTO RIVENDITORI VALUES
('RIV01', 'Venezia'),
('RIV02','Bologna'),
('RIV03','Bologna'),
('RIV04','Rimini')
;

INSERT INTO MODELLI
VALUES
('Agila', 'Opel', 998, 'Benzina', 180, 12000.00),
('Aventador', 'Lamborghini', 6498, 'Benzina', 350, 432729.00),
('Ghibli', 'Maserati', 3799, 'Benzina', 326, 150000.00),
('Stratos', 'Lancia', 2419, 'Benzina', 230, 130000.00);

INSERT INTO AUTO VALUES
('AG123AG', 'Agila', 'RIV03', 10500.00, 50000, 2003, NULL),
('AG234AG', 'Agila', 'RIV03', 9000.00, 70000, 2003, NULL),
('AV456AV', 'Aventador', 'RIV02',430000.00, 0, 2017, NULL),
('AV567AV', 'Aventador', 'RIV02', 400000.00, 0, 2015, 'SI'),
('GH789GH', 'Ghibli', 'RIV01', 90000.00, 0, 2015, 'SI'),
('GH890GH', 'Ghibli', 'RIV02', 100000.00, 30000, 2013, NULL),
('GH901GH', 'Ghibli','RIV03', 70000.00, 50000, 2015, 'SI'),
('ST123ST', 'Stratos', 'RIV04', 80000.00, 15000, 1997, 'SI'),
('ST234ST', 'Stratos','RIV04', 95000.00, 70000, 2012, 'SI');

--Q1) Le Maserati ancora in vendita a Bologna a un prezzo inferiore al 70% del listino
SELECT a.*
FROM AUTO a
JOIN MODELLI m ON m.MODELLO=a.MODELLO
JOIN RIVENDITORI r ON r.CODR=a.CODR
WHERE LOWER(r.CITTA) = 'bologna' AND (a.PREZZOVENDITA
--Q2) Il prezzo medio di un auto a benzina con cilindrata (cc) < 1000, almeno 5 anni di vita e meno di 80000 Km
SELECT AVG(a.PREZZOVENDITA) AS PREZZOMEDIO
FROM AUTO a
JOIN MODELLI m ON (m.MODELLO=a.MODELLO)
WHERE (CILINDRATA<1000) AND ((YEAR(CURRENT DATE)-a.ANNO)>4) AND (a.KM<80000)

--Q3) Per ogni modello con velocità massima > 180 Km/h, il prezzo più basso a Bologna
SELECT MIN(a.PREZZOVENDITA) AS PrezzoMinimo
FROM AUTO a
JOIN MODELLI m ON m.MODELLO=a.MODELLO
JOIN RIVENDITORI r ON r.CODR=a.CODR
WHERE (m.VELMAX > 180) AND LOWER(r.CITTA) = 'bologna'
GROUP BY m.MODELLO

--Q4) Il numero di auto complessivamente trattate e vendute in ogni città
SELECT r.CITTA, COUNT(*) AS NumeroAutoTrattate
FROM RIVENDITORI r
JOIN AUTO a ON (a.CODR=r.CODR)
GROUP BY r.CITTA

SELECT r.CITTA, COUNT(*) AS NumeroAutoVendute
FROM RIVENDITORI r
JOIN AUTO a ON (a.CODR=r.CODR)
WHERE a.VENDUTA IS NOT NULL
GROUP BY r.CITTA

--Q5) I rivenditori che hanno ancora in vendita almeno il 20% delle auto complessivamente trattate,
--ordinando il risultato per città e quindi per codice rivenditore
SELECT r.CodR
FROM RIVENDITORI r
JOIN AUTO a ON (a.CODR=r.CODR)
GROUP BY r.Codr
HAVING count(a.VENDUTA) <= count(*)*0.8

--Q6) I rivenditori che hanno disponibili auto di modelli mai venduti prima da loro
SELECT a.CodR
FROM AUTO a 
GROUP BY a.CODR, a.MODELLO
HAVING COUNT(a.VENDUTA) = 0


--Q7) Per ogni rivenditore, il numero di auto vendute, solo se il prezzo medio di tali auto risulta minore
--di 90000 Euro
SELECT codr, count(*) AS NumeroAutoVendute
FROM AUTO
WHERE VENDUTA = 'SI'
GROUP BY codr
HAVING avg(PREZZOVENDITA)<90000

--Q8) Per ogni auto A, il numero di auto vendute a un prezzo minore di quello di A
SELECT a.TARGA, COUNT(a2.TARGA)
FROM AUTO a
LEFT JOIN AUTO a2 ON a.PREZZOVENDITA > a2.PREZZOVENDITA AND a2.VENDUTA = 'SI'
GROUP BY a.TARGA

--Q9) Per ogni anno e ogni modello, il rapporto medio tra prezzo di vendita e prezzo di listino,
--considerando un minimo di 2 auto vendute
SELECT a.ANNO, AVG(a.PREZZOVENDITA/m.PREZZOLISTINO) AS MediaPrezzo
FROM AUTO a 
JOIN MODELLI m ON m.MODELLO =a.MODELLO 
GROUP BY a.ANNO 
HAVING count(a.VENDUTA) > 1

--Q10) Per ogni modello, i rivenditori che non ne hanno mai trattata una di quel modello
SELECT a.MODELLO, r.CODR AS codice, r.CITTA AS lacity
FROM AUTO a 
CROSS JOIN RIVENDITORI r
EXCEPT
SELECT a.modello, r.codr, r.CITTA
FROM auto a
JOIN RIVENDITORI r ON a.CODR = r.codr 




