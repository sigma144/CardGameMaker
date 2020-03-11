#include "interp.h"
#include "cgm.tab.h"
#include "game.h"

void Node::checkType(string var, Val val, Type type) {
    if (val.type != type) typeError(var, val.type, type);
}

void Node::printTok(int tok) {
    cout << getTokString(tok);
}

void Node::error(string message) {
    throw runtime_error(getErrorHeader() + message);
}

void Node::typeError(string var, Type expected, Type received) {
    throw runtime_error(getErrorHeader() + " expected type " + getTypeString(expected)
            + " for <" + var + ">, got type " + getTypeString(received));
}

string Node::getTokString(int tok) {
    if (Node::tokNames.count(tok)) return tokNames[tok];
    return string(1, char(tok));
}

string Node::getErrorHeader() {
    return "ERROR! " + getTokString(cmd) + ": ";
}

string Node::getTypeString(Type type) {
    string str;
    switch (type) {
        case T_NONE: str = "NONE"; break;
        case T_NUMBER: str = "NUMBER"; break;
        case T_STRING: str = "STRING"; break;
        case T_BOOLEAN: str = "BOOLEAN"; break;
        case T_CARD: str = "CARD"; break;
        case T_PLAYER: str = "PLAYER"; break;
    }
    int listLevel = (type & T_LIST) % T_LIST;
    for (; listLevel >= 0; --listLevel) {
        str = "LIST<" + str + ">";
    }
    return str;
}

Val ExpressionNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val XNode::evaluate(Game* game) {
    if (op == 0) {
        ValData vdata; vdata.number = num;
        return { T_NUMBER, vdata };
    }
    if (exp2) {
        Val min = exp1->evaluate(game);
        checkType("min", min, T_NUMBER);
        Val max = exp2->evaluate(game);
        checkType("max", max, T_NUMBER);
        list<int>* range = new list<int>();
        range->push_back(min.val.number);
        range->push_back(max.val.number);
        return { T_LIST_NUMBER, range };
    }
    else {
        Val num = exp1->evaluate(game);
        checkType("num", num, T_NUMBER);
        list<int>* range = new list<int>();
        range->push_back(num.val.number);
        return { T_LIST_NUMBER, range };
    }
}

Val LiteralNode::evaluate(Game* game) {
    return val;
}

Val ListNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val ReadVarNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val NameIteratorNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val UnaryOpNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val BinaryOpNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val CommandNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val CommandOpNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val SortNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val BranchNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val AssignmentNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val GetXNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val ChoiceNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val MoveCardsNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val RollDiceNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val ParamNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val FunctionDefNode::evaluate(Game* game) {
    return { T_NONE, 0 };
};

Val FunctionCallNode::evaluate(Game* game) {
    return { T_NONE, 0 };
};

Val EachPlayerExecNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val PlayerExecNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val VariableDeclNode::evaluate(Game* game) {
    Val val = { T_NONE, 0 };
    if (defaultValue) val = defaultValue->evaluate(game);
    if (global) {
        game->setGlobalVar(name, val, visibility );
    }
    else {
        for (Player* p : game->players)
            game->setPlayerVar(p, name, val, visibility );
    }
    return { T_NONE, 0 };
}

Val ZoneDeclNode::evaluate(Game* game) {
    Zone* zone = new Zone();
    zone->single = single;
    if (global) {
        game->setGlobalVar(name, { T_ZONE, zone }, visibility );
    }
    else {
        for (Player* p : game->players)
            game->setPlayerVar(p, name, { T_ZONE, zone }, visibility );
    }
    //TODO: Handle initial
    return { T_NONE, 0 };
}

Val NewZoneNode::evaluate(Game* game) {
    return { T_NONE, 0 };
}

Val HeaderNode::evaluate(Game* game) {
    game->title = name;

    Val range = numPlayers->evaluate(game);
    int min, max;
    if (range.type == T_NUMBER) {
        min = max = range.val.number;
    }
    else {
        list<int>* nums = (list<int>*)range.val.ptr;
        min = *nums->begin();
        max = *nums->end() - 1;
    }
    game->initPlayers(min, max);

    //TODO: Handle game type

    return { T_NONE, 0 };
}

Val ProgramNode::evaluate(Game* game) {
    header->evaluate(game);
    for (ZoneDeclNode* zone : *zones) zone->evaluate(game);
    for (VariableDeclNode* var : *variables) var->evaluate(game);
    bool buildTurnLoop = false;
    bool buildRoundLoop = false;
    for (CommandNode* statement : *statements) {
        if (statement->cmd == ON_TURN) {
            if (buildTurnLoop) error("Extra \"on turn\" statement");
            buildTurnLoop = true;
            continue;
        }
        if (statement->cmd == BEFORE_ROUND) {
            if (buildRoundLoop) error("Extra \"before round\" statement");
            if (buildTurnLoop) error("\"before round\" must come before \"on turn\"");
            buildRoundLoop = true;
            continue;
        }
        if (buildTurnLoop) game->turnLoop.push_back(statement);
        else if (buildRoundLoop) game->roundLoop.push_back(statement);
        else statement->evaluate(game);
    }
    if (!buildTurnLoop) error("No \"on turn:\" statement");
    return { T_NONE, 0 };
}