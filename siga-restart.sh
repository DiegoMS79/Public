#!/bin/bash
echo "$(date +%Y-%m-%d-%H:%M:%S) Quitando el servidor del balanceo de carga..." > restart.log
echo "$(date +%Y-%m-%d-%H:%M:%S) Quitando el servidor del balanceo de carga..."
echo "" > /usr/share/tomcat7/webapps/SIGANucleo/index.html


RESULT=$(ssh 10.100.100.18 'ipvsadm -L | grep sigatomcat1')
while [ -n "$RESULT" ]
do
        printf "."
        sleep 2s
        RESULT=$(ssh 10.100.100.18 'ipvsadm -L | grep sigatomcat1')
done


echo "$(date +%Y-%m-%d-%H:%M:%S) Deteniendo Tomcat..." >> restart.log
echo "$(date +%Y-%m-%d-%H:%M:%S) Deteniendo Tomcat..."
/etc/init.d/tomcat7 stop

RESULT=1
RESULT1=0
echo "$(date +%Y-%m-%d-%H:%M:%S) Verificando logs..." >> restart.log
echo "$(date +%Y-%m-%d-%H:%M:%S) Verificando logs..."
while [ $RESULT -ne $RESULT1 ]
do
        printf "."
        RESULT=$(cat /usr/share/tomcat7/logs/catalina.out | wc -l)
        sleep 10s
        RESULT1=$(cat /usr/share/tomcat7/logs/catalina.out | wc -l)
done

cho "$(date +%Y-%m-%d-%H:%M:%S) Verificando procesos en memoria..." >> restart.log
echo "$(date +%Y-%m-%d-%H:%M:%S) Verificando procesos en memoria..."
RESULT=$(ps aux | grep -v grep | grep tomcat)
KILLED=0
while [ -n "$RESULT" ]
do
        printf "."
        sleep 10s
                if [ $KILLED -eq 0 ]; then
                        KILLED=1
                        echo "$(date +%Y-%m-%d-%H:%M:%S) Killing process..." >> restart.log
                        ps axu | grep -v grep | grep tomcat | awk '{print $2}' | xargs kill -9

                fi
        RESULT=$(ps aux | grep -v grep | grep tomcat)
done

echo "$(date +%Y-%m-%d-%H:%M:%S) Iiciando Tomcat..." >> restart.log
echo "$(date +%Y-%m-%d-%H:%M:%S) Iiciando Tomcat..."
/etc/init.d/tomcat7 start

RESULT=1
RESULT1=0
while [ $RESULT -ne $RESULT1 ]
do
        printf "."
        RESULT=$(cat /usr/share/tomcat7/logs/catalina.out | wc -l)
        sleep 10s
        RESULT1=$(cat /usr/share/tomcat7/logs/catalina.out | wc -l)
done


echo "$(date +%Y-%m-%d-%H:%M:%S) Riniciado.........." >> restart.log
echo "$(date +%Y-%m-%d-%H:%M:%S) Riniciado.........."

#echo "Servidor Siga Web 1 Reiniciado" | mail -s "Reinicio Siga" -r siga-web-1@ABC.gov.ar ds@abc.gov.a
