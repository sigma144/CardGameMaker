#include <iostream>
#include <stdlib.h>
#include <map>
#include "interp.h"

using namespace std;

void ExpressionNode::print() {
    
}

void StatementNode::print() {
    
}

void VariableDeclNode::print() {
    cout << "Variable {" << "vis: " << visibility << " "; if (global) cout << "Global "; cout << name << "} ";
}

void ZoneDeclNode::print() {
    cout << "Zone {" << visibility << " ";
    if (initial) cout << "Initial "; if (global) cout << "Global "; if (single) cout << "Single "; 
    cout << name << "} ";
}

void NumPlayersNode::print() {
    cout << "Players {" << min << "-" << max << "} ";
}

void HeaderNode::print() {
    cout << "Header {"; numPlayers->print(); cout << "Game Type: " << gameType << "} ";
}

void ProgramNode::print() {
    cout << "Program {"; header->print(); PRINT(zones); PRINT(variables); PRINT(statements); cout << "} ";
}

void ProgramNode::evaluate() {
    cout << "Running Game " << header->name << endl;
}