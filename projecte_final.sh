#!/bin/bash

# Funció per realitzar les comprovacions de hardware i software
function comprovacions_servidor() {
    # Aquí pots incloure les comandes per realitzar les comprovacions desitjades
    echo "Comprovacions de hardware i software en curs..."
    # Exemple: comprovació de la memòria lliure
    free -h

    # Exemple: comprovació de l'espai en disc
    df -h

    # Exemple: comprovació de la versió del sistema operatiu
    uname -a

    # Exemple: comprovació dels serveis en funcionament
    systemctl list-units --type=service

    # Pots afegir més comprovacions segons les teves necessitats
}

# Funció per realitzar comprovacions de ports oberts
function comprovacions_ports() {
    echo "Comprovacions de ports oberts en curs..."
    # Comprovem si Nmap està instal·lat
    if ! command -v nmap &> /dev/null; then
        echo "Nmap no està instal·lat. S'està instal·lant..."
        sudo apt-get update
        sudo apt-get install -y nmap
    fi

    # Utilitzem Nmap per comprovar els ports oberts
    nmap -p 1-1000 localhost

    # Pots afegir més comprovacions de ports segons les teves necessitats
}

# Funció per executar les comprovacions en el servidor remot
function executar_comprovacions_remotes() {
    echo "Connectant al servidor remot..."

    # Comprovem que s'han proporcionat els arguments esperats
    if [ $# -ne 2 ]; then
        echo "Ús: $0 <nom_usuari> <nom_servidor>"
        exit 1
    fi

    # Assignem els arguments a variables
    user=$1
    server=$2

    # Comandes per executar les comprovacions en el servidor remot
    # Utilitzem SSH per connectar-nos i executar les comprovacions
    ssh $user@$server "$(typeset -f); comprovacions_servidor; comprovacions_ports"
}

# Funció principal
function main() {
    # Executem les comprovacions en el servidor remot amb els arguments proporcionats
    executar_comprovacions_remotes "$@"
}

# Executem la funció principal amb els arguments passats a l'script
main "$@"
