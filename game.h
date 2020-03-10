#pragma once
#include <list>
#include <string>
#include <map>
#include "interface.h"
#include "interp.h"

using namespace std;

struct Player {
    string name;
    map<string, Val> vars;
};

struct StackFrame {
    map<string, Val> vars;
    int context;
};

struct Game {
    list<StackFrame> stack;
    list<Player> players;
    int turn;
    int totalTurns;
    int totalRounds;
    Game() {
        turn = totalTurns = totalRounds = 0;
    }
    void run(ProgramNode* program) {
        program->evaluate(this);
    }
};