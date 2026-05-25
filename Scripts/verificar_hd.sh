#!/bin/bash
# Script para verificar uso do HD de backup e enviar alerta por email se estiver acima de 80%

LIMITE=80
ARQUIVO_CONTROLE="/tmp/alerta_hd_enviado"
DATA_ATUAL=$(date +%F)

USO=$(df -h /mnt/backup_hd | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$USO" -ge "$LIMITE" ]; then

    # Verifica se já enviou alerta hoje
    if [ -f "$ARQUIVO_CONTROLE" ]; then
        DATA_ALERTA=$(cat $ARQUIVO_CONTROLE)
    else
        DATA_ALERTA=""
    fi

    if [ "$DATA_ALERTA" != "$DATA_ATUAL" ]; then
        echo "ALERTA: O HD de backup está com $USO% de uso em $(date)" \
        | mail -s "ALERTA: HD BACKUP ACIMA DE 80%" \
        seu@email.com

        echo "$DATA_ATUAL" > $ARQUIVO_CONTROLE
    fi

else
    # Se o uso baixar, remove controle
    rm -f $ARQUIVO_CONTROLE
fi
