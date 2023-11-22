#!/bin/bash

# Atualizar lista de pacotes
sudo apt-get update

# Instalar o servidor FTP (vsftpd)
sudo apt-get install -y vsftpd

# Fazer backup do arquivo de configuração original
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original

# Criar um diretório para armazenar configurações adicionais
sudo mkdir /etc/vsftpd

# Criar um arquivo de configuração para usuários virtuais
sudo touch /etc/vsftpd/virtual_users.txt

# Adicionar usuários virtuais ao arquivo virtual_users.txt
# O formato é: username:password
echo "ftpuser1:ftppassword1" | sudo tee -a /etc/vsftpd/virtual_users.txt
echo "ftpuser2:ftppassword2" | sudo tee -a /etc/vsftpd/virtual_users.txt

# Criar um script para criar usuários virtuais
sudo touch /etc/vsftpd/virtual_users.sh
sudo chmod +x /etc/vsftpd/virtual_users.sh

echo '#!/bin/bash' | sudo tee -a /etc/vsftpd/virtual_users.sh
echo 'while IFS=: read -r local_user local_password' | sudo tee -a /etc/vsftpd/virtual_users.sh
echo 'do' | sudo tee -a /etc/vsftpd/virtual_users.sh
echo '    echo "Adding user $local_user"' | sudo tee -a /etc/vsftpd/virtual_users.sh
echo '    sudo useradd -m $local_user -p $(openssl passwd -1 $local_password)' | sudo tee -a /etc/vsftpd/virtual_users.sh
echo 'done < /etc/vsftpd/virtual_users.txt' | sudo tee -a /etc/vsftpd/virtual_users.sh

# Executar o script para criar usuários virtuais
sudo bash /etc/vsftpd/virtual_users.sh

# Remover senhas do arquivo virtual_users.txt
sudo rm /etc/vsftpd/virtual_users.txt

# Editar o arquivo de configuração do vsftpd
sudo nano /etc/vsftpd.conf

# Adicionar/configurar as seguintes linhas:
echo "listen=YES" | sudo tee -a /etc/vsftpd.conf
echo "anonymous_enable=NO" | sudo tee -a /etc/vsftpd.conf
echo "local_enable=YES" | sudo tee -a /etc/vsftpd.conf
echo "write_enable=YES" | sudo tee -a /etc/vsftpd.conf
echo "local_umask=022" | sudo tee -a /etc/vsftpd.conf
echo "dirmessage_enable=YES" | sudo tee -a /etc/vsftpd.conf
echo "use_localtime=YES" | sudo tee -a /etc/vsftpd.conf
echo "xferlog_enable=YES" | sudo tee -a /etc/vsftpd.conf
echo "connect_from_port_20=YES" | sudo tee -a /etc/vsftpd.conf
echo "chroot_local_user=YES" | sudo tee -a /etc/vsftpd.conf
echo "secure_chroot_dir=/var/run/vsftpd/empty" | sudo tee -a /etc/vsftpd.conf
echo "pam_service_name=vsftpd" | sudo tee -a /etc/vsftpd.conf
echo "rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem" | sudo tee -a /etc/vsftpd.conf
echo "rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key" | sudo tee -a /etc/vsftpd.conf
echo "pasv_enable=YES" | sudo tee -a /etc/vsftpd.conf
echo "pasv_min_port=40000" | sudo tee -a /etc/vsftpd.conf
echo "pasv_max_port=40100" | sudo tee -a /etc/vsftpd.conf
echo "user_sub_token=$USER" | sudo tee -a /etc/vsftpd.conf
echo "local_root=/home/$USER/ftp" | sudo tee -a /etc/vsftpd.conf

# Reiniciar o serviço vsftpd para aplicar as alterações
sudo service vsftpd restart

# Permitir que o serviço vsftpd inicie na inicialização do sistema
sudo systemctl enable vsftpd

echo "Servidor FTP configurado e instalado com sucesso."