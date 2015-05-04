/*
 * test.c
 *
 *  Created on: May 4, 2015
 *      Author: yonatan
 */
#include "types.h"
#include "user.h"


int main(){

	if( !fork()){
		printf (1,"fork1\n");
		exit();
	}
	printf (1,"father 1\n");
	if( !fork()){
			printf (1,"fork2\n");
			for(;;);
	}
	printf (1,"father 2\n");
	if( !fork()){
				printf (1,"fork3\n");
				for(;;);
		}
	printf (1,"father 3\n");
	if( !fork()){
				printf (1,"fork4\n");
				for(;;);
		}
	printf (1,"father 4\n");
	exit();
}
