%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "hw02_C111115_node.h"

extern int lexeme_count;
extern int id_count;

int stmt_count = 0;

Node* root;

int yylex(void);

void yyerror(const char* s) {
    printf("error: %s\n", s);
}
%}

%union {
    int num;
    char* str;
    Node* node;
}

%token INT MAIN IF ELSE WHILE RETURN

%token <str> IDENT
%token <num> NUMBER

%token ADDOP MULOP RELOP ASSIGN
%token SEMI COMMA LP RP LB RB

%type <node> program function compound_stmt
%type <node> decl_list decl ident_list
%type <node> stmt_list stmt
%type <node> expr assignment equality
%type <node> relational additive multiplicative primary

%%

program
    : function
    {
        root = $1;
    }
    ;

function
    : INT MAIN LP RP compound_stmt
    {
        $$ = createNode("<int main()>");
        addChild($$, $5);
    }
    ;

compound_stmt
    : LB decl_list stmt_list RB
    {
        $$ = createNode("block{}");

        addChild($$, $2);
        addChild($$, $3);
    }
    ;

decl_list
    : decl_list decl
    {
        $$ = linkSibling($1, $2);
    }
    | /* empty */
    {
        $$ = NULL;
    }
    ;

decl
    : INT ident_list SEMI
    {
        Node* n = createNode("<int_decl>");

        addChild(n, $2);

        $$ = n;
    }
    ;

ident_list
    : IDENT
    {
        char buf[64];

        sprintf(buf, "IDENT(%s)", $1);

        $$ = createNode(buf);

        free($1);
    }
    | ident_list COMMA IDENT
    {
        char buf[64];

        sprintf(buf, "IDENT(%s)", $3);

        $$ = linkSibling($1, createNode(buf));

        free($3);
    }
    ;

stmt_list
    : stmt_list stmt
    {
        $$ = linkSibling($1, $2);
    }
    | /* empty */
    {
        $$ = NULL;
    }
    ;

stmt
    : expr SEMI
    {
        stmt_count++;

        $$ = $1;
    }

    | compound_stmt
    {
        stmt_count++;

        $$ = $1;
    }

    | IF LP expr RP stmt
    {
        stmt_count++;

        Node* n = createNode("<if : condition-body>");

        addChild(n, $3);
        addChild(n, $5);

        $$ = n;
    }

    | IF LP expr RP stmt ELSE stmt
    {
        stmt_count++;

        Node* n = createNode("<if-else : condition-body1-body2>");

        addChild(n, $3);
        addChild(n, $5);
        addChild(n, $7);

        $$ = n;
    }

    | WHILE LP expr RP stmt
    {
        stmt_count++;

        Node* n = createNode("<while : condition-body>");

        addChild(n, $3);
        addChild(n, $5);

        $$ = n;
    }

    | RETURN expr SEMI
    {
        stmt_count++;

        Node* n = createNode("<return : expr>");

        addChild(n, $2);

        $$ = n;
    }

    | SEMI
    {
        stmt_count++;

        $$ = createNode(";");
    }
    ;

expr
    : assignment
    {
        $$ = $1;
    }
    ;

assignment
    : IDENT ASSIGN assignment
    {
        Node* n = createNode("=");

        char buf[64];

        sprintf(buf, "IDENT(%s)", $1);

        addChild(n, createNode(buf));
        addChild(n, $3);

        $$ = n;

        free($1);
    }

    | equality
    {
        $$ = $1;
    }
    ;

equality
    : relational
    {
        $$ = $1;
    }

    | equality RELOP relational
    {
        Node* n = createNode("==/!=");

        addChild(n, $1);
        addChild(n, $3);

        $$ = n;
    }
    ;

relational
    : additive
    {
        $$ = $1;
    }

    | relational RELOP additive
    {
        Node* n = createNode("<,>,<=,>=");

        addChild(n, $1);
        addChild(n, $3);

        $$ = n;
    }
    ;

additive
    : multiplicative
    {
        $$ = $1;
    }

    | additive ADDOP multiplicative
    {
        Node* n = createNode("+/-");

        addChild(n, $1);
        addChild(n, $3);

        $$ = n;
    }
    ;

multiplicative
    : primary
    {
        $$ = $1;
    }

    | multiplicative MULOP primary
    {
        Node* n = createNode("*/");

        addChild(n, $1);
        addChild(n, $3);

        $$ = n;
    }
    ;

primary
    : NUMBER
    {
        char buf[64];

        sprintf(buf, "NUMBER(%d)", $1);

        $$ = createNode(buf);
    }

    | IDENT
    {
        char buf[64];

        sprintf(buf, "IDENT(%s)", $1);

        $$ = createNode(buf);

        free($1);
    }

    | LP expr RP
    {
        $$ = $2;
    }
    ;

%%

int main() {
    yyparse();

    printf("=== AST ===\n");

    printAST(root, 0);

    printf("\n어휘 개수 : %d\n", lexeme_count);
    printf("식별자 개수 : %d\n", id_count);
    printf("문장 개수 : %d\n", stmt_count);

    return 0;
}