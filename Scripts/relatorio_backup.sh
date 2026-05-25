#!/bin/bash
#Script para gerar relatório de backup do SharePoint e enviar por email

RELATORIO="/tmp/relatorio_backup.html"
DATA=$(date)

LOG_RECENTE=$(ls -t /var/log/rclone/*.log 2>/dev/null | head -n 3)

# Detecta status
if grep -qi "error\|failed\|critical" $LOG_RECENTE 2>/dev/null; then
    STATUS="ERRO"
    COR="#ff4d4d"
else
    STATUS="OK"
    COR="#4CAF50"
fi

# Uso de disco
USO=$(df -h /mnt/backup_hd | awk 'NR==2 {print $5}')
DISCO=$(df -h /mnt/backup_hd | awk 'NR==2 {print $3 " / " $2}')

# Tamanhos
SIZE_INC=$(du -sh /mnt/backup_hd/sharepoint 2>/dev/null | awk '{print $1}')
SIZE_FULL=$(du -sh /mnt/backup_hd/full 2>/dev/null | awk '{print $1}')

#Mostra ultimo backup bem sucedido
ULTIMO_LOG=$(ls -t /var/log/rclone/backup_*.log 2>/dev/null | head -n 1)

if [ -n "$ULTIMO_LOG" ]; then
    DATA_BACKUP=$(stat -c %y "$ULTIMO_LOG" | cut -d'.' -f1)
else
    DATA_BACKUP="Nenhum backup encontrado"
fi

ULTIMO_FULL=$(ls -td /mnt/backup_hd/full/* 2>/dev/null | head -n 1)

if [ -n "$ULTIMO_FULL" ]; then
    DATA_FULL=$(basename "$ULTIMO_FULL")
else
    DATA_FULL="Nenhum FULL encontrado"
fi

# Erros recentes
ERROS=$(grep -i "error\|failed\|critical" $LOG_RECENTE 2>/dev/null | tail -n 10)

# HTML
cat <<EOF > $RELATORIO
<html>
<body style="font-family: Arial; background:#f4f6f8; padding:20px;">

<div style="background:white; padding:20px; border-radius:10px;">

<h2>📊 Relatório Backup SharePoint</h2>
<p><b>Data:</b> $DATA</p>

<hr>

<h3>Status Geral</h3>
<p style="color:$COR; font-size:18px;"><b>$STATUS</b></p>

<h3>Último Backup Incremental</h3>
<p><b>$DATA_BACKUP</b></p>

<h3>Último FULL</h3>
<p><b>$DATA_FULL</b></p>

<h3>Uso do Disco</h3>
<ul>
<li><b>Uso:</b> $USO</li>
<li><b>Espaço:</b> $DISCO</li>
</ul>

<h3>Tamanho dos Backups</h3>
<ul>
<li><b>Incremental:</b> $SIZE_INC</li>
<li><b>Full:</b> $SIZE_FULL</li>
</ul>

<h3>Erros Recentes</h3>
<pre style="background:#111; color:#0f0; padding:10px; border-radius:5px;">
$ERROS
</pre>

</div>

</body>
</html>
EOF

# Assunto dinâmico
if [ "$STATUS" = "ERRO" ]; then
    ASSUNTO="[ALERTA] Backup SharePoint com erro"
else
    ASSUNTO="[OK] Backup SharePoint"
fi

# Envio
(
echo "Subject: $ASSUNTO"
echo "Content-Type: text/html"
echo ""
cat "$RELATORIO"
) | msmtp --file=$HOME/.msmtprc  seu@email.com
