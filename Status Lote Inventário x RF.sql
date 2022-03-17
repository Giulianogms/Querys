ALTER SESSION SET current_schema = CONSINCO;

SELECT  NROEMPRESA, SEQLOTE, DECODE(SITUACAO,'P','Pendente','F','Fechado','A','Aberto') STATUS, 
        DTAHORFINALIZAATIVIDADE DTA_FINALIZADO, B.CODUSUARIO USUARIO_COLETOR, USUALTERACAO USU_GEROU, DESCRICAO
                    
     FROM MRF_ATIVIDADEUSUARIO A  JOIN Abamv_Ge_Usuario B ON A.SEQUSUARIO = B.SEQUSUARIO
     WHERE   A.SEQLOTE    =   403                         
     AND     A.NROEMPRESA =   33
     ORDER BY DTA_FINALIZADO;
