#!/bin/bash
# Script para realizar backup FULL do SharePoint usando rclone e enviar email em caso de erros

DATE=$(date +%F)
LOG="/var/log/rclone/full_$DATE.log"

mkdir -p /var/log/rclone

declare -A SITES
SITES=(
["AssistenciaTecnica"]="assistencia-tecnica:"
["Comercial"]="comercial:"
["Fabricacao"]="fabricacao:"
["Financeiro"]="financeiro:"
["Laboratorio"]="laboratorio:"
["Logistica"]="logistica:"
["PDI"]="pdi:"
["Qualidade"]="qualidade:"
["RH"]="rh:"
["TI"]="ti:"
)

ERRO=0

for SITE in "${!SITES[@]}"
do
    echo "FULL Backup de $SITE iniciado..."

    mkdir -p "/mnt/backup_hd/full/$DATE/$SITE"

    rclone sync "${SITES[$SITE]}" "/mnt/backup_hd/full/$DATE/$SITE" \
    --create-empty-src-dirs \
    --log-file="$LOG" \
    --log-level INFO \
    --progress \
    --stats 30s \
    --transfers 8 \
    --checkers 16 \
    --retries 3

    if [ $? -ne 0 ]; then
        echo "Erro no FULL de $SITE" >> $LOG
        ERRO=1
    fi

    echo "FULL Backup de $SITE finalizado."
done

if [ $ERRO -ne 0 ]; then
echo "Backup FULL SharePoint FALHOU em $(date)" | mail -s "ERRO BACKUP FULL SHAREPOINT" seu@email.com
fi
