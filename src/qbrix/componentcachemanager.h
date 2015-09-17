#pragma once

#include <QObject>
#include <QQmlEngine>

class ComponentCacheManager : public QObject
{
    Q_OBJECT
public:
    explicit ComponentCacheManager(QQmlEngine *eng);

signals:


public slots:
   void trim();
   void clear();

public:
    QScopedPointer<QQmlEngine> engene;
};


