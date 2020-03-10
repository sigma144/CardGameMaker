cgm: lex.yy.c cgm.tab.c cgm.tab.h interp.h interp.cpp interpprint.cpp types.h game.h game.cpp
	g++ -g cgm.tab.c lex.yy.c interp.cpp interpprint.cpp game.cpp -lfl -o cgm

cgm.tab.c cgm.tab.h: cgm.y
	bison -v -d cgm.y

lex.yy.c: cgm.l cgm.tab.h
	flex cgm.l

clean:
	rm cgm lex.yy.c