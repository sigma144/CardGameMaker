#pragma once

enum Type { T_NONE, T_NUMBER, T_STRING, T_BOOLEAN, T_CARD, T_PLAYER };

struct Val {
    Type type;
    int list;
    void* val;
};