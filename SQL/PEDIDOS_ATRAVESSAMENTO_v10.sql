--SQL PEDIDOS ATRAVESSAMENTO

EXECUTE BLOCK RETURNS (ID_PEDIDO INTEGER, 
                        EMPRESA VARCHAR(70), 
                         DATE_REF DATE, 
                          DIA_SEMANA VARCHAR(70),
                           WEEK_NUMBER INTEGER,
                            ANO INTEGER,
                             MES INTEGER,
                              TIPO_PEDIDOS VARCHAR(50), 
                               VRVENDA NUMERIC)

AS
DECLARE VARIABLE i INTEGER;
DECLARE VARIABLE num_days INTEGER;
DECLARE VARIABLE start_date DATE;
DECLARE VARIABLE end_date DATE;


BEGIN

 -- Calculate the start and end date for the current month last year
  start_date ='2023-06-01';
  end_date = '2023-06-30';

  -- Calculate the number of days in the current month last year
  num_days = DATEDIFF(DAY, start_date, end_date); 
  i = 0;
  
  ----------------------- START LOOP
  WHILE (i <= num_days) DO
  BEGIN
    FOR 
    
      SELECT P.ID_PEDIDO,
               TRIM(REPLACE(EMPNOMEFNT,'REPRO -','')) AS EMPRESA,
               DATEADD(:i DAY TO :start_date) AS DATE_REF,
               CASE EXTRACT(WEEKDAY FROM DATEADD(:i DAY TO :start_date))
        WHEN 0 THEN 'DOM'
        WHEN 1 THEN 'SEG'
        WHEN 2 THEN 'TER'
        WHEN 3 THEN 'QUA'
        WHEN 4 THEN 'QUI'
        WHEN 5 THEN 'SEX'
        WHEN 6 THEN 'SAB'
    END AS DIA_SEMANA,
    EXTRACT(WEEK FROM DATEADD(:i DAY TO :start_date)) AS WEEK_NUMBER,
    EXTRACT(YEAR FROM DATEADD(:i DAY TO :start_date)) ANO,
     EXTRACT(MONTH FROM DATEADD(:i DAY TO :start_date))MES,
       CASE 
        WHEN P.TPCODIGO IN (6) THEN 'ATACADÃO'
         WHEN P.TPCODIGO IN (11) AND LEFT(CHAVE,2) IN ('LA','LS') THEN 'ATACADO 11 LA'
          WHEN P.TPCODIGO IN (11) AND LEFT(CHAVE,2) NOT IN ('LA','LS') THEN 'ATACADO 11 BLOCO'
           WHEN P.TPCODIGO IN (15) THEN 'ATACADO 15' 
            WHEN P.TPCODIGO IN (1)  AND LEFT(CHAVE,2) IN ('LA','LS') THEN 'ATACADO 1 LA'
             WHEN P.TPCODIGO IN (1)  AND LEFT(CHAVE,2) NOT IN ('LA','LS') THEN 'ATACADO 1 BLOCO' 
              WHEN P.TPCODIGO IN (12) AND LEFT(CHAVE,2) IN ('LA','LS') THEN '12 LA'
               WHEN P.TPCODIGO IN (12) AND LEFT(CHAVE,2) NOT IN ('LA','LS') THEN '12 SURF' 
                WHEN P.TPCODIGO IN (2, 7, 14) AND LEFT(CHAVE,2) NOT IN ('LA','LS') THEN '2 + 7 + 14'
                 WHEN P.TPCODIGO IN (3,10) AND LEFT(CHAVE,2) IN ('LA','LS') THEN '3 + 10'
                  WHEN P.TPCODIGO IN (5) THEN 'SERVICO'
                   ELSE 'OUTROS' 
                    END AS TIPO_PEDIDOS,
                     SUM(PDPUNITLIQUIDO*PDPQTDADE) AS VRVENDA
                      FROM PEDID P
     
     ------------------- BLOCO PDRD TBFIS
     
      INNER JOIN PDPRD PRD ON PRD.ID_PEDIDO=P.ID_PEDIDO
       INNER JOIN TBFIS F ON PRD.FISCODIGO=F.FISCODIGO 
        LEFT JOIN  TPPEDID TP ON P.TPCODIGO = TP.TPCODIGO
         LEFT JOIN (SELECT PROCODIGO, IIF(PROCODIGO2 IS NULL, PROCODIGO, PROCODIGO2) CHAVE, PROTIPO FROM PRODU WHERE PROTIPO IN ('F','E'))PR ON PR.PROCODIGO=PRD.PROCODIGO
          LEFT JOIN (SELECT EMPCODIGO,EMPNOMEFNT FROM EMPRESA)EP ON P.EMPCODIGO=EP.EMPCODIGO
      
      WHERE 
      
      FISTPNATOP IN ('V','R','SR') AND
      
      PEDLCFINANC IN ('S', 'L','N') AND
      
      PEDSITPED<>'C' AND
      
      PEDDTEMIS BETWEEN '2023-03-01' AND  DATEADD(:i DAY TO :start_date) AND
      
      ---------------------------------------------- ANTI JOIN 
      
      P.ID_PEDIDO NOT IN (
      
        SELECT P1.ID_PEDIDO
        FROM PEDID P1
        
        -- BLOCO PDRD TBFIS
         INNER JOIN PDPRD PRD1 ON PRD1.ID_PEDIDO=P1.ID_PEDIDO
          INNER JOIN TBFIS F1 ON PRD1.FISCODIGO=F1.FISCODIGO 
          
        WHERE 
        
         FISTPNATOP IN ('V','R','SR') AND
         
         PEDLCFINANC IN ('S', 'L','N') AND
         
         PEDSITPED<>'C' AND
         
         PEDDTBAIXA BETWEEN '2023-03-01' AND DATEADD(:i DAY TO :start_date) AND PEDDTEMIS BETWEEN '2023-03-01' AND DATEADD(:i DAY TO :start_date)
      )
      
      -------------------------------------------- END ANTI JOIN
      
      GROUP BY P.ID_PEDIDO,
                EMPRESA,
                 DATE_REF,
                  DIA_SEMANA,
                   WEEK_NUMBER,
                    ANO,
                     MES,
                      TIPO_PEDIDOS
      
    INTO :ID_PEDIDO,:EMPRESA, :DATE_REF,:DIA_SEMANA,:WEEK_NUMBER,:ANO,:MES,:TIPO_PEDIDOS, :VRVENDA
    DO
      SUSPEND;
      
      
      

    i = i + 1;
  END
END