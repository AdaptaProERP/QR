// Programa   : QRCODEURL
// Fecha/Hora : 11/12/2018 03:45:30
// Propósito  : Generar Codigo QR, DESDE URL
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(cCodigo,cFile,lView)
   LOCAL aChar:={["],"/"}
   Local oDlg
   Local oBmp1
   LOCAL cCodOrg:=cCodigo

   DEFAULT cCodigo:=SQLGET("DPURL","URL_CODIGO")

   lMkDir("QRCODE")

//? cCodigo,cFile,lView

   cCodOrg:=ALLTRIM(SQLGET("DPURL","URL_URL","URL_CODIGO"+GetWhere("=",cCodigo)))

   AEVAL(aChar,{|a,n| cCodigo:=STRTRAN(cCodigo,a,"_")})

   cCodigo:=ALLTRIM(cCodigo)

   DEFAULT cFile  :="QRCODE\FILE"+ALLTRIM(cCodigo)+".BMP",;
           lView  :=.T.  

   // Nombre del Archivo 
   AEVAL(aChar,{|a,n| cFile:=STRTRAN(cFile,a,"_")})

   oDp:oFrameDp:SetText(cFile)

   DPWRITE("TEMP\QRCODE.TXT",cFile)  

      
   IF !FILE("qrcodelib.dll")
      MensajeErr(" Es necesario Archivo qrcodelib.dll")
      RETURN .T.
   ENDIF

   IF .T.
     QRCode( cCodOrg, cFile )
   ENDIF

   IF !lView
      RETURN .T.
   ENDIF

   DEFINE DIALOG oDlg FROM 0,0 TO 500, 440 TITLE "Exibir QRCODE ["+cFile+"]" PIXEL       ;
          COLORS CLR_BLACK, CLR_WHITE

   oDlg:lHelpIcon := .F.

   @ 10,10 BITMAP oBmp1 FILE cFile OF oDlg Size 200,200 PIXEL NOBORDER       ;
           ADJUST

   @ 230,  85 BUTTON "&Sair" SIZE 40, 12 PIXEL OF oDlg                       ;
              ACTION( oDlg:End() ) CANCEL

   ACTIVATE DIALOG oDlg CENTERED

Return Nil
/*
DLL32 STATIC FUNCTION QRCode(cStr As STRING, cFile As STRING) AS LONG PASCAL ;
      FROM "FastQRCode" LIB "QRCodelib.Dll"
RETURN NIL
*/
// EOF

