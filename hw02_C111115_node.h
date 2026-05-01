#ifndef NODE_H
#define NODE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// AST 노드 구조
typedef struct node {
    char name[50];
    struct node* child;
    struct node* sibling;
} Node;

// 노드 생성
Node* createNode(char* name) {
    Node* newNode = (Node*)malloc(sizeof(Node));
    strcpy(newNode->name, name);
    newNode->child = NULL;
    newNode->sibling = NULL;
    return newNode;
}

// 자식 추가
void addChild(Node* parent, Node* child) {
    if (!parent->child) parent->child = child;
    else {
        Node* temp = parent->child;
        while (temp->sibling) temp = temp->sibling;
        temp->sibling = child;
    }
}

// preorder 출력
void printAST(Node* root, int depth) {
    if (!root) return;

    for (int i = 0; i < depth; i++) printf("  ");
    printf("%d %s\n", depth, root->name);

    printAST(root->child, depth + 1);
    printAST(root->sibling, depth);
}

#endif