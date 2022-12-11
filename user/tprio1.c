#include "types.h"
#include "user.h"

int
main(int argc, char *argv[])
{

  // El padre sale, el hijo establece la máxima prioridad
  if (fork() != 0)
    exit(1);
  
  // Establecer máxima prioridad. Debe hacer que el shell ni aparezca hasta
  // que termine
  setprio (getpid(), HI_PRIO);

  int r = 0;
  
  for (int i = 0; i < 2000; ++i)
    for (int j = 0; j < 1000000; ++j)
      r += i + j;

  // Imprime el resultado
  printf (1, "Resultado: %d\n", r);
  
  exit(0);
/*
	printf(1,"Hola, soy tprio1, ");
	printf(1, "mi prioridad es: %d\n",getprio(getpid()));
	printf(1,"--cambio de prioridad-->%d_",HI_PRIO);
	int ret = setprio(getpid(),HI_PRIO);
	printf(1,"mi nueva prioridad es: %d\n",getprio(getpid()));
	
	exit(ret);
*/
}
