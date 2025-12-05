#!/bin/bash
set -e

echo "📁 Android yapısı kontrol ediliyor..."

# MainActivity konumu
MAIN_KT="android/app/src/main/java/com/pdfreader/app/MainActivity.kt"

# Plugin klasörü
PLUGIN_DIR="android/app/src/main/java/com/pdfreader/app"
PLUGIN_KT="$PLUGIN_DIR/AndroidFullFileAccess.kt"

# Android klasörü yoksa bekle
if [ ! -d "android" ]; then
    echo "❌ android klasörü yok!"
    echo "Bu script, CI sırasında android eklendikten sonra çalışmalı."
    exit 1
fi

mkdir -p "$PLUGIN_DIR"

echo "📝 Plugin dosyası yazılıyor: $PLUGIN_KT"

cat > "$PLUGIN_KT" << 'EOF'
package com.pdfreader.app

import android.os.Build
import android.provider.Settings
import android.net.Uri
import android.content.Intent
import com.getcapacitor.Plugin
import com.getcapacitor.PluginMethod
import com.getcapacitor.JSObject

class AndroidFullFileAccess : Plugin() {

    @PluginMethod
    fun openAllFilesAccessSettings(call: com.getcapacitor.PluginCall) {
        val context = activity

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
            intent.data = Uri.parse("package:" + context.packageName)
            context.startActivity(intent)
        } else {
            val intent = Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
            context.startActivity(intent)
        }

        val ret = JSObject()
        ret.put("status", "opened")
        call.resolve(ret)
    }
}
EOF

echo "✔ Plugin oluşturuldu"

# MainActivity yoksa otomatik oluştur
if [ ! -f "$MAIN_KT" ]; then
    echo "⚠ MainActivity.kt bulunamadı! Yeni dosya oluşturuluyor..."

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

echo "🔍 MainActivity içine plugin register ediliyor..."

if ! grep -q "AndroidFullFileAccess" "$MAIN_KT"; then
    # import ekle
    sed -i '/import com.getcapacitor.BridgeActivity/a import com.pdfreader.app.AndroidFullFileAccess' "$MAIN_KT"

    # register ekle
    sed -i '/super.onCreate/a \ \ \ \ registerPlugin(AndroidFullFileAccess::class.java)' "$MAIN_KT"
fi

echo "🎉 Android ziyaret scripti tamamlandı!"
