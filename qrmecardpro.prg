// Programa   : QRMECARDPRO
// Fecha/Hora : 01/12/2018 18:50:09
// Propósito  :
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodPro,lView)
   LOCAL cText,oTable,cFile

   DEFAULT cCodPro:=SQLGET("DPPROVEEDOR","PRO_CODIGO")

   oTable:=OpenTable("SELECT * FROM DPPROVEEDOR WHERE PRO_CODIGO"+GetWhere("=",cCodPro),.T.)
   oTable:End()
   
   cText:="BEGIN:VCARD"+CRLF+;
          "N:"           +ALLTRIM(oTable:PRO_NOMBRE)+CRLF+;
          "TEL;CELL:"    +ALLTRIM(oTable:PRO_TEL1  )+CRLF+;
          "TEL;WORK:"    +ALLTRIM(oTable:PRO_TEL2  )+CRLF+;
          "TEL;WORK;FAX:"+ALLTRIM(oTable:PRO_TEL3  )+CRLF+;
          "TEL;HOME:"    +ALLTRIM(oTable:PRO_TEL4  )+CRLF+;
          "ADR;HOME:;;"  +ALLTRIM(oTable:PRO_DIR1  )+ALLTRIM(oTable:PRO_DIR2)+" "+ALLTRIM(oTable:PRO_DIR3)+CRLF+;
          "EMAIL:"       +ALLTRIM(oTable:PRO_EMAIL )+CRLF+;
          "URL:http:"    +ALLTRIM(oTable:PRO_WEB   )+CRLF+;
          "NOTE:"        +"CODIGO="+ALLTRIM(oTable:PRO_CODIGO)+" RIF="+ALLTRIM(oTable:PRO_RIF   )+CRLF+;
          "END:VCARD"

   cFile:="QRCODE\DPPRO_"+ALLTRIM(oTable:PRO_CODIGO)+".BMP"
   EJECUTAR("QRCODE", cText, cFile ,lView )

RETURN
// EOF
