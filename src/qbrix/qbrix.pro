TEMPLATE = app

QT += qml quick
CONFIG += c++11

SOURCES += main.cpp \
    fileio.cpp \
    componentcachemanager.cpp \
    QMLHighlighter.cpp \
    SyntaxHighlighter.cpp \
    watcher.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    fileio.h \
    componentcachemanager.h \
    QMLHighlighter.h \
    SyntaxHighlighter.h \
    watcher.h

