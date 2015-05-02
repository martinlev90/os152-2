#include "proc.h"

#include "defs.h"
#include "kthread.h"
#include "mmu.h"
#include "param.h"
#include "spinlock.h"
#include "types.h"
#include "x86.h"


struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

struct {
  struct spinlock lock;
  struct kthread* thread[NTHREAD];
} tTable;


static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);


void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
  initlock(&ptable.lock, "ttable");
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
  release(&ptable.lock);

  int i;

  initlock(p->threadTable.lock);
  for (i=0; i<NTHREAD; i++)
  {
	  p->threadTable.threads[i].state=UNUSED;
  }

  // create first thread
  struct kthread* firstThread=&p->threadTable.threads[0];
  // Allocate kernel stack.
  if((firstThread->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = firstThread->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *firstThread->tf;
  firstThread->tf = (struct trapframe*)sp;
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;
  sp -= sizeof *firstThread->context;

  firstThread->context = (struct context*)sp;
  memset(firstThread->context, 0, sizeof *firstThread->context);
  firstThread->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;

  struct kthread* firstThread=&p->threadTable.threads[0];

  memset(firstThread->tf, 0, sizeof(*firstThread->tf));
  firstThread->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  firstThread->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  firstThread->tf->es = firstThread->tf->ds;
  firstThread->tf->ss = firstThread->tf->ds;
  firstThread->tf->eflags = FL_IF;
  firstThread->tf->esp = PGSIZE;
  firstThread->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  acquire(ptable.lock);
  acquire(proc->threadTable.lock);
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  release(proc->threadTable.lock);
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;

  // Allocate process.


  if((np = allocproc()) == 0)
    return -1;

  struct kthread* firstThread=np->threadTable.threads[0];
  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(firstThread->kstack);
    firstThread->kstack = 0;
    np->state = UNUSED;
    return -1;
  }

  malloc(3);

  np->parent = proc;
  *firstThread->tf = *thread->tf;

  // Clear %eax so that fork returns 0 in the child.
  firstThread->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));
 
  pid = np->pid;

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
  np->state = RUNNABLE;
  release(&ptable.lock);
  
  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Check if all threads are zombies
int threadIsDead(struct ThreadTable threadTable){

	int i;

	acquire(tTable.lock);
	for (i=0 ; i<NTHREAD; i++){

		if (! ( threadTable.threads[i].state  == ZOMBIE ||
				threadTable.threads[i].state  == UNUSED)){

			release(tTable.lock);
			return 0;
		}


	}
	release(tTable.lock);

	return 1;
}

// Wait for a child process to exit and return its pid.// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if( threadIsDead(p->threadTable)){  // process is zombie if all threads are zombies
        // Found one.
        pid = p->pid;
        int i;
        for (i=0 ; i<NTHREAD; i++){
        	struct kthread* thread=&p->threadTable.threads[i];
        	if (!thread->kernelStack){
        		kfree(thread->kstack);
        		thread->kstack = 0;
        		break; 					//there can be only 1 in each process
        	}
        }
        freevm(p->pgdir);
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
  return -1;
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct kthread *t;
  struct proc *p;
  int i;

  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over thread table looking for process to run.
    acquire(&tTable.lock);

    for(p = ptable.proc ; t < &ptable.proc[NPROC]; p++){
    	proc = p;
    	initlock(p->threadTable.lock);
		for (i=0; i<NTHREAD; i++)
		{


		  if(t->state != RUNNABLE)
			continue;

		  // Switch to chosen process.  It is the process's job
		  // to release ptable.lock and then reacquire it
		  // before jumping back to us.

		  thread =t;
		  switchuvm(thread);
		  thread->state = RUNNING;
		  swtch(&cpu->scheduler, thread->context);
		  switchkvm();

		  // Process is done running for now.
		  // It should have changed its p->state before coming back.

		  thread =0;
		}
		release(p->threadTable.lock);
		proc = 0;
    }

    release(&tTable.lock);

  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
  swtch(&thread->context, cpu->scheduler);
  cpu->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  thread->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
    initlog();
  }
  
  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{

  panic ("sleep is not implemented");

  if(proc == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.

  //
  //proc->chan = chan;
  //proc->state = SLEEPING;

  sched();

  // Tidy up.
  //proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
 panic ("wakeup is not implemented");
//  struct proc *p;
//
//  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
//    if(p->state == SLEEPING && p->chan == chan)
//      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      int i;

      initlock(p->threadTable.lock);
      for (i=0; i<NTHREAD; i++)
      {
    	  p->threadTable.threads[i].killed=1;
    	  // Wake process from sleep if necessary.
    	      if(p->threadTable.threads[i].state == SLEEPING)
    	        p->threadTable.threads[i].state = RUNNABLE;
      }
      release(p->threadTable.lock);
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)thread->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
