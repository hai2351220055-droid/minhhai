import org.gradle.api.tasks.Delete

plugins {
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(rootProject.layout.projectDirectory.dir("../build"))

subprojects {
    layout.buildDirectory.set(rootProject.layout.buildDirectory.dir(name))
}

subprojects {
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
