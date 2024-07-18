#!/bin/bash

show_use() {
    echo -e "\nUso: $0 -l lista_urls.txt\n"
    exit 1
}

if [ $# -eq 0 ]; then
    show_use
fi

while getopts "l:" opt; do
    case $opt in
        l)
            lista_urls="$OPTARG"
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

while IFS= read -r url; do
    curl -s -o /dev/null -w "%{url_effective} - %{http_code}\n" "$url"
done < "$lista_urls"

echo -e "\nFinalizado\n"