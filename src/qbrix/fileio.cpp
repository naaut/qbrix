#include "fileio.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QtCore/QObject>

fileio::fileio()
{

}

bool fileio::save(const QString& data, const QString& url){

    QUrl url_(url);
    QFile file( url_.toLocalFile());

    if(file.open(QIODevice::WriteOnly | QIODevice::Truncate)){
        QTextStream stream(&file);
        stream << data << endl;
        return true;
    }

    return false;
}

QString fileio::load(const QString &url){

    if(url.isEmpty()) {
        return QString("Url is Empty");
    }

    QUrl url_(url);
    QFile file( url_.toLocalFile());

    if(!file.exists()) {
        return QString("File " + url + " not exists");
    }

    if (!file.open(QFile::ReadOnly))
    {
        return QString("Can't open file");
    }

    QByteArray result = file.readAll();
    return QString::fromUtf8(result);
}

void fileio::setSource(const QString& source)
{
    if (m_source == source)
        return;

    m_source = source;
    emit sourceChanged(source);

    m_fileData = load(m_source);
    emit fileDataChanged(m_fileData);
}

void fileio::setFileData(const QString& fileData)
{
    if (m_fileData == fileData)
        return;

    m_fileData = fileData;

    save(m_fileData, m_source);
    emit fileDataChanged(fileData);
}


