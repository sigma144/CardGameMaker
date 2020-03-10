#include "interp.h"
#include "cgm.tab.h"



Val ExpressionNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val LiteralNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val ListNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val ReadVarNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val NameIteratorNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val UnaryOpNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val BinaryOpNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val CommandNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val CommandOpNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val SortNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val BranchNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val AssignmentNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val GetXNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val ChoiceNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val MoveCardsNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val RollDiceNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val ParamNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val FunctionDefNode::evaluate() {
    return { T_NONE, 0, 0 };
};

Val FunctionCallNode::evaluate() {
    return { T_NONE, 0, 0 };
};

Val EachPlayerExecNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val PlayerExecNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val VariableDeclNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val ZoneDeclNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val NewZoneNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val XNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val HeaderNode::evaluate() {
    return { T_NONE, 0, 0 };
}

Val ProgramNode::evaluate() {
    cout << "Running Game " << header->name << endl; 
    return { T_NONE, 0, 0 };
}