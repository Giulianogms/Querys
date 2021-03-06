ALTER SESSION SET current_schema = CONSINCO;

SELECT ROW_NUMBER() OVER(PARTITION BY A.NROPEDIDOSUPRIM ORDER BY 1) Linha,
       A.NROPEDIDOSUPRIM NROPED, A.SEQGERCOMPRA NROLOTE, A.DTAEMISSAO, A.NROEMPRESA, A.TIPPEDIDOSUPRIM TIPPED, 
       /*A.SEQCOMPRADOR, A.SEQFORNECEDOR,*/ A.SITUACAOPED, B.SEQPRODUTO, /*B.STATUSITEM */
      (B.QTDAPROVADA - (C.QTDRECEBIDA + C.QTDCANCELADA)) QTDSALDO,
       B.QTDAPROVADA, C.QTDRECEBIDA, C.QTDCANCELADA

FROM   MSU_PEDIDOSUPRIM A
       LEFT JOIN (MSU_PSITEMRECEBER B 
       LEFT JOIN  MSU_PSITEMRECEBIDO C ON B.NROEMPRESA = C.NROEMPRESA AND B.NROPEDIDOSUPRIM = C.NROPEDIDOSUPRIM
       AND B.CENTRALLOJA = C.CENTRALLOJA AND B.SEQPRODUTO = C.SEQPRODUTO) ON A.NROEMPRESA = B.NROEMPRESA AND A.CENTRALLOJA = B.CENTRALLOJA,
       MAP_PRODUTO D, MAP_FAMEMBALAGEM E
       
WHERE A.NROPEDIDOSUPRIM        =     B.NROPEDIDOSUPRIM
  AND D.SEQPRODUTO             =     B.SEQPRODUTO
  AND D.SEQFAMILIA             =     E.SEQFAMILIA
  AND B.QTDEMBALAGEM           =     E.QTDEMBALAGEM
  AND A.NROEMPRESA IN (501,502,503,504,505,601)
--AND A.DTAEMISSAO <= DATE '2021-12-31'  Pedidos anteriores à 31/12/2021

--AND A.NROPEDIDOSUPRIM = 136544       -- Pedido velho cancelado
--AND A.NROPEDIDOSUPRIM = 2808549    -- Pedido novo cancelado

AND (B.QTDAPROVADA - (C.QTDRECEBIDA + C.QTDCANCELADA)) > 0  -- Apemas com saldo

ORDER BY 1,2,3
