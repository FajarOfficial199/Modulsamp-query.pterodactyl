#!/bin/bash

# Pterodactyl SA-MP Query Module Installer
# For Ubuntu 20.04/22.04

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

header() {
    clear
    echo -e "${GREEN}"
    echo "=============================================="
    echo " Pterodactyl SA-MP Query Module Installer"
    echo "=============================================="
    echo -e "${NC}"
}

check_command() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed at last step${NC}"
        exit 1
    fi
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: This script must be run as root${NC}"
        exit 1
    fi
}

install_dependencies() {
    echo -e "${YELLOW}[1] Installing dependencies...${NC}"
    apt update
    apt install -y nodejs npm
    check_command
    
    # Ensure Node.js v14+
    node_version=$(node -v | cut -d'.' -f1 | tr -d 'v')
    if [ "$node_version" -lt 14 ]; then
        echo -e "${YELLOW}Node.js version too old, installing LTS version...${NC}"
        curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
        apt-get install -y nodejs
        check_command
    fi
}

install_module() {
    echo -e "${YELLOW}[2] Installing SA-MP Query module...${NC}"
    
    PANEL_DIR="/var/www/pterodactyl"
    
    # Create necessary directories
    mkdir -p "$PANEL_DIR/app/Extensions/ServerInfo"
    mkdir -p "$PANEL_DIR/resources/views/extensions"
    
    # Download the files directly
    wget -O "$PANEL_DIR/app/Extensions/ServerInfo/SampQueryExtension.php" \
        https://raw.githubusercontent.com/fajarofficial/pterodactyl-samp-query-module/main/SampQueryExtension.php
    
    wget -O "$PANEL_DIR/app/Extensions/ServerInfo/samp-query.js" \
        https://raw.githubusercontent.com/fajarofficial/pterodactyl-samp-query-module/main/samp-query.js
    
    wget -O "$PANEL_DIR/resources/views/extensions/samp_query.blade.php" \
        https://raw.githubusercontent.com/fajarofficial/pterodactyl-samp-query-module/main/samp_query.blade.php
    
    # Update config/extensions.php
    if ! grep -q "SampQueryExtension" "$PANEL_DIR/config/extensions.php"; then
        sed -i "/'server_info' => \[/a \        \\\App\\Extensions\\ServerInfo\\SampQueryExtension::class," "$PANEL_DIR/config/extensions.php"
    fi
    
    # Update routes/api.php
    if ! grep -q "extensions.samp-query" "$PANEL_DIR/routes/api.php"; then
        echo -e "\n// SA-MP Query Route" >> "$PANEL_DIR/routes/api.php"
        echo "Route::get('/extensions/samp-query', 'Extensions\ServerInfo\SampQueryExtension@index')" >> "$PANEL_DIR/routes/api.php"
        echo "    ->name('extensions.samp-query')" >> "$PANEL_DIR/routes/api.php"
        echo "    ->middleware('server.error');" >> "$PANEL_DIR/routes/api.php"
    fi
    
    # Install npm package
    cd "$PANEL_DIR" || exit
    npm install samp-query
    check_command
    
    # Set permissions
    chown -R www-data:www-data "$PANEL_DIR"
    
    # Clear cache
    sudo -u www-data php artisan view:clear
    sudo -u www-data php artisan cache:clear
    
    echo -e "${GREEN}Module installed successfully!${NC}"
}

main() {
    header
    check_root
    install_dependencies
    install_module
    
    echo -e "\n${GREEN}Installation complete!${NC}"
    echo -e "The SA-MP Query module will now appear in your Pterodactyl server view."
}

main
