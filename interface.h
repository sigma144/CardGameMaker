#pragma once
#include <list>
#include "game.h"

struct Interface {
    Game* game;
    virtual list<Player*> getPlayers(int min, int max) = 0;
    virtual void displayState(Game* game) = 0;
};

