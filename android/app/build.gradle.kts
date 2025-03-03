plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Must be after Android plugins
    id("com.google.gms.google-services") // Firebase plugin
}

android {
    namespace = "com.example.turfgo1"
    compileSdk = 34 // Replace with your compile SDK version

    ndkVersion = "27.2.12479018" // Set your NDK version if required

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.turfgo1"
        minSdk = 23 // Set minSdk version manually
        targetSdk = 34 // Set your target SDK version
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Change if you have a release signing config
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.9.0"))

    // Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Add any additional Firebase dependencies here
}
