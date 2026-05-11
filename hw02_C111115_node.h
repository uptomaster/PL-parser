#ifndef HW02_C111115_NODE_H
#define HW02_C111115_NODE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
    AST에서 사용하는 기본 노드 구조체이다.

    child는 현재 노드의 첫 번째 자식 노드를 가리키고,
    sibling은 같은 depth에 존재하는 형제 노드를 연결하는 역할을 한다.

    declaration list나 stmt list처럼 여러 노드가 이어지는 경우가 많아서
    별도의 리스트 구조를 만들지 않고 sibling 포인터만 이용해서 연결하도록 구현했다.
*/

typedef struct astNode {

    char label[64];

    struct astNode* child;
    struct astNode* sibling;

} Node;


/*
    새 AST 노드를 생성하는 함수이다.

    전달받은 문자열을 label에 저장하고,
    처음 생성되는 노드이므로 child와 sibling 포인터는 전부 NULL로 초기화한다.

    parser에서 AST를 구성할 때 필요한 노드를 계속 동적으로 생성하기 위해
    malloc을 이용해서 구현했다.
*/

static Node* makeNode(const char* text) {

    Node* newNode = (Node*)malloc(sizeof(Node));

    strcpy(newNode->label, text);

    newNode->child = NULL;
    newNode->sibling = NULL;

    return newNode;
}


/*
    부모 노드 아래에 자식 노드를 추가하는 함수이다.

    아직 자식 노드가 없는 경우에는 첫 번째 child로 바로 연결하고,
    이미 자식이 존재하는 경우에는 마지막 sibling까지 이동한 뒤
    가장 뒤에 이어붙이는 방식으로 처리했다.

    declaration이나 statement 순서가 유지되어야 하기 때문에
    입력된 순서 그대로 연결되도록 구현했다.
*/

static void pushChild(Node* parent, Node* childNode) {

    if (parent == NULL || childNode == NULL)
        return;

    if (parent->child == NULL) {

        parent->child = childNode;
    }
    else {

        Node* cur = parent->child;

        while (cur->sibling != NULL)
            cur = cur->sibling;

        cur->sibling = childNode;
    }
}


/*
    형제 노드를 이어붙이는 함수이다.

    같은 레벨에 존재하는 decl_list나 stmt_list 등을 연결할 때 사용한다.

    a가 NULL이면 바로 b를 반환하고,
    그렇지 않으면 마지막 sibling까지 이동한 뒤
    가장 마지막 위치에 b를 연결한다.

    결과적으로 linked list처럼 옆으로 이어지는 구조라고 보면 된다.
*/

static Node* appendSibling(Node* a, Node* b) {

    if (a == NULL)
        return b;

    Node* cur = a;

    while (cur->sibling != NULL)
        cur = cur->sibling;

    cur->sibling = b;

    return a;
}


/*
    preorder 방식으로 AST를 출력하는 함수이다.

    현재 노드를 먼저 출력한 뒤 child 방향으로 재귀적으로 내려가고,
    이후 sibling 방향으로 이동하면서 같은 레벨 노드들을 출력한다.

    과제 출력 형식에서 depth 숫자를 같이 출력해야 해서
    현재 깊이를 depth 변수로 함께 관리하도록 만들었다.

    들여쓰기도 depth만큼 공백을 출력해서
    트리 구조가 한눈에 보이도록 구현했다.
*/

static void preorderPrint(Node* root, int depth) {

    if (root == NULL)
        return;

    for (int i = 0; i < depth; i++)
        printf("  ");

    printf("%d %s\n", depth, root->label);

    preorderPrint(root->child, depth + 1);

    preorderPrint(root->sibling, depth);
}

#endif