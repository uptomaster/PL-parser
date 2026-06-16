%{
#include "hw02_C111115.tab.h"

"," {
    lexeme_count++;
    return COMMA;
}

"(" {
    lexeme_count++;
    return LP;
}
// 전체 lexeme 개수를 저장하는 변수이다.
// keyword나 괄호, 연산자 같은 것도 전부 lexeme으로 보기 때문에
// token 하나를 인식할 때마다 같이 증가하도록 만들었다.
int lexeme_count = 0;


// identifier 등장 횟수를 저장하는 변수이다.
// 같은 이름이 여러 번 등장해도 각각 따로 카운트한다.
int id_count = 0;

%}

")" {
    lexeme_count++;
    return RP;
}

"{" {
    lexeme_count++;
    return LB;
}

"int" {
    lexeme_count++;
    return INT;
}

"main" {
    lexeme_count++;
    return MAIN;
}

"if" {
    lexeme_count++;
    return IF;
}

"else" {
    lexeme_count++;
    return ELSE;
}

"while" {
    lexeme_count++;
    return WHILE;
}

"return" {
    lexeme_count++;
    return RETURN;
}


// 관계 연산자를 처리하는 부분이다.
// AST 출력 시 실제 연산자 모양 그대로 출력하기 위해
// yytext 문자열 자체를 parser로 넘겨주도록 만들었다.

"=="|"!="|"<="|">="|"<"|">" {

    lexeme_count++;

    yylval.str = strdup(yytext);

    return RELOP;
}


// 덧셈과 뺄셈 연산자를 처리하는 부분이다.
// parser 단계에서 실제 연산자 문자열이 필요하기 때문에 그대로 넘겨준다.

"+"|"-" {

    lexeme_count++;

    yylval.str = strdup(yytext);

    return ADDOP;
}


// 곱셈과 나눗셈 연산자를 처리하는 부분이다.

"*"|"/" {

    lexeme_count++;

    yylval.str = strdup(yytext);

    return MULOP;
}


// assignment 연산자를 처리하는 부분이다.

"=" {

    lexeme_count++;

    yylval.str = strdup(yytext);

    return ASSIGN;
}


";" {
    lexeme_count++;
    return SEMI;
}

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


// 정수 literal을 처리하는 부분이다.
// atoi를 사용해서 실제 int 값으로 변환한 뒤 parser로 전달한다.

/* integer literal */
[0-9]+ {

    lexeme_count++;

    yylval.num = atoi(yytext);

    return NUMBER;
}

/* identifier */

// identifier를 처리하는 부분이다.
// 영문자로 시작해야 하고 이후에는 숫자나 underscore도 허용되도록 만들었다.

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

// block comment는 parser 단계까지 넘기지 않고
// lexical analysis 단계에서 바로 제거하도록 만들었다.

"/*"([^*]|\n|(\*+([^*/]|\n)))*"*"+"/" {

}


// line comment 역시 parser까지 넘기지 않고 무시한다.

"//".* {

}


// 공백 문자나 개행 문자는 의미가 없으므로 무시한다.

[ \t\r\n]+ {

}


// 정의하지 않은 문자는 별도로 처리하지 않고 넘어간다.

. {

}

%%

/* flex 종료 처리 */
int yywrap() {

    return 1;
}