#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "fileio.h"
#include "watcher.h"
#include "componentcachemanager.h"
#include "SyntaxHighlighter.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);   


    qmlRegisterType<fileio>("CustomClasses", 1, 0, "FileIO");
    qmlRegisterType<SyntaxHighlighter>("CustomClasses", 1, 0, "SyntaxHighlighter");
    qmlRegisterType<Watcher>("CustomClasses", 1, 0, "Watcher");

    QQmlApplicationEngine engine;


    engine.rootContext()->setContextProperty("cacheManager", new ComponentCacheManager (&engine));
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

