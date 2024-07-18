#!/bin/bash

show_use() {
    echo -e "\nUso: $0 -l lista_urls.txt [-t threads]\n"
    exit 1
}

if [ $# -eq 0 ]; then
    show_use
fi

threads=1

while getopts "l:t:" opt; do
    case $opt in
        l)
            lista_urls="$OPTARG"
            ;;
        t)
            threads="$OPTARG"
            ;;
        \?)
            show_use
            ;;
    esac
done

if [ -z "$lista_urls" ]; then
    show_use
fi

if [ ! -f "$lista_urls" ]; then
    echo -e "\n$lista_urls no existe\n"
    exit 1
fi

if (( threads > 100 )); then
    echo -e "\nEl número máximo de hilos es 100\n"
    exit 1
fi

cat "$lista_urls" | xargs -P "$threads" -I {} curl -s -o /dev/null -w "%{url_effective} - %{http_code}\n" {}

echo -e "\nFinalizado\n"