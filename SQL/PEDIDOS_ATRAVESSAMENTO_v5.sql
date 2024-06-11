EXECUTE BLOCK RETURNS (ID_PEDIDO INTEGER, EMPCODIGO INTEGER, DATE_REF DATE,  VRVENDA NUMERIC)

AS
DECLARE VARIABLE i INTEGER;
DECLARE VARIABLE num_days INTEGER;


BEGIN

  num_days = DATEDIFF(DAY, DATEADD(-EXTRACT(DAY FROM CURRENT_DATE) + 1 DAY TO CURRENT_DATE-1), 
  DATEADD(-1 DAY TO CURRENT_DATE));
  
  i = 0;
  
  ----------------------- START LOOP
  WHILE (i <= num_days) DO
  BEGIN
    FOR 
    
      SELECT P.ID_PEDIDO,P.EMPCODIGO ,DATEADD(-:i DAY TO CURRENT_DATE) AS DATE_REF,SUM(PDPUNITLIQUIDO*PDPQTDADE) AS VRVENDA
      FROM PEDID P
     
     -- BLOCO PDRD TBFIS
      INNER JOIN PDPRD PRD ON PRD.ID_PEDIDO=P.ID_PEDIDO
       INNER JOIN TBFIS F ON PRD.FISCODIGO=F.FISCODIGO 
        LEFT JOIN  TPPEDID TP ON P.TPCODIGO = TP.TPCODIGO
   
      
      WHERE 
      FISTPNATOP IN ('V','R','SR') AND
      
      PEDSITPED<>'C' AND
      
      PEDDTEMIS BETWEEN '2024-03-01' AND DATEADD(-:i DAY TO CURRENT_DATE) AND
      
      ---------------------------------------------- ANTI JOIN 
      
      P.ID_PEDIDO NOT IN (
      
      
        SELECT P1.ID_PEDIDO
        FROM PEDID P1
        
        -- BLOCO PDRD TBFIS
         INNER JOIN PDPRD PRD1 ON PRD1.ID_PEDIDO=P1.ID_PEDIDO
          INNER JOIN TBFIS F1 ON PRD1.FISCODIGO=F1.FISCODIGO 
          
        WHERE 
         FISTPNATOP IN ('V','R','SR') AND
         
          PEDSITPED<>'C' AND
         
           PEDDTBAIXA BETWEEN '2024-03-01' AND DATEADD(-:i DAY TO CURRENT_DATE)AND PEDDTEMIS BETWEEN '2024-03-01' AND DATEADD(-:i DAY TO CURRENT_DATE)
        
      )
      
      -------------------------------------------- END ANTI JOIN
      
      GROUP BY P.ID_PEDIDO,P.EMPCODIGO ,DATEADD(-:i DAY TO CURRENT_DATE)
      
    INTO :ID_PEDIDO,:EMPCODIGO, :DATE_REF, :VRVENDA
    DO
      SUSPEND;

    i = i + 1;
  END
END

