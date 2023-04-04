// Programa   : QRFORM
// Fecha/Hora : 05/10/2012 00:35:19
// Propósito  : Muestra del Formulario
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

   oFrmQr:=DPEDIT():New("Generar Código QR","forms\QRFORM.edt","oFrmQr",.T.)

   oFrmQr:cNombre:=SPACE(100)
   oFrmQr:nValor :=0
   oFrmQr:lActivo:=.T.
   oFrmQr:cMemo  :=SPACE(100)
   oFrmQr:oSayMsg:=NIL
   oFrmQr:cMsg   :=""
   oFrmQr:cFile  :=PADR(CURDRIVE()+":\"+CURDIR()+"\QRCODE\QR"+LSTR(SECONDS())+".BMP",250)

   @ 1,01 SAY "Texto : " RIGHT

   @ 5,06 GET oFrmQr:oMemo VAR oFrmQr:cMemo MULTI;
          VALID oFrmQr:VALMEMO()

   oFrmQr:oMemo:bKeyDown:={|nkey| oFrmQr:oBntRun:ForWhen(.T.)}

   @ 10,10 BITMAP oFrmQr:oBmp FILE oFrmQr:cFile OF oFrmQr:oDlg Size 200,200 PIXEL;
           ADJUST

   @ 2,01 SAY "Archivo : " RIGHT

   @ 5,06 GET oFrmQr:oFile VAR oFrmQr:cFile

   oFrmQr:Activate({|| oFrmQr:FORMINI()} )

RETURN

FUNCTION VALMEMO()
   oFrmQr:oBntRun:ForWhen(.T.)
RETURN .T.

FUNCTION FORMINI()
  LOCAL oFontB
  LOCAL oCursor,oBar,oBtn,oFont,oCol
  LOCAL oDlg:=oFrmQr:oDlg

  DEFINE CURSOR oCursor HAND
  DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
         WHEN !Empty(oFrmQr:cMemo);
         ACTION (oFrmQr:QRCREAR()) CANCEL

  oFrmQr:oBntRun:=oBtn

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\XSALIR.BMP";
         ACTION (oFrmQr:Cancel()) CANCEL

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })
 
RETURN NIL

FUNCTION QRCREAR()

 QRCode( alltrim(oFrmQr:cMemo), ALLTRIM(oFrmQr:cFile) )

 oFrmQr:oBmp:LoadBMP(ALLTRIM(oFrmQr:cFile))

 oFrmQr:oBmp:Refresh(.T.)

RETURN .T.
// EOF
