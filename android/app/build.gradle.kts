plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Flutter plugin phải nằm sau Android và Kotlin plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.minhhai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        // ⚠️ Application ID là gói chính của app — KHÔNG đổi lung tung
        applicationId = "com.example.minhhai"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // hỗ trợ khi app có nhiều thư viện
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            // Khi build release chưa ký app, dùng tạm debug key
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        // tránh lỗi duplicate META-INF
        resources.excludes.add("META-INF/DEPENDENCIES")
        resources.excludes.add("META-INF/LICENSE")
        resources.excludes.add("META-INF/LICENSE.txt")
        resources.excludes.add("META-INF/license.txt")
        resources.excludes.add("META-INF/NOTICE")
        resources.excludes.add("META-INF/NOTICE.txt")
        resources.excludes.add("META-INF/notice.txt")
        resources.excludes.add("META-INF/ASL2.0")
    }
}

flutter {
    source = "../.."
}
