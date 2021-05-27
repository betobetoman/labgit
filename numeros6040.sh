#!/bin/bash

fecha=`date '+%Y%m%d'`
report_file="/var/tmp/numeros6040_${fecha}.html"
> $report_file

echo "<html>" >> $report_file
echo "<head>" >> $report_file
echo "<title>Numeros 60-40 Grupo Modelo "$(date '+%b.%d.%Y')"</title>" >> $report_file
cat /etc2/bin/classes.css >> $report_file
echo "</head>" >> $report_file
echo "<body>" >> $report_file
echo "<p><b>Reporte Mensual de N&uacute;meros 60-40 para Infraestructura de Grupo Modelo</b></p>" >> $report_file
echo "<p>Reporte generado de manera autom&aacute;tica con informaci&oacute;n de servers (JJNA)</p>" >> $report_file
echo "<table width='280' cellpadding='0' cellspacing='0'>" >> $report_file

###INICIANDO VARIABLES
physical=0
virtual=0
chimera=0
totalrealm=0
redhats=0
suses=0
others=0
totalos=0
totalall=0

for c in `cat /etc2/data/hosts.client | cut -d ":" -f2`; do
  for h in `cat /etc2/data/hosts.$c`; do
    if [ "$h" == "HDRP3002" ]; then
      opc="-p 2222"
      h="${h}a"
    else
      opc=""
    fi
    OS=`ssh -q $h $opc "cat /etc/SuSE-release /etc/redhat-release 2>/dev/null" | head -1 | awk '{print $1}'`
    case "$OS" in "Red") ((redhats++));; "SUSE") ((suses++));; *) ((others++));; esac
    ((totalos++))
    realm=`ssh -q $h $opc "sudo /usr/sbin/dmidecode" | grep -A 1 "System Information" | grep Manufacturer | awk '{if ($2 ~ /VMware/) {print "Virtual"} else {print "Fisico"}}'`
    case "$realm" in "Virtual") ((virtual++));; "Fisico") ((physical++));; *) ((chimera++));echo $h;; esac
    ((totalrealm++))
  done
done

echo "<tr><th colspan=2>SERVERS POR TIPO</th></tr>" >> $report_file
echo "<tr><td width='78%'>Servers Virtuales</td><td>$virtual</td>" >> $report_file
echo "<tr><td width='78%'>Servers F&iacute;sicos</td><td>$physical</td>" >> $report_file
if [ $chimera -gt 0 ]; then
  echo "<tr><td width='78%'>Otro tipo</td><td>$chimera</td>" >> $report_file
fi
echo "<tr><th width='78%'>TOTAL</th><th>$totalrealm</th></tr>" >> $report_file
echo "<tr><td>&nbsp;</td></tr>" >> $report_file

echo "<tr><th colspan=2>SERVERS POR SISTEMA OPERATIVO</th></tr>" >> $report_file
echo "<tr><td width='78%'>RedHat Linux</td><td>$redhats</td>" >> $report_file
echo "<tr><td width='78%'>SUSE Linux</td><td>$suses</td>" >> $report_file
if [ $chimera -gt 0 ]; then
  echo "<tr><td width='78%'>Otra distribuci&oacute;n</td><td>$others</td>" >> $report_file
fi
echo "<tr><th width='78%'>TOTAL</th><th>$totalos</th></tr>" >> $report_file
echo "<tr><td>&nbsp;</td></tr>" >> $report_file

echo "<tr><th colspan=2>SERVERS POR CLIENTE</th></tr>" >> $report_file

for c in `cat /etc2/data/hosts.client | cut -d ":" -f2`; do
  cust=`grep $c /etc2/data/hosts.client | cut -d ":" -f1`
  totalcust=`wc -l /etc2/data/hosts.$c | awk '{print $1}'`
  echo "<tr><td width='78%'>$cust</td><td>$totalcust</td></tr>" >> $report_file
  totalall=$((totalall+totalcust))
done
echo "<tr><th width='78%'>TOTAL</th><th>$totalall</th></tr>" >> $report_file

echo "</table>" >> $report_file
echo "</body>" >> $report_file
echo "</html>" >> $report_file

#mailx -a $report_file -s "Reporte 60-40 Grupo Modelo $fecha" juan.nocedal@t-systems.com <<EOF
#Reporte automatico generado mediante script (JJNA)
#EOF

#mutt -e 'set content_type=text/html' -s "Reporte 60-40 Grupo Modelo $fecha" juan.nocedal@t-systems.com < $report_file
mutt -e 'set content_type=text/html' -s "Reporte 60-40 Grupo Modelo $fecha" esmeralda.cruz@t-systems.com < $report_file
ooooo

