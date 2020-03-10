#include <list>
#include <string>
#include <map>
#include <iostream>
#include "types.h"

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
};