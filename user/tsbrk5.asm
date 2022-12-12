
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
   9:	e8 4a 01 00 00       	call   158 <sbrk>
   e:	89 c3                	mov    %eax,%ebx

  printf (1, "Debe fallar ahora por acceso mayor sz:\n");
  10:	83 c4 08             	add    $0x8,%esp
  13:	68 74 03 00 00       	push   $0x374
  18:	6a 01                	push   $0x1
  1a:	e8 f4 01 00 00       	call   213 <printf>
  *(a+1) = 1;  // Debe fallar
  1f:	c6 43 01 01          	movb   $0x1,0x1(%ebx)
  printf (2, "Ha accedido a más del sz\n");
  23:	83 c4 08             	add    $0x8,%esp
  26:	68 32 04 00 00       	push   $0x432
  2b:	6a 02                	push   $0x2
  2d:	e8 e1 01 00 00       	call   213 <printf>
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
  40:	68 9c 03 00 00       	push   $0x39c
  45:	6a 01                	push   $0x1
  47:	e8 c7 01 00 00       	call   213 <printf>
  char* a = (char*)((int)&i + 4095);
  printf (1, "0x%x\n", a);
  4c:	83 c4 0c             	add    $0xc,%esp
  4f:	68 17 16 00 00       	push   $0x1617
  54:	68 4d 04 00 00       	push   $0x44d
  59:	6a 01                	push   $0x1
  5b:	e8 b3 01 00 00       	call   213 <printf>
  *a = 1;//Esta instrucción debe fallar
  60:	c6 05 17 16 00 00 01 	movb   $0x1,0x1617
  printf(1,"Página de guarda accedida\n");
  67:	83 c4 08             	add    $0x8,%esp
  6a:	68 53 04 00 00       	push   $0x453
  6f:	6a 01                	push   $0x1
  71:	e8 9d 01 00 00       	call   213 <printf>
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
  81:	68 e8 03 00 00       	push   $0x3e8
  86:	6a 01                	push   $0x1
  88:	e8 86 01 00 00       	call   213 <printf>
  char* a = (char*)0x80000001;
  *(a+1) = 1;  // Debe fallar (si lo anterior no ha fallado)
  8d:	c6 05 02 00 00 80 01 	movb   $0x1,0x80000002
  printf(1, "Ha accedido al kernel\n");
  94:	83 c4 08             	add    $0x8,%esp
  97:	68 6f 04 00 00       	push   $0x46f
  9c:	6a 01                	push   $0x1
  9e:	e8 70 01 00 00       	call   213 <printf>
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

  // Acceso Página Guarda
  //test2();

  // Acceso Núcleo
  test3();
  b9:	e8 bd ff ff ff       	call   7b <test3>

  exit (0);
  be:	83 ec 0c             	sub    $0xc,%esp
  c1:	6a 00                	push   $0x0
  c3:	e8 08 00 00 00       	call   d0 <exit>

000000c8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  c8:	b8 01 00 00 00       	mov    $0x1,%eax
  cd:	cd 40                	int    $0x40
  cf:	c3                   	ret    

000000d0 <exit>:
SYSCALL(exit)
  d0:	b8 02 00 00 00       	mov    $0x2,%eax
  d5:	cd 40                	int    $0x40
  d7:	c3                   	ret    

000000d8 <wait>:
SYSCALL(wait)
  d8:	b8 03 00 00 00       	mov    $0x3,%eax
  dd:	cd 40                	int    $0x40
  df:	c3                   	ret    

000000e0 <pipe>:
SYSCALL(pipe)
  e0:	b8 04 00 00 00       	mov    $0x4,%eax
  e5:	cd 40                	int    $0x40
  e7:	c3                   	ret    

000000e8 <read>:
SYSCALL(read)
  e8:	b8 05 00 00 00       	mov    $0x5,%eax
  ed:	cd 40                	int    $0x40
  ef:	c3                   	ret    

000000f0 <write>:
SYSCALL(write)
  f0:	b8 10 00 00 00       	mov    $0x10,%eax
  f5:	cd 40                	int    $0x40
  f7:	c3                   	ret    

000000f8 <close>:
SYSCALL(close)
  f8:	b8 15 00 00 00       	mov    $0x15,%eax
  fd:	cd 40                	int    $0x40
  ff:	c3                   	ret    

00000100 <kill>:
SYSCALL(kill)
 100:	b8 06 00 00 00       	mov    $0x6,%eax
 105:	cd 40                	int    $0x40
 107:	c3                   	ret    

00000108 <exec>:
SYSCALL(exec)
 108:	b8 07 00 00 00       	mov    $0x7,%eax
 10d:	cd 40                	int    $0x40
 10f:	c3                   	ret    

00000110 <open>:
SYSCALL(open)
 110:	b8 0f 00 00 00       	mov    $0xf,%eax
 115:	cd 40                	int    $0x40
 117:	c3                   	ret    

00000118 <mknod>:
SYSCALL(mknod)
 118:	b8 11 00 00 00       	mov    $0x11,%eax
 11d:	cd 40                	int    $0x40
 11f:	c3                   	ret    

00000120 <unlink>:
SYSCALL(unlink)
 120:	b8 12 00 00 00       	mov    $0x12,%eax
 125:	cd 40                	int    $0x40
 127:	c3                   	ret    

00000128 <fstat>:
SYSCALL(fstat)
 128:	b8 08 00 00 00       	mov    $0x8,%eax
 12d:	cd 40                	int    $0x40
 12f:	c3                   	ret    

00000130 <link>:
SYSCALL(link)
 130:	b8 13 00 00 00       	mov    $0x13,%eax
 135:	cd 40                	int    $0x40
 137:	c3                   	ret    

00000138 <mkdir>:
SYSCALL(mkdir)
 138:	b8 14 00 00 00       	mov    $0x14,%eax
 13d:	cd 40                	int    $0x40
 13f:	c3                   	ret    

00000140 <chdir>:
SYSCALL(chdir)
 140:	b8 09 00 00 00       	mov    $0x9,%eax
 145:	cd 40                	int    $0x40
 147:	c3                   	ret    

00000148 <dup>:
SYSCALL(dup)
 148:	b8 0a 00 00 00       	mov    $0xa,%eax
 14d:	cd 40                	int    $0x40
 14f:	c3                   	ret    

00000150 <getpid>:
SYSCALL(getpid)
 150:	b8 0b 00 00 00       	mov    $0xb,%eax
 155:	cd 40                	int    $0x40
 157:	c3                   	ret    

00000158 <sbrk>:
SYSCALL(sbrk)
 158:	b8 0c 00 00 00       	mov    $0xc,%eax
 15d:	cd 40                	int    $0x40
 15f:	c3                   	ret    

00000160 <sleep>:
SYSCALL(sleep)
 160:	b8 0d 00 00 00       	mov    $0xd,%eax
 165:	cd 40                	int    $0x40
 167:	c3                   	ret    

00000168 <uptime>:
SYSCALL(uptime)
 168:	b8 0e 00 00 00       	mov    $0xe,%eax
 16d:	cd 40                	int    $0x40
 16f:	c3                   	ret    

00000170 <date>:
SYSCALL(date)
 170:	b8 16 00 00 00       	mov    $0x16,%eax
 175:	cd 40                	int    $0x40
 177:	c3                   	ret    

00000178 <dup2>:
SYSCALL(dup2)
 178:	b8 17 00 00 00       	mov    $0x17,%eax
 17d:	cd 40                	int    $0x40
 17f:	c3                   	ret    

00000180 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	83 ec 1c             	sub    $0x1c,%esp
 186:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 189:	6a 01                	push   $0x1
 18b:	8d 55 f4             	lea    -0xc(%ebp),%edx
 18e:	52                   	push   %edx
 18f:	50                   	push   %eax
 190:	e8 5b ff ff ff       	call   f0 <write>
}
 195:	83 c4 10             	add    $0x10,%esp
 198:	c9                   	leave  
 199:	c3                   	ret    

0000019a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 19a:	55                   	push   %ebp
 19b:	89 e5                	mov    %esp,%ebp
 19d:	57                   	push   %edi
 19e:	56                   	push   %esi
 19f:	53                   	push   %ebx
 1a0:	83 ec 2c             	sub    $0x2c,%esp
 1a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 1a6:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1a8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1ac:	74 04                	je     1b2 <printint+0x18>
 1ae:	85 d2                	test   %edx,%edx
 1b0:	78 3c                	js     1ee <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 1b2:	89 d1                	mov    %edx,%ecx
  neg = 0;
 1b4:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 1bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 1c0:	89 c8                	mov    %ecx,%eax
 1c2:	ba 00 00 00 00       	mov    $0x0,%edx
 1c7:	f7 f6                	div    %esi
 1c9:	89 df                	mov    %ebx,%edi
 1cb:	43                   	inc    %ebx
 1cc:	8a 92 e8 04 00 00    	mov    0x4e8(%edx),%dl
 1d2:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1d6:	89 ca                	mov    %ecx,%edx
 1d8:	89 c1                	mov    %eax,%ecx
 1da:	39 d6                	cmp    %edx,%esi
 1dc:	76 e2                	jbe    1c0 <printint+0x26>
  if(neg)
 1de:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 1e2:	74 24                	je     208 <printint+0x6e>
    buf[i++] = '-';
 1e4:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1e9:	8d 5f 02             	lea    0x2(%edi),%ebx
 1ec:	eb 1a                	jmp    208 <printint+0x6e>
    x = -xx;
 1ee:	89 d1                	mov    %edx,%ecx
 1f0:	f7 d9                	neg    %ecx
    neg = 1;
 1f2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 1f9:	eb c0                	jmp    1bb <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 1fb:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 200:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 203:	e8 78 ff ff ff       	call   180 <putc>
  while(--i >= 0)
 208:	4b                   	dec    %ebx
 209:	79 f0                	jns    1fb <printint+0x61>
}
 20b:	83 c4 2c             	add    $0x2c,%esp
 20e:	5b                   	pop    %ebx
 20f:	5e                   	pop    %esi
 210:	5f                   	pop    %edi
 211:	5d                   	pop    %ebp
 212:	c3                   	ret    

00000213 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 213:	55                   	push   %ebp
 214:	89 e5                	mov    %esp,%ebp
 216:	57                   	push   %edi
 217:	56                   	push   %esi
 218:	53                   	push   %ebx
 219:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 21c:	8d 45 10             	lea    0x10(%ebp),%eax
 21f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 222:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 227:	bb 00 00 00 00       	mov    $0x0,%ebx
 22c:	eb 12                	jmp    240 <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 22e:	89 fa                	mov    %edi,%edx
 230:	8b 45 08             	mov    0x8(%ebp),%eax
 233:	e8 48 ff ff ff       	call   180 <putc>
 238:	eb 05                	jmp    23f <printf+0x2c>
      }
    } else if(state == '%'){
 23a:	83 fe 25             	cmp    $0x25,%esi
 23d:	74 22                	je     261 <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 23f:	43                   	inc    %ebx
 240:	8b 45 0c             	mov    0xc(%ebp),%eax
 243:	8a 04 18             	mov    (%eax,%ebx,1),%al
 246:	84 c0                	test   %al,%al
 248:	0f 84 1d 01 00 00    	je     36b <printf+0x158>
    c = fmt[i] & 0xff;
 24e:	0f be f8             	movsbl %al,%edi
 251:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 254:	85 f6                	test   %esi,%esi
 256:	75 e2                	jne    23a <printf+0x27>
      if(c == '%'){
 258:	83 f8 25             	cmp    $0x25,%eax
 25b:	75 d1                	jne    22e <printf+0x1b>
        state = '%';
 25d:	89 c6                	mov    %eax,%esi
 25f:	eb de                	jmp    23f <printf+0x2c>
      if(c == 'd'){
 261:	83 f8 25             	cmp    $0x25,%eax
 264:	0f 84 cc 00 00 00    	je     336 <printf+0x123>
 26a:	0f 8c da 00 00 00    	jl     34a <printf+0x137>
 270:	83 f8 78             	cmp    $0x78,%eax
 273:	0f 8f d1 00 00 00    	jg     34a <printf+0x137>
 279:	83 f8 63             	cmp    $0x63,%eax
 27c:	0f 8c c8 00 00 00    	jl     34a <printf+0x137>
 282:	83 e8 63             	sub    $0x63,%eax
 285:	83 f8 15             	cmp    $0x15,%eax
 288:	0f 87 bc 00 00 00    	ja     34a <printf+0x137>
 28e:	ff 24 85 90 04 00 00 	jmp    *0x490(,%eax,4)
        printint(fd, *ap, 10, 1);
 295:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 298:	8b 17                	mov    (%edi),%edx
 29a:	83 ec 0c             	sub    $0xc,%esp
 29d:	6a 01                	push   $0x1
 29f:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2a4:	8b 45 08             	mov    0x8(%ebp),%eax
 2a7:	e8 ee fe ff ff       	call   19a <printint>
        ap++;
 2ac:	83 c7 04             	add    $0x4,%edi
 2af:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2b2:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2b5:	be 00 00 00 00       	mov    $0x0,%esi
 2ba:	eb 83                	jmp    23f <printf+0x2c>
        printint(fd, *ap, 16, 0);
 2bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2bf:	8b 17                	mov    (%edi),%edx
 2c1:	83 ec 0c             	sub    $0xc,%esp
 2c4:	6a 00                	push   $0x0
 2c6:	b9 10 00 00 00       	mov    $0x10,%ecx
 2cb:	8b 45 08             	mov    0x8(%ebp),%eax
 2ce:	e8 c7 fe ff ff       	call   19a <printint>
        ap++;
 2d3:	83 c7 04             	add    $0x4,%edi
 2d6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2d9:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2dc:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 2e1:	e9 59 ff ff ff       	jmp    23f <printf+0x2c>
        s = (char*)*ap;
 2e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2e9:	8b 30                	mov    (%eax),%esi
        ap++;
 2eb:	83 c0 04             	add    $0x4,%eax
 2ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2f1:	85 f6                	test   %esi,%esi
 2f3:	75 13                	jne    308 <printf+0xf5>
          s = "(null)";
 2f5:	be 86 04 00 00       	mov    $0x486,%esi
 2fa:	eb 0c                	jmp    308 <printf+0xf5>
          putc(fd, *s);
 2fc:	0f be d2             	movsbl %dl,%edx
 2ff:	8b 45 08             	mov    0x8(%ebp),%eax
 302:	e8 79 fe ff ff       	call   180 <putc>
          s++;
 307:	46                   	inc    %esi
        while(*s != 0){
 308:	8a 16                	mov    (%esi),%dl
 30a:	84 d2                	test   %dl,%dl
 30c:	75 ee                	jne    2fc <printf+0xe9>
      state = 0;
 30e:	be 00 00 00 00       	mov    $0x0,%esi
 313:	e9 27 ff ff ff       	jmp    23f <printf+0x2c>
        putc(fd, *ap);
 318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 31b:	0f be 17             	movsbl (%edi),%edx
 31e:	8b 45 08             	mov    0x8(%ebp),%eax
 321:	e8 5a fe ff ff       	call   180 <putc>
        ap++;
 326:	83 c7 04             	add    $0x4,%edi
 329:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 32c:	be 00 00 00 00       	mov    $0x0,%esi
 331:	e9 09 ff ff ff       	jmp    23f <printf+0x2c>
        putc(fd, c);
 336:	89 fa                	mov    %edi,%edx
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	e8 40 fe ff ff       	call   180 <putc>
      state = 0;
 340:	be 00 00 00 00       	mov    $0x0,%esi
 345:	e9 f5 fe ff ff       	jmp    23f <printf+0x2c>
        putc(fd, '%');
 34a:	ba 25 00 00 00       	mov    $0x25,%edx
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
 352:	e8 29 fe ff ff       	call   180 <putc>
        putc(fd, c);
 357:	89 fa                	mov    %edi,%edx
 359:	8b 45 08             	mov    0x8(%ebp),%eax
 35c:	e8 1f fe ff ff       	call   180 <putc>
      state = 0;
 361:	be 00 00 00 00       	mov    $0x0,%esi
 366:	e9 d4 fe ff ff       	jmp    23f <printf+0x2c>
    }
  }
}
 36b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 36e:	5b                   	pop    %ebx
 36f:	5e                   	pop    %esi
 370:	5f                   	pop    %edi
 371:	5d                   	pop    %ebp
 372:	c3                   	ret    
