#include "ShaController.h"
#include "ShaWorker.h"
#include <QCryptographicHash>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QThread>
#include <QUrl>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include <QCoreApplication>
#include <QStandardPaths>
#include <QProcess>

ShaController::ShaController(QObject *parent)
    : QObject(parent)
    , m_workerThread(nullptr) // Initialize m_workerThread
    , m_progress(0)
    , m_isProcessing(false)
    , m_isHashValid(false) // Initialize m_isHashValid
{
    m_networkManager = new QNetworkAccessManager(this);
    // Connect hashResultChanged to verifyHash to automatically re-evaluate validity
    connect(this, &ShaController::hashResultChanged, this, [this]() {
        // Re-evaluate hash validity if a target hash was previously set for verification
        // This assumes verifyHash might be called with a stored target, or that
        // the UI will re-trigger verification if needed.
        // For now, just reset validity when hash result changes.
        setIsHashValid(false);
    });
}

ShaController::~ShaController()
{
    if (m_workerThread) {
        m_workerThread->quit();
        m_workerThread->wait();
        delete m_workerThread; // Ensure thread is deleted
        m_workerThread = nullptr;
    }
}

int ShaController::progress() const { return m_progress; }
QString ShaController::statusMessage() const { return m_statusMessage; }
QString ShaController::hashResult() const { return m_hashResult; }
bool ShaController::isProcessing() const { return m_isProcessing; }
bool ShaController::isHashValid() const { return m_isHashValid; } // New getter

void ShaController::setProgress(int newProgress) {
    if (m_progress == newProgress) return;
    m_progress = newProgress;
    emit progressChanged();
}

void ShaController::setStatusMessage(const QString &newMessage) {
    if (m_statusMessage == newMessage) return;
    m_statusMessage = newMessage;
    emit statusMessageChanged();
}

void ShaController::setHashResult(const QString &newResult) {
    if (m_hashResult == newResult) return;
    m_hashResult = newResult;
    emit hashResultChanged();
}

void ShaController::setIsProcessing(bool newIsProcessing) {
    if (m_isProcessing == newIsProcessing) return;
    m_isProcessing = newIsProcessing;
    emit isProcessingChanged();
}

void ShaController::setIsHashValid(bool newIsHashValid) { // New setter
    if (m_isHashValid == newIsHashValid) return;
    m_isHashValid = newIsHashValid;
    emit isHashValidChanged();
}

void ShaController::calculateSha(const QString &filePath, int algoIndex)
{
    if (m_isProcessing) return;
    
    QString localFilePath = filePath;
    if (localFilePath.startsWith("file:///")) {
#ifdef Q_OS_WIN
        localFilePath = localFilePath.mid(8); 
#else
        localFilePath = localFilePath.mid(7); 
#endif
    }

    setIsProcessing(true);
    setProgress(0);
    setHashResult("");
    setStatusMessage("Calculando...");

    QCryptographicHash::Algorithm algo = QCryptographicHash::Sha256;
    switch (algoIndex) {
        case 0: algo = QCryptographicHash::Md5; break;
        case 1: algo = QCryptographicHash::Sha1; break;
        case 2: algo = QCryptographicHash::Sha224; break;
        case 3: algo = QCryptographicHash::Sha256; break;
        case 4: algo = QCryptographicHash::Sha384; break;
        case 5: algo = QCryptographicHash::Sha512; break;
        default: algo = QCryptographicHash::Sha256; break;
    }

    m_workerThread = new QThread(this);
    ShaWorker *worker = new ShaWorker(localFilePath, algo);
    worker->moveToThread(m_workerThread);

    connect(m_workerThread, &QThread::started, worker, &ShaWorker::process);
    connect(worker, &ShaWorker::progressChanged, this, &ShaController::onWorkerProgress);
    connect(worker, &ShaWorker::finished, this, &ShaController::onWorkerFinished);
    connect(worker, &ShaWorker::error, this, &ShaController::onWorkerError);
    
    connect(worker, &ShaWorker::finished, m_workerThread, &QThread::quit);
    connect(worker, &ShaWorker::finished, worker, &QObject::deleteLater);
    connect(m_workerThread, &QThread::finished, m_workerThread, &QObject::deleteLater);
    connect(m_workerThread, &QThread::finished, this, [this]() {
        m_workerThread = nullptr;
    });

    m_workerThread->start();
}

void ShaController::onWorkerProgress(int percentage)
{
    setProgress(percentage);
}

void ShaController::onWorkerFinished(const QString &hash)
{
    setHashResult(hash);
    if (!hash.isEmpty()) {
        setStatusMessage("Cálculo completado.");
    }
    setIsProcessing(false);
}

void ShaController::onWorkerError(const QString &message)
{
    setStatusMessage("Error: " + message);
    setIsProcessing(false);
}

void ShaController::saveShaToFile(const QString &originalFilePath, const QString &hashValue, int algoIndex)
{
    if (hashValue.isEmpty()) {
        setStatusMessage("No hay ningún hash para guardar.");
        return;
    }

    QString localFilePath = originalFilePath;
    if (localFilePath.startsWith("file:///")) {
#ifdef Q_OS_WIN
        localFilePath = localFilePath.mid(8);
#else
        localFilePath = localFilePath.mid(7);
#endif
    }

    QFileInfo fileInfo(localFilePath);
    QString extension = ".sha256";
    switch (algoIndex) {
        case 0: extension = ".md5"; break;
        case 1: extension = ".sha1"; break;
        case 2: extension = ".sha224"; break;
        case 3: extension = ".sha256"; break;
        case 4: extension = ".sha384"; break;
        case 5: extension = ".sha512"; break;
    }

    QString savePath = localFilePath + extension;
    QFile file(savePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out << hashValue << " *" << fileInfo.fileName() << "\n";
        file.close();
        setStatusMessage("Guardado exitosamente:\n" + savePath);
    } else {
        setStatusMessage("Error al guardar en: " + savePath);
    }
}

QString ShaController::readAboutText() const
{
    // Las rutas generadas por qt_add_qml_module inician con :/URI/
    QFile file(":/SHAGenerator/assets/about.txt");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return QString::fromUtf8(file.readAll());
    }
    // Intento secundario bajo Qt 6.5+ estándar por si acaso:
    QFile file2(":/qt/qml/SHAGenerator/assets/about.txt");
    if (file2.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return QString::fromUtf8(file2.readAll());
    }
    return "Error: No se pudo cargar el archivo about.txt desde los recursos.";
}

QString ShaController::cleanDropUrl(const QString &url) const
{
    // Las URL de arrastre vienen como "file:///C:/Ruta/Archivo.ext"
    QUrl qUrl(url);
    if (qUrl.isLocalFile()) {
        return QDir::toNativeSeparators(qUrl.toLocalFile());
    }
    return url;
}

void ShaController::verifyHash(const QString &targetHash)
{
    if (m_hashResult.isEmpty() || targetHash.isEmpty()) {
        setIsHashValid(false);
        return;
    }

    // Comparamos sin sensibilidad a mayúsculas y eliminando espacios
    QString cleanTarget = targetHash.trimmed().toLower();
    QString cleanOriginal = m_hashResult.trimmed().toLower();
    
    setIsHashValid(cleanTarget == cleanOriginal);
}

void ShaController::checkForUpdates()
{
    QUrl url("https://api.github.com/repos/jorge-rtv21/SHA_Generator/releases/latest");
    QNetworkRequest request(url);
    // GitHub API requests require a User-Agent header
    request.setHeader(QNetworkRequest::UserAgentHeader, "SHAGenerator-App");
    
    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        onUpdateCheckFinished(reply);
    });
}

void ShaController::onUpdateCheckFinished(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError) {
        QByteArray responseData = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(responseData);
        
        if (!jsonDoc.isNull() && jsonDoc.isObject()) {
            QJsonObject jsonObj = jsonDoc.object();
            if (jsonObj.contains("tag_name")) {
                QString latestVersion = jsonObj["tag_name"].toString();
                // Versión interna (base release)
                QString currentVersion = "v1.1.0"; 
                
                // Si existe un tag en Github diferente y no vacío, sugerimos actualización
                if (!latestVersion.isEmpty() && latestVersion != currentVersion) {
                    QString downloadUrl = "";
                    if (jsonObj.contains("assets") && jsonObj["assets"].isArray()) {
                        QJsonArray assets = jsonObj["assets"].toArray();
                        for (const QJsonValue &value : assets) {
                            QJsonObject asset = value.toObject();
                            QString name = asset["name"].toString();
                            if (name.endsWith(".exe")) {
                                downloadUrl = asset["browser_download_url"].toString();
                                break;
                            }
                        }
                    }
                    if (downloadUrl.isEmpty()) {
                        downloadUrl = jsonObj["html_url"].toString(); // fallback
                    }
                    emit updateAvailable(latestVersion, downloadUrl);
                }
            }
        }
    }
    reply->deleteLater();
}

void ShaController::downloadUpdate(const QString &url)
{
    if (m_downloadReply) return; // Ya existe una descarga en curso
    
    QUrl downloadUrl(url);
    if (!downloadUrl.isValid()) {
        emit updateDownloadFinished(false, "URL de descarga inválida.");
        return;
    }

    QNetworkRequest request(downloadUrl);
    // Permitir redireccionamientos (común en descargas de assets de GitHub)
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::NoLessSafeRedirectPolicy);
    request.setHeader(QNetworkRequest::UserAgentHeader, "SHAGenerator-App");

    m_downloadReply = m_networkManager->get(request);

    QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/SHAGenerator_Update.exe";
    m_downloadFile = new QFile(tempPath);
    if (m_downloadFile->exists()) {
        m_downloadFile->remove();
    }
    
    if (!m_downloadFile->open(QIODevice::WriteOnly)) {
        emit updateDownloadFinished(false, "No se pudo crear el archivo temporal de actualización.");
        m_downloadReply->deleteLater();
        m_downloadReply = nullptr;
        delete m_downloadFile;
        m_downloadFile = nullptr;
        return;
    }

    connect(m_downloadReply, &QNetworkReply::readyRead, this, [this]() {
        if (m_downloadFile) {
            m_downloadFile->write(m_downloadReply->readAll());
        }
    });
    
    connect(m_downloadReply, &QNetworkReply::downloadProgress, this, &ShaController::onDownloadProgress);
    connect(m_downloadReply, &QNetworkReply::finished, this, &ShaController::onDownloadFinished);
}

void ShaController::onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    if (bytesTotal > 0) {
        int percent = static_cast<int>((bytesReceived * 100) / bytesTotal);
        emit updateDownloadProgress(percent);
    }
}

void ShaController::onDownloadFinished()
{
    if (!m_downloadReply || !m_downloadFile) return;

    if (m_downloadReply->error() == QNetworkReply::NoError) {
        m_downloadFile->close();
        QString filePath = m_downloadFile->fileName();
        
        // Ejecutar silenciosamente como instalador y cerrar la aplicación actual
        bool started = QProcess::startDetached(filePath, QStringList() << "/SILENT");
        if (started) {
            emit updateDownloadFinished(true, "Actualización iniciada. Reiniciando programa...");
            QCoreApplication::quit();
        } else {
            emit updateDownloadFinished(false, "No se pudo ejecutar el archivo de instalación.");
        }
    } else {
        emit updateDownloadFinished(false, "Error de red: " + m_downloadReply->errorString());
        m_downloadFile->close();
        m_downloadFile->remove();
    }
    
    m_downloadReply->deleteLater();
    m_downloadReply = nullptr;
    delete m_downloadFile;
    m_downloadFile = nullptr;
}
