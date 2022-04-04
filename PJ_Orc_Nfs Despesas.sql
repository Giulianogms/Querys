ALTER SESSION SET current_schema = CONSINCO;

SELECT A.NROEMPRESA LOJA, A.NRONOTA, 
       TO_CHAR(A.VALOR, 'FM999G999G999D90', 'nls_numeric_characters='',.''') Valor,
       A.DTAINCLUSAO, B.NOMERAZAO, A.OBSERVACAO--, A.REQUISICOES, C.USUAUTORIZACAO
       
FROM OR_NFDESPESA A LEFT JOIN GE_PESSOA B ON A.SEQPESSOA = B.SEQPESSOA
     --LEFT JOIN OR_REQUISICAO C ON A.REQUISICOES = C.SEQREQUISICAO AND A.NROEMPRESA = C.NROEMPRESA

WHERE A.CGO = 999
AND NRONOTA = 9018607812

ORDER BY A.DTAINCLUSAO DESC
