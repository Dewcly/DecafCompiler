parser: GrammarTree.l GrammarTree.y GrammarTree.h
	bison -d -v GrammarTree.y
	flex GrammarTree.l
	gcc GrammarTree.tab.c lex.yy.c GrammarTree.c -lfl -ly -o spider

.PHONY: clean
clean:
	rm spider.exe GrammarTree.tab.c GrammarTree.tab.h lex.yy.c
