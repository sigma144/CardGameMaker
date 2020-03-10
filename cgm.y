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
	Node* node; ExpressionNode* expnode; CommandNode* cmdnode; VariableDeclNode* vdnode;
	ZoneDeclNode* zdnode; XNode* xnode; GetXNode* gxnode; HeaderNode* headnode; ProgramNode* prognode;
	LiteralNode* litnode; ReadVarNode* rvnode; AssignmentNode* anode; NameIteratorNode* ninode;
	FunctionCallNode* fnnode;
	list<Node*>* nlist; list<ZoneDeclNode*>* zlist; list<VariableDeclNode*>* vlist;
	list<CommandNode*>* clist; list<GetXNode*>* gxlist; list<ExpressionNode*>* explist; 
	list<ParamNode*>* pnlist;
}

%locations
%define parse.trace
%define parse.error verbose

%token '[' ']' '{' '}' '(' ')' '\n' ';'
/* Keywords */
%token<number> A ALL_NUMBERS AN ANY ANY_NUMBER_OF AT_LEAST BEFORE_ROUND BETWEEN BOTTOM BREAK BY BY_LOWEST
%token<number> CARD_GAME CHOOSE CONTINUE DELETE DESCENDING DISCARD DOWN_TO DO_WHILE DRAW EACH_PLAYER EACH_OTHER_PLAYER
%token<number> ELSE EXTRA_TURN FALSE FIRST_PLAYER FLIP FOR FROM GET GLOBAL HIDDEN IF IN TOK_INITIAL
%token<number> INTO LAST_PLAYER LIST LOOK_AT LOSE_GAME MAX MIN MOVE NEW_ROUND NEXT_PLAYER NEXT_TURN NO NONE NOT 
%token<number> OF ON OPTIONAL PLAY PLAYER_NUMBER PLAYERS PREVIOUS_PLAYER PREVIOUS_TURN PRIVATE PUBLIC RANDOM
%token<number> RANK_PLAYERS RANK_PLAYERS_STRICTLY REMOVE RETURN REVEAL ROLL ROUND_NUMBER SAY SET_TURN SHUFFLE 
%token<number> SINGLE SIZE SKIP_TURN SORT STANDARD_CARD_GAME SUM ON_TURN TEMP THEN TIE_GAME TO TOP TOP_ONLY TRUE 
%token<number> TURN_NUMBER TURN_ORDER UP_TO VARIABLES WHERE WHILE WIN_GAME YOU ZONE ZONES
/* Compound Tokens */
%token<str> STRING ID
%token<number> NUMBER
%token<str> UNKNOWN
%token<str> FUNCTION
/* Operators */
%token<number> AND OR ADD_E SUB_E MUL_E DIV_E MOD_E EQ NEQ LEQ GEQ '+' '-' '*' '/' '%' '<' '>' '.' '#' ':'
%left PLAYER
%left PLAYER_NUMBER
%right ':'
%left ANY NO
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
%left UNARY
%left AT_LEAST UP_TO DOWN_TO
%left IN FROM
%left UMINUS '#' NOT
%left LIST
%left '[' ']'
%left '.'
%left '(' ')'
/* Non=terminals */
%type<boolean> 	_bottom_of _optional _descending _random _single
%type<number> game_type visibility
%type<prognode> program
%type<headnode> header
%type<xnode> num_players indices x _x range
%type<zdnode> zone_decl
%type<vdnode> variable_decl
%type<expnode> _default_value criterion op1 op2
%type<zlist> zones zone_list
%type<vlist> variables variable_list
%type<clist> statement_block statement _then
%type<cmdnode> command
%type<anode> opassign
%type<expnode> player expr _where _to_players cards
%type<litnode> literal
%type<gxnode> choice
%type<gxlist> _choice_list choice_list _choice_list_e
%type<explist> criteria expr_list
%type<pnlist> param_list
%type<fnnode> function
%%

program : header zones variables statement_block { root = new ProgramNode($1, $2, $3, $4); }
		;
 header : STRING ':' num_players game_type '\n' { $$ = new HeaderNode($1, $3, $4); }
		;
  num_players : NUMBER '-' NUMBER ID			{ $$ = new XNode('-', new LiteralNode($1), new LiteralNode($3)); }
		| NUMBER ID		 						{ $$ = new XNode($1); }
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

statement_block	: statement_block statement '\n' _nl	{ $$ = $1; for (auto it = $2->begin(); it != $2->end(); ++it) $$->push_back(*it); }
		| _nl											{ $$ = new list<CommandNode*>(); }
		;

statement		: command							{ $$ = new list<CommandNode*>(); $$->push_back($1);}
				| statement ';' _nl command			{ $$ = $1; $1->push_back($4); }
				| '{' statement_block '}'			{ $$ = $2; }
				;

command	/* Game-Related Functions */
		: ON_TURN ':'			{ $$ = new CommandNode($1); }
		| NEXT_TURN				{ $$ = new CommandNode($1); }
		| PREVIOUS_TURN			{ $$ = new CommandNode($1); }
		| SET_TURN expr	 		{ $$ = new CommandOpNode($1, $2); }
		| SKIP_TURN				{ $$ = new CommandNode($1); }
		| EXTRA_TURN			{ $$ = new CommandNode($1); }
		| BEFORE_ROUND ':'		{ $$ = new CommandNode($1); }
		| NEW_ROUND				{ $$ = new CommandNode($1); }
		| SAY expr				{ $$ = new CommandOpNode($1, $2); }
		| WIN_GAME				{ $$ = new CommandNode($1); }
		| LOSE_GAME				{ $$ = new CommandNode($1); }
		| TIE_GAME				{ $$ = new CommandNode($1); }
		| RANK_PLAYERS criteria				{ $$ = new SortNode($1, new ExpressionNode(PLAYERS), $2, false); }
		| RANK_PLAYERS_STRICTLY criteria	{ $$ = new SortNode($1, new ExpressionNode(PLAYERS), $2, false); }
		/* Players */
		| player ':' _nl statement						{ $$ = new PlayerExecNode($1, $4); } 
		| EACH_PLAYER _where ':' _nl statement			{ $$ = new EachPlayerExecNode($2, $5, false); }
		| EACH_OTHER_PLAYER _where ':' _nl statement	{ $$ = new EachPlayerExecNode($2, $5, true); }
		/* Cards */
		| MOVE cards TO _bottom_of expr _then			{ $$ = new MoveCardsNode($1, $2, $5, $6, $4); }
		| SHUFFLE expr INTO expr _then					{ $$ = new MoveCardsNode($1, $2, $4, $5); }
		| REVEAL cards _to_players _then				{ $$ = new MoveCardsNode($1, $2, $3, $4); }
		| LOOK_AT cards _then							{ $$ = new MoveCardsNode($1, $2, NULL, $3); }
		| REMOVE cards _then							{ $$ = new MoveCardsNode($1, $2, NULL, $3); }
		| DRAW ID _then									{ $$ = new MoveCardsNode($1, new GetXNode(new XNode(1), $2, NULL), NULL, $3); }
		| DRAW x ID _then								{ $$ = new MoveCardsNode($1, new GetXNode($2, $3, NULL), NULL, $4); }
		/* Choices */
		| CHOOSE _optional _random _choice_list _then	{ $$ = new ChoiceNode($1, $2, $3, $4, $5); }
		| PLAY _optional _random _choice_list_e _then	{ $$ = new ChoiceNode($1, $2, $3, $4, $5); }
		| DISCARD _optional _random _choice_list_e _then { $$ = new ChoiceNode($1, $2, $3, $4, $5); }
		| ROLL _x ID _then								{ $$ = new RollDiceNode($2, $3, $4); }
		/* Lists */
		| SORT expr _descending					{ $$ = new SortNode($1, $2, new list<ExpressionNode*>(), $3); }
		| SORT expr ON expr _descending			{ $$ = new SortNode($1, $2, $4, $5); }
		| SHUFFLE expr							{ $$ = new CommandOpNode($1, $2); }
		/* Logic and Control Flow */
		| IF _x expr ':' _nl statement			{ $$ = new BranchNode($1, $2, $3, $6); }
		| ELSE ':' _nl statement				{ $$ = new BranchNode($1, NULL, NULL, $4); }
		| WHILE _x expr ':' _nl statement		{ $$ = new BranchNode($1, $2, $3, $6); }
		| DO_WHILE _x expr ':' _nl statement	{ $$ = new BranchNode($1, $2, $3, $6); }
		| FOR expr ':' _nl statement	 		{ $$ = new BranchNode($1, NULL, $2, $5); }
		| BREAK									{ $$ = new CommandNode($1); }
		| CONTINUE								{ $$ = new CommandNode($1); }
		/* Variables and Functions */
		| opassign						{ $$ = $1; }
		| visibility opassign			{ $$ = $2; $2->visibility = $1; }
		| TEMP opassign					{ $$ = $2; $2->temp = true; }
		| GLOBAL opassign				{ $$ = $2; $2->global = true; }
		| TEMP visibility opassign		{ $$ = $3; $3->visibility = $1; $3->temp = true; }
		| GLOBAL visibility opassign	{ $$ = $3; $3->visibility = $1; $3->global = true; }
		| visibility _single ZONE ID			{ $$ = new NewZoneNode(new ZoneDeclNode($1, false, false, $2, $4), false); }
		| visibility GLOBAL _single ZONE ID		{ $$ = new NewZoneNode(new ZoneDeclNode($1, false, true, $3, $5), false); }
		| TEMP visibility _single ZONE ID		{ $$ = new NewZoneNode(new ZoneDeclNode($2, false, false, $3, $5), true); }
		| DELETE expr					{ $$ = new CommandOpNode($1, $2); }
		| FUNCTION ID '(' param_list ')' ':' _nl statement	{ $$ = new FunctionDefNode($2, $4, $8); }
		| RETURN expr					{ $$ = new CommandOpNode($1, $2); }
		| function						{ $$ = $1; }
		;

expr	: '(' expr ')'				{ $$ = $2; }
		/* Players */
		| player %prec PLAYER		{ $$ = $1; }
		| PLAYERS					{ $$ = new ExpressionNode($1); }
		| TURN_ORDER				{ $$ = new ExpressionNode($1); }
		| TURN_NUMBER				{ $$ = new ExpressionNode($1); }
		| ROUND_NUMBER				{ $$ = new ExpressionNode($1); }
		/* Lists */
		| expr WHERE expr			{ $$ = new BinaryOpNode($2, $1, $3); }
		| TOP ID OF expr			{ $$ = new GetXNode(new XNode(1), $2, $4); }
		| BOTTOM ID OF expr			{ $$ = new GetXNode(new XNode(1), $2, $4); }
		| TOP x ID OF expr			{ $$ = new GetXNode($2, $3, $5); }
		| BOTTOM x ID OF expr		{ $$ = new GetXNode($2, $3, $5); }
		| GET FROM expr ':' expr	{ $$ = new BinaryOpNode($1, $3, $5); }
		| ID IN expr %prec IN		{ $$ = new NameIteratorNode($1, $3); }
		| LIST '[' expr_list ']'	{ $$ = new ListNode($3); }
		| ALL_NUMBERS range			{ $$ = new UnaryOpNode($1, $2); }
		/* Operators */
		| '-' expr %prec UMINUS			{ $$ = new UnaryOpNode($1, $2); }
		| MAX '(' expr ')'				{ $$ = new UnaryOpNode($1, $3); }
		| MIN '(' expr ')'				{ $$ = new UnaryOpNode($1, $3); }
		| SUM '(' expr ')'				{ $$ = new UnaryOpNode($1, $3); }
		| SIZE '(' expr ')'				{ $$ = new UnaryOpNode($1, $3); }
		| op1
		| op2
		/* Variables and Functions */
		| expr '[' indices ']'			{ $$ = new BinaryOpNode('[', $1, $3); }
		;

op1		: NO expr { $$ = new UnaryOpNode($1, $2); }
		| ANY expr { $$ = new UnaryOpNode($1, $2); }
		| NOT expr { $$ = new UnaryOpNode($1, $2); }
		;

op2		: expr EQ expr { $$ = new BinaryOpNode($2, $1, $3); }
		| expr NEQ expr { $$ = new BinaryOpNode($2, $1, $3); }
		| expr '<' expr { $$ = new BinaryOpNode($2, $1, $3); }
		| expr LEQ expr { $$ = new BinaryOpNode($2, $1, $3); }
		| expr '>' expr { $$ = new BinaryOpNode($2, $1, $3); }
		| expr GEQ expr { $$ = new BinaryOpNode($2, $1, $3); }
		| expr '+' expr { $$ = new BinaryOpNode($2, $1, $3); }
		| expr '-' expr { $$ = new BinaryOpNode($2, $1, $3); }
		| expr '*' expr { $$ = new BinaryOpNode($2, $1, $3); }
		| expr '/' expr { $$ = new BinaryOpNode($2, $1, $3); }
		| expr '%' expr { $$ = new BinaryOpNode($2, $1, $3); }
		| expr AND expr { $$ = new BinaryOpNode($2, $1, $3); }
		| expr OR expr { $$ = new BinaryOpNode($2, $1, $3); }
		;

opassign : expr '=' expr		{ $$ = new AssignmentNode($1, $3); }
		| expr ADD_E expr		{ $$ = new AssignmentNode($1, new BinaryOpNode('+', $1, $3)); }
		| expr SUB_E expr		{ $$ = new AssignmentNode($1, new BinaryOpNode('-', $1, $3)); }
		| expr MUL_E expr		{ $$ = new AssignmentNode($1, new BinaryOpNode('*', $1, $3)); }
		| expr DIV_E expr		{ $$ = new AssignmentNode($1, new BinaryOpNode('/', $1, $3)); }
		| expr MOD_E expr		{ $$ = new AssignmentNode($1, new BinaryOpNode('%', $1, $3)); }

literal	: NUMBER { $$ = new LiteralNode($1); }
		| STRING { $$ = new LiteralNode($1); }
		| TRUE { $$ = new LiteralNode(true); }
		| FALSE { $$ = new LiteralNode(false); }
		| NONE { $$ = new LiteralNode(); }
		;

cards	: ID FROM expr			{ $$ = new GetXNode(new XNode(1), $1, $3); }
		| x ID FROM expr		{ $$ = new GetXNode($1, $2, $4); }
		| expr					{ $$ = $1; }
		;

player	: YOU					{ $$ = new ExpressionNode($1); }
		| NEXT_PLAYER			{ $$ = new ExpressionNode($1); }
		| PREVIOUS_PLAYER		{ $$ = new ExpressionNode($1); }
		| FIRST_PLAYER			{ $$ = new ExpressionNode($1); }
		| LAST_PLAYER			{ $$ = new ExpressionNode($1); }
		| PLAYER_NUMBER expr	{ $$ = new UnaryOpNode($1, $2); }
		| literal				{ $$ = $1; }
		| function				{ $$ = $1; }
		| ID					{ $$ = new ReadVarNode($1); }
		| expr '.' expr			{ $$ = new BinaryOpNode('.', $1, $3); }
		;

x		: A 				{ $$ = new XNode(1); }
		| AN 				{ $$ = new XNode(1); }
		| NUMBER 			{ $$ = new XNode($1); }
		| '#' expr 			{ $$ = new XNode('#', $2); }
		| range
		;

indices	: expr			{ $$ = new XNode('#', $1); }
		| expr ':' expr	{ $$ = new XNode($2, $1, $3); }

range	: ANY_NUMBER_OF					{ $$ = new XNode($1, NULL); };
		| UP_TO	expr					{ $$ = new XNode($1, $2); };
		| DOWN_TO expr 					{ $$ = new XNode($1, $2); };
		| AT_LEAST expr					{ $$ = new XNode($1, $2); };
		| FROM expr TO expr %prec UNARY	{ $$ = new XNode($1, $2, $4); };

function	: ID '(' expr_list ')'		{ $$ = new FunctionCallNode($1, $3); }
			;

expr_list :						{ $$ = new list<ExpressionNode*>(); }
		| expr_list ',' expr	{ $$ = $1; $$->push_back($3); }
		| expr					{ $$ = new list<ExpressionNode*>(); $$->push_back($1); }
		;

_choice_list : choice_list
		| ID					{ $$ = new list<GetXNode*>(); $$->push_back(new GetXNode($1)); }

_choice_list_e : choice_list
		| expr					{ $$ = new list<GetXNode*>(); $$->push_back(new GetXNode($1)); }

choice_list	: choice_list ',' OR choice	{ $$->push_back($4); }
		| choice						{ $$ = new list<GetXNode*>(); $$->push_back($1); }
		;

choice	: ID range				{ $$ = new GetXNode(new XNode(1), $1, new UnaryOpNode(ALL_NUMBERS, $2));}
		| x ID range			{ $$ = new GetXNode($1, $2, new UnaryOpNode(ALL_NUMBERS, $3)); }
		| ID FROM expr			{ $$ = new GetXNode(new XNode(1), $1, $3); }
		| x ID FROM expr		{ $$ = new GetXNode($1, $2, $4); }
		;

param_list : 								{ $$ = new list<ParamNode*>(); }
		| param_list ',' ID _default_value	{ $$ = $1; $$->push_back(new ParamNode($3, $4));  }
		| ID _default_value					{ $$ = new list<ParamNode*>(); $$->push_back(new ParamNode($1, $2)); }
		;	

_default_value :				{ $$ = NULL; }
		| '=' expr				{ $$ = $2; }

criterion : BY expr			{ $$ = new UnaryOpNode($1, $2); }
		| BY_LOWEST	expr	{ $$ = new UnaryOpNode($1, $2); }
		;

criteria : criteria ',' THEN criterion	{ $$->push_back($4); }
		| criterion						{ $$ = new list<ExpressionNode*>(); $$->push_back($1); }
		;

_then		: { $$ = new list<CommandNode*>(); } | ':' _nl statement { $$ = $3; }
_where		: { $$ = NULL; }  | WHERE expr			{ $$ = $2; }
_bottom_of	: { $$ = false; } | BOTTOM OF			{ $$ = true; }
_to_players	: { $$ = NULL; }  | TO expr				{ $$ = $2; }
_optional	: { $$ = false; } | OPTIONAL			{ $$ = true; }
_descending	: { $$ = false; } | DESCENDING			{ $$ = true; }
_nl			: 				  | _nl '\n'
_random		: { $$ = false; } | RANDOM				{ $$ = true; }
_single		: { $$ = false; } | SINGLE				{ $$ = true; }
_x			: { $$ = NULL; } | x

statement 	: error									{ $$ = new list<CommandNode*>(); }

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
	cout << endl << "PARSE SUCCESSFUL!" << endl << endl;
	root->evaluate();
}

void yyerror(const char *s) {
  cout << "Parse error on line " << yylloc.first_line << ", column " << yylloc.first_column << ": " << s << endl;
  exit(-1);
}