WITH FIS AS (SELECT FISCODIGO FROM TBFIS WHERE FISTPNATOP IN ('V','R','SR')),
    
    PED AS (SELECT ID_PEDIDO,
                    EMPCODIGO,
                    TPCODIGO,
                     PEDDTBAIXA
                      FROM PEDID P
                        WHERE (PEDDTBAIXA BETWEEN (CURRENT_DATE) - EXTRACT(DAY FROM (CURRENT_DATE)) + 1 AND 'TODAY' OR
  PEDDTBAIXA BETWEEN DATEADD(-1 YEAR TO (CURRENT_DATE) - EXTRACT(DAY FROM CURRENT_DATE) + 1)
AND DATEADD(-1 YEAR TO (CURRENT_DATE) - EXTRACT(DAY FROM CURRENT_DATE) + 32 - 
EXTRACT(DAY FROM (CURRENT_DATE) - EXTRACT(DAY FROM (CURRENT_DATE)) + 32)))  AND PEDSITPED<>'C' AND PEDLCFINANC IN ('S', 'L','N') AND TPCODIGO<>13),
                               
    
      PROD AS (SELECT PROCODIGO,IIF(PROCODIGO2 IS NULL,PROCODIGO,PROCODIGO2)CHAVE,PROTIPO FROM PRODU WHERE PROTIPO IN ('F','E'))

    
    
      SELECT PD.EMPCODIGO,
          TRIM(REPLACE((SELECT EMPNOMEFNT FROM EMPRESA WHERE EMPCODIGO=PD.EMPCODIGO),'REPRO -','')) EMPRESA,
                        PEDDTBAIXA,
                         CASE EXTRACT(WEEKDAY FROM PEDDTBAIXA)
    WHEN 0 THEN 'DOM'
    WHEN 1 THEN 'SEG'
    WHEN 2 THEN 'TER'
    WHEN 3 THEN 'QUA'
    WHEN 4 THEN 'QUI'
    WHEN 5 THEN 'SEX'
    WHEN 6 THEN 'SAB'
     END AS DIA_SEMANA,
   EXTRACT(WEEK FROM PEDDTBAIXA)WEEK_NUMBER,
                         P.TPCODIGO,
                          TPDESCRICAO,
                         CASE 
                         WHEN P.TPCODIGO IN (6) THEN 'ATACADAO'
                          WHEN P.TPCODIGO IN (1,11,15) THEN 'ATACADO'
                           WHEN P.TPCODIGO IN (2, 7, 12) THEN 'LENTES SURFAÇADAS'
                            WHEN P.TPCODIGO IN (3,10,12) THEN 'LENTES PRONTAS'
                             WHEN P.TPCODIGO IN (5) THEN 'SERVICO'
                             ELSE 'OUTROS' END TIPO_PEDIDOS,
                            
                           IIF(PR.PROCODIGO IS NOT NULL,1,0) LENTES, 
                            COUNT(DISTINCT(PD.ID_PEDIDO)) QTD_PEDIDOS,
                             SUM(PDPQTDADE)QTD,
                              SUM(PDPUNITLIQUIDO*PDPQTDADE)VRVENDA
                              FROM PDPRD PD
                               INNER JOIN PED P ON PD.ID_PEDIDO=P.ID_PEDIDO
                                INNER JOIN FIS F ON Pd.FISCODIGO=F.FISCODIGO
                                 LEFT JOIN TPPEDID TP ON P.TPCODIGO=TP.TPCODIGO
                                 LEFT JOIN PROD PR ON PR.PROCODIGO=PD.PROCODIGO 
                                  GROUP BY 1,2,3,4,5,6,7,8,9

