#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{ // Recuperamos el valor de salida con argint
  int status;
  if(argint(0,&status) < 0)
  {
    return -1;
  }
	status = status << 8;
  exit(status);
  return 0;  // not reached
}

int
sys_wait(void)
{ //Recuperamos la variable con argptr (int *)
  int *status;
  int size = 4;

  if(argptr(0,(void**) &status,size) < 0)
  {
    return -1;
  }
  return wait(status);
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;
	int oldsz = myproc()->sz;
	int newsz = oldsz;
  addr = myproc()->sz;//Devuelvo el tamaño inicial
  if(argint(0, &n) < 0)
    return -1;
	//cprintf("old=%d,n=%d\n",oldsz,n);
	if(n > 0)
	{
		newsz = oldsz + n;//si n es positivo, aumento el tamaño (Ya fallará en trap.c) 
	}
	else if(n < 0)
	{//Si n es negativo, hago dealloc y actualizo el size tambien
		//Soy perezoso para reservar memoria, pero no para liberarla
    if((newsz = deallocuvm(myproc()->pgdir, oldsz, oldsz + n)) == 0)
      return -1;
  }
	myproc()->sz= newsz; //actualizamos el sz del proceso
	cprintf("->old=%d,new=%d,myproc()->sz=%d\n",oldsz,newsz,myproc()->sz);

 // if(growproc(n) < 0)//El tamaño nuevo se pone en esta función
 //   return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

int
sys_date(void)
{
 //Date tiene que recuperar el dato de la pila del usuario
 struct rtcdate *d;//Esto es lo que me pasa el usuario
 //vamos a usar argint para recuperar el argumento
 if(argptr(0, (void **) &d, sizeof(struct rtcdate)) < 0){//Le pasamos el rtcdate para que se rellene
  return -1;
 }
 //Ahora una vez recuperado el arg -> Implementamos la syscall
 cmostime(d);//Esta función hace las veces de date
 return 0;

}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
