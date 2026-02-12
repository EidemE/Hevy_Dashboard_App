import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load key.properties
val keystorePropertiesFile = File(rootProject.rootDir.parentFile, "key/key.properties")
if (!keystorePropertiesFile.exists()) {
    throw GradleException("Missing signing config: ${keystorePropertiesFile.path}")
}
val keystoreProperties = Properties()
keystoreProperties.load(FileInputStream(keystorePropertiesFile))

android {
    namespace = "arbitro.android.hevy_dashboard_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = "21"
    }

    signingConfigs {
        create("release") {
            val keyAliasValue = keystoreProperties.getProperty("keyAlias")
            val keyPasswordValue = keystoreProperties.getProperty("keyPassword")
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            val storePasswordValue = keystoreProperties.getProperty("storePassword")

            if (keyAliasValue.isNullOrBlank() ||
                keyPasswordValue.isNullOrBlank() ||
                storeFilePath.isNullOrBlank() ||
                storePasswordValue.isNullOrBlank()
            ) {
                throw GradleException("Incomplete signing config in key.properties")
            }

            val keystoreFile = if (File(storeFilePath).isAbsolute) {
                File(storeFilePath)
            } else {
                File(keystorePropertiesFile.parentFile, storeFilePath)
            }
            if (!keystoreFile.exists()) {
                throw GradleException("Keystore file not found: $storeFilePath")
            }

            keyAlias = keyAliasValue
            keyPassword = keyPasswordValue
            storeFile = keystoreFile
            storePassword = storePasswordValue
        }
    }

    defaultConfig {
        applicationId = "arbitro.android.hevy_dashboard_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
