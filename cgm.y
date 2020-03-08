%{
	#include <cstdio>
	#include <iostream>
	#include <list>
	#include "interp.h"
	using namespace std;

	// stuff from flex that bison needs to know about:
	extern int yylex();
	extern int yyparse();
	extern FILE *yyin;
	
	ProgramNode* root;
 
	void yyerror(const char *s);
%}

%union {
	bool boolean;
	int number;
	char* str;
	Node* node; ExpressionNode* expnode; StatementNode* stmtnode; VariableDeclNode* vdnode;
	ZoneDeclNode* zdnode; NumPlayersNode* npnode; HeaderNode* headnode; ProgramNode* prognode;
	list<Node*>* nlist; list<ZoneDeclNode*>* zlist; list<VariableDeclNode*>* vlist;
	list<StatementNode*>* slist;
}

%locations
%define parse.trace
%define parse.error verbose

%token ':' '[' ']' '{' '}' '(' ')' ';' '.' '\n' '#'
/* Keywords */
%token A ALL_NUMBERS AN ANY ANY_NUMBER_OF AT_LEAST BEFORE_ROUND BETWEEN BOTTOM BREAK BY BY_LOWEST
%token CHOOSE CONTINUE DELETE DESCENDING DISCARD DO_WHILE DRAW EACH_PLAYER EACH_OTHER_PLAYER
%token ELSE EXTRA_TURN FALSE FIRST_PLAYER FLIP FOR FROM FUNCTION GET GLOBAL IF IN TOK_INITIAL
%token INTO LAST_PLAYER LET LIST LOSE_GAME MAX MIN MOVE NEW_ROUND NEXT_PLAYER NEXT_TURN NO NONE 
%token NOT NUMBER_OF OF ON OPTIONAL PLAY PLAYER_NUMBER PLAYERS PREVIOUS_PLAYER PREVIOUS_TURN RANDOM
%token RANK_PLAYERS RANK_PLAYERS_STRICTLY REMOVE RETURN REVEAL ROLL SAY SET_TURN SHUFFLE 
%token SINGLE SKIP_TURN SORT SUM ON_TURN THEN TIE_GAME TO TOP TRUE TURN_NUMBER TURN_ORDER
%token VARIABLES WHILE WIN_GAME YOU ZONES
%token<number> CARD_GAME STANDARD_CARD_GAME PUBLIC PRIVATE HIDDEN TOP_ONLY
/* Compound Tokens */
%token<str> STRING
%token<number> NUMBER
%token<str> ID
%token UNKNOWN
/* Operators */
%left ';'
%left PLAYER
%left PLAYER_NUMBER
%right ':'
%right '=' ADD_E SUB_E MUL_E DIV_E MOD_E
%left FOR
%left TOP BOTTOM
%left OF
%right WHERE
%left OR
%left AND
%left EQ NEQ '<' '>' LEQ GEQ
%left '+' '-'
%left '*' '/' '%'
%left BINARY
%left AT_LEAST UP_TO
%left UMINUS
%left LIST
%left UNARY
%left IN FROM
%left '[' ']'
%left '.'
%left '(' ')'
/* Non=terminals */
%type<boolean> 	_bottom_of _optional _descending _random _single
%type<number> game_type visibility
//%type<str> header
%type<prognode> program
%type<headnode> header
%type<npnode> num_players
%type<zdnode> zone_decl
%type<vdnode> variable_decl
%type<expnode> _default_value
%type<zlist> zones zone_list
%type<vlist> variables variable_list
%type<slist> statement_block

%%

program : header zones variables statement_block { root = new ProgramNode($1, $2, $3, $4); }
		;
 header : STRING ':' num_players game_type '\n' { $$ = new HeaderNode($1, $3, $4); }
		;
  num_players : NUMBER '-' NUMBER ID			{ $$ = new NumPlayersNode($1, $3); }
		| NUMBER ID		 						{ $$ = new NumPlayersNode($1, $1); }
		;
  game_type : CARD_GAME
		| STANDARD_CARD_GAME
		;
 zones	: ZONES ':' zone_list '\n'				{ $$ = $3; }
		;
  zone_list : zone_list ',' zone_decl			{ $$ = $1; $$->push_back($3); }
		| zone_decl	 							{ $$ = new list<ZoneDeclNode*>(); $$->push_back($1); }
		;
   zone_decl : visibility _single ID			{ $$ = new ZoneDeclNode($1, false, false, $2, $3); }
		| visibility TOK_INITIAL _single ID		{ $$ = new ZoneDeclNode($1, true, false, $3, $4); }
		| visibility GLOBAL _single ID			{ $$ = new ZoneDeclNode($1, false, true, $3, $4); }
		;
    visibility : PUBLIC | PRIVATE | HIDDEN | TOP_ONLY
		;

 variables : VARIABLES ':' variable_list '\n'	{ $$ = $3; } | { $$ = new list<VariableDeclNode*>(); }
		;
  variable_list : variable_list ',' variable_decl	{ $$ = $1; $$->push_back($3); }
		| variable_decl	 							{ $$ = new list<VariableDeclNode*>(); $$->push_back($1); }
		;
   variable_decl : visibility ID _default_value		{ $$ = new VariableDeclNode($1, false, $2, $3); }
		| visibility GLOBAL ID _default_value		{ $$ = new VariableDeclNode($1, true, $3, $4); }
		;

statement_block	: statement_block statement '\n' _nl	{ $$ = $1; $$->push_back(new StatementNode()); }
		| _nl											{ $$ = new list<StatementNode*>(); }
		;

statement		: command							{ }
				| statement ';' _nl command			{ }
				| '{' statement_block '}'			{ }
				;

command	/* Game-Related Functions */
		: ON_TURN ':'			{ }
		| NEXT_TURN				{ }
		| PREVIOUS_TURN			{ }
		| SET_TURN expr	 		{ }
		| SKIP_TURN				{ }
		| EXTRA_TURN			{ }
		| BEFORE_ROUND ':'		{ }
		| NEW_ROUND				{ }
		| SAY expr				{ }
		| WIN_GAME				{ }
		| LOSE_GAME				{ }
		| TIE_GAME				{ }
		| RANK_PLAYERS criteria				{ }
		| RANK_PLAYERS_STRICTLY criteria	{ }
		/* Players */
		| player ':' _nl statement						{ } 
		| EACH_PLAYER _where ':' _nl statement			{ }
		| EACH_OTHER_PLAYER _where ':' _nl statement	{ }
		/* Cards */
		| MOVE x expr TO _bottom_of expr _then	{ }
		| SHUFFLE expr INTO expr _then			{ }
		| REVEAL x expr _to_players _then		{ }
		| REMOVE x expr _then					{ }
		| DRAW x ID _then						{ }
		/* Choices */
		| CHOOSE _optional _random choice_list _then	{ }
		| PLAY _optional _random choice_list _then		{ }
		| DISCARD _optional _random choice_list _then	{ }
		| ROLL x ID _then								{ }
		| FLIP x ID _then								{ }
		/* Lists */
		| SORT expr _descending					{ }
		| SORT ID OF expr ON expr _descending	{ }
		| SHUFFLE expr							{ }
		/* Logic and Control Flow */
		| IF x expr ':' _nl statement			{ }
		| ELSE ':' _nl statement				{ }
		| WHILE x expr ':' _nl statement		{ }
		| DO_WHILE x expr ':' _nl statement		{ }
		| FOR expr ':' _nl statement	 		{ }
		| BREAK									{ }
		| CONTINUE								{ }
		/* Variables and Functions */
		| expr '=' expr					{ }
		| visibility expr '=' expr		{ }
		| expr ADD_E expr				{ }
		| expr SUB_E expr				{ }
		| expr MUL_E expr				{ }
		| expr DIV_E expr				{ }
		| expr MOD_E expr				{ }
		| LET ID '=' expr				{ }
		| GLOBAL ID '=' expr			{ }
		| LET visibility ID '=' expr	{ }
		| GLOBAL visibility ID '=' expr	{ }
		| DELETE expr									{ }
		| FUNCTION ID '(' param_list ')' ':' _nl statement	{ }
		| RETURN expr				{ }
		| function						{ }
		;

expr	: '(' expr ')'
		/* Players */
		| player %prec PLAYER		{ }
		| PLAYERS					{ }
		| TURN_ORDER				{ }
		| TURN_NUMBER				{ }
		/* Lists */
		| expr WHERE expr			{ }
		| TOP x ID OF expr			{ }
		| BOTTOM x ID OF expr		{ }
		| GET FROM expr ':' expr	{ } 
		| ID IN expr				{ }
		| ID FROM expr				{ }
		| LIST '[' expr_list ']'	{ }
		| ID range					{ }
		| ALL_NUMBERS range			{ }
		/* Operators */
		| op1 expr %prec UNARY			{ }
		| expr op2 expr	%prec BINARY	{ }
		/* Variables and Functions */
		| expr '[' indices ']'	{ }
		;

op1		: NO { } | ANY { } | NOT { } | '-' %prec UMINUS { } | NUMBER_OF { } | MAX { } | MIN { } | SUM { } ;

op2		: EQ { } | NEQ { } | '<' { } | LEQ { } | '>' { } | GEQ { }
		| '+' { } | '-' { } | '*' { } | '/' { } |  '%' { }
		| AND { } | OR { }
		;

literal	: NUMBER { } | STRING { } | TRUE { } | FALSE { } | NONE { };

player	: YOU					{ }
		| NEXT_PLAYER			{ }
		| PREVIOUS_PLAYER		{ }
		| FIRST_PLAYER			{ }
		| LAST_PLAYER			{ }
		| PLAYER_NUMBER expr	{ }
		| literal				{ }
		| function				{ }
		| ID					{ }
		| expr '.' expr			{ }
		;

x		: A 				{ }
		| AN 				{ }
		| NUMBER 			{ }
		| '#' '(' expr ')'	{ }
		| range				{ }
		|					{ }
		;

indices	: expr			{ }
		| expr ':' expr	{ }

range	: ANY_NUMBER_OF					{ };
		| UP_TO	expr					{ };
		| AT_LEAST expr					{ };
		| BETWEEN expr AND expr 		{ };

function	: ID '(' expr_list ')'	{ }
			;

expr_list :
		| expr_list ',' expr	{ }
		| expr					{ }
		;

choice_list	: choice_list ',' OR choice	{ }
		| choice						{ }
		;

choice	: x expr			{ }
		;

param_list : 								{ }
		| param_list ',' ID _default_value	{ }
		| ID _default_value					{ }
		;	

_default_value :				{ $$ = NULL; }
		| '=' expr				{ $$ = new ExpressionNode(); }

criterion : BY expr			{ }
		| BY_LOWEST	expr	{ }
		;

criteria : criteria ',' THEN criterion	{ }
		| criterion					{ }
		;

_then		: { } 			  | ':' _nl statement	{ }
_where		: { } 			  | WHERE expr			{ }
_bottom_of	: { $$ = false; } | BOTTOM OF			{ $$ = true; }
_to_players	: { } 			  | TO expr				{ }
_optional	: { $$ = false; } | OPTIONAL			{ $$ = true; }
_descending	: { $$ = false; } | DESCENDING			{ $$ = true; }
_nl			: 				  | _nl '\n'
_random		: { $$ = false; } | RANDOM				{ $$ = true; }
_single		: { $$ = false; } | SINGLE				{ $$ = true; }

statement 	: error

%%

int main(int argc, char** argv) {
	if (argc == 1) {
		cout << "Please run with a file name\n";
		return -1;
	}
	FILE *myfile = fopen(argv[1], "r");
	if (!myfile) {
		cout << "Couldn't open " << argv[1] << endl;
		return -1;
	}
	yyin = myfile;
	yydebug = 0;
	yyparse();

	root->print();
	cout << endl << "RUNNING PROGRAM: " << endl << endl;
	root->evaluate();
}

void yyerror(const char *s) {
  cout << "Parse error on line " << yylloc.first_line << ", column " << yylloc.first_column << ": " << s << endl;
  exit(-1);
}