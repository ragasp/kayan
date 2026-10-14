#!/usr/bin/env bash
set -e

echo "جاري إنشاء ملفات مشروع Kayan Keyboard..."

mkdir -p app/src/main/java/com/kayan/keyboard
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/xml
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/values

# 1. settings.gradle
cat << 'EOF' > settings.gradle
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "KayanKeyboard"
include ':app'
EOF

# 2. build.gradle (Root)
cat << 'EOF' > build.gradle
plugins {
    id 'com.android.application' version '8.2.2' apply false
}
EOF

# 3. gradle.properties
cat << 'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
EOF

# 4. app/build.gradle
cat << 'EOF' > app/build.gradle
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.kayan.keyboard'
    compileSdk 34

    defaultConfig {
        applicationId "com.kayan.keyboard"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        debug {
            minifyEnabled false
        }
        release {
            minifyEnabled false
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}

dependencies {
}
EOF

# 5. أيقونة التطبيق ic_launcher.xml
cat << 'EOF' > app/src/main/res/drawable/ic_launcher.xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#121316"
        android:pathData="M0,0h108v108h-108z" />
    <path
        android:fillColor="#00BCD4"
        android:pathData="M24,34h60c4,0 7,3 7,7v26c0,4 -3,7 -7,7H24c-4,0 -7,-3 -7,-7V41c0,-4 3,-7 7,-7z" />
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M32,44h8v8h-8zM44,44h8v8h-8zM56,44h8v8h-8zM68,44h8v8h-8zM36,58h36v6h-36z" />
</vector>
EOF

# 6. AndroidManifest.xml
cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.kayan.keyboard">

    <uses-permission android:name="android.permission.VIBRATE" />

    <application
        android:allowBackup="true"
        android:icon="@drawable/ic_launcher"
        android:label="Kayan Keyboard"
        android:theme="@android:style/Theme.DeviceDefault.NoActionBar">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".KayanInputMethodService"
            android:label="Kayan Keyboard"
            android:permission="android.permission.BIND_INPUT_METHOD"
            android:exported="true">
            <intent-filter>
                <action android:name="android.view.InputMethod" />
            </intent-filter>
            <meta-data
                android:name="android.view.im"
                android:resource="@xml/method" />
        </service>

    </application>
</manifest>
EOF

# 7. method.xml
cat << 'EOF' > app/src/main/res/xml/method.xml
<?xml version="1.0" encoding="utf-8"?>
<input-method xmlns:android="http://schemas.android.com/apk/res/android">
    <subtype
        android:label="العربية"
        android:imeSubtypeLocale="ar"
        android:imeSubtypeMode="keyboard" />
    <subtype
        android:label="English"
        android:imeSubtypeLocale="en_US"
        android:imeSubtypeMode="keyboard" />
</input-method>
EOF

# 8. MainActivity.java (شاشة التفعيل والتجربة)
cat << 'EOF' > app/src/main/java/com/kayan/keyboard/MainActivity.java
package com.kayan.keyboard;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.provider.Settings;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setGravity(Gravity.CENTER);
        root.setBackgroundColor(Color.parseColor("#121316"));
        root.setPadding(48, 48, 48, 48);

        TextView title = new TextView(this);
        title.setText("Kayan Keyboard");
        title.setTextColor(Color.parseColor("#00BCD4"));
        title.setTextSize(26);
        title.setGravity(Gravity.CENTER);
        root.addView(title);

        TextView sub = new TextView(this);
        sub.setText("فعّل الكيبورد واختاره كافتراضي لتجربة جميع المميزات");
        sub.setTextColor(Color.WHITE);
        sub.setTextSize(14);
        sub.setGravity(Gravity.CENTER);
        sub.setPadding(0, 16, 0, 48);
        root.addView(sub);

        Button btnEnable = createStyledButton("1. تفعيل الكيبورد من الإعدادات", "#1E2024");
        btnEnable.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startActivity(new Intent(Settings.ACTION_INPUT_METHOD_SETTINGS));
            }
        });
        root.addView(btnEnable);

        Button btnPick = createStyledButton("2. اختيار Kayan Keyboard كافتراضي", "#00838F");
        btnPick.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
                if (imm != null) imm.showInputMethodPicker();
            }
        });
        root.addView(btnPick);

        EditText testBox = new EditText(this);
        testBox.setHint("اضغط هنا لتجربة الكيبورد والإيموجي...");
        testBox.setHintTextColor(Color.parseColor("#7A808A"));
        testBox.setTextColor(Color.WHITE);
        GradientDrawable boxBg = new GradientDrawable();
        boxBg.setColor(Color.parseColor("#1E2024"));
        boxBg.setCornerRadius(24f);
        boxBg.setStroke(2, Color.parseColor("#00BCD4"));
        testBox.setBackground(boxBg);
        testBox.setPadding(32, 32, 32, 32);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.setMargins(0, 40, 0, 0);
        testBox.setLayoutParams(lp);
        root.addView(testBox);

        setContentView(root);
    }

    private Button createStyledButton(String text, String bgHex) {
        Button b = new Button(this);
        b.setText(text);
        b.setTextColor(Color.WHITE);
        b.setAllCaps(false);
        GradientDrawable gd = new GradientDrawable();
        gd.setColor(Color.parseColor(bgHex));
        gd.setCornerRadius(24f);
        gd.setStroke(2, Color.parseColor("#00BCD4"));
        b.setBackground(gd);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, 130);
        lp.setMargins(0, 16, 0, 16);
        b.setLayoutParams(lp);
        return b;
    }
}
EOF

# 9. KayanInputMethodService.java (الكيبورد الكامل بجميع الشاشات المطابقة للصور)
cat << 'EOF' > app/src/main/java/com/kayan/keyboard/KayanInputMethodService.java
package com.kayan.keyboard;

import android.content.ClipboardManager;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.inputmethodservice.InputMethodService;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputConnection;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class KayanInputMethodService extends InputMethodService {

    private LinearLayout rootLayout;
    private LinearLayout translateBar, mainToolbar, emojiTopBar, clipTopBar;
    private FrameLayout contentFrame;
    private LinearLayout lettersContainer, bottomRowStandard, bottomRowEmoji, bottomRowKaomoji, bottomRowClip;
    private GridView emojiGrid, kaomojiGrid;
    private ListView clipListView;

    private TextView tvTranslateBuffer, btnEn, btnAr, spaceLabel, enterLabel, commaBtn;
    private boolean isArabic = true;
    private boolean isShifted = false;
    private boolean isSymbols = false;
    private boolean isTranslateMode = false;
    private StringBuilder translateBuffer = new StringBuilder();

    // الحروف العربية مع الرموز الفرعية باللون الفيروزي أعلى اليمين
    private final String[][] arKeys = {
        {"ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج"},
        {"ش", "س", "ي", "ب", "ل", "ا", "ت", "ن", "م", "ك", "ط"},
        {"ذ", "ء", "ؤ", "ر", "ى", "ة", "و", "ز", "ظ", "د", "⌫"}
    };
    private final String[][] arHints = {
        {"١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩", "٠", "@"},
        {"", "", "", "", "لا", "أ", "", "", "", "گ", ""},
        {"", "", "", "", "ئ", "", "", "", "", "", ""}
    };

    // الحروف الإنجليزية مع الأرقام باللون الفيروزي أعلى اليمين
    private final String[][] enKeys = {
        {"q", "w", "e", "r", "t", "y", "u", "i", "o", "p"},
        {"a", "s", "d", "f", "g", "h", "j", "k", "l"},
        {"⇧", "z", "x", "c", "v", "b", "n", "m", "⌫"}
    };
    private final String[][] enHints = {
        {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"},
        {"", "", "", "", "", "", "", "", ""},
        {"", "", "", "", "", "", "", "", ""}
    };

    private final String[][] symKeys = {
        {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"},
        {"@", "#", "$", "%", "&", "-", "+", "(", ")", "/"},
        {"*", "\"", "'", ":", ";", "!", "?", "_", "⌫"}
    };

    // الإيموجي المطابقة للصورة
    private final String[] emojis = {
        "😹","🤣","😭","🥺","😂","🫂","🙂","🤍",
        "🖤","💔","💕","🌹","❤️","🥰","😘","😍",
        "🙈","😢","🥲","😅","🙄","🌚","😔","😒",
        "😡","😜","😉","😊","🔥","🤔","👍","🙏",
        "🎉","✨","💯","👑","😎","🤩","😴","🤍"
    };

    // الوجوه التعبيرية Kaomoji المطابقة للصورة
    private final String[] kaomojiPopular = {
        "(^_◕)", "(｡◕‿◕｡)", "(◉_◉)", "(✪‿✪)",
        "\\(^_^)/", "(•_•)", "(*_*)", "(｡♥‿♥｡)",
        "(ง'̀-'́)ง", "o(╥﹏╥)o", "(╯︵╰,)", "(T_T)",
        "◖⚆ᴥ⚆◗", "U^ｪ^U", "ฅ^•ﻌ•^ฅ", "(ฅ'ω'ฅ)",
        "^(#｀Д´)^", "(#ﾟДﾟ)", "ʕ´•ᴥ•`ʔ", "ʕ •ᴥ•ʔ"
    };

    private final List<String> clipItems = new ArrayList<>(Arrays.asList(
        "name: Build Kayan AI K...ebug/app-debug.apk",
        ".github/workflows/build-apk.yml",
        "#!/usr/bin/env bash se...جميع ملفات المشروع بنجاح!",
        "setup.sh",
        "kayan-keyboard"
    ));

    private final String[] decorItems = {
        "✨ سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ ✨",
        "🔥 كَيَانْ كِيبُورْد - أَقْوَى كِيبُورْدْ عَرَبِي 🔥",
        "👑 اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّد 👑",
        "💎 الحَمْدُ للهِ دَائِماً وَأَبَداً 💎"
    };

    private final String[] loveItems = {
        "❤️ كل عام وأنتم بخير ❤️",
        "🌹 دمت لي شيئاً جميلاً لا ينتهي 🌹",
        "💕 وجودك في حياتي أجمل نعمة 💕"
    };

    private final String[] sadItems = {
        "💔 لَعَلَّ اللَّهَ يُحْدِثُ بَعْدَ ذَلِكَ أَمْراً 💔",
        "🌧️ الحمد لله على كل حال 🌧️"
    };

    @Override
    public View onCreateInputView() {
        rootLayout = new LinearLayout(this);
        rootLayout.setOrientation(LinearLayout.VERTICAL);
        rootLayout.setBackgroundColor(Color.parseColor("#111315"));

        buildTranslateBar();
        buildMainToolbar();
        buildEmojiTopBar();
        buildClipTopBar();

        contentFrame = new FrameLayout(this);
        contentFrame.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(215)));

        lettersContainer = new LinearLayout(this);
        lettersContainer.setOrientation(LinearLayout.VERTICAL);
        lettersContainer.setPadding(dp(2), dp(4), dp(2), dp(2));
        contentFrame.addView(lettersContainer, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        setupEmojiAndKaomojiGrids();
        setupClipboardList();

        rootLayout.addView(contentFrame);

        buildBottomStandardBar();
        buildBottomEmojiBar();
        buildBottomKaomojiBar();
        buildBottomClipBar();

        showKeyboardMode();
        return rootLayout;
    }

    private void buildTranslateBar() {
        translateBar = new LinearLayout(this);
        translateBar.setOrientation(LinearLayout.VERTICAL);
        translateBar.setBackgroundColor(Color.parseColor("#17191C"));
        translateBar.setPadding(dp(8), dp(4), dp(8), dp(4));
        translateBar.setVisibility(View.GONE);

        LinearLayout header = new LinearLayout(this);
        header.setOrientation(LinearLayout.HORIZONTAL);
        header.setGravity(Gravity.CENTER_VERTICAL);

        TextView closeBtn = makeLabel("✕", 16, "#E0E0E0");
        closeBtn.setPadding(dp(10), dp(4), dp(16), dp(4));
        closeBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isTranslateMode = false;
                translateBar.setVisibility(View.GONE);
                enterLabel.setText("↵");
            }
        });
        header.addView(closeBtn);

        View spacer = new View(this);
        header.addView(spacer, new LinearLayout.LayoutParams(0, dp(1), 1f));

        TextView langTarget = makeLabel("العربية  ▼", 12, "#FFFFFF");
        langTarget.setBackground(makeRoundedRect("#1E2024", 40, "#555960"));
        langTarget.setPadding(dp(14), dp(4), dp(14), dp(4));
        header.addView(langTarget);

        TextView arrow = makeLabel("  ←  ", 15, "#B0B5BD");
        header.addView(arrow);

        TextView langSource = makeLabel("الإنجليزية  ▼", 12, "#FFFFFF");
        langSource.setBackground(makeRoundedRect("#1E2024", 40, "#555960"));
        langSource.setPadding(dp(14), dp(4), dp(14), dp(4));
        header.addView(langSource);

        translateBar.addView(header);

        LinearLayout inputRow = new LinearLayout(this);
        inputRow.setOrientation(LinearLayout.HORIZONTAL);
        inputRow.setGravity(Gravity.CENTER_VERTICAL);
        inputRow.setPadding(0, dp(4), 0, dp(2));

        tvTranslateBuffer = makeLabel("Type text here", 14, "#7A808A");
        tvTranslateBuffer.setGravity(Gravity.CENTER_VERTICAL | Gravity.LEFT);
        tvTranslateBuffer.setPadding(dp(8), dp(6), dp(8), dp(6));
        inputRow.addView(tvTranslateBuffer, new LinearLayout.LayoutParams(0, dp(36), 1f));

        TextView sendTrans = makeLabel("✓", 16, "#121316");
        sendTrans.setBackground(makeRoundedRect("#5C6066", 36, null));
        sendTrans.setGravity(Gravity.CENTER);
        sendTrans.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                flushTranslation();
            }
        });
        inputRow.addView(sendTrans, new LinearLayout.LayoutParams(dp(48), dp(32)));

        translateBar.addView(inputRow);
        rootLayout.addView(translateBar);
    }

    private void flushTranslation() {
        if (translateBuffer.length() > 0) {
            commitText(translateBuffer.toString());
            translateBuffer.setLength(0);
            tvTranslateBuffer.setText("Type text here");
            tvTranslateBuffer.setTextColor(Color.parseColor("#7A808A"));
        }
    }

    private void buildMainToolbar() {
        mainToolbar = new LinearLayout(this);
        mainToolbar.setOrientation(LinearLayout.HORIZONTAL);
        mainToolbar.setGravity(Gravity.CENTER_VERTICAL);
        mainToolbar.setPadding(dp(6), dp(4), dp(6), dp(4));
        mainToolbar.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(46)));

        String[] icons = {"⚙", "GIF", "😊", "ـَـُ", "a→أ", "📋", "🌐"};
        for (int i = 0; i < icons.length; i++) {
            final int idx = i;
            TextView tab = makeLabel(icons[i], i == 1 ? 11 : 15, "#D5D8DC");
            tab.setGravity(Gravity.CENTER);
            if (i == 1) {
                tab.setBackground(makeRoundedRect("#1E2024", 10, "#9E9E9E"));
            }
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, dp(34), 1f);
            lp.setMargins(dp(2), 0, dp(2), 0);
            tab.setLayoutParams(lp);
            tab.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (idx == 2) showEmojiMode();
                    else if (idx == 3) showKaomojiMode();
                    else if (idx == 4) toggleTranslateBar();
                    else if (idx == 5) showClipboardMode();
                    else if (idx == 6) toggleLanguage();
                }
            });
            mainToolbar.addView(tab);
        }

        btnEn = makeLabel("En", 14, "#FFFFFF");
        btnEn.setGravity(Gravity.CENTER);
        btnEn.setLayoutParams(new LinearLayout.LayoutParams(dp(38), dp(36)));
        btnEn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isArabic = false;
                isSymbols = false;
                showKeyboardMode();
            }
        });
        mainToolbar.addView(btnEn);

        btnAr = makeLabel("ع", 16, "#FFFFFF");
        btnAr.setGravity(Gravity.CENTER);
        btnAr.setLayoutParams(new LinearLayout.LayoutParams(dp(38), dp(36)));
        btnAr.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isArabic = true;
                isSymbols = false;
                showKeyboardMode();
            }
        });
        mainToolbar.addView(btnAr);

        rootLayout.addView(mainToolbar);
    }

    private void buildEmojiTopBar() {
        emojiTopBar = new LinearLayout(this);
        emojiTopBar.setOrientation(LinearLayout.HORIZONTAL);
        emojiTopBar.setBackgroundColor(Color.parseColor("#1D1F23"));
        emojiTopBar.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(44)));
        emojiTopBar.setVisibility(View.GONE);

        String[] tabs = {"🖼 أهلا", "😎✏", "❤️", "(✪‿✪)", "😀"};
        for (int i = 0; i < tabs.length; i++) {
            final int idx = i;
            TextView t = makeLabel(tabs[i], 14, "#FFFFFF");
            t.setGravity(Gravity.CENTER);
            t.setLayoutParams(new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f));
            t.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (idx == 3) showKaomojiMode();
                    else if (idx == 2) {
                        showClipboardMode();
                        updateClipAdapter(loveItems);
                    } else showEmojiMode();
                }
            });
            emojiTopBar.addView(t);
        }
        rootLayout.addView(emojiTopBar);
    }

    private void buildClipTopBar() {
        clipTopBar = new LinearLayout(this);
        clipTopBar.setOrientation(LinearLayout.HORIZONTAL);
        clipTopBar.setGravity(Gravity.CENTER_VERTICAL);
        clipTopBar.setBackground(makeRoundedRect("#1A1D21", 40, "#2A2E35"));
        LinearLayout.LayoutParams barLp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(42));
        barLp.setMargins(dp(6), dp(4), dp(6), dp(4));
        clipTopBar.setLayoutParams(barLp);
        clipTopBar.setVisibility(View.GONE);

        final String[] titles = {"حزين", "حب", "جُمَل مزخرفة 🔥", "الجمل المستخدمة", "الحافظة"};
        for (int i = 0; i < titles.length; i++) {
            final int idx = i;
            TextView tab = makeLabel(titles[i], 11, i == 4 ? "#00BCD4" : "#64B5F6");
            tab.setGravity(Gravity.CENTER);
            tab.setLayoutParams(new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f));
            tab.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (idx == 0) updateClipAdapter(sadItems);
                    else if (idx == 1) updateClipAdapter(loveItems);
                    else if (idx == 2) updateClipAdapter(decorItems);
                    else {
                        pullSystemClipboard();
                        updateClipAdapter(clipItems.toArray(new String[0]));
                    }
                }
            });
            clipTopBar.addView(tab);
        }
        rootLayout.addView(clipTopBar);
    }

    private void setupEmojiAndKaomojiGrids() {
        emojiGrid = new GridView(this);
        emojiGrid.setNumColumns(8);
        emojiGrid.setGravity(Gravity.CENTER);
        emojiGrid.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, emojis) {
            @Override
            public View getView(int pos, View convertView, ViewGroup parent) {
                TextView tv = makeLabel(emojis[pos], 22, "#FFFFFF");
                tv.setGravity(Gravity.CENTER);
                tv.setPadding(0, dp(8), 0, dp(8));
                return tv;
            }
        });
        emojiGrid.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                commitText(emojis[position]);
            }
        });
        emojiGrid.setVisibility(View.GONE);
        contentFrame.addView(emojiGrid);

        kaomojiGrid = new GridView(this);
        kaomojiGrid.setNumColumns(4);
        kaomojiGrid.setHorizontalSpacing(dp(1));
        kaomojiGrid.setVerticalSpacing(dp(1));
        kaomojiGrid.setBackgroundColor(Color.parseColor("#1D1F24"));
        kaomojiGrid.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, kaomojiPopular) {
            @Override
            public View getView(int pos, View convertView, ViewGroup parent) {
                TextView tv = makeLabel(kaomojiPopular[pos], 13, "#E0E0E0");
                tv.setBackgroundColor(Color.parseColor("#111315"));
                tv.setGravity(Gravity.CENTER);
                tv.setPadding(dp(2), dp(12), dp(2), dp(12));
                return tv;
            }
        });
        kaomojiGrid.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                commitText(kaomojiPopular[position]);
            }
        });
        kaomojiGrid.setVisibility(View.GONE);
        contentFrame.addView(kaomojiGrid);
    }

    private void setupClipboardList() {
        clipListView = new ListView(this);
        clipListView.setVisibility(View.GONE);
        updateClipAdapter(clipItems.toArray(new String[0]));
        contentFrame.addView(clipListView);
    }

    private void updateClipAdapter(final String[] data) {
        clipListView.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, data) {
            @Override
            public View getView(int pos, View convertView, ViewGroup parent) {
                LinearLayout row = new LinearLayout(KayanInputMethodService.this);
                row.setOrientation(LinearLayout.HORIZONTAL);
                row.setGravity(Gravity.CENTER_VERTICAL);
                row.setPadding(dp(10), dp(10), dp(10), dp(10));

                TextView menuIcon = makeLabel("⋮   📌", 14, "#B0B5BD");
                row.addView(menuIcon);

                TextView text = makeLabel(data[pos], 13, "#E0E0E0");
                text.setGravity(Gravity.CENTER);
                row.addView(text, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
                return row;
            }
        });
        clipListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int pos, long id) {
                commitText(data[pos]);
            }
        });
    }

    private void buildBottomStandardBar() {
        bottomRowStandard = new LinearLayout(this);
        bottomRowStandard.setOrientation(LinearLayout.HORIZONTAL);
        bottomRowStandard.setGravity(Gravity.CENTER_VERTICAL);
        bottomRowStandard.setPadding(dp(4), dp(2), dp(4), dp(6));
        bottomRowStandard.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(52)));

        TextView btnSym = makeBottomPill("@?!", 14, "#26C6DA", 1.2f);
        btnSym.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isSymbols = !isSymbols;
                renderLetterRows();
            }
        });
        bottomRowStandard.addView(btnSym);

        TextView btn123 = makeBottomPill("123", 14, "#26C6DA", 1.1f);
        btn123.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isSymbols = !isSymbols;
                renderLetterRows();
            }
        });
        bottomRowStandard.addView(btn123);

        commaBtn = makeBottomPill("،", 16, "#FFFFFF", 0.9f);
        commaBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                handleKeyInput(isArabic ? "،" : ",");
            }
        });
        bottomRowStandard.addView(commaBtn);

        spaceLabel = makeBottomPill("🎤 ع", 14, "#26C6DA", 3.8f);
        spaceLabel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                handleKeyInput(" ");
            }
        });
        bottomRowStandard.addView(spaceLabel);

        TextView dotBtn = makeBottomPill(".", 16, "#FFFFFF", 0.9f);
        dotBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                handleKeyInput(".");
            }
        });
        bottomRowStandard.addView(dotBtn);

        enterLabel = makeBottomPill("↵", 18, "#26C6DA", 1.4f);
        enterLabel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isTranslateMode) flushTranslation();
                else commitText("\n");
            }
        });
        bottomRowStandard.addView(enterLabel);

        rootLayout.addView(bottomRowStandard);
    }

    private void buildBottomEmojiBar() {
        bottomRowEmoji = new LinearLayout(this);
        bottomRowEmoji.setOrientation(LinearLayout.HORIZONTAL);
        bottomRowEmoji.setBackgroundColor(Color.parseColor("#1A1C20"));
        bottomRowEmoji.setGravity(Gravity.CENTER_VERTICAL);
        bottomRowEmoji.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(44)));
        bottomRowEmoji.setVisibility(View.GONE);

        String[] items = {"🗑", "🏳", "💡", "🍔", "💐", "🤍", "😀", "🐱", "🕒", "🔍", "⌫", "⌨"};
        for (int i = 0; i < items.length; i++) {
            final String item = items[i];
            TextView tv = makeLabel(item, 14, "#CCCCCC");
            tv.setGravity(Gravity.CENTER);
            tv.setLayoutParams(new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f));
            tv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (item.equals("⌨")) showKeyboardMode();
                    else if (item.equals("⌫")) deleteChar();
                }
            });
            bottomRowEmoji.addView(tv);
        }
        rootLayout.addView(bottomRowEmoji);
    }

    private void buildBottomKaomojiBar() {
        bottomRowKaomoji = new LinearLayout(this);
        bottomRowKaomoji.setOrientation(LinearLayout.HORIZONTAL);
        bottomRowKaomoji.setBackgroundColor(Color.parseColor("#1D1F24"));
        bottomRowKaomoji.setGravity(Gravity.CENTER_VERTICAL);
        bottomRowKaomoji.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(44)));
        bottomRowKaomoji.setVisibility(View.GONE);

        String[] items = {"حب", "شائع", "كلاسيكي", "🕒", "⌫", "⌨"};
        for (int i = 0; i < items.length; i++) {
            final String item = items[i];
            TextView tv = makeLabel(item, 13, "#E0E0E0");
            if (item.equals("شائع")) tv.setBackgroundColor(Color.parseColor("#111315"));
            tv.setGravity(Gravity.CENTER);
            tv.setLayoutParams(new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f));
            tv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (item.equals("⌨")) showKeyboardMode();
                    else if (item.equals("⌫")) deleteChar();
                }
            });
            bottomRowKaomoji.addView(tv);
        }
        rootLayout.addView(bottomRowKaomoji);
    }

    private void buildBottomClipBar() {
        bottomRowClip = new LinearLayout(this);
        bottomRowClip.setOrientation(LinearLayout.HORIZONTAL);
        bottomRowClip.setBackgroundColor(Color.parseColor("#0B4F60"));
        bottomRowClip.setGravity(Gravity.CENTER_VERTICAL);
        bottomRowClip.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(44)));
        bottomRowClip.setVisibility(View.GONE);

        String[] leftIcons = {"🗑", "⚙", "🔒", "＋"};
        for (final String ic : leftIcons) {
            TextView tv = makeLabel(ic, 16, "#E0E0E0");
            tv.setGravity(Gravity.CENTER);
            tv.setLayoutParams(new LinearLayout.LayoutParams(dp(48), ViewGroup.LayoutParams.MATCH_PARENT));
            tv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (ic.equals("🗑")) {
                        clipItems.clear();
                        updateClipAdapter(new String[]{"الحافظة فارغة"});
                    }
                }
            });
            bottomRowClip.addView(tv);
        }

        View space = new View(this);
        bottomRowClip.addView(space, new LinearLayout.LayoutParams(0, dp(1), 1f));

        TextView backKb = makeLabel("⌨", 18, "#FFFFFF");
        backKb.setGravity(Gravity.CENTER);
        backKb.setLayoutParams(new LinearLayout.LayoutParams(dp(56), ViewGroup.LayoutParams.MATCH_PARENT));
        backKb.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showKeyboardMode();
            }
        });
        bottomRowClip.addView(backKb);

        rootLayout.addView(bottomRowClip);
    }

    private void renderLetterRows() {
        lettersContainer.removeAllViews();
        String[][] keys = isSymbols ? symKeys : (isArabic ? arKeys : enKeys);
        String[][] hints = isSymbols ? null : (isArabic ? arHints : enHints);

        for (int r = 0; r < keys.length; r++) {
            LinearLayout row = new LinearLayout(this);
            row.setOrientation(LinearLayout.HORIZONTAL);
            row.setGravity(Gravity.CENTER);
            LinearLayout.LayoutParams rLp = new LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f);
            row.setLayoutParams(rLp);

            for (int c = 0; c < keys[r].length; c++) {
                final String k = keys[r][c];
                final String h = (hints != null && r < hints.length && c < hints[r].length) ? hints[r][c] : "";

                FrameLayout keyBox = new FrameLayout(this);
                boolean isSpecial = k.equals("⌫") || k.equals("⇧");
                float weight = isSpecial ? 1.3f : 1.0f;
                LinearLayout.LayoutParams kLp = new LinearLayout.LayoutParams(
                        0, ViewGroup.LayoutParams.MATCH_PARENT, weight);
                kLp.setMargins(dp(2), dp(3), dp(2), dp(3));
                keyBox.setLayoutParams(kLp);

                keyBox.setBackground(makeRoundedRect(
                        "#17191C", isSpecial ? 50 : 14, "#2A2E33"));

                String display = (!isArabic && !isSymbols && isShifted && k.length() == 1)
                        ? k.toUpperCase() : k;

                TextView mainTv = makeLabel(display, isSpecial ? 17 : 18,
                        isSpecial ? "#26C6DA" : "#F5F5F5");
                mainTv.setGravity(Gravity.CENTER);
                keyBox.addView(mainTv, new FrameLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

                if (!h.isEmpty()) {
                    TextView hintTv = makeLabel(h, 9, "#26C6DA");
                    FrameLayout.LayoutParams hLp = new FrameLayout.LayoutParams(
                            ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                    hLp.gravity = Gravity.TOP | Gravity.RIGHT;
                    hLp.setMargins(0, dp(2), dp(4), 0);
                    keyBox.addView(hintTv, hLp);
                }

                keyBox.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        handleKeyInput(k);
                    }
                });

                keyBox.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View v) {
                        if (!h.isEmpty()) {
                            handleKeyInput(h);
                            return true;
                        }
                        return false;
                    }
                });

                row.addView(keyBox);
            }
            lettersContainer.addView(row);
        }

        btnAr.setBackground(isArabic
                ? makeRoundedRect("#163840", 50, "#26C6DA")
                : makeRoundedRect("#00000000", 50, null));
        btnEn.setBackground(!isArabic
                ? makeRoundedRect("#163840", 50, "#26C6DA")
                : makeRoundedRect("#00000000", 50, null));

        if (spaceLabel != null) spaceLabel.setText(isArabic ? "🎤  ع" : "🎤  En");
        if (commaBtn != null) commaBtn.setText(isArabic ? "،" : ",");
    }

    private void handleKeyInput(String key) {
        if (key.equals("⌫")) {
            if (isTranslateMode && translateBuffer.length() > 0) {
                translateBuffer.deleteCharAt(translateBuffer.length() - 1);
                tvTranslateBuffer.setText(translateBuffer.length() == 0 ? "Type text here" : translateBuffer.toString());
            } else {
                deleteChar();
            }
            return;
        }
        if (key.equals("⇧")) {
            isShifted = !isShifted;
            renderLetterRows();
            return;
        }
        String out = (!isArabic && !isSymbols && isShifted && key.length() == 1) ? key.toUpperCase() : key;
        if (isTranslateMode) {
            translateBuffer.append(out);
            tvTranslateBuffer.setTextColor(Color.WHITE);
            tvTranslateBuffer.setText(translateBuffer.toString());
        } else {
            commitText(out);
        }
        if (isShifted) {
            isShifted = false;
            renderLetterRows();
        }
    }

    private void showKeyboardMode() {
        mainToolbar.setVisibility(View.VISIBLE);
        emojiTopBar.setVisibility(View.GONE);
        clipTopBar.setVisibility(View.GONE);

        lettersContainer.setVisibility(View.VISIBLE);
        emojiGrid.setVisibility(View.GONE);
        kaomojiGrid.setVisibility(View.GONE);
        clipListView.setVisibility(View.GONE);

        bottomRowStandard.setVisibility(View.VISIBLE);
        bottomRowEmoji.setVisibility(View.GONE);
        bottomRowKaomoji.setVisibility(View.GONE);
        bottomRowClip.setVisibility(View.GONE);
        renderLetterRows();
    }

    private void showEmojiMode() {
        mainToolbar.setVisibility(View.GONE);
        emojiTopBar.setVisibility(View.VISIBLE);
        clipTopBar.setVisibility(View.GONE);

        lettersContainer.setVisibility(View.GONE);
        emojiGrid.setVisibility(View.VISIBLE);
        kaomojiGrid.setVisibility(View.GONE);
        clipListView.setVisibility(View.GONE);

        bottomRowStandard.setVisibility(View.GONE);
        bottomRowEmoji.setVisibility(View.VISIBLE);
        bottomRowKaomoji.setVisibility(View.GONE);
        bottomRowClip.setVisibility(View.GONE);
    }

    private void showKaomojiMode() {
        mainToolbar.setVisibility(View.GONE);
        emojiTopBar.setVisibility(View.VISIBLE);
        clipTopBar.setVisibility(View.GONE);

        lettersContainer.setVisibility(View.GONE);
        emojiGrid.setVisibility(View.GONE);
        kaomojiGrid.setVisibility(View.VISIBLE);
        clipListView.setVisibility(View.GONE);

        bottomRowStandard.setVisibility(View.GONE);
        bottomRowEmoji.setVisibility(View.GONE);
        bottomRowKaomoji.setVisibility(View.VISIBLE);
        bottomRowClip.setVisibility(View.GONE);
    }

    private void showClipboardMode() {
        pullSystemClipboard();
        updateClipAdapter(clipItems.toArray(new String[0]));

        mainToolbar.setVisibility(View.GONE);
        emojiTopBar.setVisibility(View.GONE);
        clipTopBar.setVisibility(View.VISIBLE);

        lettersContainer.setVisibility(View.GONE);
        emojiGrid.setVisibility(View.GONE);
        kaomojiGrid.setVisibility(View.GONE);
        clipListView.setVisibility(View.VISIBLE);

        bottomRowStandard.setVisibility(View.GONE);
        bottomRowEmoji.setVisibility(View.GONE);
        bottomRowKaomoji.setVisibility(View.GONE);
        bottomRowClip.setVisibility(View.VISIBLE);
    }

    private void toggleTranslateBar() {
        showKeyboardMode();
        isTranslateMode = !isTranslateMode;
        translateBar.setVisibility(isTranslateMode ? View.VISIBLE : View.GONE);
        enterLabel.setText(isTranslateMode ? "✓" : "↵");
    }

    private void toggleLanguage() {
        isArabic = !isArabic;
        isSymbols = false;
        showKeyboardMode();
    }

    private void pullSystemClipboard() {
        ClipboardManager cm = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
        if (cm != null && cm.hasPrimaryClip() && cm.getPrimaryClip().getItemCount() > 0) {
            CharSequence cs = cm.getPrimaryClip().getItemAt(0).getText();
            if (cs != null && cs.length() > 0) {
                String s = cs.toString();
                if (!clipItems.contains(s)) clipItems.add(0, s);
            }
        }
    }

    private void commitText(String s) {
        InputConnection ic = getCurrentInputConnection();
        if (ic != null) ic.commitText(s, 1);
    }

    private void deleteChar() {
        InputConnection ic = getCurrentInputConnection();
        if (ic != null) ic.deleteSurroundingText(1, 0);
    }

    private TextView makeLabel(String text, int sp, String colorHex) {
        TextView tv = new TextView(this);
        tv.setText(text);
        tv.setTextSize(TypedValue.COMPLEX_UNIT_SP, sp);
        tv.setTextColor(Color.parseColor(colorHex));
        return tv;
    }

    private TextView makeBottomPill(String text, int sp, String colorHex, float weight) {
        TextView tv = makeLabel(text, sp, colorHex);
        tv.setGravity(Gravity.CENTER);
        tv.setBackground(makeRoundedRect("#17191C", 50, "#2C3036"));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.MATCH_PARENT, weight);
        lp.setMargins(dp(3), dp(2), dp(3), dp(2));
        tv.setLayoutParams(lp);
        return tv;
    }

    private GradientDrawable makeRoundedRect(String fillHex, int radiusDp, String strokeHex) {
        GradientDrawable gd = new GradientDrawable();
        gd.setColor(Color.parseColor(fillHex));
        gd.setCornerRadius(dp(radiusDp));
        if (strokeHex != null) {
            gd.setStroke(dp(1), Color.parseColor(strokeHex));
        }
        return gd;
    }

    private int dp(int val) {
        return (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, val, getResources().getDisplayMetrics());
    }
}
EOF

echo "تم إنشاء جميع ملفات المشروع بنجاح!"

