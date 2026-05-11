%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hw02_C111115_node.h"

extern int lexeme_count;
extern int id_count;

/*
    stmt_count라는 변수는 말 그대로 지금까지 처리된 문장 개수를 세는 용도다.
    여기서 문장은 단순히 세미콜론으로 끝나는 것뿐 아니라 if, while, return 같은
    제어문까지 전부 포함해서 증가시키는 방식으로 잡아놨다.
*/
int stmt_count = 0;

/*
    ASTRoot는 전체 프로그램의 최상위 노드를 저장하는 변수다.
    파싱이 끝난 이후에는 이 루트를 기준으로 AST를 전부 순회하면서 출력하게 된다.
*/
Node* ASTRoot;

int yylex(void);

/*
    문법 에러가 발생했을 때 호출되는 함수인데,
    복잡하게 복구하거나 처리하지 않고 그냥 에러 메시지만 출력하도록 단순하게 구성했다.
*/
void yyerror(const char* s) {
    printf("parse error : %s\n", s);
}
%}

/* bison value type */
%union {
    int num;
    char* str;
    struct astNode* node;
}

/* reserved word */
%token INT MAIN IF ELSE WHILE RETURN

/* token type 지정 */
%token <str> IDENT
%token <num> NUMBER

%token <str> ADDOP
%token <str> MULOP
%token <str> RELOP
%token <str> ASSIGN

%token SEMI COMMA
%token LP RP
%token LB RB

/* nonterminal type */
%type <node> program function
%type <node> compound_stmt
%type <node> decl_list decl ident_list
%type <node> stmt_list stmt
%type <node> expr assignment
%type <node> equality relational
%type <node> additive multiplicative primary

%%

/*
    program은 전체 입력의 시작 규칙이고 결국 function 하나로 구성된다고 보면 된다.
    여기서는 function에서 만들어진 AST를 그대로 ASTRoot에 저장하는 역할만 한다.
*/
program
    : function
    {
        ASTRoot = $1;
    }
    ;

/*
    function은 int main() 형태의 전체 함수 구조를 의미한다.
    여기서는 function 노드를 만들고 그 안에 compound_stmt(블록)를 자식으로 붙이는 구조다.
*/
function
    : INT MAIN LP RP compound_stmt
    {
        $$ = makeNode("<int main()>");
        pushChild($$, $5);
    }
    ;

/*
    compound_stmt는 중괄호 블록 전체를 의미한다.
    내부에는 선언부(decl_list)랑 실행문(stmt_list)이 순서대로 들어가고
    이를 block{} 노드 아래에 붙여서 트리를 구성한다.
*/
compound_stmt
    : LB decl_list stmt_list RB
    {
        $$ = makeNode("block{}");
        pushChild($$, $2);
        pushChild($$, $3);
    }
    ;

/*
    decl_list는 선언문들이 여러 개 올 수 있기 때문에 sibling 구조로 계속 이어붙인다.
    아무것도 없으면 NULL로 처리해서 비어있는 상태도 허용한다.
*/
decl_list
    : decl_list decl
    {
        $$ = appendSibling($1, $2);
    }
    | /* empty */
    {
        $$ = NULL;
    }
    ;

/*
    decl은 int 선언 한 줄을 의미한다.
    예를 들어 int a, b, c; 같은 형태를 하나의 노드로 만들고
    내부 identifier들은 child로 붙이는 구조로 만든다.
*/
decl
    : INT ident_list SEMI
    {
        Node* declNode = makeNode("<int_decl>");
        pushChild(declNode, $2);
        $$ = declNode;
    }
    ;

/*
    ident_list는 a, b, c처럼 이어지는 변수 목록을 처리한다.
    콤마 기준으로 sibling으로 연결해서 리스트 형태로 만든다.
*/
ident_list
    : IDENT
    {
        char temp[64];
        sprintf(temp, "IDENT(%s)", $1);
        $$ = makeNode(temp);
        free($1);
    }
    | ident_list COMMA IDENT
    {
        char temp[64];
        sprintf(temp, "IDENT(%s)", $3);
        $$ = appendSibling($1, makeNode(temp));
        free($3);
    }
    ;

/*
    stmt_list는 실행문들이 여러 개 이어질 수 있어서 sibling으로 연결한다.
    순서 유지가 중요해서 들어온 순서 그대로 이어붙이는 구조다.
*/
stmt_list
    : stmt_list stmt
    {
        $$ = appendSibling($1, $2);
    }
    | /* empty */
    {
        $$ = NULL;
    }
    ;

/*
    stmt는 실제 실행문 하나를 의미한다.
    expression 뒤에 세미콜론이 오거나, if/while/return/block 같은 구조를 모두 포함한다.
    여기서 stmt_count도 같이 증가시켜 문장 개수를 세고 있다.
*/
stmt
    : expr SEMI
    {
        stmt_count++;
        $$ = $1;
    }
    | compound_stmt
    {
        $$ = $1;
    }
    | IF LP expr RP stmt
    {
        stmt_count++;
        Node* ifNode = makeNode("<if : condition-body>");
        pushChild(ifNode, $3);
        pushChild(ifNode, $5);
        $$ = ifNode;
    }
    | IF LP expr RP stmt ELSE stmt
    {
        stmt_count++;
        Node* ifElseNode = makeNode("<if-else : condition-body1-body2>");
        pushChild(ifElseNode, $3);
        pushChild(ifElseNode, $5);
        pushChild(ifElseNode, $7);
        $$ = ifElseNode;
    }
    | WHILE LP expr RP stmt
    {
        stmt_count++;
        Node* whileNode = makeNode("<while : condition-body>");
        pushChild(whileNode, $3);
        pushChild(whileNode, $5);
        $$ = whileNode;
    }
    | RETURN expr SEMI
    {
        stmt_count++;
        Node* returnNode = makeNode("<return : expr>");
        pushChild(returnNode, $2);
        $$ = returnNode;
    }
    | SEMI
    {
        stmt_count++;
        $$ = NULL;
    }
    ;

/*
    expr는 assignment부터 시작해서 전체 expression 구조의 시작점이다.
*/
expr
    : assignment
    {
        $$ = $1;
    }
    ;

/*
    assignment는 = 연산을 처리한다.
    오른쪽 결합 구조라서 a = b = c 같은 것도 처리 가능하게 만든 구조다.
*/
assignment
    : IDENT ASSIGN assignment
    {
        Node* assignNode = makeNode($2);

        char temp[64];
        sprintf(temp, "IDENT(%s)", $1);

        pushChild(assignNode, makeNode(temp));
        pushChild(assignNode, $3);

        $$ = assignNode;

        free($1);
        free($2);
    }
    | equality
    {
        $$ = $1;
    }
    ;

/*
    equality는 ==, != 같은 비교 연산을 처리하는 단계다.
*/
equality
    : relational
    {
        $$ = $1;
    }
    | equality RELOP relational
    {
        Node* opNode = makeNode($2);
        pushChild(opNode, $1);
        pushChild(opNode, $3);
        $$ = opNode;
        free($2);
    }
    ;

/*
    relational은 <, >, <=, >= 같은 비교 연산 처리다.
*/
relational
    : additive
    {
        $$ = $1;
    }
    | relational RELOP additive
    {
        Node* opNode = makeNode($2);
        pushChild(opNode, $1);
        pushChild(opNode, $3);
        $$ = opNode;
        free($2);
    }
    ;

/*
    additive는 +, - 연산 처리 단계다.
*/
additive
    : multiplicative
    {
        $$ = $1;
    }
    | additive ADDOP multiplicative
    {
        Node* opNode = makeNode($2);
        pushChild(opNode, $1);
        pushChild(opNode, $3);
        $$ = opNode;
        free($2);
    }
    ;

/*
    multiplicative는 *, / 연산 처리 단계다.
*/
multiplicative
    : primary
    {
        $$ = $1;
    }
    | multiplicative MULOP primary
    {
        Node* opNode = makeNode($2);
        pushChild(opNode, $1);
        pushChild(opNode, $3);
        $$ = opNode;
        free($2);
    }
    ;

/*
    primary는 가장 기본 단위다.
    숫자, 변수, 또는 (expr) 같은 구조를 처리한다.
*/
primary
    : NUMBER
    {
        char temp[64];
        sprintf(temp, "NUMBER(%d)", $1);
        $$ = makeNode(temp);
    }
    | IDENT
    {
        char temp[64];
        sprintf(temp, "IDENT(%s)", $1);
        $$ = makeNode(temp);
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
    preorderPrint(ASTRoot, 0);

    printf("\n");

    printf("어휘 개수 : %d\n", lexeme_count);
    printf("식별자 개수 : %d\n", id_count);
    printf("문장 개수 : %d\n", stmt_count);

    return 0;
}