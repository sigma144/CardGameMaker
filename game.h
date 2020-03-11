#pragma once
#include <list>
#include <string>
#include <map>
#include "interp.h"

using namespace std;

struct Interface;

struct VarSet {
    map<string, pair<Val, int>> vars;
    Val getVar(string name);
    void setVar(string name, Val var);
};

struct Player {
    string name;
    VarSet vars;
    Player(string name) { this->name = name; }
};

struct Zone;
struct Card {
    int id;
    string name;
    VarSet vars;
    Zone* zone;
};

struct Zone {
    bool single;
    list<Card*> cards;
};

struct StackFrame {
    VarSet vars;
    int context;
};


struct Game {
    string title;
    list<StackFrame*> stack;
    list<Player*> players;
    list<CommandNode*> turnLoop, roundLoop;
    int turn;
    int totalTurns;
    int totalRounds;
    Interface* interface;
    Game(Interface* interface, Card* cards[] = NULL);
    void run(ProgramNode* program);
    void initPlayers(int min, int max);
    Val getVar(string name);
    void setVar(string name, Val var, int visibility = 0);
    Val getPlayerVar(Player* player, string name);
    void setPlayerVar(Player* player, string name, Val var, int visibility = 0);
    Val getGlobalVar(string name);
    void setGlobalVar(string name, Val var, int visibility);
};