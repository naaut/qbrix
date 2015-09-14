#include <QObject>
#include <QtQml>

#ifndef FILEIO_H
#define FILEIO_H


class fileio : public QObject
{
    Q_OBJECT

public:
    fileio();

signals:

public slots:
    bool save(QString data, QString url);
    QString load(QString url);

};


#endif // FILEIO_H
