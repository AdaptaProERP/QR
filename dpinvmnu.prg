// Programa   : DPINVMNU
// Fecha/Hora : 18/09/2010 17:22:34
// Propósito  : Menú Abastaecimiento de Producto
// Creado Por : Juan Navas
// Llamado por: DPINVCON
// Aplicación : Inventario
// Tabla      : DPINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodInv)
   LOCAL cNombre:="",cSql,I,nGroup,cUtiliz
   LOCAL oFont,oFontB,oOut,oCursor,oBtn,oBar,oBmp
   LOCAL oBtn,nGroup,bAction,aBtn:={}

   DEFAULT cCodInv:="10005",;
           oDp:aCoors:=GetCoors( GetDesktopWindow() )

   cNombre:=SQLGET("DPINV","INV_DESCRI,INV_UTILIZ","INV_CODIGO"+GetWhere("=",cCodInv))
   cUtiliz:=IF( Empty(oDp:aRow),"",oDp:aRow[2])

   IF "Eventos"$cUtiliz
     EJECUTAR("DPINVMNUEVENTOS",cCodInv)
     RETURN .T.
   ENDIF

   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-14
   DEFINE FONT oFontB   NAME "Tahoma" SIZE 0,-14 BOLD

   DpMdi("Menú "+oDp:xDPINV,"oInvMnu","")

   oInvMnu:cCodInv   :=cCodInv
   oInvMnu:cNombre   :=cNombre
   oInvMnu:lSalir  :=.F.
   oInvMnu:nHeightD:=45
   oInvMnu:lMsgBar :=.F.
   oInvMnu:oGrp    :=NIL
   oInvMnu:cUtiliz :=cUtiliz

   SetScript("DPINVMNU")

   AADD(aBtn,{"Unidades de Medida"       ,"RULERS.BMP"           ,"MEDIDAS"}) 
   AADD(aBtn,{"Precios de Venta"         ,"PRECIOS.BMP"          ,"PRECIOS"})

   IF oDp:nVersion>=5
     AADD(aBtn,{"Precios Líneas y Columnas"  ,"PRECIOENBROWSE.BMP"      ,"PRECIOSXY"})
     AADD(aBtn,{"Imprimir Etiquetas de Barra","barcodeprint.BMP"         ,"BARRAS"})
   ENDIF

   IF oDp:nVersion>=5.1
     AADD(aBtn,{"Dirección URL del Producto"  ,"EXPLORER.BMP"      ,"URL"})
   ENDIF


   AADD(aBtn,{"Promociones"              ,"PROMOCION.BMP"        ,"PROMOCI"})
   

// Se desactivo para evitar que los usarios carguen inventaro inicial por aca ya que no se puede emitir un reporte
   AADD(aBtn,{"Inventario Inicial"       ,"entradaysalida.BMP"   ,"INICIAL"}) 
   AADD(aBtn,{"Equivalencias"            ,"BARCODE.BMP"          ,"EQUIVAL"})
   AADD(aBtn,{"Sustitutos"               ,"SUSTITUTOS.BMP"       ,"SUSTITU"})
   AADD(aBtn,{oDp:DPUBICACFIS            ,"UBICACIONFISICA.BMP"  ,"UBICAC" })

   IF .T. 
 //ISRELEASE("18.11")
      AADD(aBtn,{"Código QR"                ,"QRCODE.BMP"           ,"QRCODE" })
   ENDIF

   IF oDp:nVersion>=4.1 .AND. (oDp:cIdApl="9")
     AADD(aBtn,{"Memo por Tipo Documento","XMEMO.BMP"          ,"MEMOS"})
   ENDIF

   IF (cUtiliz="E" .OR. cUtiliz="H" .OR. cUtiliz="S") .AND. oDp:nVersion>=5 .AND. (oDp:cIdApl="9")
     AADD(aBtn,{"Eventos"                ,"EVENTOS.BMP"         ,"EVENTOS"})
   ENDIF

   IF "DATAPRO"$UPPE(oDp:cEmpresa ) .OR. "ADAPTAPRO"$UPPE(oDp:cEmpresa )
     AADD(aBtn,{"Licencias"              ,"LOGODP2.BMP"       ,"LICENCIAS"})
   ENDIF

//  oInvMnu:Windows(0,0,400+10+140+10,410+5)
   oInvMnu:Windows(0,0,oDp:aCoors[3]-160,415)  


  @ 48, -1 OUTLOOK oInvMnu:oOut ;
     SIZE 150+250, oInvMnu:oWnd:nHeight()-90;
     PIXEL ;
     FONT oFont ;
     OF oInvMnu:oWnd;
     COLOR CLR_BLACK,16774120

   DEFINE GROUP OF OUTLOOK oInvMnu:oOut PROMPT "&Vinculos del "+oDp:xDPINV

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oInvMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oInvMnu:oOut:aGroup)
      oBtn:=ATAIL(oInvMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oInvMnu:INVACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oInvMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I

   DEFINE GROUP OF OUTLOOK oInvMnu:oOut PROMPT "&Abastecimiento"

   aBtn:={}

   IF (oDp:cIdApl="9")
      // Debe pertener al PlugIn de Producción

      AADD(aBtn,{"Componentes"                      ,"COMPONENTE.BMP"       ,"COMPONE"})
      AADD(aBtn,{GetFromVar("{oDp:DPFORMULASPROD}") ,"FORMULA.BMP"  ,"FORMULA"})
      AADD(aBtn,{"Componentes de Producción"        ,"RECETA.BMP"           ,"RECETA" })
      AADD(aBtn,{"Fases de Produccion"              ,"ordenesproduccion.bmp","FASE"   })

   ENDIF

   IF DPVERSION()>= 4.1
     AADD(aBtn,{oDp:DPINVPLAABAST                  ,"ABASTECIMIENTO.BMP"          ,"ABAST"  })
   ENDIF


   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oInvMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oInvMnu:oOut:aGroup)
      oBtn:=ATAIL(oInvMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oInvMnu:INVACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oInvMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I


   DEFINE GROUP OF OUTLOOK oInvMnu:oOut PROMPT "&Restricciones"

   aBtn:={}

   AADD(aBtn,{"Por Sucursal","SUCURSAL.BMP"       ,"RESXSUC"})

   IF oDp:cIdApl="9"
     AADD(aBtn,{oDp:DPTIPDOCCLI+" No Permitidos","DOCCXC.BMP"          ,"TIPDOCCLI"})
   ENDIF

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oInvMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oInvMnu:oOut:aGroup)
      oBtn:=ATAIL(oInvMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oInvMnu:INVACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oInvMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction

   NEXT I

IF oDp:nVersion>=6.0 

   DEFINE GROUP OF OUTLOOK oInvMnu:oOut PROMPT "&Recursos"

   aBtn:={}

   AADD(aBtn,{"Recursos"        ,"RECURSOS.BMP"    ,"RECURSOS"})
   AADD(aBtn,{oDp:DPTIPDOCCLI   ,"TIPDOCUMENT.BMP" ,"RECURSOSTDC"})

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oInvMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oInvMnu:oOut:aGroup)
      oBtn:=ATAIL(oInvMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oInvMnu:INVACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oInvMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction

   NEXT I

ENDIF

/*
   @ 0, 100 SPLITTER oInvMnu:oSpl ;
            VERTICAL ;
            PREVIOUS CONTROLS oInvMnu:oOut ;
            LEFT MARGIN 70 ;
            RIGHT MARGIN 200 ;
            SIZE 40, 10  PIXEL ;
            OF oInvMnu:oWnd ;
             _3DLOOK ;
            UPDATE

   DEFINE DIALOG oInvMnu:oDlg FROM 0,oInvMnu:oOut:nWidth() TO oInvMnu:nHeightD,700;
          TITLE "" STYLE WS_CHILD OF oInvMnu:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oInvMnu:oGrp TO 10,10 PROMPT "Código ["+oInvMnu:cCodInv+"] "+oInvMnu:cUtiliz

   @ .5,.5 SAY oInvMnu:cNombre SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontB

   ACTIVATE DIALOG oInvMnu:oDlg NOWAIT VALID .F.
*/
   oInvMnu:Activate("oInvMnu:FRMINIT()",,"oInvMnu:oSpl:AdjRight()")

   EJECUTAR("DPSUBMENUCREAREG",oInvMnu,NIL,"S","DPINV")

 
RETURN oInvMnu

FUNCTION FRMINIT()
   LOCAL oCursor,oBar,oBtn,oFont,nCol:=12

   DEFINE BUTTONBAR oBar SIZE 42,42 OF oInvMnu:oWnd 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD

   IF oDp:nVersion>=6 .OR. ISRELEASE("18.11")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XBROWSE.BMP",NIL,"BITMAPS\XBROWSEG.BMP";
            ACTION EJECUTAR("OUTLOOKTOBRW",oInvMnu:oOut,oInvMnu:cCodInv,oInvMnu:cNombre,"DPINV","Menú"),oInvMnu:End();
            WHEN oDp:nVersion>=6

 ENDIF


 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oInvMnu:End()

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),;
                             nCol:=nCol+o:nWidth()})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 UNDERLINE BOLD

  @ 1,nCol SAYREF oInvMnu:oCodInv PROMPT oInvMnu:cCodInv;
           SIZE 120,19 PIXEL COLOR CLR_WHITE,16744448 OF oBar FONT oFont

  SayAction(oInvMnu:oCodInv,{||EJECUTAR("DPINV",0,oInvMnu:cCodInv)})


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD
 
  @ 21,nCol SAY oInvMnu:cNombre;
            SIZE 300,19 BORDER  PIXEL COLOR CLR_WHITE,16744448 OF oBar FONT oFont

  @ 1,311 CHECKBOX oDp:lMenuInv PROMPT "Menú" OF oBar PIXEL FONT oFont SIZE 80,19 

  
  oBar:Refresh(.T.)

  oInvMnu:oWnd:bResized:={||oInvMnu:oWnd:oClient := oInvMnu:oOut,;
                          oInvMnu:oWnd:bResized:=NIL}

                       

/*
   oInvMnu:oWnd:bResized:={||oInvMnu:oDlg:Move(0,0,oInvMnu:oWnd:nWidth(),50,.T.),;
                             oInvMnu:oGrp:Move(0,0,oInvMnu:oWnd:nWidth()-15,oInvMnu:nHeightD,.T.)}

   EVal(oInvMnu:oWnd:bResized)
*/



RETURN .T.

FUNCTION INVACTION(cAction)
   LOCAL cGrupo,cTitle,cFile,nOption:=1
   LOCAL cWhere:=NIL,cCodSuc:=NIL,nPeriodo:=NIL,dDesde:=NIL,dHasta:=NIL,cTitle:=NIL

   IF cAction="MEDIDAS"
      EJECUTAR("DPINVMED",oInvMnu:cCodInv,,oInvMnu:cNombre)
      RETURN .F.
   ENDIF

   IF cAction=="PRECIOS"
      EJECUTAR("DPPRECIOS",oInvMnu:cCodInv,oInvMnu:cNombre)
      RETURN .F.
   ENDIF

   IF cAction=="PRECIOSXY"
      EJECUTAR("DPPRECIOXY",oInvMnu:cCodInv,oInvMnu:cNombre)
      RETURN .F.
   ENDIF


   IF cAction="INICIAL"
      EJECUTAR("DPINVINICIAL",oInvMnu:cCodInv,oInvMnu:cNombre)
      RETURN .F.
   ENDIF
/*
   IF cAction="CONTAB"
      cGrupo:=MYSQLGET("DPINV","INV_GRUPO","INV_CODIGO"+GetWhere("=",oInvMnu:cCodInv))
      EJECUTAR("DPGRUCTA",3,cGrupo)
      RETURN .F.
   ENDIF
*/
   IF cAction="PROMOCI"
      EJECUTAR("DPINVPROMOCION",oInvMnu:cCodInv,,oInvMnu:cNombre)
      RETURN .F.
   ENDIF

   IF cAction="EQUIVAL"
      EJECUTAR("DPINVEQUIV",oInvMnu:cCodInv,oInvMnu:cNombre)
      RETURN .F.
   ENDIF

   IF cAction="SUSTITU"
      EJECUTAR("DPSUSTITUTOS",oInvMnu:cCodInv)
      RETURN .F.
   ENDIF

   IF cAction="COMPONE"
      EJECUTAR("DPCOMPONENTES",oInvMnu:cCodInv)
      RETURN .F.
   ENDIF

   IF cAction="FORMULA"
     EJECUTAR("DPFORMULASPROD",oInvMnu:cCodInv)
     RETURN .T.
   ENDIF

   IF cAction="RECETA"
     EJECUTAR("DPCOMPPRODUCCIO",oInvMnu:cCodInv)
     RETURN .T.
   ENDIF

   IF cAction="UBICAC"
     EJECUTAR("DPINVUBIFIS",oInvMnu:cCodInv)
     RETURN .T.
   ENDIF

   IF cAction="CLOSE"
      oInvMnu:End()
      RETURN .F.
   ENDIF

   IF cAction="FASE"
      EJECUTAR("DPFASEPRODUCC",oInvMnu:cCodInv)
      RETURN .T.
   ENDIF

   IF cAction="ABAST"
      EJECUTAR("DPINVMNUPLAABA",oInvMnu:cCodInv)
      RETURN .T.
   ENDIF

   IF cAction="LICENCIAS"
      EJECUTAR("DPLICMENU",oInvMnu:cCodInv)
   ENDIF

   IF cAction="TIPDOCCLI" .OR. cAction="MEMO"
      cTitle:=IF(cAction="TIPDOCCLI","Restricción por Tipo de Documento","Memo por Tipo de Documento")
      EJECUTAR("DPINVTIPDOCCLI",oInvMnu:cCodInv,oInvMnu:cNombre,NIL,cTitle,NIL,NIL,NIL,cAction="MEMO")
   ENDIF

   IF cAction="EVENTOS"
      EJECUTAR("DPINVEVENTOS",oInvMnu:cCodInv)
   ENDIF

   IF cAction="BARRAS"
      EJECUTAR("DPINVBARRA","INV_CODIGO"+GetWhere("=",oInvMnu:cCodInv))
   ENDIF

   IF cAction="RESXSUC"
      EJECUTAR("DPINVXSUC",oInvMnu:cCodInv,oInvMnu:cNombre)
   ENDIF

   IF cAction="QRCODE"
      cFile:=EJECUTAR("INVQRCODE",oInvMnu:cCodInv)
      EJECUTAR("QRCODE",oInvMnu:cCodInv,cFile,.T.)
   ENDIF

   IF cAction=="RECURSOS"
      EJECUTAR("DPESTRUCTORDOCREQM","INV"+oInvMnu:cCodInv,NIL,oInvMnu:cCodInv,oInvMnu:cNombre,"INV",ALLTRIM(oDp:DPINV))
   ENDIF

   IF cAction=="RECURSOSTDC"
      EJECUTAR("BRINVRECXTIPDOC",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,oInvMnu:cCodInv)
   ENDIF

   IF cAction=="URL"
      nOption:=IF(ISSQLFIND("DPINVURL","URL_CODINV"+GetWhere("=",oInvMnu:cCodInv)),3,1)
      EJECUTAR("DPINVURL",nOption,oInvMnu:cCodInv)
   ENDIF

RETURN .T.
// EOF

