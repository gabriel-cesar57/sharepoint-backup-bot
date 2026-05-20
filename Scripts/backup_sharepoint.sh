#!/bin/bash
# Script para realizar backup do SharePoint usando rclone e enviar email em caso de erros

DATE=$(date +%F)
LOG="/var/log/rclone/backup_$DATE.log"

mkdir -p /var/log/rclone

declare -A SITES
SITES=(
["AssistenciaTecnica"]="assistencia-tecnica"
["Comercial"]="comercial"
["Fabricacao"]="fabricacao"
["Financeiro"]="financeiro"
["Laboratorio"]="laboratorio"
["Logistica"]="logistica"
["PDI"]="pdi"
["Qualidade"]="qualidade"
["RH"]="rh"
["TI"]="ti"
)

ERRO=0

for SITE in "${!SITES[@]}"
do
    echo "Backup de $SITE iniciado..."

    rclone sync "${SITES[$SITE]}:" "/mnt/backup_hd/sharepoint/$SITE" \
    --backup-dir="/mnt/backup_hd/sharepoint/versionados/$DATE/$SITE" \
    --create-empty-src-dirs \
    --delete-during \
    --log-file="$LOG" \
    --log-level INFO \
    --progress \
    --stats 5s \
    --transfers 8 \
    --checkers 16 \
    --retries 3 
    if [ $? -ne 0 ]; then
        echo "Erro no backup de $SITE" >> "$LOG"
        ERRO=1
    fi

    echo "Backup de $SITE finalizado."
done

if [ $ERRO -ne 0 ]; then
{
    echo "Backup SharePoint FALHOU em $(date)"
    echo ""
    echo "Erros encontrados:"
    echo "-----------------------------------"
    grep -i "error\|failed" "$LOG"
} | mail -s "ERRO BACKUP SHAREPOINT" gabriel.cesar@intermetro.com.br pdi@intermetro.com.br coordenacao.pdi@intermetro.com.br
fi
