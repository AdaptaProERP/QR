// Programa   : INVQRCODE
// Fecha/Hora : 14/12/2018 14:27:29
// Propósito  : Codigo QR de Inventario
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo)
  LOCAL cFile
  LOCAL aChar:={["],"/"}

  DEFAULT cCodigo:=SQLGET("DPINV","INV_CODIGO")

  cCodOrg:=cCodigo

  AEVAL(aChar,{|a,n| cCodigo:=STRTRAN(cCodigo,a,"_")})

  lMkDir("QRCODE")

  cFile:="QRCODE\DPINV"+ALLTRIM(cCodigo)+".BMP"

RETURN cFile
// EOF
