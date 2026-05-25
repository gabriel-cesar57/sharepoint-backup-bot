# sharepoint-backup-bot

# DOCUMENTAÇÃO - BACKUP SHAREPOINT

## Objetivo

Este documento descreve a rotina automatizada de backup do SharePoint utilizando Rclone em servidor Debian Linux.

---

## Ambiente

| Item | Descrição |
|---|---|
| Sistema | Debian |
| Ferramenta | Rclone |
| Origem | SharePoint |
| Destino | HD Local |

---

## Estrutura de Diretórios

```bash
/mnt/backup_hd/sharepoint
/mnt/backup_hd/full
/var/log/rclone
```

---

## Scripts

### backup_sharepoint.sh

- Backup incremental diário
- Versionamento de arquivos

### full_sharepoint.sh

- Backup FULL mensal

### retencao_sharepoint.sh

- Limpeza automática caso ultrapassar 30 dias incrementais e 60 dias full
  
### verificar_hd.sh

- Alerta se hd ultrapassar 80% de uso
---

## CRON

```cron
0 23 * * * /usr/local/bin/backup_sharepoint.sh
0 2 1 * * /usr/local/bin/full_sharepoint.sh
```

---

## Política de Retenção

| Tipo | Dias |
|---|---|
| Incremental | 30 |
| FULL | 60 |

---

## Restore

```bash
rclone copy /mnt/backup_hd/sharepoint/PDI /tmp/restore_test
```

---

## Troubleshooting

| Problema | Solução |
|---|---|
| msmtp erro | configurar .msmtprc |
| cron falhando | MAILTO="" |
