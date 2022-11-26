
tsbrk4:     file format elf32-i386


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
  18:	e8 b9 01 00 00       	call   1d6 <sbrk>
  1d:	89 c3                	mov    %eax,%ebx

  fork();
  1f:	e8 22 01 00 00       	call   146 <fork>

  a[500] = 1;
  24:	c6 83 f4 01 00 00 01 	movb   $0x1,0x1f4(%ebx)

  if ((uint)a + 15000 != (uint) sbrk (-15000))
  2b:	8d b3 98 3a 00 00    	lea    0x3a98(%ebx),%esi
  31:	c7 04 24 68 c5 ff ff 	movl   $0xffffc568,(%esp)
  38:	e8 99 01 00 00       	call   1d6 <sbrk>
  3d:	83 c4 10             	add    $0x10,%esp
  40:	39 c6                	cmp    %eax,%esi
  42:	74 1b                	je     5f <main+0x5f>
  {
    printf (1, "sbrk() con número positivo falló.\n");
  44:	83 ec 08             	sub    $0x8,%esp
  47:	68 f4 03 00 00       	push   $0x3f4
  4c:	6a 01                	push   $0x1
  4e:	e8 3e 02 00 00       	call   291 <printf>
    exit(1);
  53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5a:	e8 ef 00 00 00       	call   14e <exit>
  }

  if (a != sbrk (0))
  5f:	83 ec 0c             	sub    $0xc,%esp
  62:	6a 00                	push   $0x0
  64:	e8 6d 01 00 00       	call   1d6 <sbrk>
  69:	83 c4 10             	add    $0x10,%esp
  6c:	39 c3                	cmp    %eax,%ebx
  6e:	74 1b                	je     8b <main+0x8b>
  {
    printf (1, "sbrk() con cero falló.\n");
  70:	83 ec 08             	sub    $0x8,%esp
  73:	68 19 04 00 00       	push   $0x419
  78:	6a 01                	push   $0x1
  7a:	e8 12 02 00 00       	call   291 <printf>
    exit(2);
  7f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  86:	e8 c3 00 00 00       	call   14e <exit>
  }

  if (a != sbrk (15000))
  8b:	83 ec 0c             	sub    $0xc,%esp
  8e:	68 98 3a 00 00       	push   $0x3a98
  93:	e8 3e 01 00 00       	call   1d6 <sbrk>
  98:	83 c4 10             	add    $0x10,%esp
  9b:	39 c3                	cmp    %eax,%ebx
  9d:	74 1b                	je     ba <main+0xba>
  {
    printf (1, "sbrk() negativo falló.\n");
  9f:	83 ec 08             	sub    $0x8,%esp
  a2:	68 32 04 00 00       	push   $0x432
  a7:	6a 01                	push   $0x1
  a9:	e8 e3 01 00 00       	call   291 <printf>
    exit(3);
  ae:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  b5:	e8 94 00 00 00       	call   14e <exit>
  }

  printf (1, "Debe imprimir 1: %d.\n", ++a[500]);
  ba:	8a 83 f4 01 00 00    	mov    0x1f4(%ebx),%al
  c0:	40                   	inc    %eax
  c1:	88 83 f4 01 00 00    	mov    %al,0x1f4(%ebx)
  c7:	83 ec 04             	sub    $0x4,%esp
  ca:	0f be c0             	movsbl %al,%eax
  cd:	50                   	push   %eax
  ce:	68 4b 04 00 00       	push   $0x44b
  d3:	6a 01                	push   $0x1
  d5:	e8 b7 01 00 00       	call   291 <printf>

  a=sbrk (-15000);
  da:	c7 04 24 68 c5 ff ff 	movl   $0xffffc568,(%esp)
  e1:	e8 f0 00 00 00       	call   1d6 <sbrk>

  a=sbrk(1024*4096*2);
  e6:	c7 04 24 00 00 80 00 	movl   $0x800000,(%esp)
  ed:	e8 e4 00 00 00       	call   1d6 <sbrk>
  f2:	89 c3                	mov    %eax,%ebx

  fork();
  f4:	e8 4d 00 00 00       	call   146 <fork>

  a[600*4096*2] = 1;
  f9:	c6 83 00 00 4b 00 01 	movb   $0x1,0x4b0000(%ebx)

  sbrk(-1024*4096*2);
 100:	c7 04 24 00 00 80 ff 	movl   $0xff800000,(%esp)
 107:	e8 ca 00 00 00       	call   1d6 <sbrk>

  a=sbrk(1024*4096*2);
 10c:	c7 04 24 00 00 80 00 	movl   $0x800000,(%esp)
 113:	e8 be 00 00 00       	call   1d6 <sbrk>

  printf (1, "Debe imprimir 1: %d.\n", ++a[600*4096*2]);
 118:	8a 88 00 00 4b 00    	mov    0x4b0000(%eax),%cl
 11e:	8d 51 01             	lea    0x1(%ecx),%edx
 121:	88 90 00 00 4b 00    	mov    %dl,0x4b0000(%eax)
 127:	83 c4 0c             	add    $0xc,%esp
 12a:	0f be d2             	movsbl %dl,%edx
 12d:	52                   	push   %edx
 12e:	68 4b 04 00 00       	push   $0x44b
 133:	6a 01                	push   $0x1
 135:	e8 57 01 00 00       	call   291 <printf>

  exit(0);
 13a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 141:	e8 08 00 00 00       	call   14e <exit>

00000146 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 146:	b8 01 00 00 00       	mov    $0x1,%eax
 14b:	cd 40                	int    $0x40
 14d:	c3                   	ret    

0000014e <exit>:
SYSCALL(exit)
 14e:	b8 02 00 00 00       	mov    $0x2,%eax
 153:	cd 40                	int    $0x40
 155:	c3                   	ret    

00000156 <wait>:
SYSCALL(wait)
 156:	b8 03 00 00 00       	mov    $0x3,%eax
 15b:	cd 40                	int    $0x40
 15d:	c3                   	ret    

0000015e <pipe>:
SYSCALL(pipe)
 15e:	b8 04 00 00 00       	mov    $0x4,%eax
 163:	cd 40                	int    $0x40
 165:	c3                   	ret    

00000166 <read>:
SYSCALL(read)
 166:	b8 05 00 00 00       	mov    $0x5,%eax
 16b:	cd 40                	int    $0x40
 16d:	c3                   	ret    

0000016e <write>:
SYSCALL(write)
 16e:	b8 10 00 00 00       	mov    $0x10,%eax
 173:	cd 40                	int    $0x40
 175:	c3                   	ret    

00000176 <close>:
SYSCALL(close)
 176:	b8 15 00 00 00       	mov    $0x15,%eax
 17b:	cd 40                	int    $0x40
 17d:	c3                   	ret    

0000017e <kill>:
SYSCALL(kill)
 17e:	b8 06 00 00 00       	mov    $0x6,%eax
 183:	cd 40                	int    $0x40
 185:	c3                   	ret    

00000186 <exec>:
SYSCALL(exec)
 186:	b8 07 00 00 00       	mov    $0x7,%eax
 18b:	cd 40                	int    $0x40
 18d:	c3                   	ret    

0000018e <open>:
SYSCALL(open)
 18e:	b8 0f 00 00 00       	mov    $0xf,%eax
 193:	cd 40                	int    $0x40
 195:	c3                   	ret    

00000196 <mknod>:
SYSCALL(mknod)
 196:	b8 11 00 00 00       	mov    $0x11,%eax
 19b:	cd 40                	int    $0x40
 19d:	c3                   	ret    

0000019e <unlink>:
SYSCALL(unlink)
 19e:	b8 12 00 00 00       	mov    $0x12,%eax
 1a3:	cd 40                	int    $0x40
 1a5:	c3                   	ret    

000001a6 <fstat>:
SYSCALL(fstat)
 1a6:	b8 08 00 00 00       	mov    $0x8,%eax
 1ab:	cd 40                	int    $0x40
 1ad:	c3                   	ret    

000001ae <link>:
SYSCALL(link)
 1ae:	b8 13 00 00 00       	mov    $0x13,%eax
 1b3:	cd 40                	int    $0x40
 1b5:	c3                   	ret    

000001b6 <mkdir>:
SYSCALL(mkdir)
 1b6:	b8 14 00 00 00       	mov    $0x14,%eax
 1bb:	cd 40                	int    $0x40
 1bd:	c3                   	ret    

000001be <chdir>:
SYSCALL(chdir)
 1be:	b8 09 00 00 00       	mov    $0x9,%eax
 1c3:	cd 40                	int    $0x40
 1c5:	c3                   	ret    

000001c6 <dup>:
SYSCALL(dup)
 1c6:	b8 0a 00 00 00       	mov    $0xa,%eax
 1cb:	cd 40                	int    $0x40
 1cd:	c3                   	ret    

000001ce <getpid>:
SYSCALL(getpid)
 1ce:	b8 0b 00 00 00       	mov    $0xb,%eax
 1d3:	cd 40                	int    $0x40
 1d5:	c3                   	ret    

000001d6 <sbrk>:
SYSCALL(sbrk)
 1d6:	b8 0c 00 00 00       	mov    $0xc,%eax
 1db:	cd 40                	int    $0x40
 1dd:	c3                   	ret    

000001de <sleep>:
SYSCALL(sleep)
 1de:	b8 0d 00 00 00       	mov    $0xd,%eax
 1e3:	cd 40                	int    $0x40
 1e5:	c3                   	ret    

000001e6 <uptime>:
SYSCALL(uptime)
 1e6:	b8 0e 00 00 00       	mov    $0xe,%eax
 1eb:	cd 40                	int    $0x40
 1ed:	c3                   	ret    

000001ee <date>:
SYSCALL(date)
 1ee:	b8 16 00 00 00       	mov    $0x16,%eax
 1f3:	cd 40                	int    $0x40
 1f5:	c3                   	ret    

000001f6 <dup2>:
SYSCALL(dup2)
 1f6:	b8 17 00 00 00       	mov    $0x17,%eax
 1fb:	cd 40                	int    $0x40
 1fd:	c3                   	ret    

000001fe <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 1fe:	55                   	push   %ebp
 1ff:	89 e5                	mov    %esp,%ebp
 201:	83 ec 1c             	sub    $0x1c,%esp
 204:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 207:	6a 01                	push   $0x1
 209:	8d 55 f4             	lea    -0xc(%ebp),%edx
 20c:	52                   	push   %edx
 20d:	50                   	push   %eax
 20e:	e8 5b ff ff ff       	call   16e <write>
}
 213:	83 c4 10             	add    $0x10,%esp
 216:	c9                   	leave  
 217:	c3                   	ret    

00000218 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 218:	55                   	push   %ebp
 219:	89 e5                	mov    %esp,%ebp
 21b:	57                   	push   %edi
 21c:	56                   	push   %esi
 21d:	53                   	push   %ebx
 21e:	83 ec 2c             	sub    $0x2c,%esp
 221:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 224:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 226:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 22a:	74 04                	je     230 <printint+0x18>
 22c:	85 d2                	test   %edx,%edx
 22e:	78 3c                	js     26c <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 230:	89 d1                	mov    %edx,%ecx
  neg = 0;
 232:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 239:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 23e:	89 c8                	mov    %ecx,%eax
 240:	ba 00 00 00 00       	mov    $0x0,%edx
 245:	f7 f6                	div    %esi
 247:	89 df                	mov    %ebx,%edi
 249:	43                   	inc    %ebx
 24a:	8a 92 c0 04 00 00    	mov    0x4c0(%edx),%dl
 250:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 254:	89 ca                	mov    %ecx,%edx
 256:	89 c1                	mov    %eax,%ecx
 258:	39 d6                	cmp    %edx,%esi
 25a:	76 e2                	jbe    23e <printint+0x26>
  if(neg)
 25c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 260:	74 24                	je     286 <printint+0x6e>
    buf[i++] = '-';
 262:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 267:	8d 5f 02             	lea    0x2(%edi),%ebx
 26a:	eb 1a                	jmp    286 <printint+0x6e>
    x = -xx;
 26c:	89 d1                	mov    %edx,%ecx
 26e:	f7 d9                	neg    %ecx
    neg = 1;
 270:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 277:	eb c0                	jmp    239 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 279:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 27e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 281:	e8 78 ff ff ff       	call   1fe <putc>
  while(--i >= 0)
 286:	4b                   	dec    %ebx
 287:	79 f0                	jns    279 <printint+0x61>
}
 289:	83 c4 2c             	add    $0x2c,%esp
 28c:	5b                   	pop    %ebx
 28d:	5e                   	pop    %esi
 28e:	5f                   	pop    %edi
 28f:	5d                   	pop    %ebp
 290:	c3                   	ret    

00000291 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 291:	55                   	push   %ebp
 292:	89 e5                	mov    %esp,%ebp
 294:	57                   	push   %edi
 295:	56                   	push   %esi
 296:	53                   	push   %ebx
 297:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 29a:	8d 45 10             	lea    0x10(%ebp),%eax
 29d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 2a0:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 2a5:	bb 00 00 00 00       	mov    $0x0,%ebx
 2aa:	eb 12                	jmp    2be <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 2ac:	89 fa                	mov    %edi,%edx
 2ae:	8b 45 08             	mov    0x8(%ebp),%eax
 2b1:	e8 48 ff ff ff       	call   1fe <putc>
 2b6:	eb 05                	jmp    2bd <printf+0x2c>
      }
    } else if(state == '%'){
 2b8:	83 fe 25             	cmp    $0x25,%esi
 2bb:	74 22                	je     2df <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 2bd:	43                   	inc    %ebx
 2be:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c1:	8a 04 18             	mov    (%eax,%ebx,1),%al
 2c4:	84 c0                	test   %al,%al
 2c6:	0f 84 1d 01 00 00    	je     3e9 <printf+0x158>
    c = fmt[i] & 0xff;
 2cc:	0f be f8             	movsbl %al,%edi
 2cf:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 2d2:	85 f6                	test   %esi,%esi
 2d4:	75 e2                	jne    2b8 <printf+0x27>
      if(c == '%'){
 2d6:	83 f8 25             	cmp    $0x25,%eax
 2d9:	75 d1                	jne    2ac <printf+0x1b>
        state = '%';
 2db:	89 c6                	mov    %eax,%esi
 2dd:	eb de                	jmp    2bd <printf+0x2c>
      if(c == 'd'){
 2df:	83 f8 25             	cmp    $0x25,%eax
 2e2:	0f 84 cc 00 00 00    	je     3b4 <printf+0x123>
 2e8:	0f 8c da 00 00 00    	jl     3c8 <printf+0x137>
 2ee:	83 f8 78             	cmp    $0x78,%eax
 2f1:	0f 8f d1 00 00 00    	jg     3c8 <printf+0x137>
 2f7:	83 f8 63             	cmp    $0x63,%eax
 2fa:	0f 8c c8 00 00 00    	jl     3c8 <printf+0x137>
 300:	83 e8 63             	sub    $0x63,%eax
 303:	83 f8 15             	cmp    $0x15,%eax
 306:	0f 87 bc 00 00 00    	ja     3c8 <printf+0x137>
 30c:	ff 24 85 68 04 00 00 	jmp    *0x468(,%eax,4)
        printint(fd, *ap, 10, 1);
 313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 316:	8b 17                	mov    (%edi),%edx
 318:	83 ec 0c             	sub    $0xc,%esp
 31b:	6a 01                	push   $0x1
 31d:	b9 0a 00 00 00       	mov    $0xa,%ecx
 322:	8b 45 08             	mov    0x8(%ebp),%eax
 325:	e8 ee fe ff ff       	call   218 <printint>
        ap++;
 32a:	83 c7 04             	add    $0x4,%edi
 32d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 330:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 333:	be 00 00 00 00       	mov    $0x0,%esi
 338:	eb 83                	jmp    2bd <printf+0x2c>
        printint(fd, *ap, 16, 0);
 33a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 33d:	8b 17                	mov    (%edi),%edx
 33f:	83 ec 0c             	sub    $0xc,%esp
 342:	6a 00                	push   $0x0
 344:	b9 10 00 00 00       	mov    $0x10,%ecx
 349:	8b 45 08             	mov    0x8(%ebp),%eax
 34c:	e8 c7 fe ff ff       	call   218 <printint>
        ap++;
 351:	83 c7 04             	add    $0x4,%edi
 354:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 357:	83 c4 10             	add    $0x10,%esp
      state = 0;
 35a:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 35f:	e9 59 ff ff ff       	jmp    2bd <printf+0x2c>
        s = (char*)*ap;
 364:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 367:	8b 30                	mov    (%eax),%esi
        ap++;
 369:	83 c0 04             	add    $0x4,%eax
 36c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 36f:	85 f6                	test   %esi,%esi
 371:	75 13                	jne    386 <printf+0xf5>
          s = "(null)";
 373:	be 61 04 00 00       	mov    $0x461,%esi
 378:	eb 0c                	jmp    386 <printf+0xf5>
          putc(fd, *s);
 37a:	0f be d2             	movsbl %dl,%edx
 37d:	8b 45 08             	mov    0x8(%ebp),%eax
 380:	e8 79 fe ff ff       	call   1fe <putc>
          s++;
 385:	46                   	inc    %esi
        while(*s != 0){
 386:	8a 16                	mov    (%esi),%dl
 388:	84 d2                	test   %dl,%dl
 38a:	75 ee                	jne    37a <printf+0xe9>
      state = 0;
 38c:	be 00 00 00 00       	mov    $0x0,%esi
 391:	e9 27 ff ff ff       	jmp    2bd <printf+0x2c>
        putc(fd, *ap);
 396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 399:	0f be 17             	movsbl (%edi),%edx
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
 39f:	e8 5a fe ff ff       	call   1fe <putc>
        ap++;
 3a4:	83 c7 04             	add    $0x4,%edi
 3a7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 3aa:	be 00 00 00 00       	mov    $0x0,%esi
 3af:	e9 09 ff ff ff       	jmp    2bd <printf+0x2c>
        putc(fd, c);
 3b4:	89 fa                	mov    %edi,%edx
 3b6:	8b 45 08             	mov    0x8(%ebp),%eax
 3b9:	e8 40 fe ff ff       	call   1fe <putc>
      state = 0;
 3be:	be 00 00 00 00       	mov    $0x0,%esi
 3c3:	e9 f5 fe ff ff       	jmp    2bd <printf+0x2c>
        putc(fd, '%');
 3c8:	ba 25 00 00 00       	mov    $0x25,%edx
 3cd:	8b 45 08             	mov    0x8(%ebp),%eax
 3d0:	e8 29 fe ff ff       	call   1fe <putc>
        putc(fd, c);
 3d5:	89 fa                	mov    %edi,%edx
 3d7:	8b 45 08             	mov    0x8(%ebp),%eax
 3da:	e8 1f fe ff ff       	call   1fe <putc>
      state = 0;
 3df:	be 00 00 00 00       	mov    $0x0,%esi
 3e4:	e9 d4 fe ff ff       	jmp    2bd <printf+0x2c>
    }
  }
}
 3e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3ec:	5b                   	pop    %ebx
 3ed:	5e                   	pop    %esi
 3ee:	5f                   	pop    %edi
 3ef:	5d                   	pop    %ebp
 3f0:	c3                   	ret    
