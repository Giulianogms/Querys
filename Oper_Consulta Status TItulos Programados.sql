SELECT * FROM

(SELECT  DISTINCT A.NROEMPRESA EMPRESA, A.NROTITULO||CASE WHEN A.SERIETITULO IS NULL THEN NULL ELSE ' - ' END||A.SERIETITULO TITULO,A.CODESPECIE ESPECIE, A.NOMERAZAO PESSOA,
        CASE WHEN FC.CODBARRA IS NULL THEN 'Não' ELSE 'Sim' END CODBARRAS,
        CASE WHEN A.NOMERAZAO LIKE '%RH%' THEN 'RH - '||A.CODESPECIE
          WHEN UPPER(C.OBSERVACAO) LIKE '%CANCELADO%' OR UPPER(C.OBSERVACAO) LIKE '%REJEITADO%' THEN 'Cancelado - '||(REGEXP_SUBSTR (C.OBSERVACAO,'[^.]+', 1, 1))
          WHEN C.OBSERVACAO LIKE '%Título autorizado para pagamento%' THEN 'Autorizado para pagamento - Não Programado'
          ELSE CASE WHEN UPPER(CC.DESCRICAO) LIKE '%ALTER_CAO%' THEN 'Alterado - Não Programado' ELSE NULL END||
        CASE WHEN C.USUALTERACAO = 'JOBPAGTO' THEN NULL ELSE ' - Usuario: '||C.USUALTERACAO||' - ' END||(REGEXP_SUBSTR (C.OBSERVACAO,'[^.]+', 1, 1))
          END STATUS_TITULO, 
          TO_CHAR(A.DTAPROGRAMADA, 'DD-MM-YYYY') DTAPROGRAMADA, 
        TO_CHAR(A.VLRORIGINAL, 'FM999G999G999D90', 'nls_numeric_characters='',.''') VLR_OGIRINAL,
        TO_CHAR((A.VLRORIGINAL - A.VLRDESCFIN  - A.VLRPAGO), 'FM999G999G999D90', 'nls_numeric_characters='',.''') VLR_LIQUIDO, 'A' A, NULL P
  
FROM  CONSINCO.FIV_TITULOS_EM_ABERTO A LEFT JOIN CONSINCO.FI_PROGPAGAMENTO B ON A.SEQTITULO = B.SEQTITULO
                                       LEFT JOIN(SELECT * FROM (
                                                SELECT  ROW_NUMBER() OVER(PARTITION BY FI_MOVOCOR.SEQIDENTIFICA ORDER BY DTAHORA DESC) ODR, 
                                                        FI_OCRFINANC.DESCRICAO, FI_MOVOCOR.SEQPESSOA, FI_MOVOCOR.CODOCORRENCIA, FI_MOVOCOR.SEQIDENTIFICA, 
                                                        FI_MOVOCOR.OBSERVACAO, FI_MOVOCOR.USUALTERACAO
                                                FROM    CONSINCO.FI_MOVOCOR, CONSINCO.FI_OCRFINANC
                                                WHERE   FI_MOVOCOR.CODOCORRENCIA NOT IN (802,78,77,76,75,69,68,67,66,63,62,60,57,38,26,13,5)                      
                                                AND     FI_MOVOCOR.CODOCORRENCIA = FI_OCRFINANC.CODOCORRENCIA 

                                                ORDER BY 1 DESC)) C ON C.SEQIDENTIFICA = A.SEQTITULO AND C.SEQPESSOA = A.SEQPESSOA AND C.ODR = 1
                                       LEFT JOIN(SELECT * FROM (
                                                SELECT  ROW_NUMBER() OVER(PARTITION BY FI_MOVOCOR.SEQIDENTIFICA ORDER BY DTAHORA DESC) ODR, 
                                                        FI_OCRFINANC.DESCRICAO, FI_MOVOCOR.SEQPESSOA, FI_MOVOCOR.CODOCORRENCIA, FI_MOVOCOR.SEQIDENTIFICA,
                                                        FI_MOVOCOR.OBSERVACAO   
                                                FROM    CONSINCO.FI_MOVOCOR, CONSINCO.FI_OCRFINANC
                                                WHERE   FI_MOVOCOR.CODOCORRENCIA = FI_OCRFINANC.CODOCORRENCIA 

                                                ORDER BY 1 DESC)) CC ON CC.SEQIDENTIFICA = A.SEQTITULO AND CC.SEQPESSOA = A.SEQPESSOA AND CC.ODR = 1
                                       LEFT JOIN CONSINCO.FI_COMPLTITULO FC ON A.SEQTITULO = FC.SEQTITULO 
WHERE A.OBRIGDIREITO = 'O'                    
  AND A.DTAPROGRAMADA BETWEEN :DT1 AND :DT2                  
  AND A.CODIGOFATOR IS NULL 
  AND A.CODESPECIE IN (SELECT  DISTINCT FI_ESPECIE.CODESPECIE           
                        FROM    CONSINCO.FI_ESPECIE , CONSINCO.FI_FILTRORELATRIB B 
                          WHERE FI_ESPECIE.CODESPECIE = B.VLRATRIBUTO(+) 
                            AND FI_ESPECIE.OBRIGDIREITO = 'O'
                            AND ( FI_ESPECIE.TIPOESPECIE = 'T' Or FI_ESPECIE.TIPOESPECIE = 'C' )
                            AND FI_ESPECIE.CODESPECIE NOT IN ('BEFUNC','VLDESC','MKFUNC','MKPREM','RESCIS','FÉRIAS','PENSAO','PROCIM','PROTIM','PROTRA'))
                                    
  AND A.NROEMPRESAMAE IN (  SELECT  DISTINCT A.NROEMPRESAMAE 
    FROM   CONSINCO.FI_PARAMETRO A 
    WHERE  A.NROEMPRESA IN (1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54,55, 301, 500, 501, 502, 503, 504,505, 506, 601,602, 603 )  )
  AND A.NROEMPRESA IN ( 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54,55,301, 500, 501, 502, 503,504,505, 506, 601, 602,603 )  
  AND A.NROBANCO IN ( 237, 1, 900, 11, 341, 422, 33 )   
  AND EXISTS (     
      SELECT  1  
      FROM  CONSINCO.FI_AUTPAGTO 
      WHERE   FI_AUTPAGTO.SEQTITULO = A.SEQTITULO)  
  AND NOT EXISTS   
      (  
      SELECT  1 
      FROM  CONSINCO.FI_PROGPAGAMENTO
      WHERE FI_PROGPAGAMENTO.SEQTITULO = A.SEQTITULO 
      AND NVL(FI_PROGPAGAMENTO.SITUACAO,'N') = 'N')
      
ORDER BY 6 ASC, DTAPROGRAMADA , STATUS_TITULO, A.NOMERAZAO) X

WHERE X.STATUS_TITULO LIKE (DECODE(:LS1, 'Não Programados', '%Não Programado%', 'Cancelados','%Cancelado%', '%%'))
  AND CODBARRAS       LIKE (DECODE(:LS2,'Com Código de Barras','Sim', 'Sem Código de Barras','Não','%%'))
