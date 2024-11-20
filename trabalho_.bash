#!/bin/bash

# Função para verificar se o comando curl está disponível
check_dependencies() {
    # Verifica se o comando 'curl' está instalado
    if ! command -v curl &>/dev/null; then
        echo "Erro: o comando 'curl' é necessário, mas não está instalado."
        exit 1  # Sai do script se 'curl' não estiver instalado
    fi
}

# Função para obter o diretório
get_directory() {
    # Se nenhum diretório for passado como argumento
    if [ -z "$1" ]; then
        read -p "Digite o caminho do diretório a processar: " DIRECTORY  # Solicita ao usuário o caminho do diretório
    else
        DIRECTORY="$1"  # Usa o diretório passado como argumento
    fi
    # Verifica se o diretório existe
    if [ ! -d "$DIRECTORY" ]; then
        echo "Erro: O diretório fornecido não existe."
        exit 1  # Sai do script se o diretório não existir
    fi
}

# Função para contar e listar palavras de arquivos em diretórios e subdiretórios
count_words_in_files() {
    DIRECTORY="$1"
    # Loop para cada arquivo no diretório
    for FILE in "$DIRECTORY"/*; do
        # Se for um diretório, chama a função recursivamente
        if [ -d "$FILE" ]; then
            count_words_in_files "$FILE"
        # Se for um arquivo, conta as palavras
        elif [ -f "$FILE" ]; then
            WORD_COUNT=$(wc -w < "$FILE")  # Conta o número de palavras no arquivo
            echo "$FILE: $WORD_COUNT palavras"  # Exibe o nome do arquivo e a contagem de palavras
        fi
    done
}

# Função para categorizar e organizar arquivos
organize_files() {
    SMALL_DIR="${BACKUP_DIR}/pequenos"
    MEDIUM_DIR="${BACKUP_DIR}/medios"
    LARGE_DIR="${BACKUP_DIR}/grandes"

    # Cria diretórios para pequenos, médios e grandes arquivos
    mkdir -p "$SMALL_DIR" "$MEDIUM_DIR" "$LARGE_DIR"

    # Loop para cada arquivo no diretório
    for FILE in "$DIRECTORY"/*; do
        if [ -f "$FILE" ]; then
            SIZE=$(stat -c%s "$FILE")  # Obtém o tamanho do arquivo em bytes
            count_words "$FILE" >> "${BACKUP_DIR}/contagem_palavras.txt"  # Adiciona a contagem de palavras ao relatório
            # Categoriza e move os arquivos com base no tamanho
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
    TOTAL_FILES=$(find "$DIRECTORY" -type f | wc -l)  # Conta o número total de arquivos
    SMALL_COUNT=$(find "$SMALL_DIR" -type f | wc -l)  # Conta os arquivos pequenos
    MEDIUM_COUNT=$(find "$MEDIUM_DIR" -type f | wc -l)  # Conta os arquivos médios
    LARGE_COUNT=$(find "$LARGE_DIR" -type f | wc -l)  # Conta os arquivos grandes
    LARGEST_FILE=$(find "$DIRECTORY" -type f -exec du -h {} + | sort -rh | head -1)  # Encontra o maior arquivo
    AVG_SIZE=$(find "$DIRECTORY" -type f -exec du -b {} + | awk '{total += $1; count++} END {print total/count}')  # Calcula o tamanho médio dos arquivos

    WEATHER=$(curl -s "https://wttr.in/?format=3")  # Obtém a previsão do tempo

    # Cria o relatório com todas as informações
    REPORT="Relatório de Processamento\n\n"
    REPORT+="Número total de arquivos: $TOTAL_FILES\n"
    REPORT+="Arquivos pequenos: $SMALL_COUNT\n"
    REPORT+="Arquivos médios: $MEDIUM_COUNT\n"
    REPORT+="Arquivos grandes: $LARGE_COUNT\n"
    REPORT+="Maior arquivo: $LARGEST_FILE\n"
    REPORT+="Tamanho médio dos arquivos: $AVG_SIZE bytes\n"
    REPORT+="Previsão do tempo: $WEATHER\n"

    # Salva o relatório em um arquivo e exibe no console
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




