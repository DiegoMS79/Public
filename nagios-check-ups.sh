#!/bin/bash


print_usage() {
        echo ""
        echo "Este script chequea el estado de las UPS APC"
                echo "installed using snmp version 1."
                echo ""
        echo "Usage: $0 <snmp community> <hostname> <umbral>"
        echo ""
        exit 3
}


if [ $# -lt 3 ] ; then
        print_usage
fi

UPSstatus=$(snmpget -v 1 -c $1 $3 .1.3.6.1.4.1.318.1.1.1.4.1.1.0)

if [[ -z $UPSstatus ]] ; then
    echo "UPS not responding"
    #exit 3
    exit 0 #no alertar en caso de corte de enlace
fi

testing=$(echo $UPSstatus | grep "No Such")

if [[ $? -eq 0 ]] ; then
    echo "Unknown: Check SNMP OID"
    exit 3
fi



UPSstatus=$(echo "$UPSstatus" | awk '{print $4}')
if [[ $UPSstatus -eq 3 ]] ; then
    #upsstatus
    #3 = on battery
    #2 = on line

    BatteryCapacity=$(snmpget -v 1 -c $1 $3 .1.3.6.1.4.1.318.1.1.1.2.2.1.0)
    testing=$(echo $BatteryCapacity | grep "No Such")
    if [[ $? -eq 0 ]] ; then
        echo "Unknown: Check SNMP OID"
        exit 3
    fi

    testing=$(echo "$BatteryCapacity" | awk '{print $4}')
    if [[ $testing -lt $2 ]] ; then

        #si la carga de la bateria bajo hasta 98 es porque no arranco el grupo
        TimeOnBattery=$(snmpget -v 1 -c $1 $3 .1.3.6.1.4.1.318.1.1.1.2.1.2.0 | awk '{print $5}')
        RemainingTimeOnBattery=$(snmpget -v 1 -c $1 $3 .1.3.6.1.4.1.318.1.1.1.2.2.3.0 | awk '{print $5}')

        echo "UPS ON BATTERY POWER hace $TimeOnBattery -- Capacidad ${testing}% -- Tiempo de Duracion de Baterias ${RemainingTimeOnBattery} -- Detectado $(date)"

        exit 2
    fi

fi



echo "Todo OK"
exit 0
