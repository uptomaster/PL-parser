%{
#include "hw02_C111115.tab.h"
#include <stdio.h>

int lexeme_count = 0;
int id_count = 0;
%}

%%
"int"       { lexeme_count++; return INT; }
"if"        { lexeme_count++; return IF; }
"else"      { lexeme_count++; return ELSE; }
"while"     { lexeme_count++; return WHILE; }
"return"    { lexeme_count++; return RETURN; }

[0-9]+      { lexeme_count++; yylval.num = atoi(yytext); return NUMBER; }

[a-zA-Z][a-zA-Z0-9_]* {
    lexeme_count++;
    id_count++;
    yylval.str = strdup(yytext);
    return IDENT;
}

// 연산자
"=="|"!="|"<="|">="|"<"|">"|"+"|"-"|"*"|"/"|"=" { lexeme_count++; return OP; }

";" { lexeme_count++; return SEMI; }
"," { lexeme_count++; return COMMA; }
"(" { lexeme_count++; return LP; }
")" { lexeme_count++; return RP; }
"{" { lexeme_count++; return LB; }
"}" { lexeme_count++; return RB; }

// 주석 제거
"//".*              { }
"/*"([^*]|\*+[^*/])*\*+"/" { }

[ \t\n] { }

. { }

%%