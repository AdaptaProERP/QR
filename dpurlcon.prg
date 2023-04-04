// Programa   : DPURLCON
// Fecha/Hora : 22/02/2021 10:41:47
// Prop¢sito  : Menu de DPURL	
// Creado Por : DPXBASE
// Llamado por: DPURL.LBX
// Aplicaci¢n : Menú de consulta DPURL
// Tabla      : DPURL

#INCLUDE "DPXBASE.CH"
#include "outlook.ch"
#include "splitter.Ch"

PROCE MAIN(cCodigo,cNombre,oFrm)
   LOCAL oFont,oOut,oBar,oBtn,oBar,nGroup,cTitle,nNumMain:=0,nNumMemo:=0
   LOCAL lField_Dig:=.F.
   LOCAL lField_Mem:=.F.

   DEFAULT cCodigo:=SQLGET("DPURL","URL_CODIGO          ") 

   DEFAULT cName:=SQLGET("DPURL","URL_DESCRI          ")

   lField_Dig:=.F. // ISFIELD("DPURL","                    ")  // Campo Digitalización

   lField_Mem:=.F. // ISFIELD("DPURL","                    ")  // Campo Memo

   IF Empty(cNombre) .AND. ISFIELD("DPURL","URL_DESCRI          ")
      // Busca Nombre de Descripcion o Nombre
      cNombre:=SQLGET("DPURL","URL_DESCRI          ","URL_CODIGO          "+GetWhere("=",cCodigo))
   ENDIF


   IF lField_Dig
     nNumMain:=SQLGET("DPURL","                    ","URL_CODIGO          "+GetWhere("=",oURLCON:cCodigo))
   ENDIF

   IF lField_Mem
      nNumMemo:=SQLGET("DPURL","                    ","URL_CODIGO          "+GetWhere("=",oURLCON:cCodigo))
   ENDIF


   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-14
   DEFINE FONT oFontBrw NAME "Tahoma" SIZE 0,-10 BOLD

   cTitle:="Menú de Consulta "+GetFromVar("{oDp:DPURL}")

   DpMdi(cTitle,"oURLCON","")

   oURLCON:cCodigo   :=cCodigo
   oURLCON:cNombre   :=cNombre
   oURLCON:lSalir    :=.F.
   oURLCON:nHeightD  :=45
   oURLCON:cTitle    :=cTitle
   oURLCON:lMsgBar   :=.F.
   oURLCON:oFrm      :=oFrm
   oURLCON:nNumMemo  :=nNumMemo

   SetScript("DPURLCON")

   oURLCON:Windows(0,0,540,410)


   @ 48, -1 OUTLOOK oURLCON:oOut ;
     SIZE 150+250, oURLCON:oWnd:nHeight()-90 ;
     PIXEL ;
     FONT oFont ;
     OF oURLCON:oWnd;
     COLOR CLR_BLACK,15400703


   DEFINE GROUP OF OUTLOOK oURLCON:oOut PROMPT "&Opciones"

   DEFINE BITMAP OF OUTLOOK oURLCON:oOut ;
          BITMAP "BITMAPS\\VIEW.BMP" ;
          PROMPT "Consultar Registro" ;
          ACTION  (oURLCON:REGAUDITORIA("Consultar Registro"),;
                   EJECUTAR("DPURL",2,oURLCON:cCodigo))

   DEFINE BITMAP OF OUTLOOK oURLCON:oOut ;
          BITMAP "BITMAPS\QRCODE.BMP" ;
          PROMPT "Generar Código QR" ;
          ACTION  (oURLCON:REGAUDITORIA("Consultar QR"),;
                   EJECUTAR("QRCODEURL",oURLCON:cCodigo))

   DEFINE BITMAP OF OUTLOOK oURLCON:oOut ;
          BITMAP "BITMAPS\\AUDITORIA.BMP" ;
          PROMPT "Auditoria del Registro" ;
          ACTION  (oURLCON:REGAUDITORIA("Consultar Auditoria por Registro"),;
                   EJECUTAR("VIEWAUDITOR","DPURL",oURLCON:cCodigo,oURLCON:cNombre))

   DEFINE BITMAP OF OUTLOOK oURLCON:oOut ;
          BITMAP "BITMAPS\\AUDITORIA.BMP" ;
          PROMPT "Auditoria por Campo" ;
          ACTION  (oURLCON:REGAUDITORIA("Consultar Auditoria por Campo"),;
                   EJECUTAR("DPAUDITAEMC",oURLCON:oFrm,"DPURL","DPURL.SCG",oURLCON:cCodigo,oURLCON:cNombre,"URL_CODIGO          "+GetWhere("=",oURLCON:cCodigo)))


   IF lField_Dig .AND. nNumMain>0

      DEFINE BITMAP OF OUTLOOK oURLCON:oOut ;
             BITMAP "BITMAPS\\ADJUNTAR.BMP";
             PROMPT "Digitalización";
             ACTION oURLCON:MNUDIGITALIZAR()

   ENDIF

   IF lField_Mem

      DEFINE BITMAP OF OUTLOOK oURLCON:oOut ;
             BITMAP "BITMAPS\\XMEMO.BMP";
             PROMPT "Descripción Amplia";
             ACTION oURLCON:REGMEMOS()

   ENDIF


   DEFINE BITMAP OF OUTLOOK oURLCON:oOut ;
          BITMAP "BITMAPS\\XSALIR.BMP";
          PROMPT "Salir";
          ACTION oURLCON:CLOSE()


   DEFINE DIALOG oURLCON:oDlg FROM 0,oURLCON:oOut:nWidth() TO oURLCON:nHeightD,700;
          TITLE "" STYLE WS_CHILD OF oURLCON:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oURLCON:oGrp TO 10,10 PROMPT "Código ["+oURLCON:cCodigo+"]" FONT oFont

   @ .5,.5 SAY oURLCON:cNombre SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFont

   ACTIVATE DIALOG oURLCON:oDlg NOWAIT VALID .F.

   oURLCON:Activate("oURLCON:FRMINIT()")

 
RETURN

FUNCTION FRMINIT()

   oURLCON:oWnd:bResized:={||oURLCON:oDlg:Move(0,0,oURLCON:oWnd:nWidth(),50,.T.),;
                             oURLCON:oGrp:Move(0,0,oURLCON:oWnd:nWidth()-15,oURLCON:nHeightD,.T.)}


   EVal(oURLCON:oWnd:bResized)

RETURN .T.

FUNCTION MNUDIGITALIZAR()

   LOCAL nNumMain:=SQLGET("DPURL","                    ","URL_CODIGO          "+GetWhere("=",oURLCON:cCodigo))

   oURLCON:REGAUDITORIA("Consultar Registro de Digitalización "+LSTR(nNumMain))

   nNumMain:=EJECUTAR("DPFILEEMPMAIN",nNumMain,NIL,NIL,.T.,.T.)

   SQLUPDATE("DPURL","                    ",nNumMain,"URL_CODIGO          "+GetWhere("=",oURLCON:cCodigo))

RETURN .F.

FUNCTION REGMEMOS()
   LOCAL cTitle,cWhere

   oURLCON:REGAUDITORIA("Consultar Registro Memo "+LSTR(oURLCON:nNumMemo))

   EJECUTAR("DPMEMOMDIEDIT","DPURL","URL_CODIGO          ","                    ",oURLCON:cCodigo,cTitle,cWhere,.T.)

RETURN .F.

FUNCTION REGAUDITORIA(cConsulta)
RETURN EJECUTAR("AUDITORIA","DCON",.F.,"DPURL",oURLCON:cCodigo,NIL,NIL,NIL,NIL,cConsulta)



// EOF
