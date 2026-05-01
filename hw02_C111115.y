%{
#include <stdio.h>
#include "hw02_C111115_node.h"

extern int lexeme_count;
extern int id_count;
int stmt_count = 0;

Node* root;

void yyerror(const char *s) {
    printf("Error: %s\n", s);
}
%}

%union {
    int num;
    char* str;
    Node* node;
}

%token INT IF ELSE WHILE RETURN
%token IDENT NUMBER
%token OP SEMI COMMA LP RP LB RB

%type <node> program function compound_stmt stmt expr

%%

program:
    function { root = $1; }
;

function:
    INT IDENT LP RP compound_stmt {
        $$ = createNode("<int main()>");
        addChild($$, $5);
    }
;

compound_stmt:
    LB stmt RB {
        $$ = createNode("block{}");
        addChild($$, $2);
    }
;

stmt:
      expr SEMI {
          stmt_count++;
          $$ = $1;
      }
    | compound_stmt {
          stmt_count++;
          $$ = $1;
      }
    | SEMI {
          stmt_count++;
          $$ = createNode(";");
      }
;

expr:
    IDENT OP expr {
        Node* n = createNode("=");
        Node* id = createNode($1);
        addChild(n, id);
        addChild(n, $3);
        $$ = n;
    }
    | NUMBER {
        char buf[50];
        sprintf(buf, "NUMBER(%d)", $1);
        $$ = createNode(buf);
    }
    | IDENT {
        char buf[50];
        sprintf(buf, "IDENT(%s)", $1);
        $$ = createNode(buf);
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