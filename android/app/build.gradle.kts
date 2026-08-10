plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hanin.glucotrack" // ✨ تأكدي إن ده الاسم اللي في الفايربيز
    compileSdk = flutter.compileSdkVersion

    // 1. ضيفي الجزء ده هنا (مهم جداً)
    signingConfigs {
        getByName("debug") {
            // الإعدادات الافتراضية للـ debug key بتاع الأندرويد
            keyAlias = "androiddebugkey"
            keyPassword = "android"
            storeFile = file(System.getProperty("user.home") + "/.android/debug.keystore")
            storePassword = "android"
        }
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true // ✨ مهم عشان النوتفكيشن
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.hanin.glucotrack"
        minSdk = flutter.minSdkVersion // ✨ لازم 21 عشان النوتفكيشن والفايربيز
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

   buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            // لو عايزة تعملي ضغط للأبلكيشن (اختياري)
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✨ المكتبة اللي كانت عاملة إيرور الجافا
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}
