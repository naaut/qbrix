#include "fileio.h"
#include <QFile>
#include <QTextStream>

fileio::fileio()
{

}


bool fileio::save(QString data, QString url){

    QFile file(url);

    if(file.open(QIODevice::ReadWrite)){
        QTextStream stream(&file);
        stream << data << endl;
        return true;
    }

    return false;
}

QString fileio::load(QString url){

    if(url.isEmpty()) {
        return QString("isEmpty");
    }

    QFile file(url);

    if(!file.exists()) {
        return QString("exists");
    }

    if (!file.open(QFile::ReadOnly))
    {
        return QString("open");
    }

    QByteArray result = file.readAll();
    return QString::fromUtf8(result);
}


