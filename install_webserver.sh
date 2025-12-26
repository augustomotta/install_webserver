#!/usr/bin/env bash
set -e

# -------------------------------------------------------------------
# Script: install_webserver.sh
# Ubuntu: 24.04 LTS
# Função:
#   - Instalar Apache2, MySQL, PHP e phpMyAdmin
#   - Criar comando "webserver" para start/stop dos serviços
# Uso:
#   sudo bash install_webserver.sh
# -------------------------------------------------------------------

if [ "$(id -u)" -ne 0 ]; then
    echo "Este script precisa ser executado como root (use sudo)." >&2
    exit 1
fi

# ==== ENTRADA INTERATIVA DE SENHAS ==================================
echo "=== Configuração de senhas ==="
read -s -p "Defina a senha do usuário root do MySQL: " MYSQL_ROOT_PASSWORD
echo
read -s -p "Confirme a senha do usuário root do MySQL: " MYSQL_ROOT_PASSWORD_CONFIRM
echo

if [ "$MYSQL_ROOT_PASSWORD" != "$MYSQL_ROOT_PASSWORD_CONFIRM" ]; then
    echo "As senhas do MySQL não conferem. Abortando."
    exit 1
fi

read -s -p "Defina a senha interna do phpMyAdmin (app user): " PHPMYADMIN_APP_PWD
echo
read -s -p "Confirme a senha interna do phpMyAdmin (app user): " PHPMYADMIN_APP_PWD_CONFIRM
echo

if [ "$PHPMYADMIN_APP_PWD" != "$PHPMYADMIN_APP_PWD_CONFIRM" ]; then
    echo "As senhas do phpMyAdmin não conferem. Abortando."
    exit 1
fi

HTTP_PORT="80"

# ==== INSTALAÇÃO LAMP + PHPMYADMIN ==================================
echo "Atualizando repositórios..."
apt update -y

echo "Instalando Apache2..."
apt install -y apache2

echo "Habilitando Apache na inicialização..."
systemctl enable apache2
systemctl restart apache2

# Ajusta porta se quiser mudar (basta alterar HTTP_PORT acima)
if [ "$HTTP_PORT" != "80" ]; then
    sed -i "s/Listen 80/Listen ${HTTP_PORT}/" /etc/apache2/ports.conf
    sed -i "s/*:80/*:${HTTP_PORT}/" /etc/apache2/sites-available/000-default.conf
    systemctl restart apache2
fi

echo "Instalando MySQL Server..."
DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

echo "Configurando senha do root no MySQL..."
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

echo "Aplicando endurecimento básico no MySQL..."
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

echo "Instalando PHP e extensões básicas..."
apt install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl

echo "Pré-configurando phpMyAdmin (debconf-set-selections)..."
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password ${PHPMYADMIN_APP_PWD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${MYSQL_ROOT_PASSWORD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password ${PHPMYADMIN_APP_PWD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

echo "Instalando phpMyAdmin..."
DEBIAN_FRONTEND=noninteractive apt install -y phpmyadmin

echo "Habilitando extensão mbstring e configuração do phpMyAdmin..."
phpenmod mbstring || true
if [ -f /etc/apache2/conf-available/phpmyadmin.conf ]; then
    a2enconf phpmyadmin.conf || true
fi
systemctl reload apache2

# ==== CRIAÇÃO DO WRAPPER "webserver" ================================
echo "Criando comando /usr/local/bin/webserver ..."

cat >/usr/local/bin/webserver <<'EOF'
#!/usr/bin/env bash

# Wrapper simples para controlar Apache e MySQL
# Uso:
#   webserver start
#   webserver stop
#   webserver restart
#   webserver status

if [ "$(id -u)" -ne 0 ]; then
    echo "Use sudo para executar este comando (sudo webserver ...)." >&2
    exit 1
fi

ACTION="$1"

if [ -z "$ACTION" ]; then
    echo "Uso: webserver {start|stop|restart|status}"
    exit 1
fi

case "$ACTION" in
    start)
        echo "Iniciando Apache e MySQL..."
        systemctl start apache2
        systemctl start mysql
        ;;
    stop)
        echo "Parando Apache e MySQL..."
        systemctl stop apache2
        systemctl stop mysql
        ;;
    restart)
        echo "Reiniciando Apache e MySQL..."
        systemctl restart apache2
        systemctl restart mysql
        ;;
    status)
        echo "Status do Apache:"
        systemctl --no-pager status apache2 | sed -n '1,5p'
        echo
        echo "Status do MySQL:"
        systemctl --no-pager status mysql | sed -n '1,5p'
        ;;
    *)
        echo "Ação inválida: $ACTION"
        echo "Uso: webserver {start|stop|restart|status}"
        exit 1
        ;;
esac
EOF

chmod +x /usr/local/bin/webserver

# ==== RESUMO ========================================================
IP_SERVER=$(hostname -I | awk '{print $1}')

echo
echo "-------------------------------------------------------------"
echo "Instalação concluída."
echo "Apache rodando em:  http://${IP_SERVER}:${HTTP_PORT}/"
echo "phpMyAdmin em:      http://${IP_SERVER}:${HTTP_PORT}/phpmyadmin"
echo
echo "Comando auxiliar de serviços:"
echo "  sudo webserver start   # inicia Apache e MySQL"
echo "  sudo webserver stop    # para Apache e MySQL"
echo "  sudo webserver restart # reinicia Apache e MySQL"
echo "  sudo webserver status  # status rápido"
echo
echo "Usuário root MySQL: root"
echo "Senha root MySQL:   (a que você definiu)"
echo "Senha phpMyAdmin:   (a que você definiu)"
echo "-------------------------------------------------------------"
