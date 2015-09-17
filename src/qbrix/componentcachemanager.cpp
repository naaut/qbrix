#include "componentcachemanager.h"

ComponentCacheManager::ComponentCacheManager(QQmlEngine *eng) : QObject(eng) , engene(eng)
{

}

void ComponentCacheManager::trim()
{
    if (engene)
    {
        engene->trimComponentCache();
    }
}

void ComponentCacheManager::clear()
{
    if (engene)
    {
        engene->clearComponentCache();
    }
}

