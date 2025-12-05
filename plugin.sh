#!/bin/bash
set -e

echo "🚀 plugin.sh çalışıyor..."

PLUGIN_DIR="android/app/src/main/java/com/pdfreader/app"
PLUGIN_KT="$PLUGIN_DIR/AndroidFullFileAccess.kt"

if [ ! -d "android" ]; then
  echo "⏳ Android klasörü henüz yok, plugin.sh atlanıyor."
  exit 0
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

echo "✔ plugin.sh tamamlandı"
