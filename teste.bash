#!/bin/bash

# Função para contar e listar palavras de arquivos em diretórios e subdiretórios
count_words_in_files() {
    DIRECTORY="$1"
    for FILE in "$DIRECTORY"/*; do
        if [ -d "$FILE" ]; then
            count_words_in_files "$FILE"
        elif [ -f "$FILE" ]; then
            WORD_COUNT=$(wc -w < "$FILE")
            echo "$FILE: $WORD_COUNT palavras"
        fi
    done
}

# Obter o diretório
get_directory() {
    if [ -z "$1" ]; then
        read -p "Digite o caminho do diretório a processar: " DIRECTORY
    else
        DIRECTORY="$1"
    fi
    if [ ! -d "$DIRECTORY" ]; then
        echo "Erro: O diretório fornecido não existe."
        exit 1
    fi
}

# Obter o diretório
get_directory "$1"

# Contar palavras e listar quantas palavras cada arquivo contém
count_words_in_files "$DIRECTORY"
