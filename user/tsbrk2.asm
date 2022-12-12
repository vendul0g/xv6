
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
   7:	68 30 03 00 00       	push   $0x330
   c:	6a 01                	push   $0x1
   e:	e8 bd 01 00 00       	call   1d0 <printf>
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
  6d:	68 32 03 00 00       	push   $0x332
  72:	6a 01                	push   $0x1
  74:	e8 57 01 00 00       	call   1d0 <printf>

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

0000013d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 13d:	55                   	push   %ebp
 13e:	89 e5                	mov    %esp,%ebp
 140:	83 ec 1c             	sub    $0x1c,%esp
 143:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 146:	6a 01                	push   $0x1
 148:	8d 55 f4             	lea    -0xc(%ebp),%edx
 14b:	52                   	push   %edx
 14c:	50                   	push   %eax
 14d:	e8 5b ff ff ff       	call   ad <write>
}
 152:	83 c4 10             	add    $0x10,%esp
 155:	c9                   	leave  
 156:	c3                   	ret    

00000157 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 157:	55                   	push   %ebp
 158:	89 e5                	mov    %esp,%ebp
 15a:	57                   	push   %edi
 15b:	56                   	push   %esi
 15c:	53                   	push   %ebx
 15d:	83 ec 2c             	sub    $0x2c,%esp
 160:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 163:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 165:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 169:	74 04                	je     16f <printint+0x18>
 16b:	85 d2                	test   %edx,%edx
 16d:	78 3c                	js     1ab <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 16f:	89 d1                	mov    %edx,%ecx
  neg = 0;
 171:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 178:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 17d:	89 c8                	mov    %ecx,%eax
 17f:	ba 00 00 00 00       	mov    $0x0,%edx
 184:	f7 f6                	div    %esi
 186:	89 df                	mov    %ebx,%edi
 188:	43                   	inc    %ebx
 189:	8a 92 98 03 00 00    	mov    0x398(%edx),%dl
 18f:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 193:	89 ca                	mov    %ecx,%edx
 195:	89 c1                	mov    %eax,%ecx
 197:	39 d6                	cmp    %edx,%esi
 199:	76 e2                	jbe    17d <printint+0x26>
  if(neg)
 19b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 19f:	74 24                	je     1c5 <printint+0x6e>
    buf[i++] = '-';
 1a1:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1a6:	8d 5f 02             	lea    0x2(%edi),%ebx
 1a9:	eb 1a                	jmp    1c5 <printint+0x6e>
    x = -xx;
 1ab:	89 d1                	mov    %edx,%ecx
 1ad:	f7 d9                	neg    %ecx
    neg = 1;
 1af:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 1b6:	eb c0                	jmp    178 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 1b8:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1c0:	e8 78 ff ff ff       	call   13d <putc>
  while(--i >= 0)
 1c5:	4b                   	dec    %ebx
 1c6:	79 f0                	jns    1b8 <printint+0x61>
}
 1c8:	83 c4 2c             	add    $0x2c,%esp
 1cb:	5b                   	pop    %ebx
 1cc:	5e                   	pop    %esi
 1cd:	5f                   	pop    %edi
 1ce:	5d                   	pop    %ebp
 1cf:	c3                   	ret    

000001d0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1d0:	55                   	push   %ebp
 1d1:	89 e5                	mov    %esp,%ebp
 1d3:	57                   	push   %edi
 1d4:	56                   	push   %esi
 1d5:	53                   	push   %ebx
 1d6:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1d9:	8d 45 10             	lea    0x10(%ebp),%eax
 1dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1df:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1e4:	bb 00 00 00 00       	mov    $0x0,%ebx
 1e9:	eb 12                	jmp    1fd <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1eb:	89 fa                	mov    %edi,%edx
 1ed:	8b 45 08             	mov    0x8(%ebp),%eax
 1f0:	e8 48 ff ff ff       	call   13d <putc>
 1f5:	eb 05                	jmp    1fc <printf+0x2c>
      }
    } else if(state == '%'){
 1f7:	83 fe 25             	cmp    $0x25,%esi
 1fa:	74 22                	je     21e <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 1fc:	43                   	inc    %ebx
 1fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 200:	8a 04 18             	mov    (%eax,%ebx,1),%al
 203:	84 c0                	test   %al,%al
 205:	0f 84 1d 01 00 00    	je     328 <printf+0x158>
    c = fmt[i] & 0xff;
 20b:	0f be f8             	movsbl %al,%edi
 20e:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 211:	85 f6                	test   %esi,%esi
 213:	75 e2                	jne    1f7 <printf+0x27>
      if(c == '%'){
 215:	83 f8 25             	cmp    $0x25,%eax
 218:	75 d1                	jne    1eb <printf+0x1b>
        state = '%';
 21a:	89 c6                	mov    %eax,%esi
 21c:	eb de                	jmp    1fc <printf+0x2c>
      if(c == 'd'){
 21e:	83 f8 25             	cmp    $0x25,%eax
 221:	0f 84 cc 00 00 00    	je     2f3 <printf+0x123>
 227:	0f 8c da 00 00 00    	jl     307 <printf+0x137>
 22d:	83 f8 78             	cmp    $0x78,%eax
 230:	0f 8f d1 00 00 00    	jg     307 <printf+0x137>
 236:	83 f8 63             	cmp    $0x63,%eax
 239:	0f 8c c8 00 00 00    	jl     307 <printf+0x137>
 23f:	83 e8 63             	sub    $0x63,%eax
 242:	83 f8 15             	cmp    $0x15,%eax
 245:	0f 87 bc 00 00 00    	ja     307 <printf+0x137>
 24b:	ff 24 85 40 03 00 00 	jmp    *0x340(,%eax,4)
        printint(fd, *ap, 10, 1);
 252:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 255:	8b 17                	mov    (%edi),%edx
 257:	83 ec 0c             	sub    $0xc,%esp
 25a:	6a 01                	push   $0x1
 25c:	b9 0a 00 00 00       	mov    $0xa,%ecx
 261:	8b 45 08             	mov    0x8(%ebp),%eax
 264:	e8 ee fe ff ff       	call   157 <printint>
        ap++;
 269:	83 c7 04             	add    $0x4,%edi
 26c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 26f:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 272:	be 00 00 00 00       	mov    $0x0,%esi
 277:	eb 83                	jmp    1fc <printf+0x2c>
        printint(fd, *ap, 16, 0);
 279:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 27c:	8b 17                	mov    (%edi),%edx
 27e:	83 ec 0c             	sub    $0xc,%esp
 281:	6a 00                	push   $0x0
 283:	b9 10 00 00 00       	mov    $0x10,%ecx
 288:	8b 45 08             	mov    0x8(%ebp),%eax
 28b:	e8 c7 fe ff ff       	call   157 <printint>
        ap++;
 290:	83 c7 04             	add    $0x4,%edi
 293:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 296:	83 c4 10             	add    $0x10,%esp
      state = 0;
 299:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 29e:	e9 59 ff ff ff       	jmp    1fc <printf+0x2c>
        s = (char*)*ap;
 2a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2a6:	8b 30                	mov    (%eax),%esi
        ap++;
 2a8:	83 c0 04             	add    $0x4,%eax
 2ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2ae:	85 f6                	test   %esi,%esi
 2b0:	75 13                	jne    2c5 <printf+0xf5>
          s = "(null)";
 2b2:	be 38 03 00 00       	mov    $0x338,%esi
 2b7:	eb 0c                	jmp    2c5 <printf+0xf5>
          putc(fd, *s);
 2b9:	0f be d2             	movsbl %dl,%edx
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
 2bf:	e8 79 fe ff ff       	call   13d <putc>
          s++;
 2c4:	46                   	inc    %esi
        while(*s != 0){
 2c5:	8a 16                	mov    (%esi),%dl
 2c7:	84 d2                	test   %dl,%dl
 2c9:	75 ee                	jne    2b9 <printf+0xe9>
      state = 0;
 2cb:	be 00 00 00 00       	mov    $0x0,%esi
 2d0:	e9 27 ff ff ff       	jmp    1fc <printf+0x2c>
        putc(fd, *ap);
 2d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2d8:	0f be 17             	movsbl (%edi),%edx
 2db:	8b 45 08             	mov    0x8(%ebp),%eax
 2de:	e8 5a fe ff ff       	call   13d <putc>
        ap++;
 2e3:	83 c7 04             	add    $0x4,%edi
 2e6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2e9:	be 00 00 00 00       	mov    $0x0,%esi
 2ee:	e9 09 ff ff ff       	jmp    1fc <printf+0x2c>
        putc(fd, c);
 2f3:	89 fa                	mov    %edi,%edx
 2f5:	8b 45 08             	mov    0x8(%ebp),%eax
 2f8:	e8 40 fe ff ff       	call   13d <putc>
      state = 0;
 2fd:	be 00 00 00 00       	mov    $0x0,%esi
 302:	e9 f5 fe ff ff       	jmp    1fc <printf+0x2c>
        putc(fd, '%');
 307:	ba 25 00 00 00       	mov    $0x25,%edx
 30c:	8b 45 08             	mov    0x8(%ebp),%eax
 30f:	e8 29 fe ff ff       	call   13d <putc>
        putc(fd, c);
 314:	89 fa                	mov    %edi,%edx
 316:	8b 45 08             	mov    0x8(%ebp),%eax
 319:	e8 1f fe ff ff       	call   13d <putc>
      state = 0;
 31e:	be 00 00 00 00       	mov    $0x0,%esi
 323:	e9 d4 fe ff ff       	jmp    1fc <printf+0x2c>
    }
  }
}
 328:	8d 65 f4             	lea    -0xc(%ebp),%esp
 32b:	5b                   	pop    %ebx
 32c:	5e                   	pop    %esi
 32d:	5f                   	pop    %edi
 32e:	5d                   	pop    %ebp
 32f:	c3                   	ret    
