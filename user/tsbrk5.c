#include "types.h"
#include "user.h"

int i = 1;

void test1()
{
  char* a = sbrk (0);

  printf (1, "Debe fallar ahora por acceso mayor sz:\n");
  *(a+1) = 1;  // Debe fallar
  printf (2, "Ha accedido a más del sz\n");
}

void test2()
{
  // Página de guarda:
  printf (1, "Si no fallo antes (mal), ahora tambien debe fallar por página de guarda:\n");
  char* a = (char*)((int)&i + 4095);
  printf (1, "0x%x\n", a);
  *a = 1;//Esta instrucción debe fallar
  printf(1,"Página de guarda accedida\n");
}

void test3()
{
  // Acceder al núcleo
  printf (1, "Si no fallo antes (mal), ahora tambien debe fallar por acceso al nucleo:\n");
  char* a = (char*)0x80000001;
  *(a+1) = 1;  // Debe fallar (si lo anterior no ha fallado)
  printf(1, "Ha accedido al kernel\n");
}


int
main(int argc, char *argv[])
{
  //printf (1, "Este programa primero intenta acceder mas alla de sz.\n");

  // Más allá de sz
  //test1();

  // Acceso Página Guarda
  //test2();

  // Acceso Núcleo
  test3();

  exit (0);
}
