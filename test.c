/*
 * test.c
 *
 *  Created on: May 4, 2015
 *      Author: yonatan
 */
#include "types.h"
#include "user.h"

#define MAX_STACK_SIZE 4000

int i=0;

void* testfunc();

int main(){


	void * stack0 = malloc(MAX_STACK_SIZE);

	//int tid=
	kthread_create( testfunc, stack0, MAX_STACK_SIZE);
	//kthread_join(tid);
	//printf(1,"i: %d %d\n",i,tid);




	//for(;;);
	kthread_exit();
	return 0;
}


void* testfunc(){

	int k;
	for (k=0; k<10; k++){

	printf(1, "thread is alive %d\n", ++i);
	}



	kthread_exit();
	return 0;
}
