#!/bin/bash
# Script para realizar limpeza de backups antigos do SharePoint, mantendo apenas os últimos 30 dias incrementais e 60 dias FULLs

# caminhos
INC="/mnt/backup_hd/sharepoint/versionados"
FULL="/mnt/backup_hd/full"

# retenção
RET_INC=30
RET_FULL=60

echo "Iniciando limpeza de backups..."

echo "Removendo incrementais antigos..."
find "$INC" -mindepth 1 -maxdepth 1 -type d -mtime +$RET_INC -print -exec rm -rf {} \;

echo "Removendo FULL antigos..."
find "$FULL" -mindepth 1 -maxdepth 1 -type d -mtime +$RET_FULL -print -exec rm -rf {} \;

echo "Limpeza concluída."
