
#!/bin/bash
# verificar todos os scripts de um sitecd
# Variável com o endereço do site
URL="https://example.com"

# Função para verificar se o comando wget está disponível
check_dependencies() {
    if ! command -v wget &>/dev/null; then
    echo "Erro: o comando 'wget' é necessário, mas não está instalado."
        exit 1
    fi
}

# Função para baixar todos os scripts do site
download_scripts() {
    wget -r -l 1 -A ".sh" "$URL"
}

# Verificar dependências
check_dependencies

# Baixar scripts do site
download_scripts
