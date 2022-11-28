
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
   4:	83 ec 18             	sub    $0x18,%esp
   7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  printf (1, ":%d",v);
   a:	53                   	push   %ebx
   b:	68 34 03 00 00       	push   $0x334
  10:	6a 01                	push   $0x1
  12:	e8 ba 01 00 00       	call   1d1 <printf>
  volatile int q = v;
  17:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  if (q > 0)
  1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1d:	83 c4 10             	add    $0x10,%esp
  20:	85 c0                	test   %eax,%eax
  22:	7f 0a                	jg     2e <recursive+0x2e>
    return recursive (q+1)+recursive (q+2);
  return 0;
  24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  2c:	c9                   	leave  
  2d:	c3                   	ret    
    return recursive (q+1)+recursive (q+2);
  2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  31:	83 ec 0c             	sub    $0xc,%esp
  34:	40                   	inc    %eax
  35:	50                   	push   %eax
  36:	e8 c5 ff ff ff       	call   0 <recursive>
  3b:	89 c3                	mov    %eax,%ebx
  3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  40:	83 c0 02             	add    $0x2,%eax
  43:	89 04 24             	mov    %eax,(%esp)
  46:	e8 b5 ff ff ff       	call   0 <recursive>
  4b:	01 d8                	add    %ebx,%eax
  4d:	83 c4 10             	add    $0x10,%esp
  50:	eb d7                	jmp    29 <recursive+0x29>

00000052 <main>:


int
main(int argc, char *argv[])
{
  52:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  56:	83 e4 f0             	and    $0xfffffff0,%esp
  59:	ff 71 fc             	push   -0x4(%ecx)
  5c:	55                   	push   %ebp
  5d:	89 e5                	mov    %esp,%ebp
  5f:	51                   	push   %ecx
  60:	83 ec 10             	sub    $0x10,%esp
  int i = 1;

  // Llamar recursivamente a recursive
  printf (1, ": %d\n", recursive (i));
  63:	6a 01                	push   $0x1
  65:	e8 96 ff ff ff       	call   0 <recursive>
  6a:	83 c4 0c             	add    $0xc,%esp
  6d:	50                   	push   %eax
  6e:	68 38 03 00 00       	push   $0x338
  73:	6a 01                	push   $0x1
  75:	e8 57 01 00 00       	call   1d1 <printf>

  exit(0);
  7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  81:	e8 08 00 00 00       	call   8e <exit>

00000086 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  86:	b8 01 00 00 00       	mov    $0x1,%eax
  8b:	cd 40                	int    $0x40
  8d:	c3                   	ret    

0000008e <exit>:
SYSCALL(exit)
  8e:	b8 02 00 00 00       	mov    $0x2,%eax
  93:	cd 40                	int    $0x40
  95:	c3                   	ret    

00000096 <wait>:
SYSCALL(wait)
  96:	b8 03 00 00 00       	mov    $0x3,%eax
  9b:	cd 40                	int    $0x40
  9d:	c3                   	ret    

0000009e <pipe>:
SYSCALL(pipe)
  9e:	b8 04 00 00 00       	mov    $0x4,%eax
  a3:	cd 40                	int    $0x40
  a5:	c3                   	ret    

000000a6 <read>:
SYSCALL(read)
  a6:	b8 05 00 00 00       	mov    $0x5,%eax
  ab:	cd 40                	int    $0x40
  ad:	c3                   	ret    

000000ae <write>:
SYSCALL(write)
  ae:	b8 10 00 00 00       	mov    $0x10,%eax
  b3:	cd 40                	int    $0x40
  b5:	c3                   	ret    

000000b6 <close>:
SYSCALL(close)
  b6:	b8 15 00 00 00       	mov    $0x15,%eax
  bb:	cd 40                	int    $0x40
  bd:	c3                   	ret    

000000be <kill>:
SYSCALL(kill)
  be:	b8 06 00 00 00       	mov    $0x6,%eax
  c3:	cd 40                	int    $0x40
  c5:	c3                   	ret    

000000c6 <exec>:
SYSCALL(exec)
  c6:	b8 07 00 00 00       	mov    $0x7,%eax
  cb:	cd 40                	int    $0x40
  cd:	c3                   	ret    

000000ce <open>:
SYSCALL(open)
  ce:	b8 0f 00 00 00       	mov    $0xf,%eax
  d3:	cd 40                	int    $0x40
  d5:	c3                   	ret    

000000d6 <mknod>:
SYSCALL(mknod)
  d6:	b8 11 00 00 00       	mov    $0x11,%eax
  db:	cd 40                	int    $0x40
  dd:	c3                   	ret    

000000de <unlink>:
SYSCALL(unlink)
  de:	b8 12 00 00 00       	mov    $0x12,%eax
  e3:	cd 40                	int    $0x40
  e5:	c3                   	ret    

000000e6 <fstat>:
SYSCALL(fstat)
  e6:	b8 08 00 00 00       	mov    $0x8,%eax
  eb:	cd 40                	int    $0x40
  ed:	c3                   	ret    

000000ee <link>:
SYSCALL(link)
  ee:	b8 13 00 00 00       	mov    $0x13,%eax
  f3:	cd 40                	int    $0x40
  f5:	c3                   	ret    

000000f6 <mkdir>:
SYSCALL(mkdir)
  f6:	b8 14 00 00 00       	mov    $0x14,%eax
  fb:	cd 40                	int    $0x40
  fd:	c3                   	ret    

000000fe <chdir>:
SYSCALL(chdir)
  fe:	b8 09 00 00 00       	mov    $0x9,%eax
 103:	cd 40                	int    $0x40
 105:	c3                   	ret    

00000106 <dup>:
SYSCALL(dup)
 106:	b8 0a 00 00 00       	mov    $0xa,%eax
 10b:	cd 40                	int    $0x40
 10d:	c3                   	ret    

0000010e <getpid>:
SYSCALL(getpid)
 10e:	b8 0b 00 00 00       	mov    $0xb,%eax
 113:	cd 40                	int    $0x40
 115:	c3                   	ret    

00000116 <sbrk>:
SYSCALL(sbrk)
 116:	b8 0c 00 00 00       	mov    $0xc,%eax
 11b:	cd 40                	int    $0x40
 11d:	c3                   	ret    

0000011e <sleep>:
SYSCALL(sleep)
 11e:	b8 0d 00 00 00       	mov    $0xd,%eax
 123:	cd 40                	int    $0x40
 125:	c3                   	ret    

00000126 <uptime>:
SYSCALL(uptime)
 126:	b8 0e 00 00 00       	mov    $0xe,%eax
 12b:	cd 40                	int    $0x40
 12d:	c3                   	ret    

0000012e <date>:
SYSCALL(date)
 12e:	b8 16 00 00 00       	mov    $0x16,%eax
 133:	cd 40                	int    $0x40
 135:	c3                   	ret    

00000136 <dup2>:
SYSCALL(dup2)
 136:	b8 17 00 00 00       	mov    $0x17,%eax
 13b:	cd 40                	int    $0x40
 13d:	c3                   	ret    

0000013e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 13e:	55                   	push   %ebp
 13f:	89 e5                	mov    %esp,%ebp
 141:	83 ec 1c             	sub    $0x1c,%esp
 144:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 147:	6a 01                	push   $0x1
 149:	8d 55 f4             	lea    -0xc(%ebp),%edx
 14c:	52                   	push   %edx
 14d:	50                   	push   %eax
 14e:	e8 5b ff ff ff       	call   ae <write>
}
 153:	83 c4 10             	add    $0x10,%esp
 156:	c9                   	leave  
 157:	c3                   	ret    

00000158 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	57                   	push   %edi
 15c:	56                   	push   %esi
 15d:	53                   	push   %ebx
 15e:	83 ec 2c             	sub    $0x2c,%esp
 161:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 164:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 166:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 16a:	74 04                	je     170 <printint+0x18>
 16c:	85 d2                	test   %edx,%edx
 16e:	78 3c                	js     1ac <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 170:	89 d1                	mov    %edx,%ecx
  neg = 0;
 172:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 179:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 17e:	89 c8                	mov    %ecx,%eax
 180:	ba 00 00 00 00       	mov    $0x0,%edx
 185:	f7 f6                	div    %esi
 187:	89 df                	mov    %ebx,%edi
 189:	43                   	inc    %ebx
 18a:	8a 92 a0 03 00 00    	mov    0x3a0(%edx),%dl
 190:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 194:	89 ca                	mov    %ecx,%edx
 196:	89 c1                	mov    %eax,%ecx
 198:	39 d6                	cmp    %edx,%esi
 19a:	76 e2                	jbe    17e <printint+0x26>
  if(neg)
 19c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 1a0:	74 24                	je     1c6 <printint+0x6e>
    buf[i++] = '-';
 1a2:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1a7:	8d 5f 02             	lea    0x2(%edi),%ebx
 1aa:	eb 1a                	jmp    1c6 <printint+0x6e>
    x = -xx;
 1ac:	89 d1                	mov    %edx,%ecx
 1ae:	f7 d9                	neg    %ecx
    neg = 1;
 1b0:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 1b7:	eb c0                	jmp    179 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 1b9:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1c1:	e8 78 ff ff ff       	call   13e <putc>
  while(--i >= 0)
 1c6:	4b                   	dec    %ebx
 1c7:	79 f0                	jns    1b9 <printint+0x61>
}
 1c9:	83 c4 2c             	add    $0x2c,%esp
 1cc:	5b                   	pop    %ebx
 1cd:	5e                   	pop    %esi
 1ce:	5f                   	pop    %edi
 1cf:	5d                   	pop    %ebp
 1d0:	c3                   	ret    

000001d1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1d1:	55                   	push   %ebp
 1d2:	89 e5                	mov    %esp,%ebp
 1d4:	57                   	push   %edi
 1d5:	56                   	push   %esi
 1d6:	53                   	push   %ebx
 1d7:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1da:	8d 45 10             	lea    0x10(%ebp),%eax
 1dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1e0:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1e5:	bb 00 00 00 00       	mov    $0x0,%ebx
 1ea:	eb 12                	jmp    1fe <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1ec:	89 fa                	mov    %edi,%edx
 1ee:	8b 45 08             	mov    0x8(%ebp),%eax
 1f1:	e8 48 ff ff ff       	call   13e <putc>
 1f6:	eb 05                	jmp    1fd <printf+0x2c>
      }
    } else if(state == '%'){
 1f8:	83 fe 25             	cmp    $0x25,%esi
 1fb:	74 22                	je     21f <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 1fd:	43                   	inc    %ebx
 1fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 201:	8a 04 18             	mov    (%eax,%ebx,1),%al
 204:	84 c0                	test   %al,%al
 206:	0f 84 1d 01 00 00    	je     329 <printf+0x158>
    c = fmt[i] & 0xff;
 20c:	0f be f8             	movsbl %al,%edi
 20f:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 212:	85 f6                	test   %esi,%esi
 214:	75 e2                	jne    1f8 <printf+0x27>
      if(c == '%'){
 216:	83 f8 25             	cmp    $0x25,%eax
 219:	75 d1                	jne    1ec <printf+0x1b>
        state = '%';
 21b:	89 c6                	mov    %eax,%esi
 21d:	eb de                	jmp    1fd <printf+0x2c>
      if(c == 'd'){
 21f:	83 f8 25             	cmp    $0x25,%eax
 222:	0f 84 cc 00 00 00    	je     2f4 <printf+0x123>
 228:	0f 8c da 00 00 00    	jl     308 <printf+0x137>
 22e:	83 f8 78             	cmp    $0x78,%eax
 231:	0f 8f d1 00 00 00    	jg     308 <printf+0x137>
 237:	83 f8 63             	cmp    $0x63,%eax
 23a:	0f 8c c8 00 00 00    	jl     308 <printf+0x137>
 240:	83 e8 63             	sub    $0x63,%eax
 243:	83 f8 15             	cmp    $0x15,%eax
 246:	0f 87 bc 00 00 00    	ja     308 <printf+0x137>
 24c:	ff 24 85 48 03 00 00 	jmp    *0x348(,%eax,4)
        printint(fd, *ap, 10, 1);
 253:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 256:	8b 17                	mov    (%edi),%edx
 258:	83 ec 0c             	sub    $0xc,%esp
 25b:	6a 01                	push   $0x1
 25d:	b9 0a 00 00 00       	mov    $0xa,%ecx
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	e8 ee fe ff ff       	call   158 <printint>
        ap++;
 26a:	83 c7 04             	add    $0x4,%edi
 26d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 270:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 273:	be 00 00 00 00       	mov    $0x0,%esi
 278:	eb 83                	jmp    1fd <printf+0x2c>
        printint(fd, *ap, 16, 0);
 27a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 27d:	8b 17                	mov    (%edi),%edx
 27f:	83 ec 0c             	sub    $0xc,%esp
 282:	6a 00                	push   $0x0
 284:	b9 10 00 00 00       	mov    $0x10,%ecx
 289:	8b 45 08             	mov    0x8(%ebp),%eax
 28c:	e8 c7 fe ff ff       	call   158 <printint>
        ap++;
 291:	83 c7 04             	add    $0x4,%edi
 294:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 297:	83 c4 10             	add    $0x10,%esp
      state = 0;
 29a:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 29f:	e9 59 ff ff ff       	jmp    1fd <printf+0x2c>
        s = (char*)*ap;
 2a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2a7:	8b 30                	mov    (%eax),%esi
        ap++;
 2a9:	83 c0 04             	add    $0x4,%eax
 2ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2af:	85 f6                	test   %esi,%esi
 2b1:	75 13                	jne    2c6 <printf+0xf5>
          s = "(null)";
 2b3:	be 3e 03 00 00       	mov    $0x33e,%esi
 2b8:	eb 0c                	jmp    2c6 <printf+0xf5>
          putc(fd, *s);
 2ba:	0f be d2             	movsbl %dl,%edx
 2bd:	8b 45 08             	mov    0x8(%ebp),%eax
 2c0:	e8 79 fe ff ff       	call   13e <putc>
          s++;
 2c5:	46                   	inc    %esi
        while(*s != 0){
 2c6:	8a 16                	mov    (%esi),%dl
 2c8:	84 d2                	test   %dl,%dl
 2ca:	75 ee                	jne    2ba <printf+0xe9>
      state = 0;
 2cc:	be 00 00 00 00       	mov    $0x0,%esi
 2d1:	e9 27 ff ff ff       	jmp    1fd <printf+0x2c>
        putc(fd, *ap);
 2d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2d9:	0f be 17             	movsbl (%edi),%edx
 2dc:	8b 45 08             	mov    0x8(%ebp),%eax
 2df:	e8 5a fe ff ff       	call   13e <putc>
        ap++;
 2e4:	83 c7 04             	add    $0x4,%edi
 2e7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2ea:	be 00 00 00 00       	mov    $0x0,%esi
 2ef:	e9 09 ff ff ff       	jmp    1fd <printf+0x2c>
        putc(fd, c);
 2f4:	89 fa                	mov    %edi,%edx
 2f6:	8b 45 08             	mov    0x8(%ebp),%eax
 2f9:	e8 40 fe ff ff       	call   13e <putc>
      state = 0;
 2fe:	be 00 00 00 00       	mov    $0x0,%esi
 303:	e9 f5 fe ff ff       	jmp    1fd <printf+0x2c>
        putc(fd, '%');
 308:	ba 25 00 00 00       	mov    $0x25,%edx
 30d:	8b 45 08             	mov    0x8(%ebp),%eax
 310:	e8 29 fe ff ff       	call   13e <putc>
        putc(fd, c);
 315:	89 fa                	mov    %edi,%edx
 317:	8b 45 08             	mov    0x8(%ebp),%eax
 31a:	e8 1f fe ff ff       	call   13e <putc>
      state = 0;
 31f:	be 00 00 00 00       	mov    $0x0,%esi
 324:	e9 d4 fe ff ff       	jmp    1fd <printf+0x2c>
    }
  }
}
 329:	8d 65 f4             	lea    -0xc(%ebp),%esp
 32c:	5b                   	pop    %ebx
 32d:	5e                   	pop    %esi
 32e:	5f                   	pop    %edi
 32f:	5d                   	pop    %ebp
 330:	c3                   	ret    
