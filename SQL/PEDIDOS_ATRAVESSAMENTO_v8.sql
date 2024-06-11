EXECUTE BLOCK RETURNS (ID_PEDIDO INTEGER, DATE_REF DATE)
AS
DECLARE VARIABLE i INTEGER;
DECLARE VARIABLE num_days INTEGER;

BEGIN
  -- Calculate the number of days from the start of the current month until yesterday
  num_days = DATEDIFF(DAY, DATEADD(-EXTRACT(DAY FROM CURRENT_DATE) + 1 DAY TO CURRENT_DATE - 1), DATEADD(-1 DAY TO CURRENT_DATE));

  i = 0;

  WHILE (i <= num_days) DO
  BEGIN
    -- Query for the current year period
    FOR 
      SELECT P.ID_PEDIDO,
             DATEADD(-:i DAY TO CURRENT_DATE) AS DATE_REF
      FROM PEDID P
      WHERE 
        PEDDTEMIS BETWEEN DATEADD(-EXTRACT(DAY FROM CURRENT_DATE) + 1 DAY TO CURRENT_DATE - 1) AND DATEADD(-:i DAY TO CURRENT_DATE) AND
        P.ID_PEDIDO NOT IN (
          SELECT P1.ID_PEDIDO
          FROM PEDID P1
          WHERE PEDDTBAIXA BETWEEN DATEADD(-EXTRACT(DAY FROM CURRENT_DATE) + 1 DAY TO CURRENT_DATE - 1) AND DATEADD(-:i DAY TO CURRENT_DATE) AND 
                PEDDTEMIS BETWEEN DATEADD(-EXTRACT(DAY FROM CURRENT_DATE) + 1 DAY TO CURRENT_DATE - 1) AND DATEADD(-:i DAY TO CURRENT_DATE)
        )
    INTO :ID_PEDIDO, :DATE_REF
    DO
      SUSPEND;

    -- Query for the last year period
    FOR 
      SELECT P.ID_PEDIDO,
             DATEADD(-:i DAY TO DATEADD(-1 YEAR TO CURRENT_DATE)) AS DATE_REF
      FROM PEDID P
      WHERE 
        PEDDTEMIS BETWEEN DATEADD(-1 YEAR TO DATEADD(-EXTRACT(DAY FROM CURRENT_DATE) + 1 DAY TO CURRENT_DATE - 1)) AND DATEADD(-:i DAY TO DATEADD(-1 YEAR TO CURRENT_DATE)) AND
        P.ID_PEDIDO NOT IN (
          SELECT P1.ID_PEDIDO
          FROM PEDID P1
          WHERE PEDDTBAIXA BETWEEN DATEADD(-1 YEAR TO DATEADD(-EXTRACT(DAY FROM CURRENT_DATE) + 1 DAY TO CURRENT_DATE - 1)) AND DATEADD(-:i DAY TO DATEADD(-1 YEAR TO CURRENT_DATE)) AND 
                PEDDTEMIS BETWEEN DATEADD(-1 YEAR TO DATEADD(-EXTRACT(DAY FROM CURRENT_DATE) + 1 DAY TO CURRENT_DATE - 1)) AND DATEADD(-:i DAY TO DATEADD(-1 YEAR TO CURRENT_DATE))
        )
    INTO :ID_PEDIDO, :DATE_REF
    DO
      SUSPEND;

    i = i + 1;
  END
END
