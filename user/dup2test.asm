
dup2test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fcntl.h"

int
main(int argc, char* argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
  int fd;

  // Ejemplo de dup2 con un fd incorrecto
  if (dup2 (-1,8) >= 0)
   f:	83 ec 08             	sub    $0x8,%esp
  12:	6a 08                	push   $0x8
  14:	6a ff                	push   $0xffffffff
  16:	e8 f9 03 00 00       	call   414 <dup2>
  1b:	83 c4 10             	add    $0x10,%esp
  1e:	85 c0                	test   %eax,%eax
  20:	0f 89 fc 01 00 00    	jns    222 <main+0x222>
    printf (2, "dup2 no funciona con fd incorrecto.\n");

  // Ejemplo de dup2 con un newfd incorrecto
  if (dup2 (1,-1) >= 0)
  26:	83 ec 08             	sub    $0x8,%esp
  29:	6a ff                	push   $0xffffffff
  2b:	6a 01                	push   $0x1
  2d:	e8 e2 03 00 00       	call   414 <dup2>
  32:	83 c4 10             	add    $0x10,%esp
  35:	85 c0                	test   %eax,%eax
  37:	0f 89 fc 01 00 00    	jns    239 <main+0x239>
    printf (2, "dup2 no funciona con fd incorrecto (2).\n");

  // Ejemplo de dup2 con un fd no mapeado
  if (dup2 (6,8) >= 0)
  3d:	83 ec 08             	sub    $0x8,%esp
  40:	6a 08                	push   $0x8
  42:	6a 06                	push   $0x6
  44:	e8 cb 03 00 00       	call   414 <dup2>
  49:	83 c4 10             	add    $0x10,%esp
  4c:	85 c0                	test   %eax,%eax
  4e:	0f 89 fc 01 00 00    	jns    250 <main+0x250>
    printf (2, "dup2 no funciona con fd no mapeado.\n");

  // Ejemplo de dup2 con un fd no mapeado (2)
  if (dup2 (8,1) >= 0)
  54:	83 ec 08             	sub    $0x8,%esp
  57:	6a 01                	push   $0x1
  59:	6a 08                	push   $0x8
  5b:	e8 b4 03 00 00       	call   414 <dup2>
  60:	83 c4 10             	add    $0x10,%esp
  63:	85 c0                	test   %eax,%eax
  65:	0f 89 fc 01 00 00    	jns    267 <main+0x267>
    printf (2, "dup2 no funciona con fd no mapeado (2).\n");

  if (dup2 (1,25) >= 0)
  6b:	83 ec 08             	sub    $0x8,%esp
  6e:	6a 19                	push   $0x19
  70:	6a 01                	push   $0x1
  72:	e8 9d 03 00 00       	call   414 <dup2>
  77:	83 c4 10             	add    $0x10,%esp
  7a:	85 c0                	test   %eax,%eax
  7c:	0f 89 fc 01 00 00    	jns    27e <main+0x27e>
    printf (2, "dup2 no funciona con fd superior a NOFILE.\n");

  // Ejemplo de dup2 con fd existente
  printf(1, "Empiezan las pruebas de NO error\n");
  82:	83 ec 08             	sub    $0x8,%esp
  85:	68 e4 06 00 00       	push   $0x6e4
  8a:	6a 01                	push   $0x1
  8c:	e8 1e 04 00 00       	call   4af <printf>
  if (dup2 (1,4) != 4)
  91:	83 c4 08             	add    $0x8,%esp
  94:	6a 04                	push   $0x4
  96:	6a 01                	push   $0x1
  98:	e8 77 03 00 00       	call   414 <dup2>
  9d:	83 c4 10             	add    $0x10,%esp
  a0:	83 f8 04             	cmp    $0x4,%eax
  a3:	0f 85 ec 01 00 00    	jne    295 <main+0x295>
    printf (2, "dup2 no funciona con fd existente.\n");

  printf (4, "Este mensaje debe salir por terminal.\n");
  a9:	83 ec 08             	sub    $0x8,%esp
  ac:	68 2c 07 00 00       	push   $0x72c
  b1:	6a 04                	push   $0x4
  b3:	e8 f7 03 00 00       	call   4af <printf>

  if (dup2 (4,6) != 6)
  b8:	83 c4 08             	add    $0x8,%esp
  bb:	6a 06                	push   $0x6
  bd:	6a 04                	push   $0x4
  bf:	e8 50 03 00 00       	call   414 <dup2>
  c4:	83 c4 10             	add    $0x10,%esp
  c7:	83 f8 06             	cmp    $0x6,%eax
  ca:	0f 85 dc 01 00 00    	jne    2ac <main+0x2ac>
    printf (2, "dup2 no funciona con fd existente (2).\n");

  printf (6, "Este mensaje debe salir por terminal (2).\n");
  d0:	83 ec 08             	sub    $0x8,%esp
  d3:	68 7c 07 00 00       	push   $0x77c
  d8:	6a 06                	push   $0x6
  da:	e8 d0 03 00 00       	call   4af <printf>

  if (close (4) != 0)
  df:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  e6:	e8 a9 02 00 00       	call   394 <close>
  eb:	83 c4 10             	add    $0x10,%esp
  ee:	85 c0                	test   %eax,%eax
  f0:	0f 85 cd 01 00 00    	jne    2c3 <main+0x2c3>
    printf (2, "Error en close (4)\n");
  printf (6, "Este mensaje debe salir por terminal (3).\n");
  f6:	83 ec 08             	sub    $0x8,%esp
  f9:	68 a8 07 00 00       	push   $0x7a8
  fe:	6a 06                	push   $0x6
 100:	e8 aa 03 00 00       	call   4af <printf>
  if (close (6) != 0)
 105:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
 10c:	e8 83 02 00 00       	call   394 <close>
 111:	83 c4 10             	add    $0x10,%esp
 114:	85 c0                	test   %eax,%eax
 116:	0f 85 be 01 00 00    	jne    2da <main+0x2da>
    printf (2, "Error en close (6)\n");
  if (close (6) == 0)
 11c:	83 ec 0c             	sub    $0xc,%esp
 11f:	6a 06                	push   $0x6
 121:	e8 6e 02 00 00       	call   394 <close>
 126:	83 c4 10             	add    $0x10,%esp
 129:	85 c0                	test   %eax,%eax
 12b:	0f 84 c0 01 00 00    	je     2f1 <main+0x2f1>
    printf (2, "Error en close (6) (2)\n");

  fd = open ("fichero_salida.txt", O_CREATE|O_RDWR);
 131:	83 ec 08             	sub    $0x8,%esp
 134:	68 02 02 00 00       	push   $0x202
 139:	68 88 08 00 00       	push   $0x888
 13e:	e8 69 02 00 00       	call   3ac <open>
 143:	89 c3                	mov    %eax,%ebx
  printf (fd, "Salida a fichero\n");
 145:	83 c4 08             	add    $0x8,%esp
 148:	68 9b 08 00 00       	push   $0x89b
 14d:	50                   	push   %eax
 14e:	e8 5c 03 00 00       	call   4af <printf>

  if (dup2 (fd, 9) != 9)
 153:	83 c4 08             	add    $0x8,%esp
 156:	6a 09                	push   $0x9
 158:	53                   	push   %ebx
 159:	e8 b6 02 00 00       	call   414 <dup2>
 15e:	83 c4 10             	add    $0x10,%esp
 161:	83 f8 09             	cmp    $0x9,%eax
 164:	0f 85 9e 01 00 00    	jne    308 <main+0x308>
    printf (2, "dup2 no funciona con fd existente (3).\n");

  printf (9, "Salida también a fichero.\n");
 16a:	83 ec 08             	sub    $0x8,%esp
 16d:	68 ad 08 00 00       	push   $0x8ad
 172:	6a 09                	push   $0x9
 174:	e8 36 03 00 00       	call   4af <printf>

  if (dup2 (9, 9) != 9)
 179:	83 c4 08             	add    $0x8,%esp
 17c:	6a 09                	push   $0x9
 17e:	6a 09                	push   $0x9
 180:	e8 8f 02 00 00       	call   414 <dup2>
 185:	83 c4 10             	add    $0x10,%esp
 188:	83 f8 09             	cmp    $0x9,%eax
 18b:	0f 85 8e 01 00 00    	jne    31f <main+0x31f>
    printf (2, "dup2 no funciona con newfd=oldfd.\n");

  printf (9, "Salida también a fichero.\n");
 191:	83 ec 08             	sub    $0x8,%esp
 194:	68 ad 08 00 00       	push   $0x8ad
 199:	6a 09                	push   $0x9
 19b:	e8 0f 03 00 00       	call   4af <printf>

  close (9);
 1a0:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
 1a7:	e8 e8 01 00 00       	call   394 <close>

  dup2 (1, 6);
 1ac:	83 c4 08             	add    $0x8,%esp
 1af:	6a 06                	push   $0x6
 1b1:	6a 01                	push   $0x1
 1b3:	e8 5c 02 00 00       	call   414 <dup2>

  if (dup2 (fd, 1) != 1)
 1b8:	83 c4 08             	add    $0x8,%esp
 1bb:	6a 01                	push   $0x1
 1bd:	53                   	push   %ebx
 1be:	e8 51 02 00 00       	call   414 <dup2>
 1c3:	83 c4 10             	add    $0x10,%esp
 1c6:	83 f8 01             	cmp    $0x1,%eax
 1c9:	0f 85 67 01 00 00    	jne    336 <main+0x336>
    printf (2, "dup2 no funciona con fd existente (4).\n");

  printf (1, "Cuarta salida a fichero.\n");
 1cf:	83 ec 08             	sub    $0x8,%esp
 1d2:	68 c9 08 00 00       	push   $0x8c9
 1d7:	6a 01                	push   $0x1
 1d9:	e8 d1 02 00 00       	call   4af <printf>
  if (close (1) != 0)
 1de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1e5:	e8 aa 01 00 00       	call   394 <close>
 1ea:	83 c4 10             	add    $0x10,%esp
 1ed:	85 c0                	test   %eax,%eax
 1ef:	0f 85 58 01 00 00    	jne    34d <main+0x34d>
    printf (2, "Error en close (1).\n");

  dup2 (6,fd);
 1f5:	83 ec 08             	sub    $0x8,%esp
 1f8:	53                   	push   %ebx
 1f9:	6a 06                	push   $0x6
 1fb:	e8 14 02 00 00       	call   414 <dup2>

  printf (fd, "Este mensaje debe salir por terminal.\n");
 200:	83 c4 08             	add    $0x8,%esp
 203:	68 2c 07 00 00       	push   $0x72c
 208:	53                   	push   %ebx
 209:	e8 a1 02 00 00       	call   4af <printf>
  close (fd);
 20e:	89 1c 24             	mov    %ebx,(%esp)
 211:	e8 7e 01 00 00       	call   394 <close>

  exit(0);
 216:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 21d:	e8 4a 01 00 00       	call   36c <exit>
    printf (2, "dup2 no funciona con fd incorrecto.\n");
 222:	83 ec 08             	sub    $0x8,%esp
 225:	68 10 06 00 00       	push   $0x610
 22a:	6a 02                	push   $0x2
 22c:	e8 7e 02 00 00       	call   4af <printf>
 231:	83 c4 10             	add    $0x10,%esp
 234:	e9 ed fd ff ff       	jmp    26 <main+0x26>
    printf (2, "dup2 no funciona con fd incorrecto (2).\n");
 239:	83 ec 08             	sub    $0x8,%esp
 23c:	68 38 06 00 00       	push   $0x638
 241:	6a 02                	push   $0x2
 243:	e8 67 02 00 00       	call   4af <printf>
 248:	83 c4 10             	add    $0x10,%esp
 24b:	e9 ed fd ff ff       	jmp    3d <main+0x3d>
    printf (2, "dup2 no funciona con fd no mapeado.\n");
 250:	83 ec 08             	sub    $0x8,%esp
 253:	68 64 06 00 00       	push   $0x664
 258:	6a 02                	push   $0x2
 25a:	e8 50 02 00 00       	call   4af <printf>
 25f:	83 c4 10             	add    $0x10,%esp
 262:	e9 ed fd ff ff       	jmp    54 <main+0x54>
    printf (2, "dup2 no funciona con fd no mapeado (2).\n");
 267:	83 ec 08             	sub    $0x8,%esp
 26a:	68 8c 06 00 00       	push   $0x68c
 26f:	6a 02                	push   $0x2
 271:	e8 39 02 00 00       	call   4af <printf>
 276:	83 c4 10             	add    $0x10,%esp
 279:	e9 ed fd ff ff       	jmp    6b <main+0x6b>
    printf (2, "dup2 no funciona con fd superior a NOFILE.\n");
 27e:	83 ec 08             	sub    $0x8,%esp
 281:	68 b8 06 00 00       	push   $0x6b8
 286:	6a 02                	push   $0x2
 288:	e8 22 02 00 00       	call   4af <printf>
 28d:	83 c4 10             	add    $0x10,%esp
 290:	e9 ed fd ff ff       	jmp    82 <main+0x82>
    printf (2, "dup2 no funciona con fd existente.\n");
 295:	83 ec 08             	sub    $0x8,%esp
 298:	68 08 07 00 00       	push   $0x708
 29d:	6a 02                	push   $0x2
 29f:	e8 0b 02 00 00       	call   4af <printf>
 2a4:	83 c4 10             	add    $0x10,%esp
 2a7:	e9 fd fd ff ff       	jmp    a9 <main+0xa9>
    printf (2, "dup2 no funciona con fd existente (2).\n");
 2ac:	83 ec 08             	sub    $0x8,%esp
 2af:	68 54 07 00 00       	push   $0x754
 2b4:	6a 02                	push   $0x2
 2b6:	e8 f4 01 00 00       	call   4af <printf>
 2bb:	83 c4 10             	add    $0x10,%esp
 2be:	e9 0d fe ff ff       	jmp    d0 <main+0xd0>
    printf (2, "Error en close (4)\n");
 2c3:	83 ec 08             	sub    $0x8,%esp
 2c6:	68 48 08 00 00       	push   $0x848
 2cb:	6a 02                	push   $0x2
 2cd:	e8 dd 01 00 00       	call   4af <printf>
 2d2:	83 c4 10             	add    $0x10,%esp
 2d5:	e9 1c fe ff ff       	jmp    f6 <main+0xf6>
    printf (2, "Error en close (6)\n");
 2da:	83 ec 08             	sub    $0x8,%esp
 2dd:	68 5c 08 00 00       	push   $0x85c
 2e2:	6a 02                	push   $0x2
 2e4:	e8 c6 01 00 00       	call   4af <printf>
 2e9:	83 c4 10             	add    $0x10,%esp
 2ec:	e9 2b fe ff ff       	jmp    11c <main+0x11c>
    printf (2, "Error en close (6) (2)\n");
 2f1:	83 ec 08             	sub    $0x8,%esp
 2f4:	68 70 08 00 00       	push   $0x870
 2f9:	6a 02                	push   $0x2
 2fb:	e8 af 01 00 00       	call   4af <printf>
 300:	83 c4 10             	add    $0x10,%esp
 303:	e9 29 fe ff ff       	jmp    131 <main+0x131>
    printf (2, "dup2 no funciona con fd existente (3).\n");
 308:	83 ec 08             	sub    $0x8,%esp
 30b:	68 d4 07 00 00       	push   $0x7d4
 310:	6a 02                	push   $0x2
 312:	e8 98 01 00 00       	call   4af <printf>
 317:	83 c4 10             	add    $0x10,%esp
 31a:	e9 4b fe ff ff       	jmp    16a <main+0x16a>
    printf (2, "dup2 no funciona con newfd=oldfd.\n");
 31f:	83 ec 08             	sub    $0x8,%esp
 322:	68 fc 07 00 00       	push   $0x7fc
 327:	6a 02                	push   $0x2
 329:	e8 81 01 00 00       	call   4af <printf>
 32e:	83 c4 10             	add    $0x10,%esp
 331:	e9 5b fe ff ff       	jmp    191 <main+0x191>
    printf (2, "dup2 no funciona con fd existente (4).\n");
 336:	83 ec 08             	sub    $0x8,%esp
 339:	68 20 08 00 00       	push   $0x820
 33e:	6a 02                	push   $0x2
 340:	e8 6a 01 00 00       	call   4af <printf>
 345:	83 c4 10             	add    $0x10,%esp
 348:	e9 82 fe ff ff       	jmp    1cf <main+0x1cf>
    printf (2, "Error en close (1).\n");
 34d:	83 ec 08             	sub    $0x8,%esp
 350:	68 e3 08 00 00       	push   $0x8e3
 355:	6a 02                	push   $0x2
 357:	e8 53 01 00 00       	call   4af <printf>
 35c:	83 c4 10             	add    $0x10,%esp
 35f:	e9 91 fe ff ff       	jmp    1f5 <main+0x1f5>

00000364 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 364:	b8 01 00 00 00       	mov    $0x1,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <exit>:
SYSCALL(exit)
 36c:	b8 02 00 00 00       	mov    $0x2,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <wait>:
SYSCALL(wait)
 374:	b8 03 00 00 00       	mov    $0x3,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <pipe>:
SYSCALL(pipe)
 37c:	b8 04 00 00 00       	mov    $0x4,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <read>:
SYSCALL(read)
 384:	b8 05 00 00 00       	mov    $0x5,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <write>:
SYSCALL(write)
 38c:	b8 10 00 00 00       	mov    $0x10,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <close>:
SYSCALL(close)
 394:	b8 15 00 00 00       	mov    $0x15,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <kill>:
SYSCALL(kill)
 39c:	b8 06 00 00 00       	mov    $0x6,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <exec>:
SYSCALL(exec)
 3a4:	b8 07 00 00 00       	mov    $0x7,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <open>:
SYSCALL(open)
 3ac:	b8 0f 00 00 00       	mov    $0xf,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <mknod>:
SYSCALL(mknod)
 3b4:	b8 11 00 00 00       	mov    $0x11,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <unlink>:
SYSCALL(unlink)
 3bc:	b8 12 00 00 00       	mov    $0x12,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <fstat>:
SYSCALL(fstat)
 3c4:	b8 08 00 00 00       	mov    $0x8,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <link>:
SYSCALL(link)
 3cc:	b8 13 00 00 00       	mov    $0x13,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <mkdir>:
SYSCALL(mkdir)
 3d4:	b8 14 00 00 00       	mov    $0x14,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <chdir>:
SYSCALL(chdir)
 3dc:	b8 09 00 00 00       	mov    $0x9,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <dup>:
SYSCALL(dup)
 3e4:	b8 0a 00 00 00       	mov    $0xa,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <getpid>:
SYSCALL(getpid)
 3ec:	b8 0b 00 00 00       	mov    $0xb,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <sbrk>:
SYSCALL(sbrk)
 3f4:	b8 0c 00 00 00       	mov    $0xc,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <sleep>:
SYSCALL(sleep)
 3fc:	b8 0d 00 00 00       	mov    $0xd,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <uptime>:
SYSCALL(uptime)
 404:	b8 0e 00 00 00       	mov    $0xe,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <date>:
SYSCALL(date)
 40c:	b8 16 00 00 00       	mov    $0x16,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <dup2>:
SYSCALL(dup2)
 414:	b8 17 00 00 00       	mov    $0x17,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 41c:	55                   	push   %ebp
 41d:	89 e5                	mov    %esp,%ebp
 41f:	83 ec 1c             	sub    $0x1c,%esp
 422:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 425:	6a 01                	push   $0x1
 427:	8d 55 f4             	lea    -0xc(%ebp),%edx
 42a:	52                   	push   %edx
 42b:	50                   	push   %eax
 42c:	e8 5b ff ff ff       	call   38c <write>
}
 431:	83 c4 10             	add    $0x10,%esp
 434:	c9                   	leave  
 435:	c3                   	ret    

00000436 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 436:	55                   	push   %ebp
 437:	89 e5                	mov    %esp,%ebp
 439:	57                   	push   %edi
 43a:	56                   	push   %esi
 43b:	53                   	push   %ebx
 43c:	83 ec 2c             	sub    $0x2c,%esp
 43f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 442:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 444:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 448:	74 04                	je     44e <printint+0x18>
 44a:	85 d2                	test   %edx,%edx
 44c:	78 3c                	js     48a <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 44e:	89 d1                	mov    %edx,%ecx
  neg = 0;
 450:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 457:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 45c:	89 c8                	mov    %ecx,%eax
 45e:	ba 00 00 00 00       	mov    $0x0,%edx
 463:	f7 f6                	div    %esi
 465:	89 df                	mov    %ebx,%edi
 467:	43                   	inc    %ebx
 468:	8a 92 58 09 00 00    	mov    0x958(%edx),%dl
 46e:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 472:	89 ca                	mov    %ecx,%edx
 474:	89 c1                	mov    %eax,%ecx
 476:	39 d6                	cmp    %edx,%esi
 478:	76 e2                	jbe    45c <printint+0x26>
  if(neg)
 47a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 47e:	74 24                	je     4a4 <printint+0x6e>
    buf[i++] = '-';
 480:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 485:	8d 5f 02             	lea    0x2(%edi),%ebx
 488:	eb 1a                	jmp    4a4 <printint+0x6e>
    x = -xx;
 48a:	89 d1                	mov    %edx,%ecx
 48c:	f7 d9                	neg    %ecx
    neg = 1;
 48e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 495:	eb c0                	jmp    457 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 497:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 49c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 49f:	e8 78 ff ff ff       	call   41c <putc>
  while(--i >= 0)
 4a4:	4b                   	dec    %ebx
 4a5:	79 f0                	jns    497 <printint+0x61>
}
 4a7:	83 c4 2c             	add    $0x2c,%esp
 4aa:	5b                   	pop    %ebx
 4ab:	5e                   	pop    %esi
 4ac:	5f                   	pop    %edi
 4ad:	5d                   	pop    %ebp
 4ae:	c3                   	ret    

000004af <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 4af:	55                   	push   %ebp
 4b0:	89 e5                	mov    %esp,%ebp
 4b2:	57                   	push   %edi
 4b3:	56                   	push   %esi
 4b4:	53                   	push   %ebx
 4b5:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 4b8:	8d 45 10             	lea    0x10(%ebp),%eax
 4bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 4be:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 4c3:	bb 00 00 00 00       	mov    $0x0,%ebx
 4c8:	eb 12                	jmp    4dc <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 4ca:	89 fa                	mov    %edi,%edx
 4cc:	8b 45 08             	mov    0x8(%ebp),%eax
 4cf:	e8 48 ff ff ff       	call   41c <putc>
 4d4:	eb 05                	jmp    4db <printf+0x2c>
      }
    } else if(state == '%'){
 4d6:	83 fe 25             	cmp    $0x25,%esi
 4d9:	74 22                	je     4fd <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 4db:	43                   	inc    %ebx
 4dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 4df:	8a 04 18             	mov    (%eax,%ebx,1),%al
 4e2:	84 c0                	test   %al,%al
 4e4:	0f 84 1d 01 00 00    	je     607 <printf+0x158>
    c = fmt[i] & 0xff;
 4ea:	0f be f8             	movsbl %al,%edi
 4ed:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 4f0:	85 f6                	test   %esi,%esi
 4f2:	75 e2                	jne    4d6 <printf+0x27>
      if(c == '%'){
 4f4:	83 f8 25             	cmp    $0x25,%eax
 4f7:	75 d1                	jne    4ca <printf+0x1b>
        state = '%';
 4f9:	89 c6                	mov    %eax,%esi
 4fb:	eb de                	jmp    4db <printf+0x2c>
      if(c == 'd'){
 4fd:	83 f8 25             	cmp    $0x25,%eax
 500:	0f 84 cc 00 00 00    	je     5d2 <printf+0x123>
 506:	0f 8c da 00 00 00    	jl     5e6 <printf+0x137>
 50c:	83 f8 78             	cmp    $0x78,%eax
 50f:	0f 8f d1 00 00 00    	jg     5e6 <printf+0x137>
 515:	83 f8 63             	cmp    $0x63,%eax
 518:	0f 8c c8 00 00 00    	jl     5e6 <printf+0x137>
 51e:	83 e8 63             	sub    $0x63,%eax
 521:	83 f8 15             	cmp    $0x15,%eax
 524:	0f 87 bc 00 00 00    	ja     5e6 <printf+0x137>
 52a:	ff 24 85 00 09 00 00 	jmp    *0x900(,%eax,4)
        printint(fd, *ap, 10, 1);
 531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 534:	8b 17                	mov    (%edi),%edx
 536:	83 ec 0c             	sub    $0xc,%esp
 539:	6a 01                	push   $0x1
 53b:	b9 0a 00 00 00       	mov    $0xa,%ecx
 540:	8b 45 08             	mov    0x8(%ebp),%eax
 543:	e8 ee fe ff ff       	call   436 <printint>
        ap++;
 548:	83 c7 04             	add    $0x4,%edi
 54b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 54e:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 551:	be 00 00 00 00       	mov    $0x0,%esi
 556:	eb 83                	jmp    4db <printf+0x2c>
        printint(fd, *ap, 16, 0);
 558:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 55b:	8b 17                	mov    (%edi),%edx
 55d:	83 ec 0c             	sub    $0xc,%esp
 560:	6a 00                	push   $0x0
 562:	b9 10 00 00 00       	mov    $0x10,%ecx
 567:	8b 45 08             	mov    0x8(%ebp),%eax
 56a:	e8 c7 fe ff ff       	call   436 <printint>
        ap++;
 56f:	83 c7 04             	add    $0x4,%edi
 572:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 575:	83 c4 10             	add    $0x10,%esp
      state = 0;
 578:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 57d:	e9 59 ff ff ff       	jmp    4db <printf+0x2c>
        s = (char*)*ap;
 582:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 585:	8b 30                	mov    (%eax),%esi
        ap++;
 587:	83 c0 04             	add    $0x4,%eax
 58a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 58d:	85 f6                	test   %esi,%esi
 58f:	75 13                	jne    5a4 <printf+0xf5>
          s = "(null)";
 591:	be f8 08 00 00       	mov    $0x8f8,%esi
 596:	eb 0c                	jmp    5a4 <printf+0xf5>
          putc(fd, *s);
 598:	0f be d2             	movsbl %dl,%edx
 59b:	8b 45 08             	mov    0x8(%ebp),%eax
 59e:	e8 79 fe ff ff       	call   41c <putc>
          s++;
 5a3:	46                   	inc    %esi
        while(*s != 0){
 5a4:	8a 16                	mov    (%esi),%dl
 5a6:	84 d2                	test   %dl,%dl
 5a8:	75 ee                	jne    598 <printf+0xe9>
      state = 0;
 5aa:	be 00 00 00 00       	mov    $0x0,%esi
 5af:	e9 27 ff ff ff       	jmp    4db <printf+0x2c>
        putc(fd, *ap);
 5b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5b7:	0f be 17             	movsbl (%edi),%edx
 5ba:	8b 45 08             	mov    0x8(%ebp),%eax
 5bd:	e8 5a fe ff ff       	call   41c <putc>
        ap++;
 5c2:	83 c7 04             	add    $0x4,%edi
 5c5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 5c8:	be 00 00 00 00       	mov    $0x0,%esi
 5cd:	e9 09 ff ff ff       	jmp    4db <printf+0x2c>
        putc(fd, c);
 5d2:	89 fa                	mov    %edi,%edx
 5d4:	8b 45 08             	mov    0x8(%ebp),%eax
 5d7:	e8 40 fe ff ff       	call   41c <putc>
      state = 0;
 5dc:	be 00 00 00 00       	mov    $0x0,%esi
 5e1:	e9 f5 fe ff ff       	jmp    4db <printf+0x2c>
        putc(fd, '%');
 5e6:	ba 25 00 00 00       	mov    $0x25,%edx
 5eb:	8b 45 08             	mov    0x8(%ebp),%eax
 5ee:	e8 29 fe ff ff       	call   41c <putc>
        putc(fd, c);
 5f3:	89 fa                	mov    %edi,%edx
 5f5:	8b 45 08             	mov    0x8(%ebp),%eax
 5f8:	e8 1f fe ff ff       	call   41c <putc>
      state = 0;
 5fd:	be 00 00 00 00       	mov    $0x0,%esi
 602:	e9 d4 fe ff ff       	jmp    4db <printf+0x2c>
    }
  }
}
 607:	8d 65 f4             	lea    -0xc(%ebp),%esp
 60a:	5b                   	pop    %ebx
 60b:	5e                   	pop    %esi
 60c:	5f                   	pop    %edi
 60d:	5d                   	pop    %ebp
 60e:	c3                   	ret    
