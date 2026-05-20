allprojects {
    repositories {
        google()
        mavenCentral()
        // PhonePe's IntentSDK is hosted on their private CloudRepo, not on
        // Maven Central. Required for `payWithPhonepe(...)` to build.
        maven { url = uri("https://phonepe.mycloudrepo.io/public/repositories/phonepe-intentsdk-android") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
