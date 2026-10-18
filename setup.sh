#!/bin/bash
set -e
mkdir -p app/src/main/assets app/src/main/java/com/takhta/langit app/src/main/res/mipmap-xxxhdpi
cp index.html app/src/main/assets/index.html
if [ -f icon.png ]; then cp icon.png app/src/main/res/mipmap-xxxhdpi/ic_launcher.png; ICON='android:icon="@mipmap/ic_launcher"'; else ICON=''; fi

cat > settings.gradle <<'G'
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositories { google(); mavenCentral() } }
rootProject.name = "TakhtaLangit"
include ':app'
G

cat > build.gradle <<'G'
plugins { id 'com.android.application' version '8.5.2' apply false }
G

cat > gradle.properties <<'G'
org.gradle.jvmargs=-Xmx3g
android.useAndroidX=false
G

cat > app/build.gradle <<'G'
plugins { id 'com.android.application' }
android {
    namespace 'com.takhta.langit'
    compileSdk 34
    defaultConfig {
        applicationId 'com.takhta.langit'
        minSdk 21
        targetSdk 34
        versionCode VCODE
        versionName '1.VCODE'
    }
    signingConfigs {
        tetap {
            storeFile file('../takhta.keystore')
            storePassword 'takhtalangit'
            keyAlias 'takhta'
            keyPassword 'takhtalangit'
        }
    }
    buildTypes { debug { signingConfig signingConfigs.tetap } }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}
G
sed -i "s/VCODE/${GITHUB_RUN_NUMBER:-1}/g" app/build.gradle

cat > app/src/main/AndroidManifest.xml <<M
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <application android:label="Takhta Langit" $ICON android:hardwareAccelerated="true"
        android:theme="@android:style/Theme.NoTitleBar.Fullscreen">
        <activity android:name=".MainActivity" android:exported="true"
            android:screenOrientation="fullSensor"
            android:windowSoftInputMode="adjustResize"
            android:configChanges="orientation|screenSize|keyboardHidden|screenLayout|smallestScreenSize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
M

cat > app/src/main/java/com/takhta/langit/MainActivity.java <<'J'
package com.takhta.langit;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

public class MainActivity extends Activity {
    private WebView web;
    private long lastBack = 0;

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        web = new WebView(this);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setDatabaseEnabled(true);
        s.setAllowFileAccess(true);
        s.setTextZoom(100);
        s.setMediaPlaybackRequiresUserGesture(false);
        web.setWebViewClient(new WebViewClient());
        web.setWebChromeClient(new WebChromeClient());
        setContentView(web);
        hideUi();
        web.loadUrl("file:///android_asset/index.html");
    }

    private void hideUi() {
        getWindow().getDecorView().setSystemUiVisibility(
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY | View.SYSTEM_UI_FLAG_FULLSCREEN
            | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) hideUi();
    }

    private void saveNow() {
        if (web != null) web.evaluateJavascript("try{if(typeof saveGame==='function'&&G&&G.units)saveGame(true);}catch(e){}", null);
    }

    @Override
    protected void onPause() {
        saveNow();
        super.onPause();
        web.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        web.onResume();
    }

    @Override
    public void onBackPressed() {
        web.evaluateJavascript(
            "(function(){try{"
            + "if(UI.dream){closeDream();return 'ok';}"
            + "var st=document.getElementById('setup');if(st&&!st.hidden){st.hidden=true;return 'ok';}"
            + "if(G.possess){unpossess();return 'ok';}"
            + "if(UI.tool!=='lihat'){setTool('lihat');return 'ok';}"
            + "}catch(e){}return 'exit';})()",
            new ValueCallback<String>() {
                @Override
                public void onReceiveValue(String v) {
                    if (v != null && v.contains("exit")) {
                        long now = System.currentTimeMillis();
                        if (now - lastBack < 2000) { saveNow(); finish(); }
                        else { lastBack = now; Toast.makeText(MainActivity.this, "Tekan sekali lagi untuk keluar. Dunia disimpan otomatis.", Toast.LENGTH_SHORT).show(); }
                    }
                }
            });
    }
}
J
