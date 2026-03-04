#ifndef SHACONTROLLER_H
#define SHACONTROLLER_H

#include <QObject>
#include <QString>
#include <QThread>

class ShaController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(QString hashResult READ hashResult NOTIFY hashResultChanged)
    Q_PROPERTY(bool isProcessing READ isProcessing NOTIFY isProcessingChanged)
    Q_PROPERTY(bool isHashValid READ isHashValid NOTIFY isHashValidChanged) // NUEVO: Estado de Verificacion

public:
    explicit ShaController(QObject *parent = nullptr);
    ~ShaController();

    int progress() const;
    QString statusMessage() const;
    QString hashResult() const;
    bool isProcessing() const;
    bool isHashValid() const; // NUEVO: Getter para isHashValid

    // Métodos invocables desde QML
    Q_INVOKABLE void calculateSha(const QString &filePath, int algoIndex);
    Q_INVOKABLE void saveShaToFile(const QString &originalFilePath, const QString &hashValue, int algoIndex);
    Q_INVOKABLE QString readAboutText() const;
    Q_INVOKABLE QString cleanDropUrl(const QString &url) const;
    Q_INVOKABLE void verifyHash(const QString &targetHash); // NUEVO: Evaluador de Hashes

signals:
    void progressChanged();
    void statusMessageChanged();
    void hashResultChanged();
    void isProcessingChanged();
    void isHashValidChanged();

private slots:
    void onWorkerProgress(int percentage);
    void onWorkerFinished(const QString &hash);
    void onWorkerError(const QString &message);

private:
    void setProgress(int newProgress);
    void setStatusMessage(const QString &newMessage);
    void setHashResult(const QString &newResult);
    void setIsProcessing(bool newIsProcessing);
    void setIsHashValid(bool newIsHashValid); // NUEVO: Setter para isHashValid

    int m_progress = 0;
    QString m_statusMessage;
    QString m_hashResult;
    bool m_isProcessing = false;
    bool m_isHashValid = false; // NUEVO: Miembro para el estado de validación
    
    QThread* m_workerThread = nullptr;
};

#endif // SHACONTROLLER_H
