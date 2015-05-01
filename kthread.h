#define MAX_STACK_SIZE 4000
#define MAX_MUTEXES 64


enum states { UNUSED, EMBRYO, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };




struct thread {


  char *kstack;                // Bottom of kernel stack for this thread
  enum states state;        // Process state
  int pid;                     // Process ID
  struct proc *threadsProc;     // Parent process
  struct trapframe *tf;        // Trap frame for current syscall
  struct contextf*context;     // swtch() here to run process
  void *chan;                  // If non-zero, sleeping on chan


};




/********************************
        The API of the KLT package
 ********************************/

int kthread_create(void*(*start_func)(), void* stack, uint stack_size);
int kthread_id();
void kthread_exit();
int kthread_join(int thread_id);

int kthread_mutex_alloc();
int kthread_mutex_dealloc(int mutex_id);
int kthread_mutex_lock(int mutex_id);
int kthread_mutex_unlock(int mutex_id);
int kthread_mutex_yieldlock(int mutex_id1, int mutex_id2);
