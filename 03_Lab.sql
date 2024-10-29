SELECT * FROM EMPLOYEE e

--Q1) Il numero dei dipartimenti con almeno 7 dipendenti
SELECT count(*) AS nDipartimentiCon7Imp
FROM DEPARTMENT d
WHERE 7<=(SELECT count(*)
FROM EMPLOYEE e
WHERE d.DEPTNO = e.workdept)

--Q2) I dati dei dipendenti che lavorano in un dipartimento con almeno 7 dipendenti
SELECT e.*
FROM EMPLOYEE e
WHERE e.WORKDEPT IN
(SELECT d.deptno
FROM DEPARTMENT d
WHERE 7<=(SELECT count(*)
FROM EMPLOYEE e
WHERE d.DEPTNO = e.workdept))

--Q3) I dati del dipartimento con il maggior numero di dipendenti
SELECT d.*
FROM DEPARTMENT d
WHERE (SELECT count(*)
FROM EMPLOYEE e
WHERE d.DEPTNO = e.workdept)
>= ALL
(SELECT count(e2.empno)
FROM EMPLOYEE e2
GROUP BY e2.workdept)

--Q4) Il nome delle regioni e il totale delle vendite per ogni regione con un totale di vendite
--maggiore di 30, ordinando per totale vendite decrescente
SELECT s.REGION, SUM(s.sales) AS totVendite
FROM SALES s
GROUP BY s.REGION
HAVING sum(s.sales)>30
ORDER BY totVendite DESC

--Q5) Lo stipendio medio dei dipendenti che non sono manager di nessun dipartimento
-- JOB = ‘MANAGER’ non è significativo!!
SELECT CAST(AVG(E.SALARY)AS dec(10,2)) AS StipendioMedio
FROM EMPLOYEE e
WHERE e.empno in (SELECT e.empno
FROM EMPLOYEE e
EXCEPT
SELECT DISTINCT d.mgrno
FROM DEPARTMENT d
WHERE d.mgrno IS NOT NULL)

--Q6) I dipartimenti che non hanno dipendenti il cui cognome inizia per ‘L’
SELECT d.*
FROM DEPARTMENT d
WHERE d.deptno NOT IN (
SELECT e2.workdept
FROM EMPLOYEE e2
WHERE LOWER(e2.LASTNAME) LIKE 'l%'
)

--Q7) I dipartimenti e il rispettivo massimo stipendio per tutti i dipartimenti aventi un salario
--medio minore del salario medio calcolato considerando i dipendenti di tutti gli altri
--dipartimenti
SELECT e.WORKDEPT, CAST(max(e.salary) AS dec(10, 0)) AS salarioMassimo
FROM EMPLOYEE e
GROUP BY e.WORKDEPT
HAVING avg(e.SALARY) < (SELECT CAST(avg(e.salary) AS dec(10, 0)) AS salarioMedioTot
FROM EMPLOYEE e)


--Q8) Per ogni dipartimento determinare lo stipendio medio per ogni lavoro per il quale il
--livello di educazione medio è maggiore di quello dei dipendenti dello stesso
--dipartimento che fanno un lavoro differente
SELECT e.WORKDEPT, e.job, avg(e.SALARY * 1.0) AS avgSalary
FROM EMPLOYEE e
GROUP BY e.WORKDEPT , e.JOB
having avg(e.EDLEVEL * 1.0) > (SELECT avg(e2.EDLEVEL)
FROM EMPLOYEE e2
WHERE e2.workdept = e.workdept AND e2.job <> e.job)

--Q9) Lo stipendio medio dei dipendenti che non sono addetti alle vendite
SELECT CAST(avg(e.salary) AS DEC (8, 2))
FROM EMPLOYEE e
WHERE e.LASTNAME IN (SELECT e2.LASTNAME
FROM EMPLOYEE e2
EXCEPT
SELECT DISTINCT s.sales_person
FROM SALES s)

--fede:
SELECT CAST(avg(e.salary) AS DEC (8, 2))
FROM EMPLOYEE e
WHERE e.LASTNAME NOT IN (SELECT s.sales_person
FROM sales s)

--Q10) Per ogni regione, i dati del dipendente che ha il maggior numero di vendite
--(SUM(SALES)) in quella regione
SELECT s.region, s.SALES_PERSON, e.FIRSTNME, e.EMPNO, e.WORKDEPT, sum(s.sales) AS Vendite
FROM sales s
JOIN EMPLOYEE e ON LOWER(s.SALES_PERSON) = LOWER(e.LASTNAME)
GROUP BY s.REGION, s.SALES_PERSON, e.FIRSTNME, e.EMPNO, e.WORKDEPT 
HAVING sum(s.sales) >= all (SELECT sum(s2.sales) AS Vendite
FROM sales s2
GROUP BY s2.region, s2.sales_Person
HAVING s2.region=s.region)
--!! SQL non permette di mettere aggregati come e.* in GROUP BY, 
--quindi bisogna specificare per ogni colonna

--Q11) I codici dei dipendenti che svolgono un’attività per la quale ogni tupla di EMPPROJACT
--riguarda un periodo minore di 200 giorni
SELECT e.EMPNO, CAST((e.EMENDATE-e.EMSTDATE) AS DEC(10,2)) AS GiorniAttivita
FROM EMPPROJACT e
GROUP BY e.EMPNO, e.EMSTDATE, e.EMENDATE 
HAVING 200 > e.EMENDATE-e.EMSTDATE

--Q12) Le attività, e il codice del relativo dipartimento, svolte da dipendenti di un solo
--dipartimento
SELECT e.ACTNO, p.DEPTNO
FROM EMPPROJACT e 
JOIN PROJECT p ON e.PROJNO = p.PROJNO 
WHERE e.ACTNO NOT IN (
    SELECT e.ACTNO 
    FROM EMPPROJACT e
    JOIN PROJECT p ON e.PROJNO = p.PROJNO
    GROUP BY e.ACTNO
    HAVING COUNT(DISTINCT p.DEPTNO) > 1
)
GROUP BY e.ACTNO, p.DEPTNO




