#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QCoreApplication>
#include <iostream>
#include <QFile>
#include "ShaController.h"

int main(int argc, char *argv[])
{
    // Primer paso: Inicializar como algo nativo de Qt.
    // Usamos QGuiApplication porque la aplicación podría arrancar en GUI.
    QGuiApplication app(argc, argv);
    app.setApplicationName("SHAGenerator");
    app.setApplicationVersion("1.0");

    QCommandLineParser parser;
    parser.setApplicationDescription("Generador de Hashes SHA y MD5 Hibrido (GUI / CLI)");
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption cliOption(QStringList() << "c" << "cli", "Modo Consola (No arranca GUI)");
    parser.addOption(cliOption);

    QCommandLineOption fileOption(QStringList() << "f" << "file", "Ruta del archivo a extraer hash", "filepath");
    parser.addOption(fileOption);

    QCommandLineOption algoOption(QStringList() << "a" << "algo", "Algoritmo: md5, sha1, sha224, sha256 (default), sha384, sha512", "algorithm", "sha256");
    parser.addOption(algoOption);

    // Procesamos y verificamos si hay flags.
    parser.process(app);

    bool isCli = parser.isSet(cliOption);

    if (isCli) {
        if (!parser.isSet(fileOption)) {
            std::cerr << "Error: Falta --file" << std::endl;
            return 1;
        }

        QString filePath = parser.value(fileOption);
        QString algoStr = parser.value(algoOption).toLower();
        int algoIndex = 3; // Default (SHA256)

        if (algoStr == "md5") algoIndex = 0;
        else if (algoStr == "sha1") algoIndex = 1;
        else if (algoStr == "sha224") algoIndex = 2;
        else if (algoStr == "sha256") algoIndex = 3;
        else if (algoStr == "sha384") algoIndex = 4;
        else if (algoStr == "sha512") algoIndex = 5;
        else {
            std::cerr << "Advertencia: Algoritmo desconocido. Usando SHA-256 por defecto." << std::endl;
        }

        std::cout << "-> Iniciando Hashing de [" << filePath.toStdString() << "] via CLI..." << std::endl;

        ShaController shaController;
        // Conectar las señales
        QObject::connect(&shaController, &ShaController::statusMessageChanged, [&shaController]() {
            std::cout << "Status: " << shaController.statusMessage().toStdString() << std::endl;
        });

        QObject::connect(&shaController, &ShaController::hashResultChanged, [&shaController, filePath, algoIndex, &app]() {
            if (!shaController.hashResult().isEmpty()) {
                std::cout << "\nRESULTADO HASH [" << shaController.hashResult().toStdString() << "]\n" << std::endl;
                std::cout << "-> Guardando archivo nativo en: " << filePath.toStdString() << std::endl;
                shaController.saveShaToFile(filePath, shaController.hashResult(), algoIndex);
                app.quit();
            }
        });

        // Lanzar
        std::cout << "Haciendo calculateSha en: " << filePath.toStdString() << std::endl;
        shaController.calculateSha(filePath, algoIndex);

        // QCoreApplication::exec es bloqueante, lo que mantendrá vivos los hilos Worker.
        return app.exec();
    } 

    // MODO GUI: Inicialización de la pantalla
    ShaController shaController;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("shaController", &shaController);

    const QUrl url(u"qrc:/SHAGenerator/qml/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
