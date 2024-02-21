#!/bin/bash

# Funció per realitzar les comprovacions de hardware i software
function comprovacions_servidor() {
    #Comprovacions de hardware i software en curs...
    echo "<h2>Comprovació de la memòria lliure</h2>"
    free -h
    echo "<h2>Comprovació de l'espai en disc</h2>"
    df -h
    echo "<h2>Comprovació de l'ús de CPU</h2>"
    top -n 1 -b | head -n 10
    echo "<h2>comprovació de la versió del sistema operatiu</h2>"
    uname -a
    echo "<h2>Comprovació dels serveis en funcionament</h2>"
    systemctl list-units --type=service
}

# Funció per configurar els trap's
function configurar_traps() {
    # Trap para capturar la señal SIGHUP (1)
    trap 'trap_sighup="Capturada la señal SIGHUP (1)"' SIGHUP
    # Trap para capturar la señal SIGINT (2)
    trap 'trap_sigint="Capturada la señal SIGINT (2)"' SIGINT
    # Trap per capturar la senyal SIGALRM (14)
    trap 'trap_sigalarm="Capturada la señal SIGALRM (14)"' SIGALRM
    # Establim una alarma per que s'activi en 5 segons
    sleep 5
    kill -14 $$
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

    # Guardar las salidas en variables
    comprovacions_ports_output="$ports_output $apache_status"
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

    # Utilitzem SSH per connectar-nos i executar les comprovacions
    comprovacions_servidor_output=$(ssh $user@$server "$(typeset -f); comprovacions_servidor")
    comprovacions_ports_output=$(ssh $user@$server "$(typeset -f); comprovacions_ports")
    comprovacions_traps_output=$(ssh $user@$server "$(typeset -f); comprovacions_traps")
}

# Funció principal
function main() {
    # Configuramos los trap's
    configurar_traps
    # Executem les comprovacions en el servidor remot amb els arguments proporcionats
    executar_comprovacions_remotes "$@"

    # Generar HTML con las salidas
    cat <<EOF > /home/david/Escritorio/html_d_example.html
<!DOCTYPE html>
 <html>
   <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
      <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css" integri>
      <title>Resultats de les comprovacions</title>
   </head>
        <body>
                <h1>Comprovacions de hardware i software</h1>
                <pre>$comprovacions_servidor_output</pre>
                <h1>Comprovacions de ports oberts</h1>
                <pre>$comprovacions_ports_output</pre>
                <h1>Mensajes de Trap's</h1>
                <p>Trap SIGHUP: $trap_sighup</p>
                <p>Trap SIGINT: $trap_sigint</p>
                <p>Trap SIGALRM: $trap_sigalarm</p>
        </body>
 </html>
EOF
    # Mostrar el contenido del archivo HTML
    cat /home/david/Escritorio/html_d_example.html
}

# Executem la funció principal amb els arguments passats a l'script
main "$@"

