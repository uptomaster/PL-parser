#ifndef NODE_H
#define NODE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
    AST 노드 구조체
    - name : 현재 노드 이름 저장
    - child : 첫 번째 자식 노드
    - sibling : 형제 노드 연결
*/
typedef struct node {
    char name[64];
    struct node* child;
    struct node* sibling;
} Node;

/*
    새로운 AST 노드 생성 함수
*/
static Node* createNode(const char* name) {
    Node* n = (Node*)malloc(sizeof(Node));

    strcpy(n->name, name);

    n->child = NULL;
    n->sibling = NULL;

    return n;
}

/*
    부모 노드에 자식 노드 연결
    child가 여러 개일 경우 sibling으로 이어붙임
*/
static void addChild(Node* parent, Node* child) {
    if (!child) return;

    if (!parent->child) {
        parent->child = child;
    }
    else {
        Node* temp = parent->child;

        while (temp->sibling)
            temp = temp->sibling;

        temp->sibling = child;
    }
}

/*
    형제 노드 연결 함수
    decl_list, stmt_list 등에 사용
*/
static Node* linkSibling(Node* a, Node* b) {
    if (!a) return b;

    Node* temp = a;

    while (temp->sibling)
        temp = temp->sibling;

#endif