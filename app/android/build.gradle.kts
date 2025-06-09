allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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

buildscript {
    repositories {
        // Adicione o repositório Maven do Google aqui
        google()
        // Você também pode adicionar o Maven Central se precisar de outras dependências
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.1") // versão atual
    }
}


