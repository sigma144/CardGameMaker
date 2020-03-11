cgm: lex.yy.c cgm.tab.c cgm.tab.h interp.h game.h interface.h consoleint.h *.cpp
	g++ -g cgm.tab.c lex.yy.c *.cpp -lfl -o cgm

cgm.tab.c cgm.tab.h: cgm.y
	bison -v -d cgm.y

lex.yy.c: cgm.l cgm.tab.h
	flex cgm.l

clean:
	rm cgm lex.yy.c cgm.tab.c cgm.tab.h