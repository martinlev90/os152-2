#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "kthread.h"


void
wakeupThreads(void *chan)
{



  struct kthread *t;

  acquire( proc->lock);

  for(t= proc->threads; t < &proc->threads[NTHREAD]; t++){

		  if(t->state == SLEEPING && t->chan == chan){
			  t->state =  RUNNABLE;

			  }
   }

  release(proc->lock);


}


int
kthread_create(void*(*start_func)(), void* stack, uint stack_size){



	int i, index,found;
	struct kthread *t=0;
	char *sp;
	acquire(proc->lock);
	for (i=0; i<=NTHREAD; i++){
		if ( proc->threads[i].state==UNUSED){
			found=1;
			t= &proc->threads[i];
			index=i;
			break;
		}
	}

	if (!found){
		return -1;
	}

	t->state =EMBRYO;



	sp = t->kstack + stack_size;

	// Leave room for trap frame.
	sp -= sizeof *t->tf;
	t->tf = (struct trapframe*)sp;

	sp-=4;
	*(uint*)sp = (uint)kthread_exit;

	sp -= sizeof *t->context;
	t->context = (struct context*)sp;
	memset(t->context, 0, sizeof *t->context);
	t->context->eip = (uint)start_func;
	t->kstack= stack;
	t->kernelStack=0;
	t->tid = index;
	t->parent =proc;
	t->state =RUNNABLE;
	release(proc->lock);
	return t->tid;
}

int kthread_id(){

	return thread->tid;
}

void kthread_exit(){



	 int tid;
	 int found=-1;

	 if (! ( holding(thread->ptableLock) ))
			 acquire(thread->ptableLock);
	 acquire(proc->lock);

	 thread->state= ZOMBIE;

	 for (tid=0; tid< NTHREAD; tid++){
	 	 if (!( proc->threads[tid].state== ZOMBIE || proc->threads[tid].state== UNUSED)){
	 		 found=tid;
	 		 break;

	 	 }
	 }

	 release(proc->lock);

	 if (found<0){ // this was the last thread process needs to exit
		 release(thread->ptableLock);
		 exit();
	 }

	 wakeupThreads(thread);



	 sched();
	 panic("zombie exit");
}

int kthread_join(int thread_id){



	  int found, tid;
	  struct kthread *t;
	  struct kthread *threadFound;

	  acquire(proc->lock);

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
	        t->state = UNUSED;
	        t->tid = -1;
	        t->parent = 0;
	        release(proc->lock);
	        return tid;
	      }
	    }

	    // No point waiting if we don't have any children.
	    if(!found || proc->killed){
	      release(proc->lock);
	      return -1;
	    }

	    // Wait for children to exit.  (See wakeup1 call in proc_exit.)


	    sleep(threadFound, proc->lock);  //DOC: wait-sleep

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
