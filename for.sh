#!/bin/bash

process_url() {
    local url="$1"
    curl -s -o /dev/null -w "%{url_effective} - %{http_code}\n" "$url"
}

if [ $# -eq 0 ]; then
    echo -e "\nUso: $0 -l lista_urls.txt -t threads"
    exit 1
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
            echo -e "\nParámetro inválido: -$OPTARG\n" >&2
            exit 1
            ;;
    esac
done

if [ -z "$lista_urls" ]; then
    echo -e "\nEspecifica una lista de URLs con -l lista_urls.txt\n"
    exit 1
fi

if [ ! -f "$lista_urls" ]; then
    echo -e "\n$lista_urls no existe\n"
    exit 1
fi

if (( threads > 100 )); then
    echo -e "\nEl número máximo de hilos es 100\n"
    exit 1
fi

process_urls_in_parallel() {
    local urls=("$@")
    for url in "${urls[@]}"; do
        process_url "$url" &
    done
    wait
}

mapfile -t urls < "$lista_urls"
num_urls="${#urls[@]}"
urls_per_thread=$(( (num_urls + threads - 1) / threads ))

for (( i = 0; i < num_urls; i += urls_per_thread )); do
    start=$((i))
    end=$((i + urls_per_thread - 1))
    group_urls=("${urls[@]:$start:$urls_per_thread}")
    process_urls_in_parallel "${group_urls[@]}"
done

echo -e "\nFinalizado\n"