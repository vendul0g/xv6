
tsbrk2:     file format elf32-i386


Disassembly of section .text:

00000000 <recursive>:
#include "user.h"

char a[4096] = {0};

int recursive(int v)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 1c             	sub    $0x1c,%esp
  printf (1, ".");
   7:	68 40 03 00 00       	push   $0x340
   c:	6a 01                	push   $0x1
   e:	e8 cd 01 00 00       	call   1e0 <printf>
  volatile int q = v;
  13:	8b 45 08             	mov    0x8(%ebp),%eax
  16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (q > 0)
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	83 c4 10             	add    $0x10,%esp
  1f:	85 c0                	test   %eax,%eax
  21:	7f 0a                	jg     2d <recursive+0x2d>
    return recursive (q+1)+recursive (q+2);
  return 0;
  23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  2b:	c9                   	leave  
  2c:	c3                   	ret    
    return recursive (q+1)+recursive (q+2);
  2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  30:	83 ec 0c             	sub    $0xc,%esp
  33:	40                   	inc    %eax
  34:	50                   	push   %eax
  35:	e8 c6 ff ff ff       	call   0 <recursive>
  3a:	89 c3                	mov    %eax,%ebx
  3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3f:	83 c0 02             	add    $0x2,%eax
  42:	89 04 24             	mov    %eax,(%esp)
  45:	e8 b6 ff ff ff       	call   0 <recursive>
  4a:	01 d8                	add    %ebx,%eax
  4c:	83 c4 10             	add    $0x10,%esp
  4f:	eb d7                	jmp    28 <recursive+0x28>

00000051 <main>:


int
main(int argc, char *argv[])
{
  51:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  55:	83 e4 f0             	and    $0xfffffff0,%esp
  58:	ff 71 fc             	push   -0x4(%ecx)
  5b:	55                   	push   %ebp
  5c:	89 e5                	mov    %esp,%ebp
  5e:	51                   	push   %ecx
  5f:	83 ec 10             	sub    $0x10,%esp
  int i = 1;

  // Llamar recursivamente a recursive
  printf (1, ": %d\n", recursive (i));
  62:	6a 01                	push   $0x1
  64:	e8 97 ff ff ff       	call   0 <recursive>
  69:	83 c4 0c             	add    $0xc,%esp
  6c:	50                   	push   %eax
  6d:	68 42 03 00 00       	push   $0x342
  72:	6a 01                	push   $0x1
  74:	e8 67 01 00 00       	call   1e0 <printf>

  exit(0);
  79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80:	e8 08 00 00 00       	call   8d <exit>

00000085 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  85:	b8 01 00 00 00       	mov    $0x1,%eax
  8a:	cd 40                	int    $0x40
  8c:	c3                   	ret    

0000008d <exit>:
SYSCALL(exit)
  8d:	b8 02 00 00 00       	mov    $0x2,%eax
  92:	cd 40                	int    $0x40
  94:	c3                   	ret    

00000095 <wait>:
SYSCALL(wait)
  95:	b8 03 00 00 00       	mov    $0x3,%eax
  9a:	cd 40                	int    $0x40
  9c:	c3                   	ret    

0000009d <pipe>:
SYSCALL(pipe)
  9d:	b8 04 00 00 00       	mov    $0x4,%eax
  a2:	cd 40                	int    $0x40
  a4:	c3                   	ret    

000000a5 <read>:
SYSCALL(read)
  a5:	b8 05 00 00 00       	mov    $0x5,%eax
  aa:	cd 40                	int    $0x40
  ac:	c3                   	ret    

000000ad <write>:
SYSCALL(write)
  ad:	b8 10 00 00 00       	mov    $0x10,%eax
  b2:	cd 40                	int    $0x40
  b4:	c3                   	ret    

000000b5 <close>:
SYSCALL(close)
  b5:	b8 15 00 00 00       	mov    $0x15,%eax
  ba:	cd 40                	int    $0x40
  bc:	c3                   	ret    

000000bd <kill>:
SYSCALL(kill)
  bd:	b8 06 00 00 00       	mov    $0x6,%eax
  c2:	cd 40                	int    $0x40
  c4:	c3                   	ret    

000000c5 <exec>:
SYSCALL(exec)
  c5:	b8 07 00 00 00       	mov    $0x7,%eax
  ca:	cd 40                	int    $0x40
  cc:	c3                   	ret    

000000cd <open>:
SYSCALL(open)
  cd:	b8 0f 00 00 00       	mov    $0xf,%eax
  d2:	cd 40                	int    $0x40
  d4:	c3                   	ret    

000000d5 <mknod>:
SYSCALL(mknod)
  d5:	b8 11 00 00 00       	mov    $0x11,%eax
  da:	cd 40                	int    $0x40
  dc:	c3                   	ret    

000000dd <unlink>:
SYSCALL(unlink)
  dd:	b8 12 00 00 00       	mov    $0x12,%eax
  e2:	cd 40                	int    $0x40
  e4:	c3                   	ret    

000000e5 <fstat>:
SYSCALL(fstat)
  e5:	b8 08 00 00 00       	mov    $0x8,%eax
  ea:	cd 40                	int    $0x40
  ec:	c3                   	ret    

000000ed <link>:
SYSCALL(link)
  ed:	b8 13 00 00 00       	mov    $0x13,%eax
  f2:	cd 40                	int    $0x40
  f4:	c3                   	ret    

000000f5 <mkdir>:
SYSCALL(mkdir)
  f5:	b8 14 00 00 00       	mov    $0x14,%eax
  fa:	cd 40                	int    $0x40
  fc:	c3                   	ret    

000000fd <chdir>:
SYSCALL(chdir)
  fd:	b8 09 00 00 00       	mov    $0x9,%eax
 102:	cd 40                	int    $0x40
 104:	c3                   	ret    

00000105 <dup>:
SYSCALL(dup)
 105:	b8 0a 00 00 00       	mov    $0xa,%eax
 10a:	cd 40                	int    $0x40
 10c:	c3                   	ret    

0000010d <getpid>:
SYSCALL(getpid)
 10d:	b8 0b 00 00 00       	mov    $0xb,%eax
 112:	cd 40                	int    $0x40
 114:	c3                   	ret    

00000115 <sbrk>:
SYSCALL(sbrk)
 115:	b8 0c 00 00 00       	mov    $0xc,%eax
 11a:	cd 40                	int    $0x40
 11c:	c3                   	ret    

0000011d <sleep>:
SYSCALL(sleep)
 11d:	b8 0d 00 00 00       	mov    $0xd,%eax
 122:	cd 40                	int    $0x40
 124:	c3                   	ret    

00000125 <uptime>:
SYSCALL(uptime)
 125:	b8 0e 00 00 00       	mov    $0xe,%eax
 12a:	cd 40                	int    $0x40
 12c:	c3                   	ret    

0000012d <date>:
SYSCALL(date)
 12d:	b8 16 00 00 00       	mov    $0x16,%eax
 132:	cd 40                	int    $0x40
 134:	c3                   	ret    

00000135 <dup2>:
SYSCALL(dup2)
 135:	b8 17 00 00 00       	mov    $0x17,%eax
 13a:	cd 40                	int    $0x40
 13c:	c3                   	ret    

0000013d <getprio>:
SYSCALL(getprio)
 13d:	b8 18 00 00 00       	mov    $0x18,%eax
 142:	cd 40                	int    $0x40
 144:	c3                   	ret    

00000145 <setprio>:
SYSCALL(setprio)
 145:	b8 19 00 00 00       	mov    $0x19,%eax
 14a:	cd 40                	int    $0x40
 14c:	c3                   	ret    

0000014d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 14d:	55                   	push   %ebp
 14e:	89 e5                	mov    %esp,%ebp
 150:	83 ec 1c             	sub    $0x1c,%esp
 153:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 156:	6a 01                	push   $0x1
 158:	8d 55 f4             	lea    -0xc(%ebp),%edx
 15b:	52                   	push   %edx
 15c:	50                   	push   %eax
 15d:	e8 4b ff ff ff       	call   ad <write>
}
 162:	83 c4 10             	add    $0x10,%esp
 165:	c9                   	leave  
 166:	c3                   	ret    

00000167 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 167:	55                   	push   %ebp
 168:	89 e5                	mov    %esp,%ebp
 16a:	57                   	push   %edi
 16b:	56                   	push   %esi
 16c:	53                   	push   %ebx
 16d:	83 ec 2c             	sub    $0x2c,%esp
 170:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 173:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 175:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 179:	74 04                	je     17f <printint+0x18>
 17b:	85 d2                	test   %edx,%edx
 17d:	78 3c                	js     1bb <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 17f:	89 d1                	mov    %edx,%ecx
  neg = 0;
 181:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 188:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 18d:	89 c8                	mov    %ecx,%eax
 18f:	ba 00 00 00 00       	mov    $0x0,%edx
 194:	f7 f6                	div    %esi
 196:	89 df                	mov    %ebx,%edi
 198:	43                   	inc    %ebx
 199:	8a 92 a8 03 00 00    	mov    0x3a8(%edx),%dl
 19f:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1a3:	89 ca                	mov    %ecx,%edx
 1a5:	89 c1                	mov    %eax,%ecx
 1a7:	39 d6                	cmp    %edx,%esi
 1a9:	76 e2                	jbe    18d <printint+0x26>
  if(neg)
 1ab:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 1af:	74 24                	je     1d5 <printint+0x6e>
    buf[i++] = '-';
 1b1:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1b6:	8d 5f 02             	lea    0x2(%edi),%ebx
 1b9:	eb 1a                	jmp    1d5 <printint+0x6e>
    x = -xx;
 1bb:	89 d1                	mov    %edx,%ecx
 1bd:	f7 d9                	neg    %ecx
    neg = 1;
 1bf:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 1c6:	eb c0                	jmp    188 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 1c8:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1d0:	e8 78 ff ff ff       	call   14d <putc>
  while(--i >= 0)
 1d5:	4b                   	dec    %ebx
 1d6:	79 f0                	jns    1c8 <printint+0x61>
}
 1d8:	83 c4 2c             	add    $0x2c,%esp
 1db:	5b                   	pop    %ebx
 1dc:	5e                   	pop    %esi
 1dd:	5f                   	pop    %edi
 1de:	5d                   	pop    %ebp
 1df:	c3                   	ret    

000001e0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
 1e3:	57                   	push   %edi
 1e4:	56                   	push   %esi
 1e5:	53                   	push   %ebx
 1e6:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1e9:	8d 45 10             	lea    0x10(%ebp),%eax
 1ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1ef:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1f4:	bb 00 00 00 00       	mov    $0x0,%ebx
 1f9:	eb 12                	jmp    20d <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1fb:	89 fa                	mov    %edi,%edx
 1fd:	8b 45 08             	mov    0x8(%ebp),%eax
 200:	e8 48 ff ff ff       	call   14d <putc>
 205:	eb 05                	jmp    20c <printf+0x2c>
      }
    } else if(state == '%'){
 207:	83 fe 25             	cmp    $0x25,%esi
 20a:	74 22                	je     22e <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 20c:	43                   	inc    %ebx
 20d:	8b 45 0c             	mov    0xc(%ebp),%eax
 210:	8a 04 18             	mov    (%eax,%ebx,1),%al
 213:	84 c0                	test   %al,%al
 215:	0f 84 1d 01 00 00    	je     338 <printf+0x158>
    c = fmt[i] & 0xff;
 21b:	0f be f8             	movsbl %al,%edi
 21e:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 221:	85 f6                	test   %esi,%esi
 223:	75 e2                	jne    207 <printf+0x27>
      if(c == '%'){
 225:	83 f8 25             	cmp    $0x25,%eax
 228:	75 d1                	jne    1fb <printf+0x1b>
        state = '%';
 22a:	89 c6                	mov    %eax,%esi
 22c:	eb de                	jmp    20c <printf+0x2c>
      if(c == 'd'){
 22e:	83 f8 25             	cmp    $0x25,%eax
 231:	0f 84 cc 00 00 00    	je     303 <printf+0x123>
 237:	0f 8c da 00 00 00    	jl     317 <printf+0x137>
 23d:	83 f8 78             	cmp    $0x78,%eax
 240:	0f 8f d1 00 00 00    	jg     317 <printf+0x137>
 246:	83 f8 63             	cmp    $0x63,%eax
 249:	0f 8c c8 00 00 00    	jl     317 <printf+0x137>
 24f:	83 e8 63             	sub    $0x63,%eax
 252:	83 f8 15             	cmp    $0x15,%eax
 255:	0f 87 bc 00 00 00    	ja     317 <printf+0x137>
 25b:	ff 24 85 50 03 00 00 	jmp    *0x350(,%eax,4)
        printint(fd, *ap, 10, 1);
 262:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 265:	8b 17                	mov    (%edi),%edx
 267:	83 ec 0c             	sub    $0xc,%esp
 26a:	6a 01                	push   $0x1
 26c:	b9 0a 00 00 00       	mov    $0xa,%ecx
 271:	8b 45 08             	mov    0x8(%ebp),%eax
 274:	e8 ee fe ff ff       	call   167 <printint>
        ap++;
 279:	83 c7 04             	add    $0x4,%edi
 27c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 27f:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 282:	be 00 00 00 00       	mov    $0x0,%esi
 287:	eb 83                	jmp    20c <printf+0x2c>
        printint(fd, *ap, 16, 0);
 289:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 28c:	8b 17                	mov    (%edi),%edx
 28e:	83 ec 0c             	sub    $0xc,%esp
 291:	6a 00                	push   $0x0
 293:	b9 10 00 00 00       	mov    $0x10,%ecx
 298:	8b 45 08             	mov    0x8(%ebp),%eax
 29b:	e8 c7 fe ff ff       	call   167 <printint>
        ap++;
 2a0:	83 c7 04             	add    $0x4,%edi
 2a3:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2a6:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2a9:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 2ae:	e9 59 ff ff ff       	jmp    20c <printf+0x2c>
        s = (char*)*ap;
 2b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2b6:	8b 30                	mov    (%eax),%esi
        ap++;
 2b8:	83 c0 04             	add    $0x4,%eax
 2bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2be:	85 f6                	test   %esi,%esi
 2c0:	75 13                	jne    2d5 <printf+0xf5>
          s = "(null)";
 2c2:	be 48 03 00 00       	mov    $0x348,%esi
 2c7:	eb 0c                	jmp    2d5 <printf+0xf5>
          putc(fd, *s);
 2c9:	0f be d2             	movsbl %dl,%edx
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
 2cf:	e8 79 fe ff ff       	call   14d <putc>
          s++;
 2d4:	46                   	inc    %esi
        while(*s != 0){
 2d5:	8a 16                	mov    (%esi),%dl
 2d7:	84 d2                	test   %dl,%dl
 2d9:	75 ee                	jne    2c9 <printf+0xe9>
      state = 0;
 2db:	be 00 00 00 00       	mov    $0x0,%esi
 2e0:	e9 27 ff ff ff       	jmp    20c <printf+0x2c>
        putc(fd, *ap);
 2e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2e8:	0f be 17             	movsbl (%edi),%edx
 2eb:	8b 45 08             	mov    0x8(%ebp),%eax
 2ee:	e8 5a fe ff ff       	call   14d <putc>
        ap++;
 2f3:	83 c7 04             	add    $0x4,%edi
 2f6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2f9:	be 00 00 00 00       	mov    $0x0,%esi
 2fe:	e9 09 ff ff ff       	jmp    20c <printf+0x2c>
        putc(fd, c);
 303:	89 fa                	mov    %edi,%edx
 305:	8b 45 08             	mov    0x8(%ebp),%eax
 308:	e8 40 fe ff ff       	call   14d <putc>
      state = 0;
 30d:	be 00 00 00 00       	mov    $0x0,%esi
 312:	e9 f5 fe ff ff       	jmp    20c <printf+0x2c>
        putc(fd, '%');
 317:	ba 25 00 00 00       	mov    $0x25,%edx
 31c:	8b 45 08             	mov    0x8(%ebp),%eax
 31f:	e8 29 fe ff ff       	call   14d <putc>
        putc(fd, c);
 324:	89 fa                	mov    %edi,%edx
 326:	8b 45 08             	mov    0x8(%ebp),%eax
 329:	e8 1f fe ff ff       	call   14d <putc>
      state = 0;
 32e:	be 00 00 00 00       	mov    $0x0,%esi
 333:	e9 d4 fe ff ff       	jmp    20c <printf+0x2c>
    }
  }
}
 338:	8d 65 f4             	lea    -0xc(%ebp),%esp
 33b:	5b                   	pop    %ebx
 33c:	5e                   	pop    %esi
 33d:	5f                   	pop    %edi
 33e:	5d                   	pop    %ebp
 33f:	c3                   	ret    
