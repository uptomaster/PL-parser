%{

"," {
    lexeme_count++;
    return COMMA;
}

"(" {
    lexeme_count++;
    return LP;
}

")" {
    lexeme_count++;
    return RP;
}

"{" {
    lexeme_count++;
    return LB;
}

"}" {
    lexeme_count++;
    return RB;
}

/* integer literal */
[0-9]+ {
    lexeme_count++;

    yylval.num = atoi(yytext);

    return NUMBER;
}

/* identifier */
[a-zA-Z][a-zA-Z0-9_]* {
    lexeme_count++;
    id_count++;

    yylval.str = strdup(yytext);

    return IDENT;
}

/* block comment */
"/*"([^*]|\n|(\*+([^*/]|\n)))*"*"+"/"    {}

/* line comment */
"//".*    {}

/* whitespace */
[ \t\n\r]+    {}

/* undefined character */
.    {}

%%

/* flex 종료 처리 */
int yywrap() {
    return 1;
}