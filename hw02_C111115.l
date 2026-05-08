%{
#include "hw02_C111115_node.h"
#include "hw02_C111115.tab.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int lexeme_count = 0;
int id_count = 0;
%}

%%

"int"                  { lexeme_count++; return INT; }
"main"                 { lexeme_count++; return MAIN; }
"if"                   { lexeme_count++; return IF; }
"else"                 { lexeme_count++; return ELSE; }
"while"                { lexeme_count++; return WHILE; }
"return"               { lexeme_count++; return RETURN; }

"=="|"!="|"<="|">="    { lexeme_count++; return RELOP; }
"<"|">"                { lexeme_count++; return RELOP; }

"+"|"-"                { lexeme_count++; return ADDOP; }
"*"|"/"                { lexeme_count++; return MULOP; }

"="                    { lexeme_count++; return ASSIGN; }

";"                    { lexeme_count++; return SEMI; }
","                    { lexeme_count++; return COMMA; }

"("                    { lexeme_count++; return LP; }
")"                    { lexeme_count++; return RP; }

"{"                    { lexeme_count++; return LB; }
"}"                    { lexeme_count++; return RB; }

[0-9]+ {
    lexeme_count++;

    yylval.num = atoi(yytext);

    return NUMBER;
}

[a-zA-Z][a-zA-Z0-9_]* {
    lexeme_count++;
    id_count++;

    yylval.str = strdup(yytext);

    return IDENT;
}

"/*"([^*]|\n|(\*+([^*/]|\n)))*"*"+"/"    {}

"//".*    {}

[ \t\n\r]+    {}

.    {}

%%

int yywrap() {
    return 1;
}