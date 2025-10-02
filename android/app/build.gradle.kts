def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
def flutterVersionCode = localProperties.getProperty('flutter.versionCode').toInteger()
def flutterVersionName = localProperties.getProperty('flutter.versionName')

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'com.google.gms.google-services' // ✅ Firebase plugin

android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.news_admin_app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode
        versionName flutterVersionName
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.0"
    implementation platform('com.google.firebase:firebase-bom:32.2.2')
    implementation 'com.google.firebase:firebase-auth-ktx'
    implementation 'com.google.firebase:firebase-firestore-ktx'
    implementation 'com.google.firebase:firebase-storage-ktx'
}
