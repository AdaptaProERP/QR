// Programa   : QRMECARDCLI
// Fecha/Hora : 01/12/2018 18:50:09
// Propósito  :
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCli,lView)
   LOCAL cText,oTable,cFile

   DEFAULT cCodCli:=SQLGET("DPCLIENTES","CLI_CODIGO")

   oTable:=OpenTable("SELECT * FROM DPCLIENTES WHERE CLI_CODIGO"+GetWhere("=",cCodCli),.T.)
   oTable:End()
   
   cText:="BEGIN:VCARD"+CRLF+;
          "N:"           +ALLTRIM(oTable:CLI_NOMBRE)+CRLF+;
          "TEL;CELL:"    +ALLTRIM(oTable:CLI_TEL1  )+CRLF+;
          "TEL;WORK:"    +ALLTRIM(oTable:CLI_TEL2  )+CRLF+;
          "TEL;WORK;FAX:"+ALLTRIM(oTable:CLI_TEL3  )+CRLF+;
          "TEL;HOME:"    +ALLTRIM(oTable:CLI_TEL4  )+CRLF+;
          "ADR;HOME:;;"  +ALLTRIM(oTable:CLI_DIR1  )+ALLTRIM(oTable:CLI_DIR2)+" "+ALLTRIM(oTable:CLI_DIR3)+CRLF+;
          "EMAIL:"       +ALLTRIM(oTable:CLI_EMAIL )+CRLF+;
          "URL:http:"    +ALLTRIM(oTable:CLI_WEB   )+CRLF+;
          "NOTE:"        +"CODIGO="+ALLTRIM(oTable:CLI_CODIGO)+" RIF="+ALLTRIM(oTable:CLI_RIF   )+CRLF+;
          "END:VCARD"

   cFile:="QRCODE\DPCLI_"+ALLTRIM(oTable:CLI_CODIGO)+".BMP"
/*
cText:="BEGIN:VCARD"+CRLF+"N:Reinaldo Zambrano"+CRLF+;
"TEL;CELL:600555555"+CRLF+"TEL;WORK:915555555"+CRLF+;
"TEL;WORK;FAX:915555555"+CRLF+;
"TEL;HOME:915555555"+CRLF+;
"TEL;HOME;FAX:915555555"+CRLF+;
"ADR;HOME:;;C/ calle, 12, 2º Derecha;Ciudad;Estado;28001;País"+CRLF+;
"ORG:empresa;departamento"+CRLF+;
"TITLE:Mr"+CRLF+;
"EMAIL:email@ejemplo.com"+CRLF+;
"URL:http://www.50gramos.com"+CRLF+;
"EMAIL;IM:email@hotmail.com"+CRLF+;
"NOTE:Anotación del contacto"+CRLF+;
"BDAY:19800101"+;
"END:VCARD"
*/
   EJECUTAR("QRCODE", cText, cFile ,lView )

RETURN
// EOF