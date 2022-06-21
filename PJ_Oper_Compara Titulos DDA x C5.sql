SELECT * FROM (
/* ------------------ Validação CNPJ x Regras x Filiais ------------------- */

SELECT FORNECEDOR, LPAD(X.NROCNPJCPF, 12, 0) || LPAD(X.DIGCNPJCPF, 2, 0) CNPJ,
       CASE WHEN LPAD(X.NROCNPJCPF, 12, 0) = (SELECT MAX(LPAD(D.NROCGCCPF, 12, 0)) FROM CONSINCO.GE_PESSOA D WHERE D.NROCGCCPF = X.NROCNPJCPF AND D.STATUS = 'A')
       THEN 'Cadastrado no Sistema'||CASE WHEN LPAD(X.NROCNPJCPF,12,0)||LPAD(X.DIGCNPJCPF,2,0) IN 
              (SELECT LPAD(FR.NROCNPJCPF,12,0)||LPAD(FR.DIGCNPJCPF,2,0) FROM CONSINCO.FI_DDAREGRADETALHE FR WHERE FR.NROCNPJCPF = X.NROCNPJCPF)
       THEN ' + Regras' ELSE NULL END
         WHEN LPAD(X.NROCNPJCPF,12,0)||LPAD(X.DIGCNPJCPF,2,0) IN 
              (SELECT LPAD(FR.NROCNPJCPF,12,0)||LPAD(FR.DIGCNPJCPF,2,0) FROM CONSINCO.FI_DDAREGRADETALHE FR WHERE FR.NROCNPJCPF = X.NROCNPJCPF)
       THEN 'Cadastrado nas Regras'||CASE WHEN LPAD(X.NROCNPJCPF,12,0) NOT IN (
         SELECT DISTINCT REGRACNPJ FROM (
         SELECT DISTINCT SEQFILTRODDA, A.SEQPESSOA, C.NOMERAZAO, LPAD(E.NROCNPJCPF,12,0) REGRACNPJ

                                                       FROM FI_FORNECEDOR A 
                                                       LEFT  JOIN GE_PESSOA C ON A.SEQPESSOA = C.SEQPESSOA
                                                       RIGHT JOIN FI_DDAREGRA D  ON A.SEQFILTRODDA = D.SEQFILTRO 
                                                       RIGHT JOIN FI_DDAREGRADETALHE E ON E.SEQREGRA = D.SEQREGRA
                                                       WHERE NROCNPJCPF IS NOT NULL AND A.SEQPESSOA = X.SEQ)
         ) THEN ' - Bloqueado' ELSE NULL END
        WHEN X.NROCNPJCPF IS NULL THEN NULL ELSE 'N'||
       CASE WHEN (SUBSTR(LPAD(X.NROCNPJCPF,12,0),0,8)) IN
              (SELECT SUBSTR(FRE.NROCGCCPF,0,8) FROM CONSINCO.GE_PESSOA FRE WHERE LPAD(FRE.NROCGCCPF,12,0) LIKE (SUBSTR(X.NROCNPJCPF,0,8)||'%') AND FRE.STATUS = 'A') THEN ' - Filial'
            WHEN FORNECEDOR NOT LIKE ('%'||REGEXP_SUBSTR(DESCFORNECEDOR, '(\S*)(\s)')||'%') THEN ' - Neg - '||DESCFORNECEDOR ELSE NULL END
       END CNPJ_CADASTRADO, GE.FANTASIA EMPRESA, X.CODESPECIE,
       
/* ------------------ Validação Titulo encontrado + Status CNOJ + Motivo Divergencia ------------------- */

CASE WHEN TO_CHAR(DOC_C5) = TIT_C5 THEN TO_CHAR(DOC_C5) ELSE DOC_C5||' - Tit.: '||TIT_C5 END DOC_C5, 
CASE WHEN DIVERGENCIA IS NULL AND DOCTO IS NULL     THEN 'Titulo não encontrado' 
     WHEN DIVERGENCIA IS NULL AND DOCTO IS NOT NULL THEN 'Título encontrado - '||CASE WHEN LPAD(X.NROCNPJCPF, 12, 0) = (SELECT MAX(LPAD(D.NROCGCCPF, 12, 0)) FROM CONSINCO.GE_PESSOA D WHERE D.NROCGCCPF = X.NROCNPJCPF AND D.STATUS = 'A')
      OR  LPAD(X.NROCNPJCPF,12,0)||LPAD(X.DIGCNPJCPF,2,0) IN
          (SELECT LPAD(FR.NROCNPJCPF,12,0)||LPAD(FR.DIGCNPJCPF,2,0) FROM CONSINCO.FI_DDAREGRADETALHE FR WHERE FR.NROCNPJCPF = X.NROCNPJCPF)     
     THEN 'Divergencia Não Identificada' ELSE 'CNPJ Não Cadastrado!' END
ELSE DIVERGENCIA||CASE WHEN LPAD(X.NROCNPJCPF,12,0)||LPAD(X.DIGCNPJCPF,2,0) IN
          (SELECT LPAD(FR.NROCNPJCPF,12,0)||LPAD(FR.DIGCNPJCPF,2,0) FROM CONSINCO.FI_DDAREGRADETALHE FR WHERE FR.NROCNPJCPF = X.NROCNPJCPF)
      OR  LPAD(X.NROCNPJCPF, 12, 0) = (SELECT MAX(LPAD(D.NROCGCCPF, 12, 0)) FROM CONSINCO.GE_PESSOA D WHERE D.NROCGCCPF = X.NROCNPJCPF AND D.STATUS = 'A')
          THEN NULL ELSE ' - CNPJ Não Cadastrado!' END END DIVERGENCIA, 
       DOCTO DOCTO_DDA, Emissao, Vencimento, Valor, DESCONTO1, DATADESCONTO1, DESCONTO2, DATADESCONTO2, VALORABATIMENTO, CODIGODEBARRAS, SEQ

/* ------------------ SELECT ------------------- */

FROM (

SELECT GE.NOMERAZAO||' - '||GE.SEQPESSOA Fornecedor, DDA2.DESCFORNECEDOR, GE.SEQPESSOA SEQ, DDA2.NRODOCUMENTO DOCTO, F.NRODOCUMENTO DOC_C5, F.NROTITULO TIT_C5, F.CODESPECIE, DDA2.NRODOCUMENTO,
       TO_CHAR(DDA2.DTAEMISSAO,'DD/MM/YYYY') EMISSAO, TO_CHAR(DDA2.DTAVENCIMENTO,'DD/MM/YYYY') VENCIMENTO, DDA2.VALORDOCUMENTO VALOR, DDA2.VALORDESCONTO1 DESCONTO1, TO_CHAR(DDA2.DTADESCONTO1,'DD/MM/YYYY') DATADESCONTO1, DDA2.VALORDESCONTO2 DESCONTO2, TO_CHAR(DDA2.DTADESCONTO2,'DD/MM/YYYY') DATADESCONTO2, DDA2.VALORABATIMENTO, DDA2.CODBARRAS CODIGODEBARRAS,
       
/* ------------------ Identificadores das Divergências ------------------- */
/* ------------------ Agrupamentos ------------------- */

      CASE WHEN (
            SELECT SUM(F2.VLRORIGINAL) - (SUM(NVL(FF3.VLRDESCCONTRATO,0)) + SUM(NVL(F2.VLRPAGO,0)))
            FROM FI_TITULO F2 INNER JOIN FI_COMPLTITULO FF3 ON F2.SEQTITULO = FF3.SEQTITULO
            WHERE F2.SEQPESSOA = F.SEQPESSOA
            AND F2.NROEMPRESA IN(#LS1)
            AND F2.OBRIGDIREITO = 'O'
            AND F2.ABERTOQUITADO    = 'A' 
            AND F2.SITUACAO        != 'S'  
            AND NVL(F2.SUSPLIB,'L') = 'L'
            AND F2.SEQTITULO NOT IN (     
                  SELECT  SEQTITULO  
                    FROM  FI_AUTPAGTO 
                      WHERE   FI_AUTPAGTO.SEQTITULO = F2.SEQTITULO)
            AND F2.DTAVENCIMENTO BETWEEN :DT1 AND :DT2
            HAVING COUNT (NRODOCUMENTO) > 1) IN (
            SELECT (VALORDOCUMENTO - A.VALORDESCONTO1 - A.VALORABATIMENTO) FROM FIV_DDATITULOSBUSCA A 
            WHERE A.DTAVENCIMENTO BETWEEN (:DT1 - 10) AND (:DT1 + 10)
            AND NVL(a.ACEITO,'N') = 'N'
            AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
            WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(A.NROCNPJCPFSACADO,12,0)||LPAD(A.DIGCNPJCPFSACADO,2,0)) IN(#LS1))
            THEN 'Títulos Agrupados - DOC DDA: '||DDA2.NRODOCUMENTO||' - Valor Total: '||TO_CHAR(DDA2.VALORCOMDESCONTO,'FM999G999G999D90', 'nls_numeric_characters='',.''')

           WHEN (
            SELECT SUM(F2.VLRNOMINAL) - (SUM(NVL(FF3.VLRDESCCONTRATO,0)) + SUM(NVL(F2.VLRPAGO,0)))
            FROM FI_TITULO F2 INNER JOIN FI_COMPLTITULO FF3 ON F2.SEQTITULO = FF3.SEQTITULO
            WHERE F2.SEQPESSOA = F.SEQPESSOA
            AND F2.NROEMPRESA IN(#LS1)
            AND F2.OBRIGDIREITO = 'O'
            AND F2.ABERTOQUITADO    = 'A' 
            AND F2.SITUACAO        != 'S'  
            AND NVL(F2.SUSPLIB,'L') = 'L'
            AND F2.DTAVENCIMENTO BETWEEN :DT1 AND :DT2
            HAVING COUNT (NRODOCUMENTO) > 1) IN (
            SELECT (VALORDOCUMENTO - A.VALORDESCONTO1 - A.VALORABATIMENTO) FROM FIV_DDATITULOSBUSCA A 
            WHERE A.DTAVENCIMENTO BETWEEN (:DT1 - 10) AND (:DT1 + 10)
            AND NVL(a.ACEITO,'N') = 'N'
            AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
            WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(A.NROCNPJCPFSACADO,12,0)||LPAD(A.DIGCNPJCPFSACADO,2,0)) IN(#LS1))
            THEN 'Títulos Agrupados - DOC DDA: '||DDA2.NRODOCUMENTO||' - Valor Total: '||TO_CHAR(DDA2.VALORCOMDESCONTO,'FM999G999G999D90', 'nls_numeric_characters='',.''')

           WHEN (
            SELECT SUM(F2.VLRORIGINAL) - (SUM(NVL(FF3.VLRDESCCONTRATO,0)) + SUM(NVL(F2.VLRPAGO,0)))
            AS VLRSOMADO
            FROM FI_TITULO F2 INNER JOIN FI_COMPLTITULO FF3 ON F2.SEQTITULO = FF3.SEQTITULO
            WHERE F2.SEQPESSOA = F.SEQPESSOA
            AND F2.NROEMPRESA IN(#LS1)
            AND F2.OBRIGDIREITO = 'O'
            AND F2.ABERTOQUITADO    = 'A' 
            AND F2.SITUACAO        != 'S'  
            AND NVL(F2.SUSPLIB,'L') = 'L'
            AND F2.DTAVENCIMENTO BETWEEN :DT1 AND :DT2
            HAVING COUNT (NRODOCUMENTO) > 1) IN (
            SELECT ((VALORDOCUMENTO - 0.01)- NVL(A.VALORDESCONTO1,0) - NVL(A.VALORABATIMENTO,0))  FROM FIV_DDATITULOSBUSCA A 
            WHERE A.DTAVENCIMENTO BETWEEN (:DT1 - 10) AND (:DT1 + 10)
            AND NVL(a.ACEITO,'N') = 'N' 
            AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
            WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(A.NROCNPJCPFSACADO,12,0)||LPAD(A.DIGCNPJCPFSACADO,2,0)) IN(#LS1)
            UNION ALL
            SELECT ((VALORDOCUMENTO + 0.01)- NVL(A.VALORDESCONTO1,0) - NVL(A.VALORABATIMENTO,0))  FROM FIV_DDATITULOSBUSCA A 
            WHERE A.DTAVENCIMENTO BETWEEN (:DT1 - 10) AND (:DT1 + 10)
            AND NVL(a.ACEITO,'N') = 'N' 
            AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
            WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(A.NROCNPJCPFSACADO,12,0)||LPAD(A.DIGCNPJCPFSACADO,2,0)) IN(#LS1)
            UNION ALL
            SELECT ((VALORDOCUMENTO + 0.02)- NVL(A.VALORDESCONTO1,0) - NVL(A.VALORABATIMENTO,0))  FROM FIV_DDATITULOSBUSCA A 
            WHERE A.DTAVENCIMENTO BETWEEN (:DT1 - 10) AND (:DT1 + 10)
            AND NVL(a.ACEITO,'N') = 'N' 
            AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
            WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(A.NROCNPJCPFSACADO,12,0)||LPAD(A.DIGCNPJCPFSACADO,2,0)) IN(#LS1)
            UNION ALL
            SELECT ((VALORDOCUMENTO - 0.02)- NVL(A.VALORDESCONTO1,0) - NVL(A.VALORABATIMENTO,0))  FROM FIV_DDATITULOSBUSCA A 
            WHERE A.DTAVENCIMENTO BETWEEN (:DT1 - 10) AND (:DT1 + 10)
            AND NVL(a.ACEITO,'N') = 'N' 
            AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
            WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(A.NROCNPJCPFSACADO,12,0)||LPAD(A.DIGCNPJCPFSACADO,2,0)) IN(#LS1))
            THEN 'Títulos Agrupados - Valor Sistema: '||TO_CHAR((
            SELECT SUM(F2.VLRORIGINAL) - (SUM(NVL(FF3.VLRDESCCONTRATO,0)) + SUM(NVL(F2.VLRPAGO,0)))
            AS VLRSOMADO
            FROM FI_TITULO F2 INNER JOIN FI_COMPLTITULO FF3 ON F2.SEQTITULO = FF3.SEQTITULO
            WHERE F2.SEQPESSOA = F.SEQPESSOA
            AND F2.NROEMPRESA IN(#LS1)
            AND F2.DTAVENCIMENTO BETWEEN :DT1 AND :DT2
            HAVING COUNT (NRODOCUMENTO) > 1),'FM999G999G999D90', 'nls_numeric_characters='',.''')||' - Valor DDA: '||
            TO_CHAR(DDA2.VALORCOMDESCONTO,'FM999G999G999D90', 'nls_numeric_characters='',.''')||CASE WHEN F.DTAVENCIMENTO != DDA2.DTAVENCIMENTO
            THEN ' - Data de Vencimento Sistema: '||TO_CHAR(F.DTAVENCIMENTO, 'DD/MM/YYYY')||' - DDA: '||TO_CHAR(DDA2.DTAVENCIMENTO, 'DD/MM/YYYY') ELSE NULL END

/* ------------------ Outras Divergencias ------------------- */

           WHEN (F.VLRORIGINAL - NVL((FC.VLRDESCCONTRATO + F.VLRPAGO),0)) != (DDA2.VALORDOCUMENTO - NVL((DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO),0))
            THEN 'Valor Total Sistema: '||TO_CHAR((F.VLRORIGINAL - NVL((FC.VLRDESCCONTRATO + F.VLRPAGO),0)),'FM999G999G999D90', 'nls_numeric_characters='',.''')||' - DDA: '||
              TO_CHAR(DDA2.VALORCOMDESCONTO,'FM999G999G999D90', 'nls_numeric_characters='',.''')||' | Desconto Sistema: '||
              TO_CHAR(NVL((FC.VLRDESCCONTRATO+FC.VLRDSCFINANC+F.VLRPAGO),0),'FM999G999G999D90', 'nls_numeric_characters='',.''')||' - DDA: '||
              TO_CHAR((DDA2.VALORDESCONTO1 + DDA2.VALORDESCONTO2+DDA2.VALORDESCONTO3+DDA2.VALORABATIMENTO),'FM999G999G999D90', 'nls_numeric_characters='',.''')||CASE WHEN DDA2.DTAVENCIMENTO != F.DTAVENCIMENTO THEN CASE WHEN DDA2.DTAVENCIMENTO != F.DTAPROGRAMADA 
            THEN ' | Data de Vencimento Sistema: '||TO_CHAR(F.DTAVENCIMENTO, 'DD/MM/YYYY')||' - DDA: '||TO_CHAR(DDA2.DTAVENCIMENTO, 'DD/MM/YYYY') ELSE NULL END ELSE NULL END
           WHEN DDA2.DTAVENCIMENTO != F.DTAVENCIMENTO THEN CASE WHEN DDA2.DTAVENCIMENTO != F.DTAPROGRAMADA 
            THEN 'Data de Vencimento Sistema: '||TO_CHAR(F.DTAVENCIMENTO, 'DD/MM/YYYY')||' - DDA: '||TO_CHAR(DDA2.DTAVENCIMENTO, 'DD/MM/YYYY') ELSE NULL END

            ELSE NULL END Divergencia, DDA2.NROCNPJCPF, DDA2.DIGCNPJCPF
       
FROM CONSINCO.FI_TITULO F 

                 INNER JOIN CONSINCO.FI_ESPECIE FI      ON F.CODESPECIE = FI.CODESPECIE AND F.NROEMPRESAMAE = FI.NROEMPRESAMAE
                 INNER JOIN CONSINCO.GE_PESSOA  GE      ON F.SEQPESSOA  = GE.SEQPESSOA  
                 INNER JOIN CONSINCO.FI_COMPLTITULO  FC ON F.SEQTITULO  = FC.SEQTITULO
                 
/* ------------------ Joins por 'Regra' dos titulos não conciliados  ------------------- */

                      LEFT JOIN CONSINCO.FIV_DDATITULOSBUSCA DDA2 ON /* Variaveis Valodarores Não Conciliados */
                    (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND DDA2.DTAVENCIMENTO = F.DTAVENCIMENTO AND DDA2.NRODOCUMENTO LIKE ('%'||F.NROTITULO||'%') AND (LENGTH(DDA2.NRODOCUMENTO)) > 4 AND NVL(DDA2.ACEITO,'N') = 'N'
                 OR (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND DDA2.DTAVENCIMENTO = F.DTAPROGRAMADA AND DDA2.NRODOCUMENTO LIKE ('%'||F.NROTITULO||'%')AND (LENGTH(DDA2.NRODOCUMENTO)) > 4 AND NVL(DDA2.ACEITO,'N') = 'N'
                 OR (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND DDA2.DTAVENCIMENTO = F.DTAVENCIMENTO AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%') AND (LENGTH(DDA2.NRODOCUMENTO)) > 4 AND NVL(DDA2.ACEITO,'N') = 'N' 
                 OR (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND DDA2.DTAVENCIMENTO = F.DTAPROGRAMADA AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%')AND (LENGTH(DDA2.NRODOCUMENTO)) > 4 AND NVL(DDA2.ACEITO,'N') = 'N' 
                 OR (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND DDA2.NRODOCUMENTO LIKE ('%'||F.NROTITULO||'%') AND ((F.VLRORIGINAL - (FC.VLRDESCCONTRATO + F.VLRPAGO)) = (DDA2.VALORDOCUMENTO - (DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO)))AND (LENGTH(DDA2.NRODOCUMENTO)) > 4 AND NVL(DDA2.ACEITO,'N') = 'N' AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20)
                 OR DDA2.DTAVENCIMENTO = F.DTAVENCIMENTO AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%') AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%')AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1)))  AND NVL(DDA2.ACEITO,'N') = 'N' 
                 OR DDA2.DTAVENCIMENTO = F.DTAPROGRAMADA AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%') AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%')AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND NVL(DDA2.ACEITO,'N') = 'N' 
                 OR GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND DDA2.NRODOCUMENTO LIKE ('%'||F.NROTITULO||'%') AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND ((F.VLRORIGINAL - (FC.VLRDESCCONTRATO + F.VLRPAGO)) = (DDA2.VALORDOCUMENTO - (DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO)))   AND NVL(DDA2.ACEITO,'N') = 'N' AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20)
                 OR GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND ((F.VLRORIGINAL - (FC.VLRDESCCONTRATO + F.VLRPAGO)) = (DDA2.VALORDOCUMENTO - (DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO))) AND NVL(DDA2.ACEITO,'N') = 'N' AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0)  FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1)))AND NVL(DDA2.ACEITO,'N') = 'N' AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20)
                 OR (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND (F.VLRORIGINAL) = (DDA2.VALORDOCUMENTO) AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20) AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%') AND NVL(DDA2.ACEITO,'N') = 'N' 
                 OR (F.VLRORIGINAL) = (DDA2.VALORDOCUMENTO) AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20) AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND NVL(DDA2.ACEITO,'N') = 'N' 
                 OR ((F.VLRORIGINAL - (FC.VLRDESCCONTRATO + F.VLRPAGO)) = (DDA2.VALORDOCUMENTO - (DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO))) AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND NVL(DDA2.ACEITO,'N') = 'N' AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20)
                 OR (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND (F.VLRORIGINAL) = (DDA2.VALORDOCUMENTO) AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20) AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%') AND NVL(DDA2.ACEITO,'N') = 'N' 
                 OR GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%') AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0)  FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND (F.DTAVENCIMENTO - DDA2.DTAVENCIMENTO) IN (1,2) AND NVL(DDA2.ACEITO,'N') = 'N' 
                 OR DDA2.DTAVENCIMENTO = F.DTAVENCIMENTO AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0)  FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND NVL(DDA2.ACEITO, 'N') = 'N' AND REPLACE(DDA2.NRODOCUMENTO,'.','') LIKE ('%'||F.NRODOCUMENTO||'%') AND NVL(DDA2.ACEITO,'N') = 'N' AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20)
                 OR GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)',1,2)||'%') AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0)  FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND NVL(DDA2.ACEITO, 'N') = 'N' AND (DDA2.VALORDOCUMENTO - DDA2.VALORDESCONTO1) = (F.VLRORIGINAL - FC.VLRDESCCONTRATO) AND NVL(DDA2.ACEITO,'N') = 'N' AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20)
                 OR GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND F.DTAVENCIMENTO = DDA2.DTAVENCIMENTO AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0)  FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND ((F.VLRORIGINAL - NVL((FC.VLRDESCCONTRATO + F.VLRPAGO),0)) - (DDA2.VALORDOCUMENTO - NVL((DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO),0))) 
                 IN (0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.010,-0.01,-0.02,-0.03,-0.04,-0.05,-0.06,-0.07,-0.08,-0.09,-0.010)AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20) AND NVL(DDA2.ACEITO,'N') = 'N' 
                 OR GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0)  FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND ((F.VLRORIGINAL - NVL((FC.VLRDESCCONTRATO + F.VLRPAGO),0)) - (DDA2.VALORDOCUMENTO - NVL((DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO),0))) 
                 IN (0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.010,-0.01,-0.02,-0.03,-0.04,-0.05,-0.06,-0.07,-0.08,-0.09,-0.010) AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 10) AND (F.DTAVENCIMENTO + 10) AND NVL(DDA2.ACEITO,'N') = 'N' 
                 OR DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%') AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0)  FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND ((F.VLRORIGINAL - NVL((FC.VLRDESCCONTRATO + F.VLRPAGO),0)) - (DDA2.VALORDOCUMENTO - NVL((DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO),0))) 
                 IN (0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.010,-0.01,-0.02,-0.03,-0.04,-0.05,-0.06,-0.07,-0.08,-0.09,-0.010) AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 10) AND (F.DTAVENCIMENTO + 10) AND NVL(DDA2.ACEITO,'N') = 'N' 
                 OR GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)',1,2)||'%') AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0)  FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND NVL(DDA2.ACEITO, 'N') = 'N' AND DDA2.VALORDOCUMENTO = F.VLRORIGINAL AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20) AND NVL(DDA2.ACEITO,'N') = 'N' AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20)
                 OR DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%') AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0)  FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND (F.DTAVENCIMENTO + 20) AND NVL(DDA2.ACEITO,'N') = 'N' AND  (DDA2.VALORDOCUMENTO - NVL((DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO),0)) < ((F.VLRORIGINAL - NVL((FC.VLRDESCCONTRATO + F.VLRPAGO),0)) *2) AND (LENGTH(F.NRODOCUMENTO)) >= 4 
                 OR GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)',1,2)||'%') AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0)  FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND ((F.VLRORIGINAL - NVL((FC.VLRDESCCONTRATO + F.VLRPAGO),0)) - (DDA2.VALORDOCUMENTO - NVL((DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO),0))) 
                 IN (0,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.010,-0.01,-0.02,-0.03,-0.04,-0.05,-0.06,-0.07,-0.08,-0.09,-0.010) AND DDA2.DTAVENCIMENTO = F.DTAVENCIMENTO AND NVL(DDA2.ACEITO,'N') = 'N' 
                 OR REPLACE(GE.NOMERAZAO, '.',' ') LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND F.VLRORIGINAL = DDA2.VALORDOCUMENTO AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 10) AND (F.DTAVENCIMENTO + 10) AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0)  FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1))) AND NVL(DDA2.ACEITO,'N') = 'N'
/*AGRP*/         OR
    (            SELECT SUM(F2.VLRORIGINAL) - (SUM(NVL(FF3.VLRDESCCONTRATO,0)) + SUM(NVL(F2.VLRPAGO,0)))
                 AS VLRSOMADO
                 FROM FI_TITULO F2 INNER JOIN FI_COMPLTITULO FF3 ON F2.SEQTITULO = FF3.SEQTITULO
                 WHERE F2.SEQPESSOA = F.SEQPESSOA
                 AND F2.NROEMPRESA IN(#LS1)
                 AND F2.OBRIGDIREITO = 'O'
                 AND F2.ABERTOQUITADO    = 'A' 
                 AND F2.SITUACAO        != 'S'  
                 AND NVL(F2.SUSPLIB,'L') = 'L'
                 AND F2.SEQTITULO NOT IN (     
                  SELECT  SEQTITULO  
                    FROM  FI_AUTPAGTO 
                      WHERE   FI_AUTPAGTO.SEQTITULO = F2.SEQTITULO)
                 AND F2.DTAVENCIMENTO BETWEEN :DT1 AND :DT2
                 AND FF3.CODBARRA IS NULL
                 HAVING COUNT (NRODOCUMENTO) > 1) 
                 = 
                 (DDA2.VALORDOCUMENTO - DDA2.VALORDESCONTO1 - DDA2.VALORABATIMENTO)
                 AND DDA2.DTAVENCIMENTO BETWEEN (:DT1 - 10) AND (:DT1 + 10)
                 AND NVL(DDA2.ACEITO,'N') = 'N'
                 AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
                 WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0)) IN(#LS1)
                 OR
    (            SELECT SUM(NVL(F2.VLRNOMINAL,0)) - (SUM(NVL(FF3.VLRDESCCONTRATO,0)) + SUM(NVL(F2.VLRPAGO,0)))
                 AS VLRSOMADO
                 FROM FI_TITULO F2 INNER JOIN FI_COMPLTITULO FF3 ON F2.SEQTITULO = FF3.SEQTITULO
                 WHERE F2.SEQPESSOA = F.SEQPESSOA
                 AND F2.NROEMPRESA IN(#LS1)
                 AND F2.OBRIGDIREITO = 'O'
                 AND F2.ABERTOQUITADO    = 'A' 
                 AND F2.SITUACAO        != 'S'  
                 AND NVL(F2.SUSPLIB,'L') = 'L'
                 AND FF3.CODBARRA IS NULL
                 AND F2.DTAVENCIMENTO BETWEEN :DT1 AND :DT2
                 HAVING COUNT (NRODOCUMENTO) > 1)= 
                 (DDA2.VALORDOCUMENTO - DDA2.VALORDESCONTO1 - DDA2.VALORABATIMENTO)
                 AND DDA2.DTAVENCIMENTO BETWEEN (:DT1 - 10) AND (:DT1 + 10)
                 AND NVL(DDA2.ACEITO,'N') = 'N'
                 AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
                 WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0)) IN(#LS1)
                 OR 
                 (SELECT SUM(NVL(F2.VLRORIGINAL,0)) - (SUM(NVL(FF3.VLRDESCCONTRATO,0)) + SUM(NVL(F2.VLRPAGO,0)))
                 AS VLRSOMADO
                 FROM FI_TITULO F2 INNER JOIN FI_COMPLTITULO FF3 ON F2.SEQTITULO = FF3.SEQTITULO
                 WHERE F2.SEQPESSOA = F.SEQPESSOA
                 AND F2.NROEMPRESA IN(#LS1)
                 AND F2.ABERTOQUITADO    = 'A' 
                 AND F2.SITUACAO        != 'S'  
                 AND NVL(F2.SUSPLIB,'L') = 'L'
                 AND FF3.CODBARRA IS NULL
                 AND F2.OBRIGDIREITO = 'O'
                 AND F2.DTAVENCIMENTO BETWEEN :DT1 AND :DT2
                 HAVING COUNT (NRODOCUMENTO) > 1) =
                 ((DDA2.VALORDOCUMENTO -0.01) - DDA2.VALORDESCONTO1 - DDA2.VALORABATIMENTO)
                 AND DDA2.DTAVENCIMENTO BETWEEN (:DT1 - 10) AND (:DT1 + 10)
                 AND NVL(DDA2.ACEITO,'N') = 'N'
                 AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
                 WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0)) IN(#LS1)
                 OR 
                 (SELECT SUM(NVL(F2.VLRORIGINAL,0)) - (SUM(NVL(FF3.VLRDESCCONTRATO,0)) + SUM(NVL(F2.VLRPAGO,0)))
                 AS VLRSOMADO
                 FROM FI_TITULO F2 INNER JOIN FI_COMPLTITULO FF3 ON F2.SEQTITULO = FF3.SEQTITULO
                 WHERE F2.SEQPESSOA = F.SEQPESSOA
                 AND F2.NROEMPRESA IN(#LS1)
                 AND F2.ABERTOQUITADO    = 'A' 
                 AND F2.SITUACAO        != 'S'  
                 AND NVL(F2.SUSPLIB,'L') = 'L'
                 AND FF3.CODBARRA IS NULL
                 AND F2.OBRIGDIREITO = 'O'
                 AND F2.DTAVENCIMENTO BETWEEN :DT1 AND :DT2
                 HAVING COUNT (NRODOCUMENTO) > 1) =
                 ((DDA2.VALORDOCUMENTO +0.01) - DDA2.VALORDESCONTO1 - DDA2.VALORABATIMENTO)
                 AND DDA2.DTAVENCIMENTO BETWEEN (:DT1 - 10) AND (:DT1 + 10)
                 AND NVL(DDA2.ACEITO,'N') = 'N'
                 AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
                 WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0)) IN(#LS1) 
                 OR 
                 (SELECT SUM(NVL(F2.VLRORIGINAL,0)) - (SUM(NVL(FF3.VLRDESCCONTRATO,0)) + SUM(NVL(F2.VLRPAGO,0)))
                 AS VLRSOMADO
                 FROM FI_TITULO F2 INNER JOIN FI_COMPLTITULO FF3 ON F2.SEQTITULO = FF3.SEQTITULO
                 WHERE F2.SEQPESSOA = F.SEQPESSOA
                 AND F2.NROEMPRESA IN(#LS1)
                 AND F2.ABERTOQUITADO    = 'A' 
                 AND F2.SITUACAO        != 'S'  
                 AND NVL(F2.SUSPLIB,'L') = 'L'
                 AND FF3.CODBARRA IS NULL
                 AND F2.OBRIGDIREITO = 'O'
                 AND F2.DTAVENCIMENTO BETWEEN :DT1 AND :DT2
                 HAVING COUNT (NRODOCUMENTO) > 1) =
                 ((DDA2.VALORDOCUMENTO +0.02) - DDA2.VALORDESCONTO1 - DDA2.VALORABATIMENTO)
                 AND DDA2.DTAVENCIMENTO BETWEEN (:DT1 - 10) AND (:DT1 + 10)
                 AND NVL(DDA2.ACEITO,'N') = 'N'
                 AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
                 WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0)) IN(#LS1) 
                 OR 
                 (SELECT SUM(NVL(F2.VLRORIGINAL,0)) - (SUM(NVL(FF3.VLRDESCCONTRATO,0)) + SUM(NVL(F2.VLRPAGO,0)))
                 AS VLRSOMADO
                 FROM FI_TITULO F2 INNER JOIN FI_COMPLTITULO FF3 ON F2.SEQTITULO = FF3.SEQTITULO
                 WHERE F2.SEQPESSOA = F.SEQPESSOA
                 AND F2.NROEMPRESA IN(#LS1)
                 AND F2.ABERTOQUITADO    = 'A' 
                 AND F2.SITUACAO        != 'S'  
                 AND NVL(F2.SUSPLIB,'L') = 'L'
                 AND FF3.CODBARRA IS NULL
                 AND F2.OBRIGDIREITO = 'O'
                 AND F2.DTAVENCIMENTO BETWEEN :DT1 AND :DT2
                 HAVING COUNT (NRODOCUMENTO) > 1) =
                 ((DDA2.VALORDOCUMENTO -0.02) - DDA2.VALORDESCONTO1 - DDA2.VALORABATIMENTO)
                 AND DDA2.DTAVENCIMENTO BETWEEN (:DT1 - 10) AND (:DT1 + 10)
                 AND NVL(DDA2.ACEITO,'N') = 'N'
                 AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
                 WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0)) IN(#LS1) 
                 
/* ------------------ Filtros Finais ------------------- */

WHERE F.OBRIGDIREITO     = 'O'
  AND F.CODESPECIE NOT IN ('13SAL','ADIEMP','ADIPRP','ADISAL','ANTREC','ATIPCO','ATIVOC','BONIAC','BONIDV','CHQPG','DEVCOM','DEVPAG','DEVPCO',
                           'DUPCIM','DUPPCO','DUPPCX','DVRBEC','EMPAG','EMPAIM','FATNAG','FERIAS','FINAIM','FINANC','LEIROU','ORDSAL','PAGEST','PENSAO',
                           'RECARG','REEMB','RESCIS','VLDESC','COFINS','CONTDV','DSSLL','FGTS','FGTSQT','ICMS','IMPOST','INSS','INSSNF','INSTANG','IPI',
                           'IR','IRRFFP','IRRFNF','ISSQN','ISSQNP','ISSST','LEASIM','LEASIN','PCCNF','PIS','PROTRA','ALUGPG','FATICD', 'QTPRP','ADIPPG')
  AND F.ABERTOQUITADO    = 'A' 
  AND FI.TIPOESPECIE     = 'T' 
  AND F.SITUACAO        != 'S'  
  AND NVL(F.SUSPLIB,'L') = 'L'
  AND FC.CODBARRA         IS NULL     
  AND F.DTAVENCIMENTO BETWEEN :DT1 AND :DT2
  AND F.NROEMPRESA        IN (#LS1)
  AND NVL(DDA2.ACEITO,'N') = 'N'
  AND FC.CODBARRA IS NULL
  
) X, GE_EMPRESA GE
 
WHERE GE.NROEMPRESA IN( :LS1)

ORDER BY 1,6,7) XX

WHERE XX.DIVERGENCIA NOT LIKE '%Divergencia Não Identificada%'
   OR XX.CNPJ_CADASTRADO LIKE '%N%'
   OR XX.CNPJ_CADASTRADO LIKE '%Bloqueado%'
