#pragma once
#include <list>
#include <string>
#include <cstring>
#include <map>
#include <iostream>
#include <sstream>

using namespace std;

struct Game;
enum Type { T_NONE, T_NUMBER, T_STRING, T_BOOLEAN, T_CARD, T_PLAYER, T_ZONE, T_LIST = 0x100,
            T_LIST_NUMBER = T_LIST | T_NUMBER, T_LIST_STRING = T_LIST | T_STRING,
            T_LIST_BOOLEAN = T_LIST | T_BOOLEAN, T_LIST_CARD = T_LIST | T_CARD,
            T_LIST_PLAYER = T_LIST | T_PLAYER, T_LIST_ZONE = T_LIST | T_ZONE };

union ValData {
    void* ptr;
    int number;
    char* str;
};

struct Val {
    Type type;
    ValData val;
};

struct Node {
    int cmd;
    Node() { cmd = 0; }
    virtual void print() = 0;
    virtual Val evaluate(Game* game) = 0;
    static map<int, std::string> tokNames;
    void checkType(string var, Val val, Type type);
    void printTok(int tok);
    void error(string message);
    void typeError(string var, Type expected, Type received);
private:
    string getTokString(int tok);
    string getErrorHeader();
    string getTypeString(Type type);
};

struct ExpressionNode : public Node {
    ExpressionNode() { this->cmd = 0; }
    ExpressionNode(int cmd) { this->cmd = cmd; }
    void print(); Val evaluate(Game* game);
};

struct XNode : public ExpressionNode {
    XNode(int num)
        { this->num = num; op = 0; }
    XNode(int op, ExpressionNode* num)
        { this->op = op; exp1 = num; exp2 = NULL; }
    XNode(int op, ExpressionNode* min, ExpressionNode* max)
        { this->op = op; exp1 = min; exp2 = max; }
    void print(); Val evaluate(Game* game);
    int num, op; ExpressionNode* exp1; ExpressionNode* exp2;
};

struct LiteralNode : public ExpressionNode {
    LiteralNode(int number) {
        ValData vdata; vdata.number = number;
        val = { T_NUMBER, vdata };
    }
    LiteralNode(char* str) { val = { T_STRING, str }; }
    LiteralNode(bool boolean) {
        ValData vdata; vdata.number = boolean;
        val = { T_BOOLEAN, vdata };
    }
    LiteralNode() { val = { T_NONE, 0 }; }
    void print(); Val evaluate(Game* game);
    Val val;
};

struct ListNode : public ExpressionNode {
    ListNode(list<ExpressionNode*>* nlist) { this->nlist = nlist; }
    void print(); Val evaluate(Game* game);
    list<ExpressionNode*>* nlist;
};

struct ReadVarNode : public ExpressionNode {
    ReadVarNode(char* id) { this->id = id; }
    void print(); Val evaluate(Game* game);
    char* id; 
};

struct NameIteratorNode : public ExpressionNode {
    NameIteratorNode(char* id, ExpressionNode* exp) { this->id = id; this->exp = exp; }
    void print(); Val evaluate(Game* game);
    char* id; ExpressionNode* exp;
};

struct UnaryOpNode : public ExpressionNode {
    UnaryOpNode(int op, ExpressionNode* operand) { this->operand = operand; this->op = op; }
    void print(); Val evaluate(Game* game);
    ExpressionNode* operand; int op;
};

struct BinaryOpNode : public ExpressionNode {
    BinaryOpNode(int op, ExpressionNode* left, ExpressionNode* right)
        { this->left = left; this->right = right; this->op = op; }
    void print(); Val evaluate(Game* game);
    ExpressionNode* left; ExpressionNode* right; int op;
};

struct CommandNode : public Node {
    CommandNode() { }
    CommandNode(int cmd) { this->cmd = cmd; }
    void print(); Val evaluate(Game* game);
};

struct CommandOpNode : public CommandNode {
    CommandOpNode(int cmd, ExpressionNode* op) : CommandNode(cmd) { this->op = op; }
    void print(); Val evaluate(Game* game);
    ExpressionNode* op;
};

struct SortNode : public CommandNode {
    SortNode(int cmd, ExpressionNode* nlist, ExpressionNode* criterion, bool descending) : 
        SortNode(cmd, nlist, new list<ExpressionNode*>(), descending) { criteria->push_back(criterion); }
    SortNode(int cmd, ExpressionNode* nlist, list<ExpressionNode*>* criteria, bool descending) : CommandNode(cmd)
        { this->criteria = criteria; this->descending = descending; }
    void print(); Val evaluate(Game* game);
    ExpressionNode* nlist; list<ExpressionNode*>* criteria; bool descending;
};

struct BranchNode : public CommandNode {
    BranchNode(int cmd, XNode* x, ExpressionNode* condition, list<CommandNode*>* then) : CommandNode(cmd)
        { this->cmd = cmd; this->x = x; this->condition = condition; this->then = then; }
    void print(); Val evaluate(Game* game);
    XNode* x; ExpressionNode* condition; list<CommandNode*>* then;
};

struct AssignmentNode : public CommandNode {
    AssignmentNode(ExpressionNode* left, ExpressionNode* right)
        { this->left = left; this->right = right; visibility = 0; global = temp = false; }
    void print(); Val evaluate(Game* game);
    ExpressionNode* left; ExpressionNode* right; int visibility; bool global, temp; 
};

struct GetXNode : public ExpressionNode {
    GetXNode(Node* x, char* name, ExpressionNode* source) {
        this->x = x; this->name = name; this->source = source;
        if (source == NULL) { //Default to deck
            char* hand = strdup("Deck");
            this->source = new ReadVarNode(hand); 
        } 
    }
    GetXNode(ExpressionNode* source) {
        this->source = source; this->name = NULL;
    }
    GetXNode(char* name) {
        this->name = name;  this->source = NULL;
    }
    void print(); Val evaluate(Game* game);
    Node* x; char* name; ExpressionNode* source;
};

struct ChoiceNode : public CommandNode {
    ChoiceNode(int cmd,  bool optional, bool random, list<GetXNode*>* options, list<CommandNode*>* then) : CommandNode(cmd)
        { this->cmd = cmd; this->options = options; this->then = then; this->optional = optional; this->random = random; }
    void print(); Val evaluate(Game* game);
    list<GetXNode*>* options; list<CommandNode*>* then; bool optional, random;
};

struct MoveCardsNode : public CommandNode {
    MoveCardsNode(int cmd, ExpressionNode* cards, ExpressionNode* dest, list<CommandNode*>* then)
        : CommandNode(cmd) { this->cards = cards; this->dest = dest; this->bottom = false; this->then = then; }
    MoveCardsNode(int cmd, ExpressionNode* cards, ExpressionNode* dest, list<CommandNode*>* then, bool bottom)
        : MoveCardsNode(cmd, cards, dest, then) { this->bottom = bottom; }
    void print(); Val evaluate(Game* game);
    ExpressionNode* cards; ExpressionNode* dest; bool bottom; list<CommandNode*>* then;
};

struct RollDiceNode : public CommandNode {
    RollDiceNode(XNode* x, char* name, list<CommandNode*>* then)
        { this->x = x; this->name = name; this->then = then; }
    void print(); Val evaluate(Game* game);
    XNode* x; char* name; list<CommandNode*>* then;
};

struct ParamNode : public Node {
    ParamNode(char* name, ExpressionNode* defaultValue) { this->name = name; this->defaultValue = defaultValue; }
    void print(); Val evaluate(Game* game);
    char* name; ExpressionNode* defaultValue;
};

struct FunctionDefNode : public CommandNode {
    FunctionDefNode(char* name, list<ParamNode*>* params, list<CommandNode*>* body)
        { this->name = name; this->params = params; this->body = body; }
    void print(); Val evaluate(Game* game);
    char* name; list<ParamNode*>* params; list<CommandNode*>* body;
};

struct FunctionCallNode : public CommandNode, public ExpressionNode {
    FunctionCallNode(char* name, list<ExpressionNode*>* params)
        { this->name = name; this->params = params; }
    void print(); Val evaluate(Game* game);
    char* name; list<ExpressionNode*>* params;
};

struct EachPlayerExecNode : public CommandNode {
    EachPlayerExecNode(ExpressionNode* condition, list<CommandNode*>* statement, bool other)
        { this->condition = condition; this->statement = statement; }
    void print(); Val evaluate(Game* game);
    ExpressionNode* condition; list<CommandNode*>* statement;
};

struct PlayerExecNode : public CommandNode {
    PlayerExecNode(ExpressionNode* player, list<CommandNode*>* statement)
        { this->player = player; this->statement = statement; }
    void print(); Val evaluate(Game* game);
    ExpressionNode* player; list<CommandNode*>* statement;
};

struct VariableDeclNode : public Node {
    VariableDeclNode(int visibility, bool global, char* name, ExpressionNode* defaultValue)
        { this->visibility = visibility; this->global = global; this->name = name; this->defaultValue = defaultValue; }
    void print(); Val evaluate(Game* game);
    int visibility; bool global; char* name; ExpressionNode* defaultValue;
};

struct ZoneDeclNode : public Node {
    ZoneDeclNode(int visibility, bool initial, bool global, bool single, char* name)
        { this->visibility = visibility; this->initial = initial; this->global = global; this->single = single; this->name = name; }
    void print(); Val evaluate(Game* game);
    int visibility; bool initial, global, single; char* name;
};

struct NewZoneNode : public CommandNode {
    NewZoneNode(ZoneDeclNode* decl, bool temp)
        { this->decl = decl; this->temp = temp; }
    void print(); Val evaluate(Game* game);
    ZoneDeclNode* decl; bool temp; 
};

struct HeaderNode : public Node {
    HeaderNode(char* name, XNode* numPlayers, int gameType)
        { this->name = name; this->numPlayers = numPlayers; this->gameType = gameType; }
    void print(); Val evaluate(Game* game);
    char* name; XNode* numPlayers; int gameType;
};

struct ProgramNode : public Node {
    ProgramNode(HeaderNode* header, list<ZoneDeclNode*>* zones, list<VariableDeclNode*>* variables, list<CommandNode*>* statements)
        { this->header = header; this->zones = zones; this->variables = variables; this->statements = statements; }
    void print(); Val evaluate(Game* game);
    HeaderNode* header; list<ZoneDeclNode*>* zones; list<VariableDeclNode*>* variables; list<CommandNode*>* statements;
};