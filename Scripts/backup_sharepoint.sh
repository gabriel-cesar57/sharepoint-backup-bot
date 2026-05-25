#!/bin/bash
# Script para realizar backup do SharePoint usando rclone e enviar email em caso de erros

#variavel data e log
DATE=$(date +%F)
LOG="/var/log/rclone/backup_$DATE.log"

#cria os diretórios de logs
mkdir -p /var/log/rclone

# Sites do Sharepoint que deseja realizar o backup (nomes devem ser iguais ao apresentados no Sharepoint Admin)
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

#variavel erro, inicia nula
ERRO=0

#inicia a sincronização e copia dos dados de cada site mencionado anteriormente. Se houver erros, adiciona os detalhes no log.
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

#caso erro, enviar log por email
if [ $ERRO -ne 0 ]; then
{
    echo "Backup SharePoint FALHOU em $(date)"
    echo ""
    echo "Erros encontrados:"
    echo "-----------------------------------"
    grep -i "error\|failed" "$LOG"
} | mail -s "ERRO BACKUP SHAREPOINT" seu@email.com
fi
