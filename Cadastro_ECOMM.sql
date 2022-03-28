ALTER SESSION SET current_schema = CONSINCO;

SELECT A.SEQPRODUTO PLU, B.CODACESSO EAN, A.DESCCOMPLETA, F.MARCA, D.NOMERAZAO FORNECEDOR,
       G.STATUS STATUS_VENDA, A.DTAHORINCLUSAO DATA_CADASTRO,
       CASE WHEN A.INDINTEGRAECOMMERCE  IS NULL THEN 'N' ELSE A.INDINTEGRAECOMMERCE  END INTEGRA_ECOMM, 
       CASE WHEN A.PERSIMILIARECOMMERCE IS NULL THEN 'N' ELSE A.PERSIMILIARECOMMERCE END PERM_SIMILAR_ECOMM,
       H.EMBALAGEM, H.QTDEMBALAGEM, 
       CASE WHEN H.EMBDECIMAL           IS NULL THEN 'N' ELSE H.EMBDECIMAL END PERM_DECIMAL, 
       H.PESOBRUTO PESOBRUTO_KG, H.PESOLIQUIDO PESOLIQUIDO_KG,
       H.ALTURA ALTURA_CM, H.LARGURA LARGURA_CM, H.PROFUNDIDADE PROFUNDIDADE_CM, H.QTDUNIDEMB, H.MULTEQPEMB

FROM CONSINCO.MAP_PRODUTO A
       LEFT JOIN (SELECT SEQPRODUTO, CODACESSO FROM MAP_PRODCODIGO WHERE TIPCODIGO = 'E') B     ON A.SEQPRODUTO = B.SEQPRODUTO
       LEFT JOIN ((SELECT * FROM MAP_FAMFORNEC C WHERE C.PRINCIPAL = 'S') C LEFT JOIN GE_PESSOA D ON C.SEQFORNECEDOR = D.SEQPESSOA)    
                                                                                                ON A.SEQFAMILIA = C.SEQFAMILIA
       LEFT JOIN ((MAP_FAMILIA  E LEFT JOIN MAP_MARCA F ON E.SEQMARCA = F.SEQMARCA))            ON A.SEQFAMILIA = E.SEQFAMILIA
       LEFT JOIN (SELECT * FROM MAP_FAMEMBALAGEM WHERE QTDEMBALAGEM = 1 OR EMBALAGEM IN('CX', 'SC')) H  ON A.SEQFAMILIA = H.SEQFAMILIA
       LEFT JOIN (SELECT DISTINCT(SEQPRODUTO), 
       CASE WHEN SEQPRODUTO IN (SELECT DISTINCT(SEQPRODUTO) FROM MRL_PRODUTOEMPRESA WHERE STATUSCOMPRA = 'A') 
       THEN 'ATIVO' ELSE 'INATIVO' END STATUS
       FROM MRL_PRODUTOEMPRESA) G                                                              ON A.SEQPRODUTO = G.SEQPRODUTO 
      
ORDER BY 3,11,1,2;
