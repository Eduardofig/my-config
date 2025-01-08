#include <stdio.h>
#include <stdlib.h>

typedef struct node {
  struct node *next;
  int data;
} node;

typedef struct list {
  node *root;
  int sz;
} list;

node *new_node(int num) {
  node *n = malloc(sizeof(node));

  n->data = num;
  n->next = NULL;

  return n;
}

int main() {

}
