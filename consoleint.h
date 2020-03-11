#pragma once
#include "interface.h"

struct ConsoleInterface : public Interface
{
    list<Player*> getPlayers(int min, int max);
    void displayState(Game* game);
};