#include "game.h"
#include "consoleint.h"
#include <iostream>

list<Player*> ConsoleInterface::getPlayers(int min, int max) {
    return {new Player("You"), new Player("CPU")};
}

void ConsoleInterface::displayState(Game* game) {
    cout << "Game State Here" << endl;
}

