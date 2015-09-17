#include <QObject>
#include <QtQml>

#ifndef FILEIO_H
#define FILEIO_H


class fileio : public QObject
{
    Q_OBJECT
    Q_PROPERTY(const QString& source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(const QString& fileData READ fileData WRITE setFileData NOTIFY fileDataChanged)

    QString m_source;
    QString m_fileData;

public:
    fileio();

    QString source() const
    {
        return m_source;
    }

    QString fileData() const
    {
        return m_fileData;
    }

signals:

    void sourceChanged(const QString& source);
    void fileDataChanged(const QString& fileData);

public slots:
    void setSource(const QString& source);
    void setFileData(const QString& fileData);
    bool save(const QString& data, const QString& url);
    QString load(const QString& url);
};


#endif // FILEIO_H
