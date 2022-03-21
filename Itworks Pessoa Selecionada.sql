ALTER SESSION SET current_schema = CONSINCO;

SELECT T.* 
FROM CONSINCO.NAGV_PESSOAITWORKS T
WHERE T.RAZAO_SOCIAL <> ('CADASTRADO PELA LEITURA DO CAIXA')
    AND LPAD(T.CNPJCPF,14,0) = ((SELECT LPAD(ge.nrocgccpf,12,0)||LPAD(GE.DIGCGCCPF,2,0) 
    FROM CONSINCO.GE_PESSOA GE WHERE GE.SEQPESSOA = :NR1));


    
    
