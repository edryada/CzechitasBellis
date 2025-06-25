-- TVORBA ČÍSLENÍKŮ
-- Číselník pohlaví 
CREATE OR REPLACE TABLE L0_CIS_POHLAVI (
    ID NUMBER(1,0) PRIMARY KEY,
    POPIS VARCHAR(10)
);

INSERT INTO L0_CIS_POHLAVI (ID, POPIS) VALUES
(1, 'muž'),
(2, 'žena');

select * from L0_CIS_POHLAVI;

------------------------------------------------------------------------------------------------------------------
-- Číselník kraje
CREATE OR REPLACE TABLE L0_CIS_KRAJE (
    KOD VARCHAR(5) PRIMARY KEY,
    NAZEV VARCHAR(100)
);

INSERT INTO L0_CIS_KRAJE (KOD, NAZEV) VALUES
('CZ010', 'Hlavní město Praha'),
('CZ020', 'Středočeský kraj'),
('CZ031', 'Jihočeský kraj'),
('CZ032', 'Plzeňský kraj'),
('CZ041', 'Karlovarský kraj'),
('CZ042', 'Ústecký kraj'),
('CZ051', 'Liberecký kraj'),
('CZ052', 'Královéhradecký kraj'),
('CZ053', 'Pardubický kraj'),
('CZ063', 'Kraj Vysočina'),
('CZ064', 'Jihomoravský kraj'),
('CZ071', 'Olomoucký kraj'),
('CZ072', 'Zlínský kraj'),
('CZ080', 'Moravskoslezský kraj');

select * from L0_CIS_KRAJE;

-------------------------------------------------------------------------------------------------------------------
-- Číselník skupin diagnóz
CREATE OR REPLACE TABLE L0_CIS_DIAG_SKUPINY (
    ID NUMBER(2,0) PRIMARY KEY,
    POPIS VARCHAR(255)
);

INSERT INTO L0_CIS_DIAG_SKUPINY (ID, POPIS) VALUES
(1, 'ZN hlavy a krku (C00–C14, C30–C31)'),
(2, 'ZN jícnu (C15)'),
(3, 'ZN žaludku (C16)'),
(4, 'ZN tlustého střeva a konečníku (C18–C20)'),
(5, 'ZN jater a intrahepatálních žlučových cest (C22)'),
(6, 'ZN žlučníku a žlučových cest (C23, C24)'),
(7, 'ZN slinivky břišní (C25)'),
(8, 'ZN hrtanu (C32)'),
(9, 'ZN průdušnice, průdušky a plíce (C33, C34)'),
(10, 'Zhoubný melanom kůže (C43)'),
(11, 'Nemelanomový kožní ZN (C44)'),
(12, 'ZN pojivových a měkkých tkání a periferních nervů (C47, C49)'),
(13, 'ZN prsu (C50)'),
(14, 'ZN hrdla děložního (C53)'),
(15, 'ZN dělohy (C54, C55)'),
(16, 'ZN vaječníku (C56)'),
(17, 'ZN prostaty (C61)'),
(18, 'ZN varlete (C62)'),
(19, 'ZN ledviny (C64)'),
(20, 'ZN močového měchýře (C67)'),
(21, 'ZN mozku, míchy a jiných částí CNS (C70–C72)'),
(22, 'ZN štítné žlázy (C73)'),
(23, 'Hodgkinův lymfom (C81)'),
(24, 'Non-Hodgkinův lymfom (C82–C86)'),
(25, 'Mnohočetný myelom (C90)'),
(26, 'Leukémie (C91–C95)'),
(27, 'Ostatní zhoubné novotvary'),
(28, 'Novotvary in situ (D00–D09)'),
(29, 'Novotvary nezhoubné a neznámého chování (D10–D36, D37–D48)');

select * from L0_CIS_DIAG_SKUPINY;

-----------------------------------------------------------------------------------------------------------------
-- Číselník stadium
CREATE OR REPLACE TABLE L0_CIS_STADIUM (
    KOD VARCHAR(1) PRIMARY KEY,
    POPIS VARCHAR(255)
);

INSERT INTO L0_CIS_STADIUM (KOD, POPIS) VALUES
('1', 'Stadium I'),
('2', 'Stadium II'),
('3', 'Stadium III'),
('4', 'Stadium IV'),
('X', 'Stadium neuvedeno'),
('Y', 'Chybějící údaj o stadiu');

select * from L0_CIS_STADIUM;

------------------------------------------------------------------------------------------------------------------
-- Číselník úmrtí
CREATE OR REPLACE TABLE L0_CIS_UMRTI (
    KOD NUMBER(1,0) PRIMARY KEY,
    POPIS VARCHAR(10)
);

INSERT INTO L0_CIS_UMRTI (KOD, POPIS) VALUES
(0, 'žije'),
(1, 'zemřel');

select * from L0_CIS_UMRTI;
-------------------------------------------------------------------------------
-- Číselník první další
CREATE OR REPLACE TABLE L0_CIS_PORADI (
    ID NUMBER(1,0) PRIMARY KEY,
    POPIS VARCHAR(10)
);

INSERT INTO L0_CIS_PORADI (ID, POPIS) VALUES
(1, 'první'),
(2, 'další');

select * from L0_CIS_PORADI;
-------------------------------------------------------------------------------------------------------------------

-- VRSTVA L1
-- L1_INCIDENCE
-- (měníme datový typ na integer a vybíráme pouze ženské pacienty přes "diagnoza_skupina")
CREATE OR REPLACE TABLE L1_INCIDENCE AS
SELECT 
  "id"
  , "pohlavi" :: int as "pohlavi"
  , "kraj_kod"
  , "diagnoza_kod"
  , "diagnoza_skupina" :: int as "diagnoza_skupina"
  , "novotvar_poradi" :: int as "novotvar_poradi"
  , "novotvar_poradi_dg" :: int as "novotvar_poradi_dg"
  , "novotvar_poradi_dg_skupina" :: int as "novotvar_poradi_dg_skupina"
  , "novotvar_poradi_maligni" :: int as "novotvar_poradi_maligni"
  , "novotvar_poradi_maligni_bez_C44" :: int as "novotvar_poradi_maligni_bez_C44"
  , "stadium"
  , "rok_dg"
  , "vek_kategorie_kod_dg" :: int as "vek_kategorie_kod_dg"
  , "umrti_rok"
  , "vek_kategorie_kod_umrti"
  , "umrti"
FROM l0_nor_inc_prev_do_2022
WHERE "diagnoza_skupina" = 13; /* Obsahuje pouze ženy s rakovinou prsu. Ženy i muži s rakovinou prsu jsou obsažení v diagnoza_kod = C50. */
-------------------------------------------------------------------------------------------------------------------

-- L1_POPULACE
CREATE OR REPLACE TABLE L1_POPULACE AS
SELECT *
FROM l0_populace_vek;
------------------------------------------------------------------------------------------------------------------

-- L1_CIS_VEK_SKUP
-- (očištění číselníku od nepotřebných sloupců, vek_kod jako integer)
CREATE OR REPLACE TABLE L1_CIS_VEK_SKUP AS
select 
    "vek_kod" :: int as VEK_KOD, 
    "vek_nazev" as VEK_NAZEV
from l0_ciselnik_vek_skup_nzis;
----------------------------------------------------------------------------------------------------------------

-- VRSTVA L2
-- L2_INCIDENCE
-- (napojujeme číselníky pro vizualizace v Tableau)
CREATE OR REPLACE TABLE L2_INCIDENCE AS
SELECT
    INC."id" AS ID,
    INC."diagnoza_kod" AS DIAGNOZA_KOD,
    DIAGNOZA.POPIS AS DIAGNOZA,
    KRAJ.NAZEV AS KRAJ,
    POHLAVI.POPIS AS POHLAVI,
    PORADI.POPIS AS PORADI,
    PORADI_DG.POPIS AS PORADI_DG,
    PORADI_DG_SKUPINA.POPIS AS PORADI_DG_SKUPINA,
    PORADI_MALIGNI.POPIS AS PORADI_MALIGNI,
    STADIUM.POPIS AS STADIUM,
    INC."rok_dg" AS ROK_DG,
    VEK_DG.VEK_NAZEV AS VEK_DG,
    
    -- TADY: umrti_rok nastavíme jen pokud úmrtí existuje
    CASE 
      WHEN UMRTI.KOD IS NULL THEN NULL
      ELSE NULLIF(INC."umrti_rok", '')
    END AS UMRTI_ROK,

    VEK_UMRTI.VEK_NAZEV AS VEK_UMRTI,
    UMRTI.POPIS AS UMRTI

FROM L1_INCIDENCE AS INC
LEFT JOIN L0_CIS_DIAG_SKUPINY AS DIAGNOZA ON INC."diagnoza_skupina" = DIAGNOZA.ID
LEFT JOIN L0_CIS_KRAJE AS KRAJ ON INC."kraj_kod" = KRAJ.KOD
LEFT JOIN L0_CIS_POHLAVI AS POHLAVI ON INC."pohlavi" = POHLAVI.ID
LEFT JOIN L0_CIS_PORADI AS PORADI ON INC."novotvar_poradi" = PORADI.ID
LEFT JOIN L0_CIS_PORADI AS PORADI_DG ON INC."novotvar_poradi_dg" = PORADI_DG.ID
LEFT JOIN L0_CIS_PORADI AS PORADI_DG_SKUPINA ON INC."novotvar_poradi_dg" = PORADI_DG_SKUPINA.ID
LEFT JOIN L0_CIS_PORADI AS PORADI_MALIGNI ON INC."novotvar_poradi_maligni" = PORADI_MALIGNI.ID
LEFT JOIN L0_CIS_STADIUM AS STADIUM ON INC."stadium" = STADIUM.KOD
LEFT JOIN L1_CIS_VEK_SKUP AS VEK_DG ON INC."vek_kategorie_kod_dg" = VEK_DG.VEK_KOD
LEFT JOIN L1_CIS_VEK_SKUP AS VEK_UMRTI ON NULLIF(INC."vek_kategorie_kod_umrti",'') = VEK_UMRTI.VEK_KOD
LEFT JOIN L0_CIS_UMRTI AS UMRTI ON INC."umrti" = UMRTI.KOD;
---------------------------------------------------------------------------------------------------------------------------

--- L2_POPULACE
CREATE OR REPLACE TABLE L2_POPULACE AS
SELECT
    POP.ROK AS ROK, 
    KRAJ.NAZEV AS KRAJ, 
    SUM(POP.POCET_OBYVATEL:: INT) AS POCET_OBYVATEL,
    CASE 
        WHEN POP.VEK IS NULL THEN 'NEZNÁMÁ'
        WHEN POP.VEK >= 85 THEN '85 let a více'
        WHEN POP.VEK >= 80 THEN '80–84 let'
        WHEN POP.VEK >= 75 THEN '75–79 let'
        WHEN POP.VEK >= 70 THEN '70–74 let'
        WHEN POP.VEK >= 65 THEN '65–69 let'
        WHEN POP.VEK >= 60 THEN '60–64 let'
        WHEN POP.VEK >= 55 THEN '55–59 let'
        WHEN POP.VEK >= 50 THEN '50–54 let'
        WHEN POP.VEK >= 45 THEN '45–49 let'
        WHEN POP.VEK >= 40 THEN '40–44 let'
        WHEN POP.VEK >= 35 THEN '35–39 let'
        WHEN POP.VEK >= 30 THEN '30–34 let'
        WHEN POP.VEK >= 25 THEN '25–29 let'
        WHEN POP.VEK >= 20 THEN '20–24 let'
        WHEN POP.VEK >= 15 THEN '15–19 let'
        WHEN POP.VEK >= 10 THEN '10–14 let'
        WHEN POP.VEK >= 5 THEN '5–9 let'
        ELSE '0–4 let'
    END AS VEKOVA_SKUPINA, /* rozřazení jednotlivých let do 5tiletých věkových skupin*/

FROM L1_POPULACE AS POP
LEFT JOIN L0_CIS_KRAJE AS KRAJ ON POP.KOD_KRAJE = KRAJ.KOD

GROUP BY VEKOVA_SKUPINA, POP.ROK, KRAJ
HAVING POP.ROK BETWEEN '2008' AND '2022'/* vynechání roku 2023*/
ORDER BY POP.ROK, VEKOVA_SKUPINA, KRAJ;
-----------------------------------------------------------------------------------------------------------------------------------

-- L2_MORTALITA
CREATE OR REPLACE TABLE L2_MORTALITA AS
SELECT 
    "id" as ID,
    KRAJ.NAZEV AS KRAJ,
    "umrti_rok" AS ROK_UMRTI,
    VEK_UMRTI.VEK_NAZEV AS VEK_UMRTI
FROM L0_NOR_MORTALITA_DO_2022 MOR
    LEFT JOIN L0_CIS_KRAJE AS KRAJ ON MOR."kraj_kod" = KRAJ.KOD
    LEFT JOIN L1_CIS_VEK_SKUP AS VEK_UMRTI ON NULLIF(MOR."umrti_vek_kategorie_kod",'') = VEK_UMRTI.VEK_KOD
WHERE "pohlavi" = 2 AND "diagnoza_skupina" = 13;
----------------------------------------------------------------------------------------------------------------------------

-- VRSTVA L2 GROUP
-- L2 INCIDENCE_GROUP
-- (sjednocujeme granulaitu s L2_POPULACE)
CREATE OR REPLACE TABLE L2_INCIDENCE_GROUP AS
SELECT 
    ROK_DG, 
    KRAJ, 
    VEK_DG,
    STADIUM,
    COUNT(*) AS POCET_PRIPADU
FROM L2_INCIDENCE 
GROUP BY ROK_DG, KRAJ, VEK_DG, STADIUM
ORDER BY ROK_DG, KRAJ, VEK_DG, STADIUM;
--------------------------------------------------------------------------------------------------------------

-- L2 MORTALITA_GROUP
-- (sjednocujeme granulaitu s L2_POPULACE)
CREATE OR REPLACE TABLE L2_MORTALITA_GROUP AS
SELECT
    ROK_UMRTI,
    KRAJ, 
    VEK_UMRTI, 
    COUNT(*) AS POCET_PRIPADU
FROM L2_MORTALITA
GROUP BY ROK_UMRTI, KRAJ, VEK_UMRTI
ORDER BY ROK_UMRTI, KRAJ, VEK_UMRTI;
----------------------------------------------------------------------------------------------------------------

-- VÝPOČET PREVALENCE
-- ROKY
CREATE OR REPLACE TABLE ROKY (ROK INT);

INSERT INTO ROKY (ROK)
VALUES 
  (2008), (2009), (2010), (2011), (2012), (2013), (2014),
  (2015), (2016), (2017), (2018), (2019), (2020),
  (2021), (2022);
-----------------------------------------------------------------------------------------------------------

-- L2_PREVALENCE
CREATE OR REPLACE TABLE L2_PREVALENCE AS 
WITH ROKY AS (
  SELECT DISTINCT(rok_dg) AS ROK FROM L2_INCIDENCE
)
SELECT
  r.ROK AS rok,
  i.kraj,
  i.vek_dg AS vekova_skupina,
  COUNT(*) AS prevalence,
FROM
  ROKY r
JOIN L2_INCIDENCE i ON i.rok_dg <= r.ROK AND (i.UMRTI_ROK IS NULL OR i.UMRTI_ROK > r.ROK)
GROUP BY
  r.ROK, i.kraj, i.vek_dg
ORDER BY
  r.ROK, i.kraj, i.vek_dg;
-------------------------------------------------------------------------------------------------------------

-- L2_PREVALENCE_POP
CREATE OR REPLACE TABLE L2_PREVALENCE_POP AS 
SELECT
  p.rok, p.kraj, p.vekova_skupina,
  SUM(IFNULL(pk.prevalence, 0)) AS prevalence,
  SUM(p.pocet_obyvatel) AS pocet_obyvatel,
  SUM(IFNULL(pk.prevalence, 0))/SUM(p.pocet_obyvatel)*1e5 AS prevalence_100k
FROM L2_POPULACE p
LEFT JOIN L2_PREVALENCE pk ON p.rok = pk.rok AND p.kraj = pk.kraj AND p.vekova_skupina = pk.vekova_skupina
GROUP BY p.rok, p.kraj, p.vekova_skupina
ORDER BY p.rok, p.kraj, p.vekova_skupina
