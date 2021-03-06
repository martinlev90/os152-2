#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "kthread.h"


int nexttid=1;
extern void forkret(void);
extern void trapret(void);

void
wakeupThreads(void *chan)
{


  struct kthread *t;
  for(t= proc->threads; t < &proc->threads[NTHREAD]; t++){

		  if(t->state == SLEEPING && t->chan == chan){
			  t->state =  RUNNABLE;

			  }
   }


}


int
kthread_create(void*(*start_func)(), void* stack, uint stack_size){

	  struct kthread *t;
	  char *sp;

	  acquire(thread->ptableLock);
	  for(t = proc->threads;t<&proc->threads[NTHREAD];t++){
	    if(t->state == UNUSED){
	       goto found;
	    }
	  }
	  release(thread->ptableLock);
	  return -1;

	  found:
	       t->state=EMBRYO;
	       t->tid= nexttid++;
	       release(thread->ptableLock);
//	       if((t->kstack = kalloc()) == 0){
//	        t->state = UNUSED;
//	        return -1;
//	       }
	       sp = t->kstack + stack_size;//KSTACKSIZE;
	       sp -= sizeof *t->tf;

	       t->tf = (struct trapframe*)sp ;
	       sp -= 4;
	       *(uint*)sp = (uint)trapret;
	       sp -= sizeof *t->context;
	       t->context = (struct context*)sp;
	       memset(t->context, 0, sizeof *t->context);
	       //t->wait_time = 0;

	       t->context->eip = (uint)forkret;
	       *t->tf=*thread->tf;
	       t->tf->eip = (uint)start_func;
	       t->tf->esp = (uint)(stack+stack_size);
	       t->tf->eflags = FL_IF;
	       t->parent = proc;
	       t->state = RUNNABLE;
	       return t->tid;


}

int kthread_id(){

	return thread->tid;
}

void kthread_exit(){



	 int tid;
	 int found=-1;


	 acquire(thread->ptableLock);

	 thread->state= ZOMBIE;
	 for (tid=0; tid< NTHREAD; tid++){
	 	 if (!( proc->threads[tid].state== ZOMBIE || proc->threads[tid].state== UNUSED) ){
	 		 found=tid;
	 		 break;

	 	 }
	 }

	 if (found<0){ // this was the last thread process needs to exit
		 proc->state = ZOMBIE;
		 release(thread->ptableLock);
		 exit();
	 }

	 thread->state= ZOMBIE;
	 thread->kernelStack=0;
	 thread->parent=0;
	 thread->ptableLock=0;
	 thread->tf=0;
	 thread->tid=0;
	 wakeupThreads(thread);

	 sched();
	 panic("zombie exit");
}

int kthread_join(int thread_id){


	//printf( "thread id : %d ", thread_id);
	  int found, tid;
	  struct kthread *t;
	  struct kthread *threadFound;

	  acquire(thread->ptableLock);

	  for(;;){
	    // Scan through table looking for zombie children.
	    found = 0;

	    for(t = proc->threads; t < &proc->threads[NTHREAD]; t++){

	      if(t->tid != thread_id)
	        continue;
	      found = 1;
	      threadFound= t;

	      if(t->state == ZOMBIE){
	        // Found one.
	        tid = t->tid;
	        //t->state = ZOMBIE;
	        t->tid = -1;
	        t->parent = 0;
	        printf("ffdsfsd");
	        release(thread->ptableLock);
	        return tid;
	      }
	    }


	    if(!found || proc->killed){

	      release(thread->ptableLock);
	      return -1;
	    }

	    // Wait for thread to exit.

	    sleep(threadFound, thread->ptableLock);  //DOC: wait-sleep

	  }


	  return -1;
}
/*
int kthread_mutex_alloc();
int kthread_mutex_dealloc(int mutex_id);
int kthread_mutex_lock(int mutex_id);
int kthread_mutex_unlock(int mutex_id);
int kthread_mutex_yieldlock(int mutex_id1, int mutex_id2);
*/
