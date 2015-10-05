#include <QFileSystemWatcher>

#ifndef WATCHER_H
#define WATCHER_H


class Watcher : public QFileSystemWatcher
{
    Q_OBJECT


    Q_PROPERTY(QString fileName READ fileName WRITE setFileName NOTIFY fileNameChanged)
    Q_PROPERTY(QString folderName READ folderName WRITE setFolderName NOTIFY folderNameChanged)

    QString m_fileName;
    QString m_folderName;

public:
    Watcher(QObject *parent = 0);


    const QString& fileName() const
    {
        return m_fileName;
    }

    const QString folderName() const
    {
        return m_folderName;
    }

signals:
    void fileNameChanged(const QString& fileName);
    void folderNameChanged(const QString& folderName);

public slots:

    void setFileName(const QString&);
    void setFolderName(const QString&);
    void rmLastFileName();

private:

//    const QString& m_folderName;
//    const QString& m_fileName;
};

#endif // WATCHER_H
