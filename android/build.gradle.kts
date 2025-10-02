// Top-level build file

buildscript {
    repositories {
        google()       // Required for Firebase
        mavenCentral() // Required for dependencies
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'       // Android Gradle plugin
        classpath 'com.google.gms:google-services:4.4.0'       // Firebase plugin
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: custom build directories (can be removed if not needed)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
