#!/bin/bash

# Pterodactyl SA-MP Query Module Installer
# Optimized for direct GitHub raw URL installation
# By FajarOfficial

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# GitHub URLs
EXTENSION_URL="https://raw.githubusercontent.com/FajarOfficial199/Modulsamp-query.pterodactyl/main/SampQueryExtension.php"
JS_URL="https://raw.githubusercontent.com/FajarOfficial199/Modulsamp-query.pterodactyl/main/samp-query.js"
BLADE_URL="https://raw.githubusercontent.com/FajarOfficial199/Modulsamp-query.pterodactyl/main/samp_query.blade.php"

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

check_nodejs() {
    echo -e "${YELLOW}[1] Checking Node.js version...${NC}"
    
    if ! command -v node &> /dev/null; then
        echo -e "${YELLOW}Node.js not found, installing LTS version...${NC}"
        install_nodejs
        return
    fi
    
    node_version=$(node -v | cut -d'.' -f1 | tr -d 'v')
    if [ "$node_version" -lt 14 ]; then
        echo -e "${YELLOW}Node.js version too old (v$node_version), upgrading...${NC}"
        install_nodejs
    else
        echo -e "${GREEN}✓ Node.js v$node_version (meets requirement)${NC}"
    fi
}

check_npm() {
    echo -e "${YELLOW}[2] Checking npm version...${NC}"
    
    if ! command -v npm &> /dev/null; then
        echo -e "${YELLOW}npm not found, installing...${NC}"
        install_nodejs
        return
    fi
    
    npm_version=$(npm -v | cut -d'.' -f1)
    if [ "$npm_version" -lt 6 ]; then
        echo -e "${YELLOW}npm version too old (v$npm_version), upgrading...${NC}"
        install_nodejs
    else
        echo -e "${GREEN}✓ npm v$npm_version (meets requirement)${NC}"
    fi
}

install_nodejs() {
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs
    check_command
    echo -e "${GREEN}✓ Node.js $(node -v) installed${NC}"
}

install_module() {
    echo -e "${YELLOW}[3] Installing SA-MP Query module...${NC}"
    
    PANEL_DIR="/var/www/pterodactyl"
    
    # Create directories
    mkdir -p "$PANEL_DIR/app/Extensions/ServerInfo"
    mkdir -p "$PANEL_DIR/resources/views/extensions"
    
    # Download files directly from GitHub
    wget -q --show-progress -O "$PANEL_DIR/app/Extensions/ServerInfo/SampQueryExtension.php" "$EXTENSION_URL"
    wget -q --show-progress -O "$PANEL_DIR/app/Extensions/ServerInfo/samp-query.js" "$JS_URL"
    wget -q --show-progress -O "$PANEL_DIR/resources/views/extensions/samp_query.blade.php" "$BLADE_URL"
    
    # Install samp-query package if not exists
    if [ ! -d "$PANEL_DIR/node_modules/samp-query" ]; then
        echo -e "${YELLOW}[4] Installing samp-query package...${NC}"
        cd "$PANEL_DIR"
        sudo -u www-data npm install samp-query
        check_command
    else
        echo -e "${GREEN}✓ samp-query already installed${NC}"
    fi
    
    # Update config
    update_config
}

update_config() {
    echo -e "${YELLOW}[5] Updating panel configuration...${NC}"
    
    PANEL_DIR="/var/www/pterodactyl"
    
    # Update extensions.php
    if ! grep -q "SampQueryExtension" "$PANEL_DIR/config/extensions.php"; then
        sed -i "/'server_info' => \[/a \        \\\App\\Extensions\\ServerInfo\\SampQueryExtension::class," "$PANEL_DIR/config/extensions.php"
        echo -e "${GREEN}✓ Added to config/extensions.php${NC}"
    fi
    
    # Update routes/api.php
    if ! grep -q "extensions.samp-query" "$PANEL_DIR/routes/api.php"; then
        echo -e "\n// SA-MP Query Route" >> "$PANEL_DIR/routes/api.php"
        echo "Route::get('/extensions/samp-query', 'Extensions\ServerInfo\SampQueryExtension@index')" >> "$PANEL_DIR/routes/api.php"
        echo "    ->name('extensions.samp-query')" >> "$PANEL_DIR/routes/api.php"
        echo "    ->middleware('server.error');" >> "$PANEL_DIR/routes/api.php"
        echo -e "${GREEN}✓ Added to routes/api.php${NC}"
    fi
    
    # Set permissions
    chown -R www-data:www-data "$PANEL_DIR"
    
    # Clear cache
    sudo -u www-data php artisan view:clear
    sudo -u www-data php artisan cache:clear
    
    echo -e "${GREEN}✓ Module installed successfully!${NC}"
}

main() {
    header
    check_root
    check_nodejs
    check_npm
    install_module
    
    echo -e "\n${GREEN}Installation complete!${NC}"
    echo -e "The SA-MP Query module will now appear in your Pterodactyl server view."
    echo -e "\nNote: Make sure your SA-MP server allows queries from external IPs."
}

main
