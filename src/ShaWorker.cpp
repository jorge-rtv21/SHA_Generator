#include "ShaWorker.h"
#include <QFile>
#include <QFileInfo>

ShaWorker::ShaWorker(const QString &filePath, QCryptographicHash::Algorithm algo, QObject *parent)
    : QObject(parent), m_filePath(filePath), m_algo(algo)
{
}

void ShaWorker::process()
{
    QFile file(m_filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        emit error("No se pudo abrir el archivo para lectura.");
        emit finished("");
        return;
    }

    qint64 fileSize = file.size();
    if (fileSize == 0) {
        QCryptographicHash hash(m_algo);
        emit progressChanged(100);
        emit finished(hash.result().toHex());
        return;
    }

    QCryptographicHash hash(m_algo);
    qint64 bytesReadTotal = 0;
    
    // Leemos en bloques de 4MB
    const qint64 bufferSize = 4 * 1024 * 1024;
    
    while (!file.atEnd()) {
        QByteArray buffer = file.read(bufferSize);
        if (buffer.isEmpty()) {
            break; // Ocurrió un error de lectura o llegamos al final repentino
        }
        
        hash.addData(buffer);
        bytesReadTotal += buffer.size();
        
        int percentage = static_cast<int>((bytesReadTotal * 100) / fileSize);
        emit progressChanged(percentage);
    }
    
    file.close();
    emit progressChanged(100);
    emit finished(QString(hash.result().toHex()));
}
