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

static Node* createNode(const char* name) {
    Node* n = (Node*)malloc(sizeof(Node));

    strcpy(n->name, name);

    n->child = NULL;
    n->sibling = NULL;

    return n;
}

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

static Node* linkSibling(Node* a, Node* b) {
    if (!a) return b;

    Node* temp = a;

    while (temp->sibling)
        temp = temp->sibling;

    temp->sibling = b;

    return a;
}

static void printAST(Node* root, int depth) {
    if (!root) return;

    for (int i = 0; i < depth; i++)
        printf("  ");

    printf("%d %s\n", depth, root->name);

    printAST(root->child, depth + 1);
    printAST(root->sibling, depth);
}

#endif