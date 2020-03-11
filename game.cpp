#include "game.h"
#include "interface.h"

Game::Game(Interface* interface, Card* cards[]) {
    turn = totalTurns = totalRounds = 0;
    this->interface = interface;
    interface->game = this;
}

Val VarSet::getVar(string name) {

}

void VarSet::setVar(string name, Val var) {

}

void Game::run(ProgramNode* program) {
    program->evaluate(this);
    interface->displayState(this);
    //TODO: Run turn/round loop
}

void Game::initPlayers(int min, int max) {
    players = interface->getPlayers(min, max);
}

Val Game::getVar(string name) {

}

void Game::setVar(string name, Val var, int visibility) {

}

Val Game::getPlayerVar(Player* player, string name) {

}

void Game::setPlayerVar(Player* player, string name, Val var, int visibility) {

}

Val Game::getGlobalVar(string name) {

}

void Game::setGlobalVar(string name, Val var, int visibility) {

}