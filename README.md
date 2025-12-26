# Instalação Automática do LAMP + phpMyAdmin no Ubuntu 24.04

[![License](https://img.shields.io/github/license/seuusuario/seu-repo?style=for-the-badge)](LICENSE)
![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=GNU%20Bash&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Status](https://img.shields.io/badge/status-stable-brightgreen?style=for-the-badge)

Este repositório contém um script **Bash** que automatiza a instalação e configuração do *stack* **LAMP (Linux, Apache, MySQL e PHP)** juntamente com o **phpMyAdmin** no **Ubuntu 24.04 LTS**, de forma interativa e fácil. 

Além da instalação, o script cria um utilitário de linha de comando chamado `webserver` para controlar rapidamente os serviços **Apache** e **MySQL** (`start`, `stop`, `restart`, `status`).

---

## 🧰 Recursos principais

- Instalação automatizada do **Apache 2**, **MySQL Server**, **PHP 8.3** e **phpMyAdmin**.
- Configuração segura e interativa das senhas (sem eco no terminal).
- Ajuste automático de serviços e módulos do Apache. 
- Pré-configuração *non-interactive* do phpMyAdmin. 
- Criação do comando auxiliar `webserver` para gerenciamento fácil dos serviços.

---

## ⚙️ Pré-requisitos

- **Ubuntu 24.04 LTS** (server ou desktop).   
- Execução com privilégios de `root` ou `sudo`.   
- Conexão à internet para instalação via `apt`.     

---

## 🚀 Como usar

1. **Clone o repositório:**

git clone https://github.com/augustomotta/install_webserver.git
cd seu-repo


2. **Dê permissão de execução ao script:**

chmod +x instalar_lamp_phpmyadmin.sh   


3. **Execute o script como root:**

sudo ./instalar_lamp_phpmyadmin.sh   


4. **Durante a instalação, o script solicitará:**
- Senha do usuário root do MySQL.
- Senha interna usada pelo phpMyAdmin.

Nenhuma senha é exibida durante a digitação (modo oculto).

---

## 🖥️ Após a instalação

Ao final da execução, o script exibirá os endereços e credenciais principais.

- **Apache:** `http://<ip_do_servidor>/`   
- **phpMyAdmin:** `http://<ip_do_servidor>/phpmyadmin`   
- **Usuário MySQL:** `root`   
- **Senha:** conforme informado durante a instalação.   

---

## 🔧 Comando auxiliar `webserver`

Após a instalação, é criado o comando `/usr/local/bin/webserver`, permitindo controlar os serviços do servidor web facilmente.   
 
### Exemplo de uso:   

sudo webserver start # Inicia Apache e MySQL   
sudo webserver stop # Para Apache e MySQL   
sudo webserver restart # Reinicia ambos   
sudo webserver status # Mostra o status atual dos serviços   

### Saída esperada (exemplo)

$ sudo webserver status   
Status do Apache:   
● apache2.service - The Apache HTTP Server   
Active: active (running)   

Status do MySQL:   
● mysql.service - MySQL Community Server   
Active: active (running)   

---

## 🧩 Estrutura do projeto

├── install_webserver.sh # Script principal de instalação   
├── README.md # Este arquivo de documentação

---

## 🔒 Segurança

- O script ajusta as permissões de usuário root do MySQL e remove entradas anônimas e banco de teste. 
- Senhas são pedidas de forma segura e não ficam armazenadas no sistema após a execução.

---

## 🧑‍💻 Autor

**Augusto Motta**  
📍 Pará, Brasil  
📧 amotta.eti.br@gmail.com  

---

## 🪪 Licença

Este projeto está licenciado sob a licença **MIT** — veja o arquivo [LICENSE](LICENSE) para detalhes.
