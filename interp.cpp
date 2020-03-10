#include "interp.h"
#include "cgm.tab.h"
#include "game.h"

Val ExpressionNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val LiteralNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val ListNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val ReadVarNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val NameIteratorNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val UnaryOpNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val BinaryOpNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val CommandNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val CommandOpNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val SortNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val BranchNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val AssignmentNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val GetXNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val ChoiceNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val MoveCardsNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val RollDiceNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val ParamNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val FunctionDefNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
};

Val FunctionCallNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
};

Val EachPlayerExecNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val PlayerExecNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val VariableDeclNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val ZoneDeclNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val NewZoneNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val XNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val HeaderNode::evaluate(Game* game) {
    return { T_NONE, 0, 0 };
}

Val ProgramNode::evaluate(Game* game) {
    cout << "Running Game " << header->name << endl; 
    return { T_NONE, 0, 0 };
}