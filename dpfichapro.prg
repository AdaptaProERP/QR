// Programa   : DPFICHAPRO
// Fecha/Hora : 10/08/2004 12:10:53
// Propósito  : Construir la Ficha del Cliente
// Creado Por : Juan Navas
// Llamado por: REPORTE 
// Aplicación : Nómina
// Tabla      : DPPROVEEDOR

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodIni,cFile,lAdd,cWhere,cOrder,oDlg,oText,oMeter,lEnd,lView)
   LOCAL aStruct:={},cSql,aFields:={},cMemo,cFileScg:="forms\DPPROVEEDOR.SCG",I
   LOCAL aData  :={},aView:={},nAt,uValue,cRefere:="",lParam
   LOCAL oTable,oBtn
   LOCAL cCodFin,oLee
   LOCAL aRecord:={}

   oDp:lMySqlNativo:=.T.

   CURSORWAIT()

   lParam:=(!cWhere=NIL)

   DEFAULT cCodIni:=STRZERO(1,10),cCodFin:=cCodIni,cFile:=oDp:cPathScr+"PROVEEDOR.DBF",lAdd:=.T.,lEnd:=.F.,lView:=.T.

   AADD(aStruct,{"CODIGO"  ,"C",10,0})
   AADD(aStruct,{"CAMPO"   ,"C",10,0})
   AADD(aStruct,{"DESCRI"  ,"C",40,0})
   AADD(aStruct,{"VALOR"   ,"C",40,0})
   AADD(aStruct,{"REFERE"  ,"C",40,0}) // Referencia

   // Campos
   AADD(aFields,{"PRO_CODIGO","","",""})
   AADD(aFields,{"PRO_NOMBRE","","",""})
   AADD(aFields,{"PRO_RIF"   ,"","",""})

   // Obtiene los Datos según la Ficha de Carga de Datos
   cMemo :=MemoRead(cFileScg)
   cMemo :=STRTRAN(cMemo,CHR(13),"")
   aData :=_VECTOR(cMemo,CHR(10))

   FOR I=1 TO LEN(aData)

      aData[I]   :=_VECTOR(aData[I],CHR(9))
      aData[I,03]:=STRTRAN(aData[I,03],CHR(8),CRLF)
      aData[I,04]:=STRTRAN(aData[I,04],CHR(8),CRLF)
      aData[I,05]:=STRTRAN(aData[I,05],CHR(8),CRLF)
      aData[I,06]:=STRTRAN(aData[I,06],CHR(8),CRLF) 
      aData[I,07]:=STRTRAN(aData[I,07],CHR(8),"")
      aData[I,08]:=STRTRAN(aData[I,08],CHR(8),"")

      nAt:=ASCAN(aFields,{|a|a[1]==aData[I,1]})

      IF nAt=0
        AADD(aFields,{aData[I,1],aData[I,2],aData[I,07]})
      ENDIF

   NEXT I

   // Complementa los Datos según la Estructura del Trabajador
   // lAdd:=.T. Indica los Campos no Visuales de la Ficha

   oTable:=OpenTable("SELECT CAM_NAME,CAM_DESCRI FROM DPCAMPOS WHERE CAM_TABLE='DPPROVEEDOR'",.T.)
   oTable:GoTop()
   WHILE !oTable:Eof()
     nAt:=ASCAN(aFields,{|a,n|ALLTRIM(a[1])==ALLTRIM(oTable:CAM_NAME)})
     IF nAt=0
       AADD(aFields,{oTable:CAM_NAME,oTable:CAM_DESCRI,"","",""})
     ENDIF
     IF nAt>0 .AND. EMPTY(aFields[nAt,2])
       aFields[nAt,2]:=GetFromVar(oTable:CAM_DESCRI)
     ENDIF
     oTable:DbSkip()
   ENDDO
   oTable:End()

   /*
   // Lee trabajador por Trabajador y Genera una Nueva Estructura
   */
   IF EMPTY(cWhere) .AND. !lParam
      cWhere:=" WHERE (PRO_CODIGO"+GetWhere(">=",cCodIni)+" AND PRO_CODIGO"+GetWhere("<=",cCodFin)+")"
   ENDIF

   cOrder:=IIF( EMPTY(cOrder) , " ORDER BY PRO_CODIGO " , cOrder )

   oLee  :=OpenTable("SELECT PRO_CODIGO FROM DPPROVEEDOR "+cWhere+cOrder,.T.)

//   ? oLee:cSql
//   oLee:Browse()
//   oLee:End()

   IIF(ValType(oMeter)="O",oMeter:SetTotal(oLee:RecCount()),NIL)

   oLee:Gotop()

   WHILE !oLee:Eof() .AND. !lEnd

      oTable:=OpenTable("SELECT * FROM DPPROVEEDOR WHERE PRO_CODIGO"+GetWhere("=",oLee:PRO_CODIGO),.T.)

      IF oLee:Recno()=1
         AEVAL(oTable:aFields,{|a,n|PUBLICO(a[1],NIL)})
      ENDIF

      FOR I=1 TO LEN(aFields)
    
         nAt    :=oTable:FieldPos(aFields[I,1])
         uValue :=oTable:FieldGet(nAt)
         cRefere:=""

         AEVAL(oTable:aFields,{|a,n|PUBLICO(a[1],oTable:FieldGet(n))})

         IF ValType(uValue)="C".AND.!EMPTY(SAYOPTIONS("DPPROVEEDOR",aFields[I,1],uValue))
            uValue:=SAYOPTIONS("DPPROVEEDOR",aFields[I,1],uValue)
         ENDIF
 
         IF Valtype(uValue)="L"
            uValue:=IIF(uValue,"Si","No")
         ENDIF

         IF !EMPTY(aFields[I,3])
            cRefere:=MacroEje(aFields[I,3])
         ENDIF

       AADD(aRecord,{ALLTRIM(aFields[I,2])+":",;
                     uValue      ,;
                     cRefere})

      NEXT I
              
      oLee:DbSkip()
      oTable:End()

   ENDDO
 
   AEVAL(aRecord,{|a,n|aRecord[n,1]:=GetFromVar(aRecord[n,1])})
   AEVAL(oTable:aFields,{|a,n|__MXRELEASE(a[1])})

   oTable:End()
   oLee:End()

   oDp:lMySqlNativo:=.F.

  //  ViewArray(aRecord)
   IF lView
     VIEW_FICHA(aRecord,cCodIni)
   ENDIF

RETURN .t.

FUNCTION VIEW_FICHA(aRecord,cCodPro)
  LOCAL oDlg,oFont,oFontB,oBrw

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

  oFichaP:=DPEDIT():New("Ficha del "+GetFromVar("{oDp:xDPPROVEEDOR}")+" ["+ALLTRIM(cCodPro)+"]","DPFICHAPRO.edt","oFichaP",.T.)
  oFichaP:cCodPro  :=cCodPro
  oFichaP:cNombre  :=MySQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",cCodPro))

  oDlg:=oFichaP:oDlg

  oBrw:=TXBrowse():New( oDlg )

  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aRecord, .F. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .F.
  oBrw:oFont               :=oFont
  oBrw:nHeaderLines        := 1

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oBrw:CreateFromCode()

  oBrw:aCols[1]:cHeader:="Campo"
  oBrw:aCols[1]:nWidth :=185+20
  oBrw:aCols[1]:nDataStrAlign:= AL_RIGHT
  oBrw:aCols[1]:nHeadStrAlign:= AL_RIGHT

  oBrw:aCols[2]:cHeader  :="Valor"
  oBrw:aCols[2]:nWidth   :=235
  oBrw:aCols[2]:oDataFont:=oFontB

  oBrw:aCols[3]:cHeader:="Referencia"
  oBrw:aCols[3]:nWidth :=305-20

  oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oBrw:bClrStd   :={|oBrw,cCod,nClrText|oBrw:=oFichaP:oBrw,;
                               nClrText:=0,;
                               {nClrText, iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ) } }

  oBrw:aCols[2]:bClrStd     :={|oBrw|oBrw:=oFichaP:oBrw,;
                               IIF(oBrw:nArrayAt%2=0,{CLR_BLACK,15790320},{CLR_BLUE,16382457})}

  oBrw:aCols[3]:bClrStd     :={|oBrw|oBrw:=oFichaP:oBrw,;
                               IIF(oBrw:nArrayAt%2=0,{CLR_BLACK,15790320},{CLR_RED,16382457})}

//oBrw:bLDblClick:={|oBrw,cCodCon|oBrw:=oFichaP:oBrw,cCodCon:=oBrw:aArrayData[oBrw:nArrayAt,1],;
//                   EJECUTAR("NMRECVIEW",oBrw:aArrayData[oBrw:nArrayAt,09])}

  oBrw:SetFont(oFont)

  oFichaP:oBrw:=oBrw
  oFichaP:Activate({||oFichaP:FICHABAR(oFichaP)})

  DpFocus(oBrw)

  oDp:nDif:=(oDp:aCoors[3]-160-oFichaP:oWnd:nHeight())
  oFichaP:oWnd:SetSize(NIL,oDp:aCoors[3]-160,.T.)
  oFichaP:oBrw:SetSize(NIL,oFichaP:oBrw:nHeight()+oDp:nDif+5,.T.)


  STORE NIL TO oBrw,oDlg
//  Memory(-1)

RETURN .T.


/*
// Coloca la Barra de Botones
*/
FUNCTION FICHABAR(oFichaP)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oFichaP:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oFichaP:oRep:=REPORTE("DPPROFICHA"),;
                 oFichaP:oRep:SetRango(1,oFichaP:cCodPro,oFichaP:cCodPro))

   oBtn:cToolTip:="Imprimir Ficha"

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\qrcode.BMP";
          ACTION EJECUTAR("QRMECARDPRO",oFichaP:cCodPro);
          WHEN .t.

   oBtn:cToolTip:="Código QR"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XCOPY.BMP";
          ACTION oFichaP:COPIARNCLP()

   oBtn:cToolTip:="Copiar en ClipBoard"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oFichaP:oBrw,oFichaP:cTitle,oFichaP:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oFichaP:oBrw:GoTop(),oFichaP:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oFichaP:oBrw:PageDown(),oFichaP:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oFichaP:oBrw:PageUp(),oFichaP:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oFichaP:oBrw:GoBottom(),oFichaP:oBrw:Setfocus())

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oFichaP:Close()

  oFichaP:oBrw:SetColor(0,15790320)

//  @ 0.1,60 SAY oFichaP:cNombre OF oBar BORDER SIZE 345,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.

FUNCTION COPIARNCLP()
   LOCAL cMemo:="",nLen:=10

   AEVAL(oFichaP:oBrw:aArrayData,{|a,n|nLen:=MAX(nLen,LEN(a[1])) })

   AEVAL(oFichaP:oBrw:aArrayData,{|a,n|cMemo:=cMemo+PADR(a[1],nLen)+":"+CTOO(a[2],"C")+CRLF})

   CLPCOPY(cMemo)

   MensajeErr("Ficha Copiada en ClipBoard")

RETURN .T.

// EOF



