#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M415GRV   º Autor ³ EMERSON TAMBORILO  º Data ³  19/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CONTROLE DE EMPENHO DOS ORCAMENTOS.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function A415TDOK()

Local aAreaSF4		:= SF4->(GetArea())
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSCJ		:= SCJ->(GetArea())
Local aAreaSCK		:= SCK->(GetArea())
Local aAreaTMP1		:= TMP1->(GetArea())
Local aFisGet		:= {}
Local aFisGetSCJ	:= {}
Local aDupl     	:= {}
Local aVencto   	:= {}
Local aEntr     	:= {}
Local aDuplTmp  	:= {}
Local aRentab   	:= {}
Local nPSuframa 	:= 0
Local nUsado    	:= Len(aHeader)
Local nAcerto   	:= 0
Local nPrcLista 	:= 0
Local nValMerc  	:= 0
Local nDesconto 	:= 0
Local nAcresFin 	:= 0	// Valor do acrescimo financeiro do total do item
Local nQtdPeso  	:= 0
Local nRecOri   	:= 0
Local nPosEntr  	:= 0
Local nValorIpi 	:= 0
Local nValIcm		:= 0
Local nY        	:= 0
Local nPosCpo   	:= 0
Local lDtEmi    	:= SuperGetMv("MV_DPDTEMI",.F.,.T.)
Local dDataCnd  	:= M->CJ_EMISSAO
Local oDlg
Local oDupl
Local oFolder
Local oRentab
Local lCondVenda 	:= .F.
Local aRentabil 	:= {}
Local cProduto  	:= ""
Local nTotDesc  	:= 0
Local lSaldo    	:= .f. //MV_PAR04 == 1 .And. !INCLUI
Local nQtdEnt   	:= 0
Local aSolid		:= {}
Local nLancAp		:=	0
Local aHeadCDA		:=	{}
Local aColsCDA		:=	{}
Local aTransp		:= {"","",""}
Local nAcresUnit	:= 0	// Valor do acrescimo financeiro do valor unitario
Local nAcresTot 	:= 0	// Somatoria dos Valores dos acrescimos financeiros dos itens
PRIVATE oLancApICMS

M->CJ_TJDATA := DATE()
M->CJ_TJHORA := TIME()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca referencias no SCK                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFisGet	:= {}
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SCK")
While !Eof().And.X3_ARQUIVO=="SCK"
	cValid := UPPER(X3_VALID+X3_VLDUSER)
	If 'MAFISGET("'$cValid
		nPosIni 	:= AT('MAFISGET("',cValid)+10
		nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
		cReferencia := Substr(cValid,nPosIni,nLen)
		aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
	EndIf
	If 'MAFISREF("'$cValid
		nPosIni		:= AT('MAFISREF("',cValid) + 10
		cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
		aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
	EndIf
	dbSkip()
EndDo
aSort(aFisGet,,,{|x,y| x[3]<y[3]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca referencias no SCJ                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFisGetSCJ	:= {}
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SCJ")
While !Eof().And.X3_ARQUIVO=="SCJ"
	cValid := UPPER(X3_VALID+X3_VLDUSER)
	If 'MAFISGET("'$cValid
		nPosIni 	:= AT('MAFISGET("',cValid)+10
		nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
		cReferencia := Substr(cValid,nPosIni,nLen)
		aAdd(aFisGetSCJ,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
	EndIf
	If 'MAFISREF("'$cValid
		nPosIni		:= AT('MAFISREF("',cValid) + 10
		cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
		aAdd(aFisGetSCJ,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
	EndIf
	dbSkip()
EndDo

aSort(aFisGetSCJ,,,{|x,y| x[3]<y[3]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza alteracoes de referencias do SCJ         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aFisGetSCJ) > 0
	dbSelectArea("SCJ")
	For nY := 1 to Len(aFisGetSCJ)
		If !Empty(&("M->"+Alltrim(aFisGetSCJ[ny][2])))
			MaFisAlt(aFisGetSCJ[ny][1],&("M->"+Alltrim(aFisGetSCJ[ny][2])),,.F.)
		EndIf
	Next nY
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Agrega os itens para a funcao fiscal         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nQtdPeso := 0
TMP1->(DbGotop())

While TMP1->(!Eof())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona Registros                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	SB2->(dbSetOrder(1))
	SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD+TMP1->CK_LOCAL))
	SF4->(dbSetOrder(1))
	SF4->(MsSeek(xFilial("SF4")+TMP1->CK_TES))
	
	If lSaldo .And. nPItem > 0
		dbSelectArea("SCK")
		dbSetOrder(1)
		MsSeek(xFilial("SCK")+M->CJ_NUM+TMP1->CK_ITEM+TMP1->CK_PRODUTO)
		nQtdEnt := IIf(!SubStr(TMP1->CK_BLQ,1,1)$"RS" .And. Empty(TMP1->CK_BLOQUEI),TMP1->CK_QTDENT,TMP1->CK_QTDVEN)
	Else
		lSaldo := .F.
	EndIf
	
	cProduto := TMP1->CK_PRODUTO
	MatGrdPrRf(@cProduto)
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+cProduto))
		nQtdPeso := TMP1->CK_QTDVEN*SB1->B1_PESO
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o preco de lista                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValMerc  := If(TMP1->CK_QTDVEN==0,TMP1->CK_VALOR,If(lSaldo,(TMP1->CK_QTDVEN-nQtdEnt)*TMP1->CK_PRCVEN,TMP1->CK_VALOR))
	
	nDesconto := TMP1->CK_VALDESC //a410Arred(nPrcLista*If(lSaldo,TMP1->CK_QTDVEN-nQtdEnt,TMP1->CK_QTDVEN),"D2_DESCON")-nValMerc
	If ( nPrcLista == 0 )
		nValMerc  := If(TMP1->CK_QTDVEN==0,TMP1->CK_VALOR,If(lSaldo,(TMP1->CK_QTDVEN-nQtdEnt)*TMP1->CK_PRCVEN,TMP1->CK_VALOR))
		nDesconto := 0
	EndIf
	
	//Para os outros paises, este tratamento e feito no programas que calculam os impostos.
	If cPaisLoc=="BRA"
		nValMerc  += nDesconto
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a data de entrega para as duplicatas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dDataCnd  := M->CJ_EMISSAO
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a funcao fiscal                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisSave()
	MaFisEnd()
	MaFisIni(Iif(Empty(M->CJ_CLIENT),M->CJ_CLIENTE,M->CJ_CLIENT),;// 1-Codigo Cliente/Fornecedor
	M->CJ_LOJAENT,;		// 2-Loja do Cliente/Fornecedor
	IIf(M->CJ_TIPO$'DB',"F","C"),;				// 3-C:Cliente , F:Fornecedor
	M->CJ_TIPO,;				// 4-Tipo da NF
	M->CJ_TIPOCLI,;		// 5-Tipo do Cliente/Fornecedor
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	"MATA461",;
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	aTransp)
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrega os itens para a funcao fiscal         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisAdd(cProduto,;   		// 1-Codigo do Produto ( Obrigatorio )
	TMP1->CK_TES,;	   			// 2-Codigo do TES ( Opcional )
	TMP1->CK_QTDVEN,;  			// 3-Quantidade ( Obrigatorio )
	nPrcLista,;		  			// 4-Preco Unitario ( Obrigatorio )
	nDesconto,; 				// 5-Valor do Desconto ( Opcional )
	"",;	   					// 6-Numero da NF Original ( Devolucao/Benef )
	"",;						// 7-Serie da NF Original ( Devolucao/Benef )
	nRecOri,;					// 8-RecNo da NF Original no arq SD1/SD2
	0,;							// 9-Valor do Frete do Item ( Opcional )
	0,;							// 10-Valor da Despesa do item ( Opcional )
	0,;							// 11-Valor do Seguro do item ( Opcional )
	0,;							// 12-Valor do Frete Autonomo ( Opcional )
	nValMerc,;					// 13-Valor da Mercadoria ( Obrigatorio )
	0,;							// 14-Valor da Embalagem ( Opiconal )
	,;							// 15
	,;							// 16
	TMP1->CK_ITEM,; 			// 17
	0,;							// 18-Despesas nao tributadas - Portugal
	0,;							// 19-Tara - Portugal
	SF4->F4_CF)					// 20-CFO
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do ISS                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( SF4->F4_ISS=="S" )
		nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
		nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
		MaFisAlt("IT_PRCUNI",nPrcLista,1) //NITEM
		MaFisAlt("IT_VALMERC",nValMerc,1 ) //nItem)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Altera peso para calcular frete              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisAlt("IT_PESO",nQtdPeso,1)//nItem)
	MaFisAlt("IT_PRCUNI",nPrcLista,1)//nItem)
	MaFisAlt("IT_VALMERC",nValMerc,1)//nItem)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Analise da Rentabilidade                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF4->F4_DUPLIC=="S"
		nTotDesc += MaFisRet(1,"IT_DESCONTO")//NITEM
		nY := aScan(aRentab,{|x| x[1] == TMP1->CK_PRODUTO})
		If nY == 0
			aadd(aRenTab,{TMP1->CK_PRODUTO,0,0,0,0,0})
			nY := Len(aRenTab)
		EndIf
		If cPaisLoc=="BRA"
			aRentab[nY][2] += (nValMerc - nDesconto)
		Else
			aRentab[nY][2] += nValMerc
		Endif
		aRentab[nY][3] += If(lSaldo,TMP1->CK_QTDVEN-nQtdEnt,TMP1->CK_QTDVEN)*SB2->B2_CM1
	Else
		If GetNewPar("MV_TPDPIND","1")=="1"
			nTotDesc += MaFisRet(1,"IT_DESCONTO")//NITEM
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indica os valores do cabecalho               ³ // criar estes campos
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisAlt("NF_FRETE",M->CJ_FRETE)
	MaFisAlt("NF_VLR_FRT",M->CJ_VLR_FRT)
	MaFisAlt("NF_SEGURO",M->CJ_SEGURO)
	MaFisAlt("NF_AUTONOMO",M->CJ_FRETAUT)
	MaFisAlt("NF_DESPESA",M->CJ_DESPESA)
	If cPaisLoc == "PTG"
		MaFisAlt("NF_DESNTRB",M->CJ_DESNTRB)
		MaFisAlt("NF_TARA",M->CJ_TARA)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indenizacao por valor                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->CJ_DESCONT > 0
		MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,nTotDesc+M->CJ_DESCONT),/*nItem*/,/*lNoCabec*/,/*nItemNao*/,GetNewPar("MV_TPDPIND","1")=="2" )
	EndIf
	
	If M->CJ_PDESCAB > 0
		MaFisAlt("NF_DESCONTO",A410Arred(MaFisRet(,"NF_VALMERC")*M->CJ_PDESCAB/100,"CK_VALOR")+MaFisRet(,"NF_DESCONTO"))
	EndIf
	
	IF M->CJ_TIPO <> "D"
		nValorIpi    := MaFisRet(1,"IT_VALIPI")//NITEM
		nValIcm      := MaFisRet(1,"IT_VALICM")//NITEM
		nValIcmST    := MaFisRet(1,"IT_VALSOL")//NITEM
		//nTotal       := IIF(Posicione("SF4",1,xFilial("SF4")+TMP1->CK_TES,"F4_INCSOL")=="S",nValIcmST,0) // nValorIpi+nValIcm
	ELSE
		//nTotal := 0 // nValorIpi+nValIcm
	ENDIF
	
	TMP1->CK_XICMSRE := nValIcmST
	
	TMP1->(DbSkip())
End

RestArea(aAreaSF4)
RestArea(aAreaSA1)
RestArea(aAreaSCJ)
RestArea(aAreaSCK)
RestArea(aAreaTMP1)

Return  (.t.)