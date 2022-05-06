SELECT FORNECEDOR, LPAD(X.NROCNPJCPF, 12, 0) || LPAD(X.DIGCNPJCPF, 2, 0) CNPJ,
       CASE WHEN LPAD(X.NROCNPJCPF, 12, 0) =
              (SELECT MAX(LPAD(D.NROCGCCPF, 12, 0)) FROM CONSINCO.GE_PESSOA D WHERE D.NROCGCCPF = X.NROCNPJCPF AND D.STATUS = 'A')
          THEN 'S' WHEN X.NROCNPJCPF IS NULL THEN NULL ELSE 'N'
       END CNPJ_CADASTRADO,
      GE.FANTASIA EMPRESA, X.CODESPECIE,

 CASE WHEN TO_CHAR(DOC_C5) = TIT_C5 THEN TO_CHAR(DOC_C5) ELSE DOC_C5||' - Tit.: '||TIT_C5 END DOC_C5, 
                   CASE /*WHEN CODESPECIE = 'BONIAC' THEN 'Espécie: BONIAC - Bonificação'*/
                        WHEN DIVERGENCIA IS NULL AND DOCTO IS NULL THEN 'Titulo não encontrado' 
                        WHEN DIVERGENCIA IS NULL AND DOCTO IS NOT NULL THEN 'Motivo não identificado' ELSE DIVERGENCIA END DIVERGENCIA, 
       DOCTO DOCTO_DDA, Emissao, Vencimento, Valor, DESCONTO1, DATADESCONTO1, DESCONTO2, DATADESCONTO2, VALORABATIMENTO, CODIGODEBARRAS

FROM (

SELECT 
       CASE WHEN F.DTAVENCIMENTO = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL - (FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = (DDA.VALORDOCUMENTO - DDA.VALORDESCONTO1) AND DDA.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%')                 THEN 'OK(1)' 
            WHEN F.DTAVENCIMENTO = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL - (FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = (DDA.VALORDOCUMENTO - DDA.VALORDESCONTO1 - DDA.VALORABATIMENTO)AND DDA.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%')    THEN 'OK(2)'
            WHEN F.DTAVENCIMENTO = DDA.DTAVENCIMENTO AND((F.VLRORIGINAL - (FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = (DDA.VALORDOCUMENTO - DDA.VALORDESCONTO1))AND DDA.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%')                 THEN 'OK(3)'
            WHEN F.DTAPROGRAMADA = DDA.DTAVENCIMENTO AND DDA.NRODOCUMENTO LIKE (F.NRODOCUMENTO||'%') AND FC.VLRDESCCONTRATO = DDA.VALORDESCONTO1                                                               THEN 'OK(4)' 
            WHEN F.DTAPROGRAMADA = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL) = DDA.VALORDOCUMENTO AND DDA.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%') AND
                 (CASE WHEN FC.VLRDESCCONTRATO IS NULL THEN '0' ELSE TO_CHAR(FC.VLRDESCCONTRATO) END) = (DDA.VALORDESCONTO1 + DDA.VALORABATIMENTO)                                                                 THEN 'OK(5)'
            WHEN F.DTAVENCIMENTO = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL - (FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = DDA.VALORCOMDESCONTO AND GE.NOMERAZAO LIKE ('%'||DDA.DESCFORNECEDOR||'%')AND (LPAD(DDA.NROCNPJCPFSACADO,12,0)||LPAD(DDA.DIGCNPJCPFSACADO,2,0) = (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN (#LS1))) THEN 'OK(6)' 
            WHEN F.DTAVENCIMENTO = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL - (FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = (DDA.VALORDOCUMENTO - (DDA.VALORDESCONTO1 + DDA.VALORABATIMENTO))AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND (LPAD(DDA.NROCNPJCPFSACADO,12,0)||LPAD(DDA.DIGCNPJCPFSACADO,2,0) = (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN (#LS1))) THEN 'OK(7)'
            WHEN F.DTAVENCIMENTO = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL - ((FC.VLRDESCCONTRATO + F.VLRPAGO)) = (DDA.VALORDOCUMENTO - DDA.VALORDESCONTO1) AND DDA.NRODOCUMENTO LIKE ('%'||F.NROTITULO||'%'))                    THEN 'OK(8)' 
            WHEN F.DTAPROGRAMADA = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL - (FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = (DDA.VALORDOCUMENTO - (DDA.VALORDESCONTO1 + DDA.VALORABATIMENTO))AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA.DESCFORNECEDOR, '(\S*)(\s)')||'%') THEN 'OK(9)'
            WHEN F.DTAPROGRAMADA = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL - (FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = (DDA.VALORDOCUMENTO - DDA.VALORDESCONTO1) AND DDA.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%')                 THEN 'OK(10)'
       ELSE NULL END VLD,
       GE.NOMERAZAO||' - '||GE.SEQPESSOA Fornecedor, DDA2.NRODOCUMENTO DOCTO, F.NRODOCUMENTO DOC_C5, F.NROTITULO TIT_C5, F.CODESPECIE, DDA2.NRODOCUMENTO, DDA.NRODOCUMENTO TITULO_DDA,
       TO_CHAR(DDA2.DTAEMISSAO,'DD/MM/YYYY') EMISSAO, TO_CHAR(DDA2.DTAVENCIMENTO,'DD/MM/YYYY') VENCIMENTO, DDA2.VALORDOCUMENTO VALOR, DDA2.VALORDESCONTO1 DESCONTO1, TO_CHAR(DDA2.DTADESCONTO1,'DD/MM/YYYY') DATADESCONTO1, DDA2.VALORDESCONTO2 DESCONTO2, TO_CHAR(DDA2.DTADESCONTO2,'DD/MM/YYYY') DATADESCONTO2, DDA2.VALORABATIMENTO, DDA2.CODBARRAS CODIGODEBARRAS,
       CASE WHEN (F.VLRORIGINAL - NVL((FC.VLRDESCCONTRATO + F.VLRPAGO),0)) != (DDA2.VALORDOCUMENTO - NVL((DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO),0))
         THEN 'Valor Total Sistema: '||TO_CHAR((F.VLRORIGINAL - NVL((FC.VLRDESCCONTRATO + F.VLRPAGO),0)),'FM999G999G999D90', 'nls_numeric_characters='',.''')||' - DDA: '||
              TO_CHAR(DDA2.VALORCOMDESCONTO,'FM999G999G999D90', 'nls_numeric_characters='',.''')||' | Desconto Sistema: '||
              TO_CHAR(NVL((FC.VLRDESCCONTRATO+FC.VLRDSCFINANC+F.VLRPAGO),0),'FM999G999G999D90', 'nls_numeric_characters='',.''')||' - DDA: '||
              TO_CHAR((DDA2.VALORDESCONTO1 + DDA2.VALORDESCONTO2+DDA2.VALORDESCONTO3+DDA2.VALORABATIMENTO),'FM999G999G999D90', 'nls_numeric_characters='',.''')||CASE WHEN DDA2.DTAVENCIMENTO != F.DTAVENCIMENTO THEN CASE WHEN DDA2.DTAVENCIMENTO != F.DTAPROGRAMADA 
                 THEN ' | Data de Vencimento Sistema: '||TO_CHAR(F.DTAVENCIMENTO, 'DD/MM/YYYY')||' - DDA: '||TO_CHAR(DDA2.DTAVENCIMENTO, 'DD/MM/YYYY') ELSE NULL END ELSE NULL END
            WHEN DDA2.DTAVENCIMENTO != F.DTAVENCIMENTO THEN CASE WHEN DDA2.DTAVENCIMENTO != F.DTAPROGRAMADA 
                 THEN 'Data de Vencimento Sistema: '||TO_CHAR(F.DTAVENCIMENTO, 'DD/MM/YYYY')||' - DDA: '||TO_CHAR(DDA2.DTAVENCIMENTO, 'DD/MM/YYYY') ELSE NULL END
              WHEN (
SELECT SUM(VALORDOCUMENTO) - SUM(A.VALORDESCONTO1) - SUM(A.VALORABATIMENTO)FROM FIV_DDATITULOSBUSCA A 
WHERE A.DTAVENCIMENTO BETWEEN :DT1 AND :DT2
AND NVL(a.ACEITO,'N') = 'N'
AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(A.DESCFORNECEDOR, '(\S*)(\s)')||'%')
AND  (SELECT GEE.NROEMPRESA FROM CONSINCO.GE_EMPRESA GEE
WHERE LPAD(GEE.NROCGC,12,0)||LPAD(GEE.DIGCGC,2,0) = LPAD(A.NROCNPJCPFSACADO,12,0)||LPAD(A.DIGCNPJCPFSACADO,2,0)) IN (#LS1))

= (

SELECT SUM(F2.VLRORIGINAL) - (SUM(FF3.VLRDESCCONTRATO) + SUM(F2.VLRPAGO))
AS VLRSOMADO
FROM FI_TITULO F2 INNER JOIN FI_COMPLTITULO FF3 ON F2.SEQTITULO = FF3.SEQTITULO
WHERE F2.SEQPESSOA = F.SEQPESSOA
AND F2.NROEMPRESA = F.NROEMPRESA
AND F2.DTAVENCIMENTO BETWEEN :DT1 AND :DT2) THEN 'Títulos Agrupados - Verificar'
            ELSE NULL END Divergencia, DDA2.NROCNPJCPF, DDA2.DIGCNPJCPF
       
FROM CONSINCO.FI_TITULO F 
                 INNER JOIN CONSINCO.FI_ESPECIE FI      ON F.CODESPECIE = FI.CODESPECIE AND F.NROEMPRESAMAE = FI.NROEMPRESAMAE
                 INNER JOIN CONSINCO.GE_PESSOA  GE      ON F.SEQPESSOA  = GE.SEQPESSOA  
                 INNER JOIN CONSINCO.FI_COMPLTITULO  FC ON F.SEQTITULO  = FC.SEQTITULO
                     LEFT JOIN CONSINCO.FIV_DDATITULOSBUSCA DDA ON
                    F.DTAVENCIMENTO = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL -(FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = (DDA.VALORDOCUMENTO - DDA.VALORDESCONTO1)
                 AND DDA.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%')
                 OR F.DTAVENCIMENTO = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL -(FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = (DDA.VALORDOCUMENTO - DDA.VALORDESCONTO1 - DDA.VALORABATIMENTO)
                 AND DDA.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%')
                 OR F.DTAPROGRAMADA = DDA.DTAVENCIMENTO AND DDA.NRODOCUMENTO LIKE (F.NRODOCUMENTO||'%')
                 AND FC.VLRDESCCONTRATO = DDA.VALORDESCONTO1
                 OR F.DTAPROGRAMADA = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL) = DDA.VALORDOCUMENTO
                 AND DDA.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%') AND
                 (CASE WHEN FC.VLRDESCCONTRATO IS NULL THEN '0' ELSE TO_CHAR(FC.VLRDESCCONTRATO) END) = (DDA.VALORDESCONTO1 + DDA.VALORABATIMENTO)
                 OR F.DTAVENCIMENTO = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL - (FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = DDA.VALORCOMDESCONTO 
                 AND GE.NOMERAZAO LIKE ('%'||DDA.DESCFORNECEDOR||'%') AND (LPAD(DDA.NROCNPJCPFSACADO,12,0)||LPAD(DDA.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN (#LS1)))
                 OR F.DTAVENCIMENTO = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL - (FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = (DDA.VALORDOCUMENTO - (DDA.VALORDESCONTO1 + DDA.VALORABATIMENTO))
                 AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND (LPAD(DDA.NROCNPJCPFSACADO,12,0)||LPAD(DDA.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN (#LS1)))
                 OR F.DTAVENCIMENTO = DDA.DTAVENCIMENTO AND ((F.VLRORIGINAL - (FC.VLRDESCCONTRATO + F.VLRPAGO + FC.VLRDSCFINANC)) = (DDA.VALORDOCUMENTO - DDA.VALORDESCONTO1) 
                 AND DDA.NRODOCUMENTO LIKE ('%'||F.NROTITULO||'%'))
                 OR F.DTAPROGRAMADA = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL - (FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = (DDA.VALORDOCUMENTO - (DDA.VALORDESCONTO1 + DDA.VALORABATIMENTO))
                 AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND (LPAD(DDA.NROCNPJCPFSACADO,12,0)||LPAD(DDA.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN (#LS1)))
                 OR F.DTAPROGRAMADA = DDA.DTAVENCIMENTO AND (F.VLRORIGINAL - (FC.VLRDESCCONTRATO + FC.VLRDSCFINANC)) = (DDA.VALORDOCUMENTO - DDA.VALORDESCONTO1)
                 AND DDA.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%')
                    LEFT JOIN CONSINCO.FIV_DDATITULOSBUSCA DDA2 ON
                 GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND DDA2.DTAVENCIMENTO = F.DTAVENCIMENTO AND DDA2.NRODOCUMENTO LIKE ('%'||F.NROTITULO||'%')
                 OR GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND DDA2.DTAVENCIMENTO = F.DTAPROGRAMADA AND DDA2.NRODOCUMENTO LIKE ('%'||F.NROTITULO||'%')
                 OR GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND DDA2.DTAVENCIMENTO = F.DTAVENCIMENTO AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%')
                 OR GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND DDA2.DTAVENCIMENTO = F.DTAPROGRAMADA AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%')
                 OR GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND DDA2.NRODOCUMENTO LIKE ('%'||F.NROTITULO||'%') AND ((F.VLRORIGINAL - (FC.VLRDESCCONTRATO + F.VLRPAGO)) = (DDA2.VALORDOCUMENTO - (DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO)))
                 OR DDA2.DTAVENCIMENTO = F.DTAVENCIMENTO AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%') AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%')
                 OR DDA2.DTAVENCIMENTO = F.DTAPROGRAMADA AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%') AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%')
                 OR GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND DDA2.NRODOCUMENTO LIKE ('%'||F.NROTITULO||'%') AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN (#LS1))) AND ((F.VLRORIGINAL - (FC.VLRDESCCONTRATO + F.VLRPAGO)) = (DDA2.VALORDOCUMENTO - (DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO)))  
                 OR GE.NOMERAZAO LIKE ('%'||DDA2.DESCFORNECEDOR||'%') AND ((F.VLRORIGINAL - (FC.VLRDESCCONTRATO + F.VLRPAGO)) = (DDA2.VALORDOCUMENTO - (DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO))) AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN (#LS1)))
                 OR (F.VLRORIGINAL) = (DDA2.VALORDOCUMENTO) AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 40) AND (F.DTAVENCIMENTO + 40) AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%')
                 OR DDA2.DTAVENCIMENTO = F.DTAVENCIMENTO AND DDA2.NRODOCUMENTO LIKE ('%'||F.NROTITULO||'%')
                 OR (F.VLRORIGINAL) = (DDA2.VALORDOCUMENTO) AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 40) AND (F.DTAVENCIMENTO + 40) AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0) FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN (#LS1)))
                 OR ((F.VLRORIGINAL - (FC.VLRDESCCONTRATO + F.VLRPAGO)) = (DDA2.VALORDOCUMENTO - (DDA2.VALORDESCONTO1 + DDA2.VALORABATIMENTO))) AND GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND DDA2.NRODOCUMENTO LIKE ('%'||F.NRODOCUMENTO||'%')
                 OR GE.NOMERAZAO LIKE ('%'||REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)')||'%') AND DDA2.DTAVENCIMENTO = F.DTAPROGRAMADA AND (LPAD(DDA2.NROCNPJCPFSACADO,12,0)||LPAD(DDA2.DIGCNPJCPFSACADO,2,0) IN (SELECT LPAD(DE.NROCGCCPF,12,0)||LPAD(DE.DIGCGCCPF,2,0)  FROM CONSINCO.GE_PESSOA DE WHERE SEQPESSOA IN(#LS1)))


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
  
) X, GE_EMPRESA GE
 
WHERE VLD IS NULL
AND GE.NROEMPRESA = :LS1

ORDER BY 1 
