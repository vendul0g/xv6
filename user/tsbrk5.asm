
tsbrk5:     file format elf32-i386


Disassembly of section .text:

00000000 <test1>:
#include "user.h"

int i = 1;

void test1()
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 10             	sub    $0x10,%esp
  char* a = sbrk (0);
   7:	6a 00                	push   $0x0
   9:	e8 54 01 00 00       	call   162 <sbrk>
   e:	89 c3                	mov    %eax,%ebx

  printf (1, "Debe fallar ahora por acceso mayor sz:\n");
  10:	83 c4 08             	add    $0x8,%esp
  13:	68 90 03 00 00       	push   $0x390
  18:	6a 01                	push   $0x1
  1a:	e8 0e 02 00 00       	call   22d <printf>
  *(a+1) = 1;  // Debe fallar
  1f:	c6 43 01 01          	movb   $0x1,0x1(%ebx)
  printf (2, "Ha accedido a más del sz\n");
  23:	83 c4 08             	add    $0x8,%esp
  26:	68 4e 04 00 00       	push   $0x44e
  2b:	6a 02                	push   $0x2
  2d:	e8 fb 01 00 00       	call   22d <printf>
}
  32:	83 c4 10             	add    $0x10,%esp
  35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  38:	c9                   	leave  
  39:	c3                   	ret    

0000003a <test2>:

void test2()
{
  3a:	55                   	push   %ebp
  3b:	89 e5                	mov    %esp,%ebp
  3d:	83 ec 10             	sub    $0x10,%esp
  // Página de guarda:
  printf (1, "Si no fallo antes (mal), ahora tambien debe fallar por página de guarda:\n");
  40:	68 b8 03 00 00       	push   $0x3b8
  45:	6a 01                	push   $0x1
  47:	e8 e1 01 00 00       	call   22d <printf>
  char* a = (char*)((int)&i + 4095);
  printf (1, "0x%x\n", a);
  4c:	83 c4 0c             	add    $0xc,%esp
  4f:	68 33 16 00 00       	push   $0x1633
  54:	68 69 04 00 00       	push   $0x469
  59:	6a 01                	push   $0x1
  5b:	e8 cd 01 00 00       	call   22d <printf>
  *a = 1;//Esta instrucción debe fallar
  60:	c6 05 33 16 00 00 01 	movb   $0x1,0x1633
  printf(1,"Página de guarda accedida\n");
  67:	83 c4 08             	add    $0x8,%esp
  6a:	68 6f 04 00 00       	push   $0x46f
  6f:	6a 01                	push   $0x1
  71:	e8 b7 01 00 00       	call   22d <printf>
}
  76:	83 c4 10             	add    $0x10,%esp
  79:	c9                   	leave  
  7a:	c3                   	ret    

0000007b <test3>:

void test3()
{
  7b:	55                   	push   %ebp
  7c:	89 e5                	mov    %esp,%ebp
  7e:	83 ec 10             	sub    $0x10,%esp
  // Acceder al núcleo
  printf (1, "Si no fallo antes (mal), ahora tambien debe fallar por acceso al nucleo:\n");
  81:	68 04 04 00 00       	push   $0x404
  86:	6a 01                	push   $0x1
  88:	e8 a0 01 00 00       	call   22d <printf>
  char* a = (char*)0x80000001;
  *(a+1) = 1;  // Debe fallar (si lo anterior no ha fallado)
  8d:	c6 05 02 00 00 80 01 	movb   $0x1,0x80000002
  printf(1, "Ha accedido al kernel\n");
  94:	83 c4 08             	add    $0x8,%esp
  97:	68 8b 04 00 00       	push   $0x48b
  9c:	6a 01                	push   $0x1
  9e:	e8 8a 01 00 00       	call   22d <printf>
}
  a3:	83 c4 10             	add    $0x10,%esp
  a6:	c9                   	leave  
  a7:	c3                   	ret    

000000a8 <main>:


int
main(int argc, char *argv[])
{
  a8:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  ac:	83 e4 f0             	and    $0xfffffff0,%esp
  af:	ff 71 fc             	push   -0x4(%ecx)
  b2:	55                   	push   %ebp
  b3:	89 e5                	mov    %esp,%ebp
  b5:	51                   	push   %ecx
  b6:	83 ec 04             	sub    $0x4,%esp
  //printf (1, "Este programa primero intenta acceder mas alla de sz.\n");

  // Más allá de sz
  test1();
  b9:	e8 42 ff ff ff       	call   0 <test1>

  // Acceso Página Guarda
  test2();
  be:	e8 77 ff ff ff       	call   3a <test2>

  // Acceso Núcleo
  test3();
  c3:	e8 b3 ff ff ff       	call   7b <test3>

  exit (0);
  c8:	83 ec 0c             	sub    $0xc,%esp
  cb:	6a 00                	push   $0x0
  cd:	e8 08 00 00 00       	call   da <exit>

000000d2 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  d2:	b8 01 00 00 00       	mov    $0x1,%eax
  d7:	cd 40                	int    $0x40
  d9:	c3                   	ret    

000000da <exit>:
SYSCALL(exit)
  da:	b8 02 00 00 00       	mov    $0x2,%eax
  df:	cd 40                	int    $0x40
  e1:	c3                   	ret    

000000e2 <wait>:
SYSCALL(wait)
  e2:	b8 03 00 00 00       	mov    $0x3,%eax
  e7:	cd 40                	int    $0x40
  e9:	c3                   	ret    

000000ea <pipe>:
SYSCALL(pipe)
  ea:	b8 04 00 00 00       	mov    $0x4,%eax
  ef:	cd 40                	int    $0x40
  f1:	c3                   	ret    

000000f2 <read>:
SYSCALL(read)
  f2:	b8 05 00 00 00       	mov    $0x5,%eax
  f7:	cd 40                	int    $0x40
  f9:	c3                   	ret    

000000fa <write>:
SYSCALL(write)
  fa:	b8 10 00 00 00       	mov    $0x10,%eax
  ff:	cd 40                	int    $0x40
 101:	c3                   	ret    

00000102 <close>:
SYSCALL(close)
 102:	b8 15 00 00 00       	mov    $0x15,%eax
 107:	cd 40                	int    $0x40
 109:	c3                   	ret    

0000010a <kill>:
SYSCALL(kill)
 10a:	b8 06 00 00 00       	mov    $0x6,%eax
 10f:	cd 40                	int    $0x40
 111:	c3                   	ret    

00000112 <exec>:
SYSCALL(exec)
 112:	b8 07 00 00 00       	mov    $0x7,%eax
 117:	cd 40                	int    $0x40
 119:	c3                   	ret    

0000011a <open>:
SYSCALL(open)
 11a:	b8 0f 00 00 00       	mov    $0xf,%eax
 11f:	cd 40                	int    $0x40
 121:	c3                   	ret    

00000122 <mknod>:
SYSCALL(mknod)
 122:	b8 11 00 00 00       	mov    $0x11,%eax
 127:	cd 40                	int    $0x40
 129:	c3                   	ret    

0000012a <unlink>:
SYSCALL(unlink)
 12a:	b8 12 00 00 00       	mov    $0x12,%eax
 12f:	cd 40                	int    $0x40
 131:	c3                   	ret    

00000132 <fstat>:
SYSCALL(fstat)
 132:	b8 08 00 00 00       	mov    $0x8,%eax
 137:	cd 40                	int    $0x40
 139:	c3                   	ret    

0000013a <link>:
SYSCALL(link)
 13a:	b8 13 00 00 00       	mov    $0x13,%eax
 13f:	cd 40                	int    $0x40
 141:	c3                   	ret    

00000142 <mkdir>:
SYSCALL(mkdir)
 142:	b8 14 00 00 00       	mov    $0x14,%eax
 147:	cd 40                	int    $0x40
 149:	c3                   	ret    

0000014a <chdir>:
SYSCALL(chdir)
 14a:	b8 09 00 00 00       	mov    $0x9,%eax
 14f:	cd 40                	int    $0x40
 151:	c3                   	ret    

00000152 <dup>:
SYSCALL(dup)
 152:	b8 0a 00 00 00       	mov    $0xa,%eax
 157:	cd 40                	int    $0x40
 159:	c3                   	ret    

0000015a <getpid>:
SYSCALL(getpid)
 15a:	b8 0b 00 00 00       	mov    $0xb,%eax
 15f:	cd 40                	int    $0x40
 161:	c3                   	ret    

00000162 <sbrk>:
SYSCALL(sbrk)
 162:	b8 0c 00 00 00       	mov    $0xc,%eax
 167:	cd 40                	int    $0x40
 169:	c3                   	ret    

0000016a <sleep>:
SYSCALL(sleep)
 16a:	b8 0d 00 00 00       	mov    $0xd,%eax
 16f:	cd 40                	int    $0x40
 171:	c3                   	ret    

00000172 <uptime>:
SYSCALL(uptime)
 172:	b8 0e 00 00 00       	mov    $0xe,%eax
 177:	cd 40                	int    $0x40
 179:	c3                   	ret    

0000017a <date>:
SYSCALL(date)
 17a:	b8 16 00 00 00       	mov    $0x16,%eax
 17f:	cd 40                	int    $0x40
 181:	c3                   	ret    

00000182 <dup2>:
SYSCALL(dup2)
 182:	b8 17 00 00 00       	mov    $0x17,%eax
 187:	cd 40                	int    $0x40
 189:	c3                   	ret    

0000018a <getprio>:
SYSCALL(getprio)
 18a:	b8 18 00 00 00       	mov    $0x18,%eax
 18f:	cd 40                	int    $0x40
 191:	c3                   	ret    

00000192 <setprio>:
SYSCALL(setprio)
 192:	b8 19 00 00 00       	mov    $0x19,%eax
 197:	cd 40                	int    $0x40
 199:	c3                   	ret    

0000019a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 19a:	55                   	push   %ebp
 19b:	89 e5                	mov    %esp,%ebp
 19d:	83 ec 1c             	sub    $0x1c,%esp
 1a0:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 1a3:	6a 01                	push   $0x1
 1a5:	8d 55 f4             	lea    -0xc(%ebp),%edx
 1a8:	52                   	push   %edx
 1a9:	50                   	push   %eax
 1aa:	e8 4b ff ff ff       	call   fa <write>
}
 1af:	83 c4 10             	add    $0x10,%esp
 1b2:	c9                   	leave  
 1b3:	c3                   	ret    

000001b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
 1b7:	57                   	push   %edi
 1b8:	56                   	push   %esi
 1b9:	53                   	push   %ebx
 1ba:	83 ec 2c             	sub    $0x2c,%esp
 1bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 1c0:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1c2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1c6:	74 04                	je     1cc <printint+0x18>
 1c8:	85 d2                	test   %edx,%edx
 1ca:	78 3c                	js     208 <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 1cc:	89 d1                	mov    %edx,%ecx
  neg = 0;
 1ce:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 1d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 1da:	89 c8                	mov    %ecx,%eax
 1dc:	ba 00 00 00 00       	mov    $0x0,%edx
 1e1:	f7 f6                	div    %esi
 1e3:	89 df                	mov    %ebx,%edi
 1e5:	43                   	inc    %ebx
 1e6:	8a 92 04 05 00 00    	mov    0x504(%edx),%dl
 1ec:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1f0:	89 ca                	mov    %ecx,%edx
 1f2:	89 c1                	mov    %eax,%ecx
 1f4:	39 d6                	cmp    %edx,%esi
 1f6:	76 e2                	jbe    1da <printint+0x26>
  if(neg)
 1f8:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 1fc:	74 24                	je     222 <printint+0x6e>
    buf[i++] = '-';
 1fe:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 203:	8d 5f 02             	lea    0x2(%edi),%ebx
 206:	eb 1a                	jmp    222 <printint+0x6e>
    x = -xx;
 208:	89 d1                	mov    %edx,%ecx
 20a:	f7 d9                	neg    %ecx
    neg = 1;
 20c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 213:	eb c0                	jmp    1d5 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 215:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 21a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 21d:	e8 78 ff ff ff       	call   19a <putc>
  while(--i >= 0)
 222:	4b                   	dec    %ebx
 223:	79 f0                	jns    215 <printint+0x61>
}
 225:	83 c4 2c             	add    $0x2c,%esp
 228:	5b                   	pop    %ebx
 229:	5e                   	pop    %esi
 22a:	5f                   	pop    %edi
 22b:	5d                   	pop    %ebp
 22c:	c3                   	ret    

0000022d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 22d:	55                   	push   %ebp
 22e:	89 e5                	mov    %esp,%ebp
 230:	57                   	push   %edi
 231:	56                   	push   %esi
 232:	53                   	push   %ebx
 233:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 236:	8d 45 10             	lea    0x10(%ebp),%eax
 239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 23c:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 241:	bb 00 00 00 00       	mov    $0x0,%ebx
 246:	eb 12                	jmp    25a <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 248:	89 fa                	mov    %edi,%edx
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	e8 48 ff ff ff       	call   19a <putc>
 252:	eb 05                	jmp    259 <printf+0x2c>
      }
    } else if(state == '%'){
 254:	83 fe 25             	cmp    $0x25,%esi
 257:	74 22                	je     27b <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 259:	43                   	inc    %ebx
 25a:	8b 45 0c             	mov    0xc(%ebp),%eax
 25d:	8a 04 18             	mov    (%eax,%ebx,1),%al
 260:	84 c0                	test   %al,%al
 262:	0f 84 1d 01 00 00    	je     385 <printf+0x158>
    c = fmt[i] & 0xff;
 268:	0f be f8             	movsbl %al,%edi
 26b:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 26e:	85 f6                	test   %esi,%esi
 270:	75 e2                	jne    254 <printf+0x27>
      if(c == '%'){
 272:	83 f8 25             	cmp    $0x25,%eax
 275:	75 d1                	jne    248 <printf+0x1b>
        state = '%';
 277:	89 c6                	mov    %eax,%esi
 279:	eb de                	jmp    259 <printf+0x2c>
      if(c == 'd'){
 27b:	83 f8 25             	cmp    $0x25,%eax
 27e:	0f 84 cc 00 00 00    	je     350 <printf+0x123>
 284:	0f 8c da 00 00 00    	jl     364 <printf+0x137>
 28a:	83 f8 78             	cmp    $0x78,%eax
 28d:	0f 8f d1 00 00 00    	jg     364 <printf+0x137>
 293:	83 f8 63             	cmp    $0x63,%eax
 296:	0f 8c c8 00 00 00    	jl     364 <printf+0x137>
 29c:	83 e8 63             	sub    $0x63,%eax
 29f:	83 f8 15             	cmp    $0x15,%eax
 2a2:	0f 87 bc 00 00 00    	ja     364 <printf+0x137>
 2a8:	ff 24 85 ac 04 00 00 	jmp    *0x4ac(,%eax,4)
        printint(fd, *ap, 10, 1);
 2af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2b2:	8b 17                	mov    (%edi),%edx
 2b4:	83 ec 0c             	sub    $0xc,%esp
 2b7:	6a 01                	push   $0x1
 2b9:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2be:	8b 45 08             	mov    0x8(%ebp),%eax
 2c1:	e8 ee fe ff ff       	call   1b4 <printint>
        ap++;
 2c6:	83 c7 04             	add    $0x4,%edi
 2c9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2cc:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2cf:	be 00 00 00 00       	mov    $0x0,%esi
 2d4:	eb 83                	jmp    259 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 2d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2d9:	8b 17                	mov    (%edi),%edx
 2db:	83 ec 0c             	sub    $0xc,%esp
 2de:	6a 00                	push   $0x0
 2e0:	b9 10 00 00 00       	mov    $0x10,%ecx
 2e5:	8b 45 08             	mov    0x8(%ebp),%eax
 2e8:	e8 c7 fe ff ff       	call   1b4 <printint>
        ap++;
 2ed:	83 c7 04             	add    $0x4,%edi
 2f0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2f3:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2f6:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 2fb:	e9 59 ff ff ff       	jmp    259 <printf+0x2c>
        s = (char*)*ap;
 300:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 303:	8b 30                	mov    (%eax),%esi
        ap++;
 305:	83 c0 04             	add    $0x4,%eax
 308:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 30b:	85 f6                	test   %esi,%esi
 30d:	75 13                	jne    322 <printf+0xf5>
          s = "(null)";
 30f:	be a2 04 00 00       	mov    $0x4a2,%esi
 314:	eb 0c                	jmp    322 <printf+0xf5>
          putc(fd, *s);
 316:	0f be d2             	movsbl %dl,%edx
 319:	8b 45 08             	mov    0x8(%ebp),%eax
 31c:	e8 79 fe ff ff       	call   19a <putc>
          s++;
 321:	46                   	inc    %esi
        while(*s != 0){
 322:	8a 16                	mov    (%esi),%dl
 324:	84 d2                	test   %dl,%dl
 326:	75 ee                	jne    316 <printf+0xe9>
      state = 0;
 328:	be 00 00 00 00       	mov    $0x0,%esi
 32d:	e9 27 ff ff ff       	jmp    259 <printf+0x2c>
        putc(fd, *ap);
 332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 335:	0f be 17             	movsbl (%edi),%edx
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	e8 5a fe ff ff       	call   19a <putc>
        ap++;
 340:	83 c7 04             	add    $0x4,%edi
 343:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 346:	be 00 00 00 00       	mov    $0x0,%esi
 34b:	e9 09 ff ff ff       	jmp    259 <printf+0x2c>
        putc(fd, c);
 350:	89 fa                	mov    %edi,%edx
 352:	8b 45 08             	mov    0x8(%ebp),%eax
 355:	e8 40 fe ff ff       	call   19a <putc>
      state = 0;
 35a:	be 00 00 00 00       	mov    $0x0,%esi
 35f:	e9 f5 fe ff ff       	jmp    259 <printf+0x2c>
        putc(fd, '%');
 364:	ba 25 00 00 00       	mov    $0x25,%edx
 369:	8b 45 08             	mov    0x8(%ebp),%eax
 36c:	e8 29 fe ff ff       	call   19a <putc>
        putc(fd, c);
 371:	89 fa                	mov    %edi,%edx
 373:	8b 45 08             	mov    0x8(%ebp),%eax
 376:	e8 1f fe ff ff       	call   19a <putc>
      state = 0;
 37b:	be 00 00 00 00       	mov    $0x0,%esi
 380:	e9 d4 fe ff ff       	jmp    259 <printf+0x2c>
    }
  }
}
 385:	8d 65 f4             	lea    -0xc(%ebp),%esp
 388:	5b                   	pop    %ebx
 389:	5e                   	pop    %esi
 38a:	5f                   	pop    %edi
 38b:	5d                   	pop    %ebp
 38c:	c3                   	ret    
