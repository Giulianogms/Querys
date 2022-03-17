ALTER SESSION SET current_schema = CONSINCO;

SELECT P_EDI.NROEMPRESA AS LJ, TIT.NROTITULO AS NRO_TITULO, TIT.CODESPECIE AS ESPECIE, CLI.NOMERAZAO, 
       NF.DTAHOREMISSAO AS DT_EMISSAO, NF.DTAVENCIMENTO AS DT_VENCIMENTO, TIT.VLRORIGINAL AS VALOR_TITULO,
       (SELECT ROUND(SUM(A.VLRACRESCIMO) + SUM(A.VLRITEM),2) AS TOTAL
       FROM CONSINCO.MFL_DFITEM A     
       WHERE  A.NUMERODF = NF.NUMERODF
       AND    A.NROEMPRESA = NF.NROEMPRESA  
       AND    A.SERIEDF = NF.SERIEDF
       AND    A.STATUSITEM = 'V') AS Valor_Total_NF,
       TIT.SEQTITULO AS NUMERO_TITULO, P_EDI.NROPEDCLIENTE AS NUMERO_PEDIDO, P_EDI.PEDIDOID AS PLATAFORMA
       
FROM (SELECT * FROM CONSINCO.EDI_PEDVENDA P_EDI
      WHERE P_EDI.PEDIDOID IN ('IFOOD','SM','MMC')
      AND P_EDI.NROEMPRESA = 48                   -- Empresa
      AND P_EDI.dtapedidoafv >= SYSDATE -7) P_EDI -- Ir� retornar a tabela reduzida mediante crit�rio de data
INNER JOIN (SELECT NROPEDVENDA FROM CONSINCO.MAD_PEDVENDA WHERE ORIGEMPEDIDO = 'E' AND INDENTREGARETIRA IN ('E','R')) PED 
      ON (P_EDI.NROPEDVENDA = PED.NROPEDVENDA)    -- Tipo Cursor - S� tr�s colunas nescess�rias e n�o a tabela inteira
LEFT JOIN  (SELECT SERIEDF, NROEMPRESA, SEQPESSOA, DTAMOVIMENTO, NROPEDIDOVENDA, NUMERODF, DTAVENCIMENTO, DTAHOREMISSAO
            FROM CONSINCO.MFL_DOCTOFISCAL) NF ON (PED.NROPEDVENDA = NF.NROPEDIDOVENDA)        -- Tipo Cursor
-- LEFT JOIN CONSINCO.GE_PESSOA PES ON (NF.SEQPESSOA = PES.SEQPESSOA)                        -- Qual a utiliza��o desse join?
LEFT JOIN CONSINCO.FI_TITULO TIT ON (NF.NUMERODF = TIT.NROTITULO
      AND NF.SERIEDF = TIT.SERIETITULO
      AND NF.NROEMPRESA = TIT.NROEMPRESA
      AND NF.SEQPESSOA = TIT.SEQPESSOANOTA 
      AND NF.DTAMOVIMENTO = TIT.DTAEMISSAO)
/* LEFT JOIN CONSINCO.FI_TITULONSU NSU ON (TIT.SEQTITULO = NSU.SEQTITULO)                    -- Qual a utiliza��o desse join?
LEFT JOIN CONSINCO.FI_ESPECIE ESP ON (TRIM(TIT.CODESPECIE) = TRIM(ESP.CODESPECIE))  */       -- Qual a utiliza��o desse join?
LEFT JOIN CONSINCO.EDI_PEDVENDACLIENTE CLI ON (P_EDI.NROPEDIDOAFV = CLI.NROPEDIDOAFV)

/* WHERE P_EDI.PEDIDOID IN ('IFOOD','SM','MMC') 
     AND P_EDI.NROEMPRESA = 48
     AND P_EDI.dtapedidoafv >= SYSDATE -7 */                                                 -- Crit�rios j� adicionados no FROM
      
ORDER BY DT_EMISSAO DESC;
