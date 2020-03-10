#include "interp.h"
#include "cgm.tab.h"

using namespace std;

#define PRINT(NLIST) for (auto it = NLIST->begin(); it != NLIST->end(); ++it) (*it)->print();

map<int, std::string> Node::tokNames = {
    {ALL_NUMBERS, "ALL NUMBERS"}, {ANY, "ANY"}, {ANY_NUMBER_OF, "ANY NUMBER OF"},
    {AT_LEAST, "AT LEAST"}, {BEFORE_ROUND, "BEFORE ROUND"}, {BETWEEN, "BETWEEN"},
    {BOTTOM, "BOTTOM"}, {BREAK, "BREAK"}, {BY, "BY"}, {BY_LOWEST, "BY LOWEST"},
    {CARD_GAME, "CARD GAME"}, {CHOOSE, "CHOOSE"}, {CONTINUE, "CONTINUE"},{DELETE, "DELETE"},
    {DESCENDING, "DESCENDING"}, {DISCARD, "DISCARD"}, {DOWN_TO, "DOWN TO"}, {DO_WHILE, "DO WHILE"},
    {DRAW, "DRAW"}, {EACH_PLAYER, "EACH PLAYER"}, {EACH_OTHER_PLAYER, "EACH OTHER PLAYER"},
    {ELSE, "ELSE"}, {EXTRA_TURN, "EXTRA TURN"}, {FALSE, "FALSE"}, {FIRST_PLAYER, "FIRST PLAYER"},
    {FLIP, "FLIP"}, {FOR, "FOR"}, {FROM, "FROM"}, {GET, "GET"}, {GLOBAL, "GLOBAL"},
    {HIDDEN, "HIDDEN"}, {IF, "IF"}, {IN, "IN"}, {TOK_INITIAL, "INITIAL"}, {INTO, "INTO"},
    {LAST_PLAYER, "LAST PLAYER"}, {LIST, "LIST"}, {LOOK_AT, "LOOK AT"}, {LOSE_GAME, "LOSE GAME"},
    {MAX, "MAX"}, {MIN, "MIN"}, {MOVE, "MOVE"}, {NEW_ROUND, "NEW ROUND"},
    {NEXT_PLAYER, "NEXT PLAYER"}, {NEXT_TURN, "NEXT TURN"}, {NO, "NO"}, {NONE, "NONE"},
    {NOT, "NOT"}, {OF, "OF"}, {ON, "ON"}, {OPTIONAL, "OPTIONAL"}, {PLAY, "PLAY"},
    {PLAYER_NUMBER, "PLAYER NUMBER"}, {PLAYERS, "PLAYERS"}, {PREVIOUS_PLAYER, "PREVIOUS PLAYER"},
    {PREVIOUS_TURN, "PREVIOUS TURN"}, {PRIVATE, "PRIVATE"}, {PUBLIC, "PUBLIC"},
    {RANDOM, "RANDOM"}, {RANK_PLAYERS, "RANK PLAYERS"}, {RANK_PLAYERS_STRICTLY, "RANK PLAYERS STRICTLY"},
    {REMOVE, "REMOVE"}, {RETURN, "RETURN"}, {REVEAL, "REVEAL"}, {ROLL, "ROLL"},
    {ROUND_NUMBER, "ROUND NUMBER"}, {SAY, "SAY"}, {SET_TURN, "SET TURN"}, {SHUFFLE, "SHUFFLE"},
    {SINGLE, "SINGLE"}, {SIZE, "SIZE"}, {SKIP_TURN, "SKIP TURN"}, {SORT, "SORT"},
    {STANDARD_CARD_GAME, "STANDRAD CARD GAME"}, {SUM, "SUM"}, {ON_TURN, "ON TURN"}, {TEMP, "TEMP"}, 
    {THEN, "THEN"}, {TIE_GAME, "TIE GAME"}, {TO, "TO"}, {TOP, "TOP"}, {TOP_ONLY, "TOP ONLY"},
    {TRUE, "TRUE"}, {TURN_NUMBER, "TURN NUMBER"}, {TURN_ORDER, "TURN ORDER"}, {UP_TO, "UP TO"},
    {VARIABLES, "VARIABLES"}, {WHERE, "WHERE"}, {WHILE, "WHILE"}, {WIN_GAME, "WIN GAME"},
    {YOU, "YOU"}, {ZONES, "ZONES"}, {AND, "AND"}, {OR, "OR"}, {ADD_E, "+="}, {SUB_E, "-="},
    {MUL_E, "*="}, {DIV_E, "/="}, {MOD_E, "%="}, {EQ, "=="}, {NEQ, "!="}, {LEQ, "<="}, {GEQ, ">="}
};

void ExpressionNode::print() {
    printTok(cmd); cout << " ";
}

void LiteralNode::print() {
    if (type == T_NONE) cout << "none";
    else if (type == T_NUMBER) cout << number;
    else if (type == T_STRING) cout << str;
    else if (type == T_BOOLEAN) cout << (boolean ? "true" : "false");
    else cout << "unknown";
}

void ListNode::print() {
    cout << "["; for (auto it = nlist->begin(); it != nlist->end(); ++it) { (*it)->print(); cout << ", "; } cout << "]";
}

void ReadVarNode::print() {
    cout << "id(" << id << ")";
}

void NameIteratorNode::print() {
    cout << "<" << id << " IN "; exp->print(); cout << ">";
}

void UnaryOpNode::print() {
    cout << "<"; printTok(op); cout << " "; operand->print(); cout << ">";
}

void BinaryOpNode::print() {
    cout << "["; if (left) left->print(); cout << " "; printTok(op); cout << " "; if (right) right->print(); cout << "]";
}

void CommandNode::print() {
    printTok(cmd); cout << " "; cout << endl;
}

void CommandOpNode::print() {
    printTok(cmd); cout << " "; op->print(); cout << endl;
}

void SortNode::print() {
    printTok(cmd); PRINT(criteria); cout << endl;
}

void BranchNode::print() {
    printTok(cmd); cout << " "; if (x) { cout << "(x = "; x->print(); cout << ") "; } cout << "(";
    if (condition) condition->print(); cout << "): {" << endl; PRINT(then); cout << "}" << endl;
}

void AssignmentNode::print() {
    left->print(); cout << " = "; right->print(); cout << endl;
}

void GetXNode::print() {
    if (source == NULL) cout << name << endl;
    else if (name == NULL) { cout << "["; source->print(); cout << "]" << endl; }
    else {
        cout << "GETX {"; if (x) { cout << "(x = "; x->print(); cout << ") "; }
        cout << name << " FROM "; source->print(); cout << "}";
    }
}

void ChoiceNode::print() {
    printTok(cmd); cout << "{ "; PRINT(options); cout << "}: {"; PRINT(then); cout << "}"; cout << endl;
}

void MoveCardsNode::print() {
    printTok(cmd); cout << " "; if (cards) cards->print();
    cout << " "; if (dest) { cout << "TO "; dest->print(); }
    if (then->size() > 0) { cout << ": {" << endl; PRINT(then); cout << "}"; } cout<< endl;
}

void RollDiceNode::print() {
    cout << "ROLL "; x->print(); cout << " " << name; if (then) { cout << ": ("; PRINT(then); cout << ")"; } cout << endl;
}

void ParamNode::print() {
    cout << name;
    if (defaultValue) { cout << " = "; defaultValue->print(); }
}

void FunctionDefNode::print() {
    cout << "FUNCTION " << name; cout << "("; PRINT(params); cout << "): {" << endl; PRINT(body); cout << "}" << endl;
};

void FunctionCallNode::print() {
    cout << name << "("; PRINT(params); cout << ")" << endl;
};

void EachPlayerExecNode::print() {
    if (condition) { cout << "Each Player {"; condition->print(); cout << "} exec {" << endl; PRINT(statement); cout << "}" << endl; }
    else { cout << "Each Player exec {" << endl; PRINT(statement); cout << "}" << endl; }
}

void PlayerExecNode::print() {
    cout << "Player {"; player->print(); cout << "} exec {" << endl; PRINT(statement); cout << "}" << endl;
}

void VariableDeclNode::print() {
    cout << "Variable {"; printTok(visibility); cout<< " "; if (global) cout << "Global "; cout << name << "} ";
}

void ZoneDeclNode::print() {
    cout << "Zone {"; printTok(visibility); cout << " ";
    if (initial) cout << "Initial "; if (global) cout << "Global "; if (single) cout << "Single "; 
    cout << name << "} ";
}

void NewZoneNode::print() {
    if (temp) cout << "NEW (TEMP) ZONE " << decl; else cout << "NEW ZONE " << decl;
}

void XNode::print() {
    if (op == 0) cout << num;
    else { cout << "["; printTok(op); cout << " "; exp1->print(); cout << " ";
            if (exp2) exp2->print(); cout << "]"; }
}

void HeaderNode::print() {
    cout << "Header {"; numPlayers->print(); cout << "Game Type: "; printTok(gameType); cout << "}" << endl;
}

void ProgramNode::print() {
    cout << "Program {"; header->print(); PRINT(zones); cout << endl; PRINT(variables); cout << endl; PRINT(statements); cout << "}" << endl;
}