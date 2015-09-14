#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "fileio.h"



int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<fileio>("CustomClasses", 1, 0, "FileIO");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

