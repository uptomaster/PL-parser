#ifndef NODE_H
#define NODE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct node {
    char name[64];
    struct node* child;
    struct node* sibling;
} Node;

Node* createNode(const char* name) {
    Node* n = (Node*)malloc(sizeof(Node));
    strcpy(n->name, name);
    n->child = NULL;
    n->sibling = NULL;
    return n;
}

void addChild(Node* parent, Node* child) {
    if (!child) return;
    if (!parent->child) parent->child = child;
    else {
        Node* temp = parent->child;
        while (temp->sibling) temp = temp->sibling;
        temp->sibling = child;
    }
}

Node* linkSibling(Node* a, Node* b) {
    if (!a) return b;
    Node* t = a;
    while (t->sibling) t = t->sibling;
    t->sibling = b;
    return a;
}

void printAST(Node* root, int depth) {
    if (!root) return;
    for (int i = 0; i < depth; i++) printf("  ");
    printf("%d %s\n", depth, root->name);
    printAST(root->child, depth + 1);
    printAST(root->sibling, depth);
}

#endif