
tsbrk1:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	56                   	push   %esi
   e:	53                   	push   %ebx
   f:	51                   	push   %ecx
  10:	83 ec 18             	sub    $0x18,%esp
  char* a = sbrk (15000);
  13:	68 98 3a 00 00       	push   $0x3a98
  18:	e8 4b 01 00 00       	call   168 <sbrk>
  1d:	89 c3                	mov    %eax,%ebx

  a[500] = 1;
  1f:	c6 80 f4 01 00 00 01 	movb   $0x1,0x1f4(%eax)

  if ((uint)a + 15000 != (uint) sbrk (-15000))
  26:	8d b0 98 3a 00 00    	lea    0x3a98(%eax),%esi
  2c:	c7 04 24 68 c5 ff ff 	movl   $0xffffc568,(%esp)
  33:	e8 30 01 00 00       	call   168 <sbrk>
  38:	83 c4 10             	add    $0x10,%esp
  3b:	39 c6                	cmp    %eax,%esi
  3d:	74 1b                	je     5a <main+0x5a>
  {
    printf (1, "sbrk() con número positivo falló.\n");
  3f:	83 ec 08             	sub    $0x8,%esp
  42:	68 84 03 00 00       	push   $0x384
  47:	6a 01                	push   $0x1
  49:	e8 d5 01 00 00       	call   223 <printf>
    exit(1);
  4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  55:	e8 86 00 00 00       	call   e0 <exit>
  }

  if (a != sbrk (0))
  5a:	83 ec 0c             	sub    $0xc,%esp
  5d:	6a 00                	push   $0x0
  5f:	e8 04 01 00 00       	call   168 <sbrk>
  64:	83 c4 10             	add    $0x10,%esp
  67:	39 c3                	cmp    %eax,%ebx
  69:	74 1b                	je     86 <main+0x86>
  {
    printf (1, "sbrk() con cero falló.\n");
  6b:	83 ec 08             	sub    $0x8,%esp
  6e:	68 a9 03 00 00       	push   $0x3a9
  73:	6a 01                	push   $0x1
  75:	e8 a9 01 00 00       	call   223 <printf>
    exit(2);
  7a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  81:	e8 5a 00 00 00       	call   e0 <exit>
  }

  if (a != sbrk (15000))
  86:	83 ec 0c             	sub    $0xc,%esp
  89:	68 98 3a 00 00       	push   $0x3a98
  8e:	e8 d5 00 00 00       	call   168 <sbrk>
  93:	83 c4 10             	add    $0x10,%esp
  96:	39 c3                	cmp    %eax,%ebx
  98:	74 1b                	je     b5 <main+0xb5>
  {
    printf (1, "sbrk() negativo falló.\n");
  9a:	83 ec 08             	sub    $0x8,%esp
  9d:	68 c2 03 00 00       	push   $0x3c2
  a2:	6a 01                	push   $0x1
  a4:	e8 7a 01 00 00       	call   223 <printf>
    exit(3);
  a9:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  b0:	e8 2b 00 00 00       	call   e0 <exit>
  }

  printf (1, "Debe imprimir 1: %d.\n", a[500]);//++a[500]. Como va a funcionar si le suma 1
  b5:	83 ec 04             	sub    $0x4,%esp
  b8:	0f be 83 f4 01 00 00 	movsbl 0x1f4(%ebx),%eax
  bf:	50                   	push   %eax
  c0:	68 db 03 00 00       	push   $0x3db
  c5:	6a 01                	push   $0x1
  c7:	e8 57 01 00 00       	call   223 <printf>

  exit(0);
  cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  d3:	e8 08 00 00 00       	call   e0 <exit>

000000d8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  d8:	b8 01 00 00 00       	mov    $0x1,%eax
  dd:	cd 40                	int    $0x40
  df:	c3                   	ret    

000000e0 <exit>:
SYSCALL(exit)
  e0:	b8 02 00 00 00       	mov    $0x2,%eax
  e5:	cd 40                	int    $0x40
  e7:	c3                   	ret    

000000e8 <wait>:
SYSCALL(wait)
  e8:	b8 03 00 00 00       	mov    $0x3,%eax
  ed:	cd 40                	int    $0x40
  ef:	c3                   	ret    

000000f0 <pipe>:
SYSCALL(pipe)
  f0:	b8 04 00 00 00       	mov    $0x4,%eax
  f5:	cd 40                	int    $0x40
  f7:	c3                   	ret    

000000f8 <read>:
SYSCALL(read)
  f8:	b8 05 00 00 00       	mov    $0x5,%eax
  fd:	cd 40                	int    $0x40
  ff:	c3                   	ret    

00000100 <write>:
SYSCALL(write)
 100:	b8 10 00 00 00       	mov    $0x10,%eax
 105:	cd 40                	int    $0x40
 107:	c3                   	ret    

00000108 <close>:
SYSCALL(close)
 108:	b8 15 00 00 00       	mov    $0x15,%eax
 10d:	cd 40                	int    $0x40
 10f:	c3                   	ret    

00000110 <kill>:
SYSCALL(kill)
 110:	b8 06 00 00 00       	mov    $0x6,%eax
 115:	cd 40                	int    $0x40
 117:	c3                   	ret    

00000118 <exec>:
SYSCALL(exec)
 118:	b8 07 00 00 00       	mov    $0x7,%eax
 11d:	cd 40                	int    $0x40
 11f:	c3                   	ret    

00000120 <open>:
SYSCALL(open)
 120:	b8 0f 00 00 00       	mov    $0xf,%eax
 125:	cd 40                	int    $0x40
 127:	c3                   	ret    

00000128 <mknod>:
SYSCALL(mknod)
 128:	b8 11 00 00 00       	mov    $0x11,%eax
 12d:	cd 40                	int    $0x40
 12f:	c3                   	ret    

00000130 <unlink>:
SYSCALL(unlink)
 130:	b8 12 00 00 00       	mov    $0x12,%eax
 135:	cd 40                	int    $0x40
 137:	c3                   	ret    

00000138 <fstat>:
SYSCALL(fstat)
 138:	b8 08 00 00 00       	mov    $0x8,%eax
 13d:	cd 40                	int    $0x40
 13f:	c3                   	ret    

00000140 <link>:
SYSCALL(link)
 140:	b8 13 00 00 00       	mov    $0x13,%eax
 145:	cd 40                	int    $0x40
 147:	c3                   	ret    

00000148 <mkdir>:
SYSCALL(mkdir)
 148:	b8 14 00 00 00       	mov    $0x14,%eax
 14d:	cd 40                	int    $0x40
 14f:	c3                   	ret    

00000150 <chdir>:
SYSCALL(chdir)
 150:	b8 09 00 00 00       	mov    $0x9,%eax
 155:	cd 40                	int    $0x40
 157:	c3                   	ret    

00000158 <dup>:
SYSCALL(dup)
 158:	b8 0a 00 00 00       	mov    $0xa,%eax
 15d:	cd 40                	int    $0x40
 15f:	c3                   	ret    

00000160 <getpid>:
SYSCALL(getpid)
 160:	b8 0b 00 00 00       	mov    $0xb,%eax
 165:	cd 40                	int    $0x40
 167:	c3                   	ret    

00000168 <sbrk>:
SYSCALL(sbrk)
 168:	b8 0c 00 00 00       	mov    $0xc,%eax
 16d:	cd 40                	int    $0x40
 16f:	c3                   	ret    

00000170 <sleep>:
SYSCALL(sleep)
 170:	b8 0d 00 00 00       	mov    $0xd,%eax
 175:	cd 40                	int    $0x40
 177:	c3                   	ret    

00000178 <uptime>:
SYSCALL(uptime)
 178:	b8 0e 00 00 00       	mov    $0xe,%eax
 17d:	cd 40                	int    $0x40
 17f:	c3                   	ret    

00000180 <date>:
SYSCALL(date)
 180:	b8 16 00 00 00       	mov    $0x16,%eax
 185:	cd 40                	int    $0x40
 187:	c3                   	ret    

00000188 <dup2>:
SYSCALL(dup2)
 188:	b8 17 00 00 00       	mov    $0x17,%eax
 18d:	cd 40                	int    $0x40
 18f:	c3                   	ret    

00000190 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	83 ec 1c             	sub    $0x1c,%esp
 196:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 199:	6a 01                	push   $0x1
 19b:	8d 55 f4             	lea    -0xc(%ebp),%edx
 19e:	52                   	push   %edx
 19f:	50                   	push   %eax
 1a0:	e8 5b ff ff ff       	call   100 <write>
}
 1a5:	83 c4 10             	add    $0x10,%esp
 1a8:	c9                   	leave  
 1a9:	c3                   	ret    

000001aa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 1aa:	55                   	push   %ebp
 1ab:	89 e5                	mov    %esp,%ebp
 1ad:	57                   	push   %edi
 1ae:	56                   	push   %esi
 1af:	53                   	push   %ebx
 1b0:	83 ec 2c             	sub    $0x2c,%esp
 1b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 1b6:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1b8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1bc:	74 04                	je     1c2 <printint+0x18>
 1be:	85 d2                	test   %edx,%edx
 1c0:	78 3c                	js     1fe <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 1c2:	89 d1                	mov    %edx,%ecx
  neg = 0;
 1c4:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 1cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 1d0:	89 c8                	mov    %ecx,%eax
 1d2:	ba 00 00 00 00       	mov    $0x0,%edx
 1d7:	f7 f6                	div    %esi
 1d9:	89 df                	mov    %ebx,%edi
 1db:	43                   	inc    %ebx
 1dc:	8a 92 50 04 00 00    	mov    0x450(%edx),%dl
 1e2:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1e6:	89 ca                	mov    %ecx,%edx
 1e8:	89 c1                	mov    %eax,%ecx
 1ea:	39 d6                	cmp    %edx,%esi
 1ec:	76 e2                	jbe    1d0 <printint+0x26>
  if(neg)
 1ee:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 1f2:	74 24                	je     218 <printint+0x6e>
    buf[i++] = '-';
 1f4:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1f9:	8d 5f 02             	lea    0x2(%edi),%ebx
 1fc:	eb 1a                	jmp    218 <printint+0x6e>
    x = -xx;
 1fe:	89 d1                	mov    %edx,%ecx
 200:	f7 d9                	neg    %ecx
    neg = 1;
 202:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 209:	eb c0                	jmp    1cb <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 20b:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 210:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 213:	e8 78 ff ff ff       	call   190 <putc>
  while(--i >= 0)
 218:	4b                   	dec    %ebx
 219:	79 f0                	jns    20b <printint+0x61>
}
 21b:	83 c4 2c             	add    $0x2c,%esp
 21e:	5b                   	pop    %ebx
 21f:	5e                   	pop    %esi
 220:	5f                   	pop    %edi
 221:	5d                   	pop    %ebp
 222:	c3                   	ret    

00000223 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 223:	55                   	push   %ebp
 224:	89 e5                	mov    %esp,%ebp
 226:	57                   	push   %edi
 227:	56                   	push   %esi
 228:	53                   	push   %ebx
 229:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 22c:	8d 45 10             	lea    0x10(%ebp),%eax
 22f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 232:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 237:	bb 00 00 00 00       	mov    $0x0,%ebx
 23c:	eb 12                	jmp    250 <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 23e:	89 fa                	mov    %edi,%edx
 240:	8b 45 08             	mov    0x8(%ebp),%eax
 243:	e8 48 ff ff ff       	call   190 <putc>
 248:	eb 05                	jmp    24f <printf+0x2c>
      }
    } else if(state == '%'){
 24a:	83 fe 25             	cmp    $0x25,%esi
 24d:	74 22                	je     271 <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 24f:	43                   	inc    %ebx
 250:	8b 45 0c             	mov    0xc(%ebp),%eax
 253:	8a 04 18             	mov    (%eax,%ebx,1),%al
 256:	84 c0                	test   %al,%al
 258:	0f 84 1d 01 00 00    	je     37b <printf+0x158>
    c = fmt[i] & 0xff;
 25e:	0f be f8             	movsbl %al,%edi
 261:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 264:	85 f6                	test   %esi,%esi
 266:	75 e2                	jne    24a <printf+0x27>
      if(c == '%'){
 268:	83 f8 25             	cmp    $0x25,%eax
 26b:	75 d1                	jne    23e <printf+0x1b>
        state = '%';
 26d:	89 c6                	mov    %eax,%esi
 26f:	eb de                	jmp    24f <printf+0x2c>
      if(c == 'd'){
 271:	83 f8 25             	cmp    $0x25,%eax
 274:	0f 84 cc 00 00 00    	je     346 <printf+0x123>
 27a:	0f 8c da 00 00 00    	jl     35a <printf+0x137>
 280:	83 f8 78             	cmp    $0x78,%eax
 283:	0f 8f d1 00 00 00    	jg     35a <printf+0x137>
 289:	83 f8 63             	cmp    $0x63,%eax
 28c:	0f 8c c8 00 00 00    	jl     35a <printf+0x137>
 292:	83 e8 63             	sub    $0x63,%eax
 295:	83 f8 15             	cmp    $0x15,%eax
 298:	0f 87 bc 00 00 00    	ja     35a <printf+0x137>
 29e:	ff 24 85 f8 03 00 00 	jmp    *0x3f8(,%eax,4)
        printint(fd, *ap, 10, 1);
 2a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2a8:	8b 17                	mov    (%edi),%edx
 2aa:	83 ec 0c             	sub    $0xc,%esp
 2ad:	6a 01                	push   $0x1
 2af:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2b4:	8b 45 08             	mov    0x8(%ebp),%eax
 2b7:	e8 ee fe ff ff       	call   1aa <printint>
        ap++;
 2bc:	83 c7 04             	add    $0x4,%edi
 2bf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2c2:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2c5:	be 00 00 00 00       	mov    $0x0,%esi
 2ca:	eb 83                	jmp    24f <printf+0x2c>
        printint(fd, *ap, 16, 0);
 2cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2cf:	8b 17                	mov    (%edi),%edx
 2d1:	83 ec 0c             	sub    $0xc,%esp
 2d4:	6a 00                	push   $0x0
 2d6:	b9 10 00 00 00       	mov    $0x10,%ecx
 2db:	8b 45 08             	mov    0x8(%ebp),%eax
 2de:	e8 c7 fe ff ff       	call   1aa <printint>
        ap++;
 2e3:	83 c7 04             	add    $0x4,%edi
 2e6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2e9:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2ec:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 2f1:	e9 59 ff ff ff       	jmp    24f <printf+0x2c>
        s = (char*)*ap;
 2f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2f9:	8b 30                	mov    (%eax),%esi
        ap++;
 2fb:	83 c0 04             	add    $0x4,%eax
 2fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 301:	85 f6                	test   %esi,%esi
 303:	75 13                	jne    318 <printf+0xf5>
          s = "(null)";
 305:	be f1 03 00 00       	mov    $0x3f1,%esi
 30a:	eb 0c                	jmp    318 <printf+0xf5>
          putc(fd, *s);
 30c:	0f be d2             	movsbl %dl,%edx
 30f:	8b 45 08             	mov    0x8(%ebp),%eax
 312:	e8 79 fe ff ff       	call   190 <putc>
          s++;
 317:	46                   	inc    %esi
        while(*s != 0){
 318:	8a 16                	mov    (%esi),%dl
 31a:	84 d2                	test   %dl,%dl
 31c:	75 ee                	jne    30c <printf+0xe9>
      state = 0;
 31e:	be 00 00 00 00       	mov    $0x0,%esi
 323:	e9 27 ff ff ff       	jmp    24f <printf+0x2c>
        putc(fd, *ap);
 328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 32b:	0f be 17             	movsbl (%edi),%edx
 32e:	8b 45 08             	mov    0x8(%ebp),%eax
 331:	e8 5a fe ff ff       	call   190 <putc>
        ap++;
 336:	83 c7 04             	add    $0x4,%edi
 339:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 33c:	be 00 00 00 00       	mov    $0x0,%esi
 341:	e9 09 ff ff ff       	jmp    24f <printf+0x2c>
        putc(fd, c);
 346:	89 fa                	mov    %edi,%edx
 348:	8b 45 08             	mov    0x8(%ebp),%eax
 34b:	e8 40 fe ff ff       	call   190 <putc>
      state = 0;
 350:	be 00 00 00 00       	mov    $0x0,%esi
 355:	e9 f5 fe ff ff       	jmp    24f <printf+0x2c>
        putc(fd, '%');
 35a:	ba 25 00 00 00       	mov    $0x25,%edx
 35f:	8b 45 08             	mov    0x8(%ebp),%eax
 362:	e8 29 fe ff ff       	call   190 <putc>
        putc(fd, c);
 367:	89 fa                	mov    %edi,%edx
 369:	8b 45 08             	mov    0x8(%ebp),%eax
 36c:	e8 1f fe ff ff       	call   190 <putc>
      state = 0;
 371:	be 00 00 00 00       	mov    $0x0,%esi
 376:	e9 d4 fe ff ff       	jmp    24f <printf+0x2c>
    }
  }
}
 37b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 37e:	5b                   	pop    %ebx
 37f:	5e                   	pop    %esi
 380:	5f                   	pop    %edi
 381:	5d                   	pop    %ebp
 382:	c3                   	ret    
