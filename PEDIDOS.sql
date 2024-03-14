
WITH FIS AS (SELECT FISCODIGO FROM TBFIS WHERE FISTPNATOP IN ('V','R','SR')),
    
    PED AS (SELECT ID_PEDIDO,
                    EMPCODIGO,
                    TPCODIGO,
                     PEDDTEMIS
                      FROM PEDID P
                       INNER JOIN FIS ON P.FISCODIGO1=FIS.FISCODIGO
                        WHERE PEDDTEMIS BETWEEN '01.03.2024' AND 'YESTERDAY' AND PEDSITPED<>'C' AND PEDLCFINANC IN ('S', 'L','N')),
                               
    
      PROD AS (SELECT PROCODIGO,IIF(PROCODIGO2 IS NULL,PROCODIGO,PROCODIGO2)CHAVE,PROTIPO FROM PRODU WHERE PROTIPO IN ('F','E'))

    
    
      SELECT PD.EMPCODIGO,
                        PEDDTEMIS,
                         CASE EXTRACT(WEEKDAY FROM PEDDTEMIS)
    WHEN 0 THEN 'DOM'
    WHEN 1 THEN 'SEG'
    WHEN 2 THEN 'TER'
    WHEN 3 THEN 'QUA'
    WHEN 4 THEN 'QUI'
    WHEN 5 THEN 'SEX'
    WHEN 6 THEN 'SAB'
     END AS DIA_SEMANA,
   EXTRACT(WEEK FROM PEDDTEMIS)WEEK_NUMBER,
                         P.TPCODIGO,
                          TPDESCRICAO,
                           IIF(PR.PROCODIGO IS NOT NULL,1,0) LENTES, 
                            COUNT(DISTINCT(PD.ID_PEDIDO)) QTD_PEDIDOS,
                             SUM(PDPQTDADE)QTD,
                              SUM(PDPUNITLIQUIDO*PDPQTDADE)VRVENDA
                              FROM PDPRD PD
                               INNER JOIN PED P ON PD.ID_PEDIDO=P.ID_PEDIDO
                                LEFT JOIN TPPEDID TP ON P.TPCODIGO=TP.TPCODIGO
                                 LEFT JOIN PROD PR ON PR.PROCODIGO=PD.PROCODIGO 
                                  GROUP BY 1,2,3,4,5,6,7

                               