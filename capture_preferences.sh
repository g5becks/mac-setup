#!/usr/bin/env bash

# Script to capture current macOS preferences
# This will help create a restore function for your setup script

echo "Capturing current macOS preferences..."

# Create output file
OUTPUT_FILE="macos_preferences.sh"
echo "#!/usr/bin/env bash" > $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "# Auto-generated macOS preferences restore script" >> $OUTPUT_FILE
echo "# Generated on $(date)" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "restore_macos_preferences() {" >> $OUTPUT_FILE
echo "    echo 'Restoring macOS preferences...'" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Function to capture defaults for a domain
capture_domain() {
    local domain=$1
    local description=$2
    
    echo "    # $description" >> $OUTPUT_FILE
    
    # Get all keys for this domain and convert to defaults write commands
    defaults read $domain 2>/dev/null | while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*\"?([^\"[:space:]]+)\"?[[:space:]]*=[[:space:]]*(.+)\;?$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            
            # Clean up the value and determine type
            value=$(echo "$value" | sed 's/;$//' | xargs)
            
            if [[ $value =~ ^[0-9]+$ ]]; then
                # Integer
                echo "    defaults write $domain $key -int $value" >> $OUTPUT_FILE
            elif [[ $value =~ ^[0-9]+\.[0-9]+$ ]]; then
                # Float
                echo "    defaults write $domain $key -float $value" >> $OUTPUT_FILE
            elif [[ $value == "1" ]] || [[ $value == "0" ]]; then
                # Boolean
                bool_val="true"
                [[ $value == "0" ]] && bool_val="false"
                echo "    defaults write $domain $key -bool $bool_val" >> $OUTPUT_FILE
            else
                # String (remove quotes if present)
                value=$(echo "$value" | sed 's/^"//; s/"$//')
                echo "    defaults write $domain $key \"$value\"" >> $OUTPUT_FILE
            fi
        fi
    done
    
    echo "" >> $OUTPUT_FILE
}

# Capture key preference domains
echo "Capturing Finder preferences..."
capture_domain "com.apple.finder" "Finder preferences"

echo "Capturing Dock preferences..."
capture_domain "com.apple.dock" "Dock preferences"

echo "Capturing Global preferences..."
capture_domain "NSGlobalDomain" "Global system preferences"

echo "Capturing Trackpad preferences..."
capture_domain "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Trackpad preferences"

echo "Capturing Keyboard preferences..."
capture_domain "com.apple.HIToolbox" "Keyboard preferences"

echo "Capturing Safari preferences..."
capture_domain "com.apple.Safari" "Safari preferences"

echo "Capturing Terminal preferences..."
capture_domain "com.apple.Terminal" "Terminal preferences"

# Add restart commands
echo "    # Restart affected services" >> $OUTPUT_FILE
echo "    killall Finder 2>/dev/null || true" >> $OUTPUT_FILE
echo "    killall Dock 2>/dev/null || true" >> $OUTPUT_FILE
echo "    killall SystemUIServer 2>/dev/null || true" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "    echo 'macOS preferences restored. Some changes may require logout/restart.'" >> $OUTPUT_FILE
echo "}" >> $OUTPUT_FILE

echo ""
echo "Preferences captured to: $OUTPUT_FILE"
echo "Review the file and add it to your install.sh script"