#!/bin/bash

echo "➡️ Capacitor Android plugin setup başlıyor..."

PLUGIN_PACKAGE="com.pdfreader.app"
PLUGIN_CLASS="AndroidFullFileAccess"
ANDROID_PATH="android/app/src/main/java"

# Android platformu yoksa çık
if [ ! -d "android/app" ]; then
  echo "❌ Android platformu bulunamadı! Önce: npx cap add android"
  exit 1
fi

# Plugin dizinini oluştur
PLUGIN_DIR="$ANDROID_PATH/$(echo $PLUGIN_PACKAGE | tr . /)"
mkdir -p "$PLUGIN_DIR"

# Plugin dosyası yolu
PLUGIN_FILE="$PLUGIN_DIR/$PLUGIN_CLASS.java"

# Plugin Java sınıfı üret
cat <<EOF > "$PLUGIN_FILE"
package $PLUGIN_PACKAGE;

import android.content.Intent;
import android.provider.Settings;
import android.os.Build;

import com.getcapacitor.Plugin;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.PluginCall;

@CapacitorPlugin(name = "AndroidFullFileAccess")
public class $PLUGIN_CLASS extends Plugin {

    public void openSettings(PluginCall call) {
        Intent intent = new Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION);
        getActivity().startActivity(intent);
        call.resolve();
    }
}
EOF

echo "✔️ Plugin Java dosyası oluşturuldu: $PLUGIN_FILE"

# MainActivity path
MAIN_ACTIVITY="$ANDROID_PATH/$(echo $PLUGIN_PACKAGE | tr . /)/MainActivity.java"

# registerPlugin ekli mi?
if grep -q "$PLUGIN_CLASS" "$MAIN_ACTIVITY"; then
    echo "ℹ️ MainActivity zaten register içeriyor."
else
    echo "➡️ MainActivity'ye plugin register ekleniyor..."
    sed -i "/super.onCreate/a\        registerPlugin($PLUGIN_CLASS.class);" "$MAIN_ACTIVITY"
fi

echo "✔️ Plugin kurulumu tamamlandı!"
