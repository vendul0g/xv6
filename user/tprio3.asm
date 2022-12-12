
tprio3:     file format elf32-i386


Disassembly of section .text:

00000000 <do_calc>:
#include "types.h"
#include "user.h"

void
do_calc (char* nombre)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 04             	sub    $0x4,%esp
  int r = 0;

  for (int i = 0; i < 2000; ++i)
   7:	bb 00 00 00 00       	mov    $0x0,%ebx
  int r = 0;
   c:	ba 00 00 00 00       	mov    $0x0,%edx
  for (int i = 0; i < 2000; ++i)
  11:	eb 0e                	jmp    21 <do_calc+0x21>
    for (int j = 0; j < 1000000; ++j)
      r += i + j;
  13:	8d 0c 03             	lea    (%ebx,%eax,1),%ecx
  16:	01 ca                	add    %ecx,%edx
    for (int j = 0; j < 1000000; ++j)
  18:	40                   	inc    %eax
  19:	3d 3f 42 0f 00       	cmp    $0xf423f,%eax
  1e:	7e f3                	jle    13 <do_calc+0x13>
  for (int i = 0; i < 2000; ++i)
  20:	43                   	inc    %ebx
  21:	81 fb cf 07 00 00    	cmp    $0x7cf,%ebx
  27:	7f 07                	jg     30 <do_calc+0x30>
    for (int j = 0; j < 1000000; ++j)
  29:	b8 00 00 00 00       	mov    $0x0,%eax
  2e:	eb e9                	jmp    19 <do_calc+0x19>

  // Imprime el resultado
  printf (1, "%s: %d\n", nombre, r);
  30:	52                   	push   %edx
  31:	ff 75 08             	push   0x8(%ebp)
  34:	68 68 03 00 00       	push   $0x368
  39:	6a 01                	push   $0x1
  3b:	e8 c8 01 00 00       	call   208 <printf>
}
  40:	83 c4 10             	add    $0x10,%esp
  43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  46:	c9                   	leave  
  47:	c3                   	ret    

00000048 <main>:


int
main(int argc, char *argv[])
{
  48:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  4c:	83 e4 f0             	and    $0xfffffff0,%esp
  4f:	ff 71 fc             	push   -0x4(%ecx)
  52:	55                   	push   %ebp
  53:	89 e5                	mov    %esp,%ebp
  55:	51                   	push   %ecx
  56:	83 ec 04             	sub    $0x4,%esp
  // El proceso se inicia en baja prioridad.
  // Genera otro proceso hijo que a su vez genera dos
  if (fork() == 0)
  59:	e8 4f 00 00 00       	call   ad <fork>
  5e:	85 c0                	test   %eax,%eax
  60:	75 1e                	jne    80 <main+0x38>
  {
    fork();  // Ambos ejecutan:
  62:	e8 46 00 00 00       	call   ad <fork>
    do_calc("Low");
  67:	83 ec 0c             	sub    $0xc,%esp
  6a:	68 70 03 00 00       	push   $0x370
  6f:	e8 8c ff ff ff       	call   0 <do_calc>
    exit(1);
  74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7b:	e8 35 00 00 00       	call   b5 <exit>
  }

  // Establecer máxima prioridad. Debe hacer que el shell ni aparezca hasta
  // que termine
  setprio (getpid(), HI_PRIO);
  80:	e8 b0 00 00 00       	call   135 <getpid>
  85:	83 ec 08             	sub    $0x8,%esp
  88:	6a 01                	push   $0x1
  8a:	50                   	push   %eax
  8b:	e8 dd 00 00 00       	call   16d <setprio>

  fork();  // Ambos ejecutan:
  90:	e8 18 00 00 00       	call   ad <fork>
  do_calc("Hi");
  95:	c7 04 24 74 03 00 00 	movl   $0x374,(%esp)
  9c:	e8 5f ff ff ff       	call   0 <do_calc>
  exit(0);
  a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  a8:	e8 08 00 00 00       	call   b5 <exit>

000000ad <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  ad:	b8 01 00 00 00       	mov    $0x1,%eax
  b2:	cd 40                	int    $0x40
  b4:	c3                   	ret    

000000b5 <exit>:
SYSCALL(exit)
  b5:	b8 02 00 00 00       	mov    $0x2,%eax
  ba:	cd 40                	int    $0x40
  bc:	c3                   	ret    

000000bd <wait>:
SYSCALL(wait)
  bd:	b8 03 00 00 00       	mov    $0x3,%eax
  c2:	cd 40                	int    $0x40
  c4:	c3                   	ret    

000000c5 <pipe>:
SYSCALL(pipe)
  c5:	b8 04 00 00 00       	mov    $0x4,%eax
  ca:	cd 40                	int    $0x40
  cc:	c3                   	ret    

000000cd <read>:
SYSCALL(read)
  cd:	b8 05 00 00 00       	mov    $0x5,%eax
  d2:	cd 40                	int    $0x40
  d4:	c3                   	ret    

000000d5 <write>:
SYSCALL(write)
  d5:	b8 10 00 00 00       	mov    $0x10,%eax
  da:	cd 40                	int    $0x40
  dc:	c3                   	ret    

000000dd <close>:
SYSCALL(close)
  dd:	b8 15 00 00 00       	mov    $0x15,%eax
  e2:	cd 40                	int    $0x40
  e4:	c3                   	ret    

000000e5 <kill>:
SYSCALL(kill)
  e5:	b8 06 00 00 00       	mov    $0x6,%eax
  ea:	cd 40                	int    $0x40
  ec:	c3                   	ret    

000000ed <exec>:
SYSCALL(exec)
  ed:	b8 07 00 00 00       	mov    $0x7,%eax
  f2:	cd 40                	int    $0x40
  f4:	c3                   	ret    

000000f5 <open>:
SYSCALL(open)
  f5:	b8 0f 00 00 00       	mov    $0xf,%eax
  fa:	cd 40                	int    $0x40
  fc:	c3                   	ret    

000000fd <mknod>:
SYSCALL(mknod)
  fd:	b8 11 00 00 00       	mov    $0x11,%eax
 102:	cd 40                	int    $0x40
 104:	c3                   	ret    

00000105 <unlink>:
SYSCALL(unlink)
 105:	b8 12 00 00 00       	mov    $0x12,%eax
 10a:	cd 40                	int    $0x40
 10c:	c3                   	ret    

0000010d <fstat>:
SYSCALL(fstat)
 10d:	b8 08 00 00 00       	mov    $0x8,%eax
 112:	cd 40                	int    $0x40
 114:	c3                   	ret    

00000115 <link>:
SYSCALL(link)
 115:	b8 13 00 00 00       	mov    $0x13,%eax
 11a:	cd 40                	int    $0x40
 11c:	c3                   	ret    

0000011d <mkdir>:
SYSCALL(mkdir)
 11d:	b8 14 00 00 00       	mov    $0x14,%eax
 122:	cd 40                	int    $0x40
 124:	c3                   	ret    

00000125 <chdir>:
SYSCALL(chdir)
 125:	b8 09 00 00 00       	mov    $0x9,%eax
 12a:	cd 40                	int    $0x40
 12c:	c3                   	ret    

0000012d <dup>:
SYSCALL(dup)
 12d:	b8 0a 00 00 00       	mov    $0xa,%eax
 132:	cd 40                	int    $0x40
 134:	c3                   	ret    

00000135 <getpid>:
SYSCALL(getpid)
 135:	b8 0b 00 00 00       	mov    $0xb,%eax
 13a:	cd 40                	int    $0x40
 13c:	c3                   	ret    

0000013d <sbrk>:
SYSCALL(sbrk)
 13d:	b8 0c 00 00 00       	mov    $0xc,%eax
 142:	cd 40                	int    $0x40
 144:	c3                   	ret    

00000145 <sleep>:
SYSCALL(sleep)
 145:	b8 0d 00 00 00       	mov    $0xd,%eax
 14a:	cd 40                	int    $0x40
 14c:	c3                   	ret    

0000014d <uptime>:
SYSCALL(uptime)
 14d:	b8 0e 00 00 00       	mov    $0xe,%eax
 152:	cd 40                	int    $0x40
 154:	c3                   	ret    

00000155 <date>:
SYSCALL(date)
 155:	b8 16 00 00 00       	mov    $0x16,%eax
 15a:	cd 40                	int    $0x40
 15c:	c3                   	ret    

0000015d <dup2>:
SYSCALL(dup2)
 15d:	b8 17 00 00 00       	mov    $0x17,%eax
 162:	cd 40                	int    $0x40
 164:	c3                   	ret    

00000165 <getprio>:
SYSCALL(getprio)
 165:	b8 18 00 00 00       	mov    $0x18,%eax
 16a:	cd 40                	int    $0x40
 16c:	c3                   	ret    

0000016d <setprio>:
SYSCALL(setprio)
 16d:	b8 19 00 00 00       	mov    $0x19,%eax
 172:	cd 40                	int    $0x40
 174:	c3                   	ret    

00000175 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 175:	55                   	push   %ebp
 176:	89 e5                	mov    %esp,%ebp
 178:	83 ec 1c             	sub    $0x1c,%esp
 17b:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 17e:	6a 01                	push   $0x1
 180:	8d 55 f4             	lea    -0xc(%ebp),%edx
 183:	52                   	push   %edx
 184:	50                   	push   %eax
 185:	e8 4b ff ff ff       	call   d5 <write>
}
 18a:	83 c4 10             	add    $0x10,%esp
 18d:	c9                   	leave  
 18e:	c3                   	ret    

0000018f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 18f:	55                   	push   %ebp
 190:	89 e5                	mov    %esp,%ebp
 192:	57                   	push   %edi
 193:	56                   	push   %esi
 194:	53                   	push   %ebx
 195:	83 ec 2c             	sub    $0x2c,%esp
 198:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 19b:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 19d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1a1:	74 04                	je     1a7 <printint+0x18>
 1a3:	85 d2                	test   %edx,%edx
 1a5:	78 3c                	js     1e3 <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 1a7:	89 d1                	mov    %edx,%ecx
  neg = 0;
 1a9:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 1b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 1b5:	89 c8                	mov    %ecx,%eax
 1b7:	ba 00 00 00 00       	mov    $0x0,%edx
 1bc:	f7 f6                	div    %esi
 1be:	89 df                	mov    %ebx,%edi
 1c0:	43                   	inc    %ebx
 1c1:	8a 92 d8 03 00 00    	mov    0x3d8(%edx),%dl
 1c7:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1cb:	89 ca                	mov    %ecx,%edx
 1cd:	89 c1                	mov    %eax,%ecx
 1cf:	39 d6                	cmp    %edx,%esi
 1d1:	76 e2                	jbe    1b5 <printint+0x26>
  if(neg)
 1d3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 1d7:	74 24                	je     1fd <printint+0x6e>
    buf[i++] = '-';
 1d9:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1de:	8d 5f 02             	lea    0x2(%edi),%ebx
 1e1:	eb 1a                	jmp    1fd <printint+0x6e>
    x = -xx;
 1e3:	89 d1                	mov    %edx,%ecx
 1e5:	f7 d9                	neg    %ecx
    neg = 1;
 1e7:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 1ee:	eb c0                	jmp    1b0 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 1f0:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1f8:	e8 78 ff ff ff       	call   175 <putc>
  while(--i >= 0)
 1fd:	4b                   	dec    %ebx
 1fe:	79 f0                	jns    1f0 <printint+0x61>
}
 200:	83 c4 2c             	add    $0x2c,%esp
 203:	5b                   	pop    %ebx
 204:	5e                   	pop    %esi
 205:	5f                   	pop    %edi
 206:	5d                   	pop    %ebp
 207:	c3                   	ret    

00000208 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 208:	55                   	push   %ebp
 209:	89 e5                	mov    %esp,%ebp
 20b:	57                   	push   %edi
 20c:	56                   	push   %esi
 20d:	53                   	push   %ebx
 20e:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 211:	8d 45 10             	lea    0x10(%ebp),%eax
 214:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 217:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 21c:	bb 00 00 00 00       	mov    $0x0,%ebx
 221:	eb 12                	jmp    235 <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 223:	89 fa                	mov    %edi,%edx
 225:	8b 45 08             	mov    0x8(%ebp),%eax
 228:	e8 48 ff ff ff       	call   175 <putc>
 22d:	eb 05                	jmp    234 <printf+0x2c>
      }
    } else if(state == '%'){
 22f:	83 fe 25             	cmp    $0x25,%esi
 232:	74 22                	je     256 <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 234:	43                   	inc    %ebx
 235:	8b 45 0c             	mov    0xc(%ebp),%eax
 238:	8a 04 18             	mov    (%eax,%ebx,1),%al
 23b:	84 c0                	test   %al,%al
 23d:	0f 84 1d 01 00 00    	je     360 <printf+0x158>
    c = fmt[i] & 0xff;
 243:	0f be f8             	movsbl %al,%edi
 246:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 249:	85 f6                	test   %esi,%esi
 24b:	75 e2                	jne    22f <printf+0x27>
      if(c == '%'){
 24d:	83 f8 25             	cmp    $0x25,%eax
 250:	75 d1                	jne    223 <printf+0x1b>
        state = '%';
 252:	89 c6                	mov    %eax,%esi
 254:	eb de                	jmp    234 <printf+0x2c>
      if(c == 'd'){
 256:	83 f8 25             	cmp    $0x25,%eax
 259:	0f 84 cc 00 00 00    	je     32b <printf+0x123>
 25f:	0f 8c da 00 00 00    	jl     33f <printf+0x137>
 265:	83 f8 78             	cmp    $0x78,%eax
 268:	0f 8f d1 00 00 00    	jg     33f <printf+0x137>
 26e:	83 f8 63             	cmp    $0x63,%eax
 271:	0f 8c c8 00 00 00    	jl     33f <printf+0x137>
 277:	83 e8 63             	sub    $0x63,%eax
 27a:	83 f8 15             	cmp    $0x15,%eax
 27d:	0f 87 bc 00 00 00    	ja     33f <printf+0x137>
 283:	ff 24 85 80 03 00 00 	jmp    *0x380(,%eax,4)
        printint(fd, *ap, 10, 1);
 28a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 28d:	8b 17                	mov    (%edi),%edx
 28f:	83 ec 0c             	sub    $0xc,%esp
 292:	6a 01                	push   $0x1
 294:	b9 0a 00 00 00       	mov    $0xa,%ecx
 299:	8b 45 08             	mov    0x8(%ebp),%eax
 29c:	e8 ee fe ff ff       	call   18f <printint>
        ap++;
 2a1:	83 c7 04             	add    $0x4,%edi
 2a4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2a7:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2aa:	be 00 00 00 00       	mov    $0x0,%esi
 2af:	eb 83                	jmp    234 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 2b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2b4:	8b 17                	mov    (%edi),%edx
 2b6:	83 ec 0c             	sub    $0xc,%esp
 2b9:	6a 00                	push   $0x0
 2bb:	b9 10 00 00 00       	mov    $0x10,%ecx
 2c0:	8b 45 08             	mov    0x8(%ebp),%eax
 2c3:	e8 c7 fe ff ff       	call   18f <printint>
        ap++;
 2c8:	83 c7 04             	add    $0x4,%edi
 2cb:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2ce:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2d1:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 2d6:	e9 59 ff ff ff       	jmp    234 <printf+0x2c>
        s = (char*)*ap;
 2db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2de:	8b 30                	mov    (%eax),%esi
        ap++;
 2e0:	83 c0 04             	add    $0x4,%eax
 2e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2e6:	85 f6                	test   %esi,%esi
 2e8:	75 13                	jne    2fd <printf+0xf5>
          s = "(null)";
 2ea:	be 77 03 00 00       	mov    $0x377,%esi
 2ef:	eb 0c                	jmp    2fd <printf+0xf5>
          putc(fd, *s);
 2f1:	0f be d2             	movsbl %dl,%edx
 2f4:	8b 45 08             	mov    0x8(%ebp),%eax
 2f7:	e8 79 fe ff ff       	call   175 <putc>
          s++;
 2fc:	46                   	inc    %esi
        while(*s != 0){
 2fd:	8a 16                	mov    (%esi),%dl
 2ff:	84 d2                	test   %dl,%dl
 301:	75 ee                	jne    2f1 <printf+0xe9>
      state = 0;
 303:	be 00 00 00 00       	mov    $0x0,%esi
 308:	e9 27 ff ff ff       	jmp    234 <printf+0x2c>
        putc(fd, *ap);
 30d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 310:	0f be 17             	movsbl (%edi),%edx
 313:	8b 45 08             	mov    0x8(%ebp),%eax
 316:	e8 5a fe ff ff       	call   175 <putc>
        ap++;
 31b:	83 c7 04             	add    $0x4,%edi
 31e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 321:	be 00 00 00 00       	mov    $0x0,%esi
 326:	e9 09 ff ff ff       	jmp    234 <printf+0x2c>
        putc(fd, c);
 32b:	89 fa                	mov    %edi,%edx
 32d:	8b 45 08             	mov    0x8(%ebp),%eax
 330:	e8 40 fe ff ff       	call   175 <putc>
      state = 0;
 335:	be 00 00 00 00       	mov    $0x0,%esi
 33a:	e9 f5 fe ff ff       	jmp    234 <printf+0x2c>
        putc(fd, '%');
 33f:	ba 25 00 00 00       	mov    $0x25,%edx
 344:	8b 45 08             	mov    0x8(%ebp),%eax
 347:	e8 29 fe ff ff       	call   175 <putc>
        putc(fd, c);
 34c:	89 fa                	mov    %edi,%edx
 34e:	8b 45 08             	mov    0x8(%ebp),%eax
 351:	e8 1f fe ff ff       	call   175 <putc>
      state = 0;
 356:	be 00 00 00 00       	mov    $0x0,%esi
 35b:	e9 d4 fe ff ff       	jmp    234 <printf+0x2c>
    }
  }
}
 360:	8d 65 f4             	lea    -0xc(%ebp),%esp
 363:	5b                   	pop    %ebx
 364:	5e                   	pop    %esi
 365:	5f                   	pop    %edi
 366:	5d                   	pop    %ebp
 367:	c3                   	ret    
