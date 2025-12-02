#!/bin/bash

echo "🔍 config.xml taranıyor ve pluginler yükleniyor..."

CONFIG_FILE="config.xml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ config.xml bulunamadı! Script durduruldu."
    exit 1
fi

# config.xml içinden plugin listesi çekilir
PLUGINS=$(grep -oP '(?<=<plugin name=")[^"]+' "$CONFIG_FILE")

if [ -z "$PLUGINS" ]; then
    echo "⚠️ config.xml içinde plugin bulunamadı. İşlem bitirildi."
    exit 0
fi

echo "📦 Bulunan pluginler:"
echo "$PLUGINS"
echo ""

# Pluginler sırayla yüklenir
for PLUGIN in $PLUGINS; do
    echo "➡️ Yükleniyor: $PLUGIN"
    cordova plugin add "$PLUGIN" || {
        echo "❌ Plugin yüklenemedi: $PLUGIN"
        exit 1
    }
done

echo ""
echo "✅ Tüm pluginler başarıyla yüklendi!"
