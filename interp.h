#pragma once
#include <list>
#include <string>

using namespace std;
/*
class Node;

union NodeVal {
    bool boolean;
	int number;
	char* str;
	Node* node;
	list<Node*>* nlist;
};*/

#define PRINT(NLIST) for (auto it = NLIST->begin(); it != NLIST->end(); ++it) (*it)->print();

class Node {
public:
    virtual void print() = 0;
};

class ExpressionNode : public Node {
public:
    ExpressionNode() { }
    void print();
};

class StatementNode : public Node {
public:
    StatementNode() { }
    void print();
};

class VariableDeclNode : public Node {
public:
    VariableDeclNode(int visibility, bool global, char* name, ExpressionNode* defaultValue)
        { this->visibility = visibility; this->global = global; this->name = name; this->defaultValue = defaultValue; }
    void print();
    int visibility; bool global; char* name; ExpressionNode* defaultValue;
};

class ZoneDeclNode : public Node {
public:
    ZoneDeclNode(int visibility, bool initial, bool global, bool single, char* name)
        { this->visibility = visibility; this->initial = initial; this->global = global; this->single = single; this->name = name; }
    void print();
    int visibility; bool initial, global, single; char* name;
};

class NumPlayersNode : public Node {
public:
    NumPlayersNode(int min, int max)
        { this->min = min; this->max = max; }
    void print();
    int min, max;
};

class HeaderNode : public Node {
public:
    HeaderNode(char* name, NumPlayersNode* numPlayers, int gameType)
        { this->name = name; this->numPlayers = numPlayers; this->gameType = gameType; }
    void print();
    char* name; NumPlayersNode* numPlayers; int gameType;
};

class ProgramNode : public Node {
public:
    ProgramNode(HeaderNode* header, list<ZoneDeclNode*>* zones, list<VariableDeclNode*>* variables, list<StatementNode*>* statements)
        { this->header = header; this->zones = zones; this->variables = variables; this->statements = statements; }
    void print();
    void evaluate();
    HeaderNode* header; list<ZoneDeclNode*>* zones; list<VariableDeclNode*>* variables; list<StatementNode*>* statements;
};