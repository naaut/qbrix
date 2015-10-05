#include "watcher.h"
#include <QUrl>

Watcher::Watcher(QObject *parent):
    QFileSystemWatcher(parent)
{

}

void Watcher::setFileName(const QString& fileName)
{
    if (m_fileName == fileName)
    {
        QUrl url_(m_fileName);
        addPath(url_.toLocalFile());
    } else {
        QUrl ourl_(m_fileName);
        removePath(ourl_.toLocalFile());
        m_fileName = fileName;
        QUrl url(m_fileName);
        addPath(url.toLocalFile());
    }

    emit fileNameChanged(m_fileName);
}

void Watcher::setFolderName(const QString &)
{

}

void Watcher::rmLastFileName()
{
    QUrl url_(m_fileName);
    removePath(url_.toLocalFile());
}
