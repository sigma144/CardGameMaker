%{
  #include "interp.h"
  #include "cgm.tab.h"
  #define YY_USER_ACTION \
    yylloc.first_line = yylloc.last_line; \
    yylloc.first_column = yylloc.last_column; \
    for(int i = 0; yytext[i] != '\0'; i++) { \
        if(yytext[i] == '\n') { \
            yylloc.last_line++; \
            yylloc.last_column = 0; \
        } \
        else { \
            yylloc.last_column++; \
        } \
    }
%}
%option noyywrap
%option yylineno
%%
[ \t]|"\\\r\n"|"\\\n" ;
[0-9]+			    { yylval.number = atoi(yytext); return NUMBER; }
\"(?:[^"\\]|\\.)*\" { yylval.str = strdup(yytext); return STRING; }
:			        { return ':'; }
"["			        { return '['; }
"]"		          	{ return ']'; }
"{"			        { return '{'; }
"}"			        { return '}'; }
"("			        { return '('; }
")"			        { return ')'; }
"#"                 { return '#'; }
;				    { return ';'; }
,                   { return ','; }
"."                 { return '.'; }
"\r\n"+|"\n"+	    { return '\n'; }
=                   { return '='; }
==                  { yylval.number = EQ; return EQ; }
!=                  { yylval.number = NEQ; return NEQ; }
"<"                 { yylval.number = '<'; return '<'; }
">"                 { yylval.number = '>'; return '>'; }
"<="                { yylval.number = LEQ; return LEQ; }
">="                { yylval.number = GEQ; return GEQ; }
"+="	            { yylval.number = ADD_E; return ADD_E; }
"-="	            { yylval.number = SUB_E; return SUB_E; }
"*="	            { yylval.number = MUL_E; return MUL_E; }
"/="	            { yylval.number = DIV_E; return DIV_E; }
"%="	            { yylval.number = MOD_E; return MOD_E; }
"+"	                { yylval.number = '+'; return '+'; }
"-"	                { yylval.number = '-'; return '-'; }
"*"	                { yylval.number = '*'; return '*'; }
"/"	                { yylval.number = '/'; return '/'; }
"%"	                { yylval.number = '%'; return '%'; }
a				    { yylval.number = A; return A; }
"all numbers"	    { yylval.number = ALL_NUMBERS; return ALL_NUMBERS; }
an			        { yylval.number = AN; return AN; }
and		        	{ yylval.number = AND; return AND; }
any                 { yylval.number = ANY; return ANY; }
"any number of" 	{ yylval.number = ANY_NUMBER_OF; return ANY_NUMBER_OF; }
"at least"          { yylval.number = AT_LEAST; return AT_LEAST; }
"before round"  	{ yylval.number = BEFORE_ROUND; return BEFORE_ROUND; }
between	      		{ yylval.number = BETWEEN; return BETWEEN; }
bottom	      		{ yylval.number = BOTTOM; return BOTTOM; }
break	        	{ yylval.number = BREAK; return BREAK; }
by			        { yylval.number = BY; return BY; }
"by lowest"	    	{ yylval.number = BY_LOWEST; return BY_LOWEST; }
"card game"	    	{ yylval.number = CARD_GAME; return CARD_GAME; }
choose		       	{ yylval.number = CHOOSE; return CHOOSE; }
continue	      	{ yylval.number = BY; return CONTINUE; }
delete		      	{ yylval.number = CONTINUE; return DELETE; }
descending	    	{ yylval.number = DESCENDING; return DESCENDING; }
discard	      		{ yylval.number = DISCARD; return DISCARD; }
"do while"	    	{ yylval.number = DO_WHILE; return DO_WHILE; }
"down to"           { yylval.number = DOWN_TO; return DOWN_TO; }
draw		        { yylval.number = DRAW; return DRAW; }
"each player"	  	{ yylval.number = EACH_PLAYER; return EACH_PLAYER; }
"each other player"	{ yylval.number = EACH_OTHER_PLAYER; return EACH_OTHER_PLAYER; }
else		        { yylval.number = ELSE; return ELSE; }
"extra turn"    	{ yylval.number = EXTRA_TURN; return EXTRA_TURN; }
false		        { yylval.number = FALSE; return FALSE; }
"first player"  	{ yylval.number = FIRST_PLAYER; return FIRST_PLAYER; }
flip		        { yylval.number = FLIP; return FLIP; }
for			        { yylval.number = FOR; return FOR; }
from		        { yylval.number = FROM; return FROM; }
function	       	{ yylval.number = FUNCTION; return FUNCTION; }
get			        { yylval.number = GET; return GET; }
global	      		{ yylval.number = GLOBAL; return GLOBAL; }
hidden		      	{ yylval.number = HIDDEN; return HIDDEN; }
if			        { yylval.number = IF; return IF; }
in			        { yylval.number = IN; return IN; }
initial	      		{ yylval.number = TOK_INITIAL; return TOK_INITIAL; }
into		        { yylval.number = INTO; return INTO; }
"last player"	    { yylval.number = LAST_PLAYER; return LAST_PLAYER; }
temp		        { yylval.number = TEMP; return TEMP; }
list		        { yylval.number = LIST; return LIST; }
"look at"           { yylval.number = LOOK_AT; return LOOK_AT; }
"lose game"	    	{ yylval.number = LOSE_GAME; return LOSE_GAME; }
max			        { yylval.number = MAX; return MAX; }
min			        { yylval.number = MIN; return MIN; }
move		        { yylval.number = MOVE; return MOVE; }
"new round"	     	{ yylval.number = NEW_ROUND; return NEW_ROUND; }
"next player"	    { yylval.number = NEXT_PLAYER; return NEXT_PLAYER; }
"next turn"		    { yylval.number = NEXT_TURN; return NEXT_TURN; }
no			        { yylval.number = NO; return NO; }
none		        { yylval.number = NONE; return NONE; }
not			        { yylval.number = NOT; return NOT; }
of			        { yylval.number = OF; return OF; }
on			        { yylval.number = ON; return ON; }
"on turn"	      	{ yylval.number = ON_TURN; return ON_TURN; }
optional	      	{ yylval.number = OPTIONAL; return OPTIONAL; }
or		        	{ yylval.number = OR; return OR; }
play		        { yylval.number = PLAY; return PLAY; }
"player number" 	{ yylval.number = PLAYER_NUMBER; return PLAYER_NUMBER; }
players		      	{ yylval.number = PLAYERS; return PLAYERS; }
"previous player"   { yylval.number = PREVIOUS_PLAYER; return PREVIOUS_PLAYER; }
"previous turn" 	{ yylval.number = PREVIOUS_TURN; return PREVIOUS_TURN; }
private		      	{ yylval.number = PRIVATE; return PRIVATE; }
public		      	{ yylval.number = PUBLIC; return PUBLIC; }
random		      	{ yylval.number = RANDOM; return RANDOM; }
"rank players"  	{ yylval.number = RANK_PLAYERS; return RANK_PLAYERS; }
"rank players strictly"	{ yylval.number = RANK_PLAYERS_STRICTLY; return RANK_PLAYERS_STRICTLY; }
remove		      	{ yylval.number = REMOVE; return REMOVE; }
return 		      	{ yylval.number = RETURN; return RETURN; }
reveal		      	{ yylval.number = REVEAL; return REVEAL; }
roll			    { yylval.number = ROLL; return ROLL; }
"round number"      { yylval.number = ROUND_NUMBER; return ROUND_NUMBER; }
say				    { yylval.number = SAY; return SAY; }
"set turn"	    	{ yylval.number = SET_TURN; return SET_TURN; }
shuffle		      	{ yylval.number = SHUFFLE; return SHUFFLE; }
single              { yylval.number = SINGLE; return SINGLE; }
size                { yylval.number = SIZE; return SIZE; }
"skip turn"	    	{ yylval.number = SKIP_TURN; return SKIP_TURN; }
sort		        { yylval.number = SORT; return SORT; }
"standard card game" { yylval.number = STANDARD_CARD_GAME; return STANDARD_CARD_GAME; }
sum			        { yylval.number = SUM; return SUM; }
then		        { yylval.number = THEN; return THEN; }
"tie game"	    	{ yylval.number = TIE_GAME; return TIE_GAME; }
to			        { yylval.number = TO; return TO; }
top				    { yylval.number = TOP; return TOP; }
"top only"	    	{ yylval.number = TOP_ONLY; return TOP_ONLY; }
true		        { yylval.number = TRUE; return TRUE; }
"turn number"	    { yylval.number = TURN_NUMBER; return TURN_NUMBER; }
"turn order"    	{ yylval.number = TURN_ORDER; return TURN_ORDER; }
"up to"		      	{ yylval.number = UP_TO; return UP_TO; }
variables	      	{ yylval.number = VARIABLES; return VARIABLES; }
where		        { yylval.number = WHERE; return WHERE; }
while			    { yylval.number = WHILE; return WHILE; }
"win game"	    	{ yylval.number = WIN_GAME; return WIN_GAME; }
you			        { yylval.number = YOU; return YOU; }
zone		       	{ yylval.number = ZONE; return ZONE; }
zones		       	{ yylval.number = ZONES; return ZONES; }
[A-Za-z_][A-Za-z0-9_]*	{ yylval.str = strdup(yytext); return ID; }
"//"[^\n]*               { };
"/*"(\*[^\/]|[^*])*"*/" { };
.             	        { yylval.str = strdup(yytext); return UNKNOWN; }
%%