ALTER SESSION SET current_schema = CONSINCO;

SELECT * FROM MRL_CUSTODIA
WHERE SEQPRODUTO IN ( --Insetir PLU(s)
  /*491556,491563,221957,221956,491327,221959,491341,237492,221972,
    491365,242616,491525,221958,491488,491549,237029,559232,559270*/
  )
                     
ORDER BY DTAENTRADASAIDA DESC
