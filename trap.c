#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  int status = -1;

  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit(status);
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit(status);
    return;
  }

  status = tf->trapno+1;

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
    break;

  //PAGEBREAK: 13
	case T_PGFLT://Fallo de página
		//Comprobamos que no se pase del kerbase
		if(rcr2() >= KERNBASE)
		{
			cprintf("kernbase superado");
			myproc()->killed = 1;
			break;
		}
		//comprobar si está en la página de guardia
		
		//Comprobamos si es el kernel el que provoca el fallo de página
		if((tf->cs&3) == 0)
		{
			cprintf("Hola soy el kernel y tengo un fallo de página\n");
			myproc()->killed = 1;
			break;
		}
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x ->sz = %d\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2(),myproc()->sz);
		//Vamos a coger una página solo si se cumplen las condiciones anteriores
		char *mem = kalloc();//Cogemos la página física
		if(mem == 0)
		{
			cprintf("panic: kalloc didn't reserve page\n");
			myproc()->killed = 1;
			break;
		}
		memset(mem, 0, PGSIZE);//Pongo la página a 0 para entregarla
		for(int i=0; i<PGSIZE; i++)
		{
			if(mem[i]==1)
				cprintf("HAY UN 1\n");
			//cprintf("%d-%d\n",i,mem[i]);
		}

		//mapeo en la TP
		if(mappages(myproc()->pgdir, (char *)PGROUNDDOWN(rcr2()), PGSIZE, V2P(mem), PTE_W | PTE_U) < 0)
		{
      cprintf("allocuvm out of memory (2)\n");
      kfree(mem);
			myproc()->killed = 1;
			break;
		}
		cprintf("Pagina concedida\n");
		break;

  default://Aquí llegan las demás
		if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
																		
    // In user space, assume process misbehaved.
    cprintf("_pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
  }//fin switch

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
  {     
    exit(status);
  }

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit(status);
}
