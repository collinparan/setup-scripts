#!/usr/bin/env bash

clear

function step1(){
    echo "Installing updates & code-server..."; 
    (sudo apt-get update && sudo apt-get upgrade && sudo apt -y install git nodejs npm yarn wget wput unzip && sudo apt install xclip xsel);

    #Installs and sets up Python 3
    echo "Installing updates & setup for python apt..."; 
    (sudo apt -y install software-properties-common && sudo add-apt-repository -y ppa:deadsnakes/ppa);
    echo "Installing Python 3..."; 
    (sudo apt -y install python3);
    echo "Removing other python links....";
    (sudo rm /usr/bin/python);
    echo "Adding symlink to python..."; 
    (sudo ln -s /usr/bin/python3 /usr/bin/python);
    echo "Installing pip..."; 
    (sudo apt -y install python3-pip);
    echo "Adding symlink to pip..."; 
    (sudo ln -s /usr/bin/pip3 /usr/bin/pip);
    echo "Preventing Python 2 and Pip2 from being installed..."; 
    (sudo apt-mark hold python python-pip);
    echo "Verifying python and pip versions...";
    (python -V && pip -V); 

    #Installing code server
    echo "Getting code server deb...";
    (curl -fOL https://github.com/cdr/code-server/releases/download/v3.5.0/code-server_3.5.0_amd64.deb);
    echo "Unpackaging code server..."
    (sudo dpkg -i code-server_3.5.0_amd64.deb);
    echo "Enabling code server..."
    (sudo systemctl enable --now code-server@root);

    #Installing Nginx
    echo "Installing nginx...";
    (sudo apt-get update && sudo apt-get upgrade && sudo apt install nginx);
    echo "Setting up ufw...";
    (sudo ufw app list && sudo ufw allow ssh && sudo ufw allow 22 &&  sudo ufw allow 8080 && sudo ufw allow 8787 && sudo ufw allow 'Nginx Full' && sudo ufw enable && sudo ufw status verbose);

    #Setup Nginx
    read -p "Domain or dot com: " domain;
    echo "Creating nginx sites available file...";
    (cd /etc/nginx/sites-available && echo "server {
        listen 80;
        listen [::]:80;
        server_name $domain;
        location / {
        proxy_pass http://localhost:8080/;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
        }
    }" > $domain);
    echo "Creating symlink...";
    (sudo ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/);
    echo "Uncomment 'server_names_hash_bucket_size' & restart nginx...";
    read -p "Press Enter or Return to Continue";
    (sudo nano /etc/nginx/nginx.conf);
}

function step2(){
    echo "Testing nginx...";
    (sudo nginx -t);
    echo "Restarting nginx service...";
    (sudo systemctl restart nginx);
}

function step3(){
    echo -p "Save the following password...press Enter or Return to Continue";
    (cat ~/.config/code-server/config.yaml);
    read -p "Press Enter or Return to Continue";
}

echo "Select to launch setup steps:"
select pd in "step1" "step2" "step3" "exit"; do 
    case $pd in 
        step1 ) step1; exit;;
        step2 ) step2; exit;;
        step3 ) step3; exit;;
        exit ) exit;;
    esac
done
