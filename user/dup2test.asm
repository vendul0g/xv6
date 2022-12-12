
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
  16:	e8 ea 03 00 00       	call   405 <dup2>
  1b:	83 c4 10             	add    $0x10,%esp
  1e:	85 c0                	test   %eax,%eax
  20:	0f 89 ed 01 00 00    	jns    213 <main+0x213>
    printf (2, "dup2 no funciona con fd incorrecto.\n");

  // Ejemplo de dup2 con un newfd incorrecto
  if (dup2 (1,-1) >= 0)
  26:	83 ec 08             	sub    $0x8,%esp
  29:	6a ff                	push   $0xffffffff
  2b:	6a 01                	push   $0x1
  2d:	e8 d3 03 00 00       	call   405 <dup2>
  32:	83 c4 10             	add    $0x10,%esp
  35:	85 c0                	test   %eax,%eax
  37:	0f 89 ed 01 00 00    	jns    22a <main+0x22a>
    printf (2, "dup2 no funciona con fd incorrecto (2).\n");

  // Ejemplo de dup2 con un fd no mapeado
  if (dup2 (6,8) >= 0)
  3d:	83 ec 08             	sub    $0x8,%esp
  40:	6a 08                	push   $0x8
  42:	6a 06                	push   $0x6
  44:	e8 bc 03 00 00       	call   405 <dup2>
  49:	83 c4 10             	add    $0x10,%esp
  4c:	85 c0                	test   %eax,%eax
  4e:	0f 89 ed 01 00 00    	jns    241 <main+0x241>
    printf (2, "dup2 no funciona con fd no mapeado.\n");

  // Ejemplo de dup2 con un fd no mapeado (2)
  if (dup2 (8,1) >= 0)
  54:	83 ec 08             	sub    $0x8,%esp
  57:	6a 01                	push   $0x1
  59:	6a 08                	push   $0x8
  5b:	e8 a5 03 00 00       	call   405 <dup2>
  60:	83 c4 10             	add    $0x10,%esp
  63:	85 c0                	test   %eax,%eax
  65:	0f 89 ed 01 00 00    	jns    258 <main+0x258>
    printf (2, "dup2 no funciona con fd no mapeado (2).\n");

  if (dup2 (1,25) >= 0)
  6b:	83 ec 08             	sub    $0x8,%esp
  6e:	6a 19                	push   $0x19
  70:	6a 01                	push   $0x1
  72:	e8 8e 03 00 00       	call   405 <dup2>
  77:	83 c4 10             	add    $0x10,%esp
  7a:	85 c0                	test   %eax,%eax
  7c:	0f 89 ed 01 00 00    	jns    26f <main+0x26f>
    printf (2, "dup2 no funciona con fd superior a NOFILE.\n");

  // Ejemplo de dup2 con fd existente
  if (dup2 (1,4) != 4)
  82:	83 ec 08             	sub    $0x8,%esp
  85:	6a 04                	push   $0x4
  87:	6a 01                	push   $0x1
  89:	e8 77 03 00 00       	call   405 <dup2>
  8e:	83 c4 10             	add    $0x10,%esp
  91:	83 f8 04             	cmp    $0x4,%eax
  94:	0f 85 ec 01 00 00    	jne    286 <main+0x286>
    printf (2, "dup2 no funciona con fd existente.\n");

  printf (4, "Este mensaje debe salir por terminal.\n");
  9a:	83 ec 08             	sub    $0x8,%esp
  9d:	68 08 07 00 00       	push   $0x708
  a2:	6a 04                	push   $0x4
  a4:	e8 07 04 00 00       	call   4b0 <printf>

  if (dup2 (4,6) != 6)
  a9:	83 c4 08             	add    $0x8,%esp
  ac:	6a 06                	push   $0x6
  ae:	6a 04                	push   $0x4
  b0:	e8 50 03 00 00       	call   405 <dup2>
  b5:	83 c4 10             	add    $0x10,%esp
  b8:	83 f8 06             	cmp    $0x6,%eax
  bb:	0f 85 dc 01 00 00    	jne    29d <main+0x29d>
    printf (2, "dup2 no funciona con fd existente (2).\n");

  printf (6, "Este mensaje debe salir por terminal (2).\n");
  c1:	83 ec 08             	sub    $0x8,%esp
  c4:	68 58 07 00 00       	push   $0x758
  c9:	6a 06                	push   $0x6
  cb:	e8 e0 03 00 00       	call   4b0 <printf>

  if (close (4) != 0)
  d0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  d7:	e8 a9 02 00 00       	call   385 <close>
  dc:	83 c4 10             	add    $0x10,%esp
  df:	85 c0                	test   %eax,%eax
  e1:	0f 85 cd 01 00 00    	jne    2b4 <main+0x2b4>
    printf (2, "Error en close (4)\n");
  printf (6, "Este mensaje debe salir por terminal (3).\n");
  e7:	83 ec 08             	sub    $0x8,%esp
  ea:	68 84 07 00 00       	push   $0x784
  ef:	6a 06                	push   $0x6
  f1:	e8 ba 03 00 00       	call   4b0 <printf>
  if (close (6) != 0)
  f6:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  fd:	e8 83 02 00 00       	call   385 <close>
 102:	83 c4 10             	add    $0x10,%esp
 105:	85 c0                	test   %eax,%eax
 107:	0f 85 be 01 00 00    	jne    2cb <main+0x2cb>
    printf (2, "Error en close (6)\n");
  if (close (6) == 0)
 10d:	83 ec 0c             	sub    $0xc,%esp
 110:	6a 06                	push   $0x6
 112:	e8 6e 02 00 00       	call   385 <close>
 117:	83 c4 10             	add    $0x10,%esp
 11a:	85 c0                	test   %eax,%eax
 11c:	0f 84 c0 01 00 00    	je     2e2 <main+0x2e2>
    printf (2, "Error en close (6) (2)\n");

  fd = open ("fichero_salida.txt", O_CREATE|O_RDWR);
 122:	83 ec 08             	sub    $0x8,%esp
 125:	68 02 02 00 00       	push   $0x202
 12a:	68 64 08 00 00       	push   $0x864
 12f:	e8 69 02 00 00       	call   39d <open>
 134:	89 c3                	mov    %eax,%ebx
  printf (fd, "Salida a fichero\n");
 136:	83 c4 08             	add    $0x8,%esp
 139:	68 77 08 00 00       	push   $0x877
 13e:	50                   	push   %eax
 13f:	e8 6c 03 00 00       	call   4b0 <printf>

  if (dup2 (fd, 9) != 9)
 144:	83 c4 08             	add    $0x8,%esp
 147:	6a 09                	push   $0x9
 149:	53                   	push   %ebx
 14a:	e8 b6 02 00 00       	call   405 <dup2>
 14f:	83 c4 10             	add    $0x10,%esp
 152:	83 f8 09             	cmp    $0x9,%eax
 155:	0f 85 9e 01 00 00    	jne    2f9 <main+0x2f9>
    printf (2, "dup2 no funciona con fd existente (3).\n");

  printf (9, "Salida también a fichero.\n");
 15b:	83 ec 08             	sub    $0x8,%esp
 15e:	68 89 08 00 00       	push   $0x889
 163:	6a 09                	push   $0x9
 165:	e8 46 03 00 00       	call   4b0 <printf>

  if (dup2 (9, 9) != 9)
 16a:	83 c4 08             	add    $0x8,%esp
 16d:	6a 09                	push   $0x9
 16f:	6a 09                	push   $0x9
 171:	e8 8f 02 00 00       	call   405 <dup2>
 176:	83 c4 10             	add    $0x10,%esp
 179:	83 f8 09             	cmp    $0x9,%eax
 17c:	0f 85 8e 01 00 00    	jne    310 <main+0x310>
    printf (2, "dup2 no funciona con newfd=oldfd.\n");

  printf (9, "Salida también a fichero.\n");
 182:	83 ec 08             	sub    $0x8,%esp
 185:	68 89 08 00 00       	push   $0x889
 18a:	6a 09                	push   $0x9
 18c:	e8 1f 03 00 00       	call   4b0 <printf>

  close (9);
 191:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
 198:	e8 e8 01 00 00       	call   385 <close>

  dup2 (1, 6);
 19d:	83 c4 08             	add    $0x8,%esp
 1a0:	6a 06                	push   $0x6
 1a2:	6a 01                	push   $0x1
 1a4:	e8 5c 02 00 00       	call   405 <dup2>

  if (dup2 (fd, 1) != 1)
 1a9:	83 c4 08             	add    $0x8,%esp
 1ac:	6a 01                	push   $0x1
 1ae:	53                   	push   %ebx
 1af:	e8 51 02 00 00       	call   405 <dup2>
 1b4:	83 c4 10             	add    $0x10,%esp
 1b7:	83 f8 01             	cmp    $0x1,%eax
 1ba:	0f 85 67 01 00 00    	jne    327 <main+0x327>
    printf (2, "dup2 no funciona con fd existente (4).\n");

  printf (1, "Cuarta salida a fichero.\n");
 1c0:	83 ec 08             	sub    $0x8,%esp
 1c3:	68 a5 08 00 00       	push   $0x8a5
 1c8:	6a 01                	push   $0x1
 1ca:	e8 e1 02 00 00       	call   4b0 <printf>
  if (close (1) != 0)
 1cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1d6:	e8 aa 01 00 00       	call   385 <close>
 1db:	83 c4 10             	add    $0x10,%esp
 1de:	85 c0                	test   %eax,%eax
 1e0:	0f 85 58 01 00 00    	jne    33e <main+0x33e>
    printf (2, "Error en close (1).\n");

  dup2 (6,fd);
 1e6:	83 ec 08             	sub    $0x8,%esp
 1e9:	53                   	push   %ebx
 1ea:	6a 06                	push   $0x6
 1ec:	e8 14 02 00 00       	call   405 <dup2>

  printf (fd, "Este mensaje debe salir por terminal.\n");
 1f1:	83 c4 08             	add    $0x8,%esp
 1f4:	68 08 07 00 00       	push   $0x708
 1f9:	53                   	push   %ebx
 1fa:	e8 b1 02 00 00       	call   4b0 <printf>
  close (fd);
 1ff:	89 1c 24             	mov    %ebx,(%esp)
 202:	e8 7e 01 00 00       	call   385 <close>

  exit(0);
 207:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 20e:	e8 4a 01 00 00       	call   35d <exit>
    printf (2, "dup2 no funciona con fd incorrecto.\n");
 213:	83 ec 08             	sub    $0x8,%esp
 216:	68 10 06 00 00       	push   $0x610
 21b:	6a 02                	push   $0x2
 21d:	e8 8e 02 00 00       	call   4b0 <printf>
 222:	83 c4 10             	add    $0x10,%esp
 225:	e9 fc fd ff ff       	jmp    26 <main+0x26>
    printf (2, "dup2 no funciona con fd incorrecto (2).\n");
 22a:	83 ec 08             	sub    $0x8,%esp
 22d:	68 38 06 00 00       	push   $0x638
 232:	6a 02                	push   $0x2
 234:	e8 77 02 00 00       	call   4b0 <printf>
 239:	83 c4 10             	add    $0x10,%esp
 23c:	e9 fc fd ff ff       	jmp    3d <main+0x3d>
    printf (2, "dup2 no funciona con fd no mapeado.\n");
 241:	83 ec 08             	sub    $0x8,%esp
 244:	68 64 06 00 00       	push   $0x664
 249:	6a 02                	push   $0x2
 24b:	e8 60 02 00 00       	call   4b0 <printf>
 250:	83 c4 10             	add    $0x10,%esp
 253:	e9 fc fd ff ff       	jmp    54 <main+0x54>
    printf (2, "dup2 no funciona con fd no mapeado (2).\n");
 258:	83 ec 08             	sub    $0x8,%esp
 25b:	68 8c 06 00 00       	push   $0x68c
 260:	6a 02                	push   $0x2
 262:	e8 49 02 00 00       	call   4b0 <printf>
 267:	83 c4 10             	add    $0x10,%esp
 26a:	e9 fc fd ff ff       	jmp    6b <main+0x6b>
    printf (2, "dup2 no funciona con fd superior a NOFILE.\n");
 26f:	83 ec 08             	sub    $0x8,%esp
 272:	68 b8 06 00 00       	push   $0x6b8
 277:	6a 02                	push   $0x2
 279:	e8 32 02 00 00       	call   4b0 <printf>
 27e:	83 c4 10             	add    $0x10,%esp
 281:	e9 fc fd ff ff       	jmp    82 <main+0x82>
    printf (2, "dup2 no funciona con fd existente.\n");
 286:	83 ec 08             	sub    $0x8,%esp
 289:	68 e4 06 00 00       	push   $0x6e4
 28e:	6a 02                	push   $0x2
 290:	e8 1b 02 00 00       	call   4b0 <printf>
 295:	83 c4 10             	add    $0x10,%esp
 298:	e9 fd fd ff ff       	jmp    9a <main+0x9a>
    printf (2, "dup2 no funciona con fd existente (2).\n");
 29d:	83 ec 08             	sub    $0x8,%esp
 2a0:	68 30 07 00 00       	push   $0x730
 2a5:	6a 02                	push   $0x2
 2a7:	e8 04 02 00 00       	call   4b0 <printf>
 2ac:	83 c4 10             	add    $0x10,%esp
 2af:	e9 0d fe ff ff       	jmp    c1 <main+0xc1>
    printf (2, "Error en close (4)\n");
 2b4:	83 ec 08             	sub    $0x8,%esp
 2b7:	68 24 08 00 00       	push   $0x824
 2bc:	6a 02                	push   $0x2
 2be:	e8 ed 01 00 00       	call   4b0 <printf>
 2c3:	83 c4 10             	add    $0x10,%esp
 2c6:	e9 1c fe ff ff       	jmp    e7 <main+0xe7>
    printf (2, "Error en close (6)\n");
 2cb:	83 ec 08             	sub    $0x8,%esp
 2ce:	68 38 08 00 00       	push   $0x838
 2d3:	6a 02                	push   $0x2
 2d5:	e8 d6 01 00 00       	call   4b0 <printf>
 2da:	83 c4 10             	add    $0x10,%esp
 2dd:	e9 2b fe ff ff       	jmp    10d <main+0x10d>
    printf (2, "Error en close (6) (2)\n");
 2e2:	83 ec 08             	sub    $0x8,%esp
 2e5:	68 4c 08 00 00       	push   $0x84c
 2ea:	6a 02                	push   $0x2
 2ec:	e8 bf 01 00 00       	call   4b0 <printf>
 2f1:	83 c4 10             	add    $0x10,%esp
 2f4:	e9 29 fe ff ff       	jmp    122 <main+0x122>
    printf (2, "dup2 no funciona con fd existente (3).\n");
 2f9:	83 ec 08             	sub    $0x8,%esp
 2fc:	68 b0 07 00 00       	push   $0x7b0
 301:	6a 02                	push   $0x2
 303:	e8 a8 01 00 00       	call   4b0 <printf>
 308:	83 c4 10             	add    $0x10,%esp
 30b:	e9 4b fe ff ff       	jmp    15b <main+0x15b>
    printf (2, "dup2 no funciona con newfd=oldfd.\n");
 310:	83 ec 08             	sub    $0x8,%esp
 313:	68 d8 07 00 00       	push   $0x7d8
 318:	6a 02                	push   $0x2
 31a:	e8 91 01 00 00       	call   4b0 <printf>
 31f:	83 c4 10             	add    $0x10,%esp
 322:	e9 5b fe ff ff       	jmp    182 <main+0x182>
    printf (2, "dup2 no funciona con fd existente (4).\n");
 327:	83 ec 08             	sub    $0x8,%esp
 32a:	68 fc 07 00 00       	push   $0x7fc
 32f:	6a 02                	push   $0x2
 331:	e8 7a 01 00 00       	call   4b0 <printf>
 336:	83 c4 10             	add    $0x10,%esp
 339:	e9 82 fe ff ff       	jmp    1c0 <main+0x1c0>
    printf (2, "Error en close (1).\n");
 33e:	83 ec 08             	sub    $0x8,%esp
 341:	68 bf 08 00 00       	push   $0x8bf
 346:	6a 02                	push   $0x2
 348:	e8 63 01 00 00       	call   4b0 <printf>
 34d:	83 c4 10             	add    $0x10,%esp
 350:	e9 91 fe ff ff       	jmp    1e6 <main+0x1e6>

00000355 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 355:	b8 01 00 00 00       	mov    $0x1,%eax
 35a:	cd 40                	int    $0x40
 35c:	c3                   	ret    

0000035d <exit>:
SYSCALL(exit)
 35d:	b8 02 00 00 00       	mov    $0x2,%eax
 362:	cd 40                	int    $0x40
 364:	c3                   	ret    

00000365 <wait>:
SYSCALL(wait)
 365:	b8 03 00 00 00       	mov    $0x3,%eax
 36a:	cd 40                	int    $0x40
 36c:	c3                   	ret    

0000036d <pipe>:
SYSCALL(pipe)
 36d:	b8 04 00 00 00       	mov    $0x4,%eax
 372:	cd 40                	int    $0x40
 374:	c3                   	ret    

00000375 <read>:
SYSCALL(read)
 375:	b8 05 00 00 00       	mov    $0x5,%eax
 37a:	cd 40                	int    $0x40
 37c:	c3                   	ret    

0000037d <write>:
SYSCALL(write)
 37d:	b8 10 00 00 00       	mov    $0x10,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <close>:
SYSCALL(close)
 385:	b8 15 00 00 00       	mov    $0x15,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <kill>:
SYSCALL(kill)
 38d:	b8 06 00 00 00       	mov    $0x6,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <exec>:
SYSCALL(exec)
 395:	b8 07 00 00 00       	mov    $0x7,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <open>:
SYSCALL(open)
 39d:	b8 0f 00 00 00       	mov    $0xf,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <mknod>:
SYSCALL(mknod)
 3a5:	b8 11 00 00 00       	mov    $0x11,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <unlink>:
SYSCALL(unlink)
 3ad:	b8 12 00 00 00       	mov    $0x12,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <fstat>:
SYSCALL(fstat)
 3b5:	b8 08 00 00 00       	mov    $0x8,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <link>:
SYSCALL(link)
 3bd:	b8 13 00 00 00       	mov    $0x13,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <mkdir>:
SYSCALL(mkdir)
 3c5:	b8 14 00 00 00       	mov    $0x14,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <chdir>:
SYSCALL(chdir)
 3cd:	b8 09 00 00 00       	mov    $0x9,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <dup>:
SYSCALL(dup)
 3d5:	b8 0a 00 00 00       	mov    $0xa,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <getpid>:
SYSCALL(getpid)
 3dd:	b8 0b 00 00 00       	mov    $0xb,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <sbrk>:
SYSCALL(sbrk)
 3e5:	b8 0c 00 00 00       	mov    $0xc,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <sleep>:
SYSCALL(sleep)
 3ed:	b8 0d 00 00 00       	mov    $0xd,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret    

000003f5 <uptime>:
SYSCALL(uptime)
 3f5:	b8 0e 00 00 00       	mov    $0xe,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <date>:
SYSCALL(date)
 3fd:	b8 16 00 00 00       	mov    $0x16,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <dup2>:
SYSCALL(dup2)
 405:	b8 17 00 00 00       	mov    $0x17,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <getprio>:
SYSCALL(getprio)
 40d:	b8 18 00 00 00       	mov    $0x18,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <setprio>:
SYSCALL(setprio)
 415:	b8 19 00 00 00       	mov    $0x19,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 41d:	55                   	push   %ebp
 41e:	89 e5                	mov    %esp,%ebp
 420:	83 ec 1c             	sub    $0x1c,%esp
 423:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 426:	6a 01                	push   $0x1
 428:	8d 55 f4             	lea    -0xc(%ebp),%edx
 42b:	52                   	push   %edx
 42c:	50                   	push   %eax
 42d:	e8 4b ff ff ff       	call   37d <write>
}
 432:	83 c4 10             	add    $0x10,%esp
 435:	c9                   	leave  
 436:	c3                   	ret    

00000437 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 437:	55                   	push   %ebp
 438:	89 e5                	mov    %esp,%ebp
 43a:	57                   	push   %edi
 43b:	56                   	push   %esi
 43c:	53                   	push   %ebx
 43d:	83 ec 2c             	sub    $0x2c,%esp
 440:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 443:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 445:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 449:	74 04                	je     44f <printint+0x18>
 44b:	85 d2                	test   %edx,%edx
 44d:	78 3c                	js     48b <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 44f:	89 d1                	mov    %edx,%ecx
  neg = 0;
 451:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 458:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 45d:	89 c8                	mov    %ecx,%eax
 45f:	ba 00 00 00 00       	mov    $0x0,%edx
 464:	f7 f6                	div    %esi
 466:	89 df                	mov    %ebx,%edi
 468:	43                   	inc    %ebx
 469:	8a 92 34 09 00 00    	mov    0x934(%edx),%dl
 46f:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 473:	89 ca                	mov    %ecx,%edx
 475:	89 c1                	mov    %eax,%ecx
 477:	39 d6                	cmp    %edx,%esi
 479:	76 e2                	jbe    45d <printint+0x26>
  if(neg)
 47b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 47f:	74 24                	je     4a5 <printint+0x6e>
    buf[i++] = '-';
 481:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 486:	8d 5f 02             	lea    0x2(%edi),%ebx
 489:	eb 1a                	jmp    4a5 <printint+0x6e>
    x = -xx;
 48b:	89 d1                	mov    %edx,%ecx
 48d:	f7 d9                	neg    %ecx
    neg = 1;
 48f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 496:	eb c0                	jmp    458 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 498:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 49d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 4a0:	e8 78 ff ff ff       	call   41d <putc>
  while(--i >= 0)
 4a5:	4b                   	dec    %ebx
 4a6:	79 f0                	jns    498 <printint+0x61>
}
 4a8:	83 c4 2c             	add    $0x2c,%esp
 4ab:	5b                   	pop    %ebx
 4ac:	5e                   	pop    %esi
 4ad:	5f                   	pop    %edi
 4ae:	5d                   	pop    %ebp
 4af:	c3                   	ret    

000004b0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	57                   	push   %edi
 4b4:	56                   	push   %esi
 4b5:	53                   	push   %ebx
 4b6:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 4b9:	8d 45 10             	lea    0x10(%ebp),%eax
 4bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 4bf:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 4c4:	bb 00 00 00 00       	mov    $0x0,%ebx
 4c9:	eb 12                	jmp    4dd <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 4cb:	89 fa                	mov    %edi,%edx
 4cd:	8b 45 08             	mov    0x8(%ebp),%eax
 4d0:	e8 48 ff ff ff       	call   41d <putc>
 4d5:	eb 05                	jmp    4dc <printf+0x2c>
      }
    } else if(state == '%'){
 4d7:	83 fe 25             	cmp    $0x25,%esi
 4da:	74 22                	je     4fe <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 4dc:	43                   	inc    %ebx
 4dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e0:	8a 04 18             	mov    (%eax,%ebx,1),%al
 4e3:	84 c0                	test   %al,%al
 4e5:	0f 84 1d 01 00 00    	je     608 <printf+0x158>
    c = fmt[i] & 0xff;
 4eb:	0f be f8             	movsbl %al,%edi
 4ee:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 4f1:	85 f6                	test   %esi,%esi
 4f3:	75 e2                	jne    4d7 <printf+0x27>
      if(c == '%'){
 4f5:	83 f8 25             	cmp    $0x25,%eax
 4f8:	75 d1                	jne    4cb <printf+0x1b>
        state = '%';
 4fa:	89 c6                	mov    %eax,%esi
 4fc:	eb de                	jmp    4dc <printf+0x2c>
      if(c == 'd'){
 4fe:	83 f8 25             	cmp    $0x25,%eax
 501:	0f 84 cc 00 00 00    	je     5d3 <printf+0x123>
 507:	0f 8c da 00 00 00    	jl     5e7 <printf+0x137>
 50d:	83 f8 78             	cmp    $0x78,%eax
 510:	0f 8f d1 00 00 00    	jg     5e7 <printf+0x137>
 516:	83 f8 63             	cmp    $0x63,%eax
 519:	0f 8c c8 00 00 00    	jl     5e7 <printf+0x137>
 51f:	83 e8 63             	sub    $0x63,%eax
 522:	83 f8 15             	cmp    $0x15,%eax
 525:	0f 87 bc 00 00 00    	ja     5e7 <printf+0x137>
 52b:	ff 24 85 dc 08 00 00 	jmp    *0x8dc(,%eax,4)
        printint(fd, *ap, 10, 1);
 532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 535:	8b 17                	mov    (%edi),%edx
 537:	83 ec 0c             	sub    $0xc,%esp
 53a:	6a 01                	push   $0x1
 53c:	b9 0a 00 00 00       	mov    $0xa,%ecx
 541:	8b 45 08             	mov    0x8(%ebp),%eax
 544:	e8 ee fe ff ff       	call   437 <printint>
        ap++;
 549:	83 c7 04             	add    $0x4,%edi
 54c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 54f:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 552:	be 00 00 00 00       	mov    $0x0,%esi
 557:	eb 83                	jmp    4dc <printf+0x2c>
        printint(fd, *ap, 16, 0);
 559:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 55c:	8b 17                	mov    (%edi),%edx
 55e:	83 ec 0c             	sub    $0xc,%esp
 561:	6a 00                	push   $0x0
 563:	b9 10 00 00 00       	mov    $0x10,%ecx
 568:	8b 45 08             	mov    0x8(%ebp),%eax
 56b:	e8 c7 fe ff ff       	call   437 <printint>
        ap++;
 570:	83 c7 04             	add    $0x4,%edi
 573:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 576:	83 c4 10             	add    $0x10,%esp
      state = 0;
 579:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 57e:	e9 59 ff ff ff       	jmp    4dc <printf+0x2c>
        s = (char*)*ap;
 583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 586:	8b 30                	mov    (%eax),%esi
        ap++;
 588:	83 c0 04             	add    $0x4,%eax
 58b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 58e:	85 f6                	test   %esi,%esi
 590:	75 13                	jne    5a5 <printf+0xf5>
          s = "(null)";
 592:	be d4 08 00 00       	mov    $0x8d4,%esi
 597:	eb 0c                	jmp    5a5 <printf+0xf5>
          putc(fd, *s);
 599:	0f be d2             	movsbl %dl,%edx
 59c:	8b 45 08             	mov    0x8(%ebp),%eax
 59f:	e8 79 fe ff ff       	call   41d <putc>
          s++;
 5a4:	46                   	inc    %esi
        while(*s != 0){
 5a5:	8a 16                	mov    (%esi),%dl
 5a7:	84 d2                	test   %dl,%dl
 5a9:	75 ee                	jne    599 <printf+0xe9>
      state = 0;
 5ab:	be 00 00 00 00       	mov    $0x0,%esi
 5b0:	e9 27 ff ff ff       	jmp    4dc <printf+0x2c>
        putc(fd, *ap);
 5b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5b8:	0f be 17             	movsbl (%edi),%edx
 5bb:	8b 45 08             	mov    0x8(%ebp),%eax
 5be:	e8 5a fe ff ff       	call   41d <putc>
        ap++;
 5c3:	83 c7 04             	add    $0x4,%edi
 5c6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 5c9:	be 00 00 00 00       	mov    $0x0,%esi
 5ce:	e9 09 ff ff ff       	jmp    4dc <printf+0x2c>
        putc(fd, c);
 5d3:	89 fa                	mov    %edi,%edx
 5d5:	8b 45 08             	mov    0x8(%ebp),%eax
 5d8:	e8 40 fe ff ff       	call   41d <putc>
      state = 0;
 5dd:	be 00 00 00 00       	mov    $0x0,%esi
 5e2:	e9 f5 fe ff ff       	jmp    4dc <printf+0x2c>
        putc(fd, '%');
 5e7:	ba 25 00 00 00       	mov    $0x25,%edx
 5ec:	8b 45 08             	mov    0x8(%ebp),%eax
 5ef:	e8 29 fe ff ff       	call   41d <putc>
        putc(fd, c);
 5f4:	89 fa                	mov    %edi,%edx
 5f6:	8b 45 08             	mov    0x8(%ebp),%eax
 5f9:	e8 1f fe ff ff       	call   41d <putc>
      state = 0;
 5fe:	be 00 00 00 00       	mov    $0x0,%esi
 603:	e9 d4 fe ff ff       	jmp    4dc <printf+0x2c>
    }
  }
}
 608:	8d 65 f4             	lea    -0xc(%ebp),%esp
 60b:	5b                   	pop    %ebx
 60c:	5e                   	pop    %esi
 60d:	5f                   	pop    %edi
 60e:	5d                   	pop    %ebp
 60f:	c3                   	ret    
