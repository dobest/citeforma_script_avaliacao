#!/bin/bash

# Função para verificar se o comando curl está disponível
check_dependencies() {
    if ! command -v curl &>/dev/null; then
        echo "Erro: o comando 'curl' é necessário, mas não está instalado."
        exit 1
    fi
}

# Função para obter o diretório
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


# Função para categorizar e organizar arquivos
organize_files() {
    SMALL_DIR="${BACKUP_DIR}/pequenos"
    MEDIUM_DIR="${BACKUP_DIR}/medios"
    LARGE_DIR="${BACKUP_DIR}/grandes"

    mkdir -p "$SMALL_DIR" "$MEDIUM_DIR" "$LARGE_DIR"

    for FILE in "$DIRECTORY"/*; do
        if [ -f "$FILE" ]; then
            SIZE=$(stat -c%s "$FILE")
            count_words "$FILE" >> "${BACKUP_DIR}/contagem_palavras.txt" # Adiciona a contagem de palavras ao relatório
            if [ "$SIZE" -le 100000 ]; then
                mv "$FILE" "$SMALL_DIR/"
            elif [ "$SIZE" -le 1000000 ]; then
                mv "$FILE" "$MEDIUM_DIR/"
            else
                mv "$FILE" "$LARGE_DIR/"
            fi
        fi
    done
}

# Função para gerar o relatório
generate_report() {
    TOTAL_FILES=$(find "$DIRECTORY" -type f | wc -l)
    SMALL_COUNT=$(find "$SMALL_DIR" -type f | wc -l)
    MEDIUM_COUNT=$(find "$MEDIUM_DIR" -type f | wc -l)
    LARGE_COUNT=$(find "$LARGE_DIR" -type f | wc -l)
    LARGEST_FILE=$(find "$DIRECTORY" -type f -exec du -h {} + | sort -rh | head -1)
    AVG_SIZE=$(find "$DIRECTORY" -type f -exec du -b {} + | awk '{total += $1; count++} END {print total/count}')

    WEATHER=$(curl -s "https://wttr.in/?format=3")

    REPORT="Relatório de Processamento\n\n"
    REPORT+="Número total de arquivos: $TOTAL_FILES\n"
    REPORT+="Arquivos pequenos: $SMALL_COUNT\n"
    REPORT+="Arquivos médios: $MEDIUM_COUNT\n"
    REPORT+="Arquivos grandes: $LARGE_COUNT\n"
    REPORT+="Maior arquivo: $LARGEST_FILE\n"
    REPORT+="Tamanho médio dos arquivos: $AVG_SIZE bytes\n"
    REPORT+="Previsão do tempo: $WEATHER\n"

    echo -e "$REPORT" > "${BACKUP_DIR}/relatorio.txt"
    echo -e "$REPORT"
}



# Configurar diretórios de backup
BACKUP_DIR="${DIRECTORY}/backup_$(date +%F)"
mkdir -p "$BACKUP_DIR"





# Verificar dependências
check_dependencies

# Obter o diretório
get_directory "$1"


# Contar palavras e listar quantas palavras cada arquivo contém
count_words_in_files "$DIRECTORY"

# Organizar arquivos
organize_files

# Gerar relatório
generate_report




