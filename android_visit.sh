#!/bin/bash
set -e

echo "🔍 android_visit.sh çalışıyor..."

MAIN_KT="android/app/src/main/java/com/pdfreader/app/MainActivity.kt"
PLUGIN_IMPORT="import com.pdfreader.app.AndroidFullFileAccess"

if [ ! -d "android" ]; then
  echo "⏳ android klasörü yok, android_visit.sh atlanıyor."
  exit 0
fi

mkdir -p "$(dirname "$MAIN_KT")"

# Eğer MainActivity yoksa oluştur
if [ ! -f "$MAIN_KT" ]; then
  echo "⚠ MainActivity.kt bulunamadı! Yeni oluşturuluyor..."

  cat > "$MAIN_KT" << 'EOF'
package com.pdfreader.app

import android.os.Bundle
import com.getcapacitor.BridgeActivity

class MainActivity : BridgeActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
}
EOF
fi

echo "🔧 MainActivity düzenleniyor..."

# Import ekle
if ! grep -q "AndroidFullFileAccess" "$MAIN_KT"; then
  sed -i "/import com.getcapacitor.BridgeActivity/a $PLUGIN_IMPORT" "$MAIN_KT"
fi

# Plugin register satırı ekle
if ! grep -q "registerPlugin(AndroidFullFileAccess" "$MAIN_KT"; then
  sed -i '/super.onCreate/a \ \ \ \ registerPlugin(AndroidFullFileAccess::class.java)' "$MAIN_KT"
fi

echo "🎉 android_visit.sh tamamlandı!"
