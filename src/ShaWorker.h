#ifndef SHAWORKER_H
#define SHAWORKER_H

#include <QObject>
#include <QString>
#include <QCryptographicHash>

class ShaWorker : public QObject
{
    Q_OBJECT
public:
    explicit ShaWorker(const QString &filePath, QCryptographicHash::Algorithm algo, QObject *parent = nullptr);

public slots:
    void process();

signals:
    void progressChanged(int percentage);
    void finished(const QString &hash);
    void error(const QString &message);

private:
    QString m_filePath;
    QCryptographicHash::Algorithm m_algo;
};

#endif // SHAWORKER_H
