
date:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "date.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 30             	sub    $0x30,%esp
	struct rtcdate r;
	if(date(&r))
  11:	8d 45 e0             	lea    -0x20(%ebp),%eax
  14:	50                   	push   %eax
  15:	e8 ec 00 00 00       	call   106 <date>
  1a:	83 c4 10             	add    $0x10,%esp
  1d:	85 c0                	test   %eax,%eax
  1f:	74 1b                	je     3c <main+0x3c>
	{
		printf(2, "date failed\n");
  21:	83 ec 08             	sub    $0x8,%esp
  24:	68 1c 03 00 00       	push   $0x31c
  29:	6a 02                	push   $0x2
  2b:	e8 89 01 00 00       	call   1b9 <printf>
		exit(0);
  30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  37:	e8 2a 00 00 00       	call   66 <exit>
	}	

	//Añadimos el printf para mostrar por pantalla 
	printf(1, "%d/%d/%d\n", r.day, r.month, r.year);
  3c:	83 ec 0c             	sub    $0xc,%esp
  3f:	ff 75 f4             	push   -0xc(%ebp)
  42:	ff 75 f0             	push   -0x10(%ebp)
  45:	ff 75 ec             	push   -0x14(%ebp)
  48:	68 29 03 00 00       	push   $0x329
  4d:	6a 01                	push   $0x1
  4f:	e8 65 01 00 00       	call   1b9 <printf>
	
	exit(0);
  54:	83 c4 14             	add    $0x14,%esp
  57:	6a 00                	push   $0x0
  59:	e8 08 00 00 00       	call   66 <exit>

0000005e <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  5e:	b8 01 00 00 00       	mov    $0x1,%eax
  63:	cd 40                	int    $0x40
  65:	c3                   	ret    

00000066 <exit>:
SYSCALL(exit)
  66:	b8 02 00 00 00       	mov    $0x2,%eax
  6b:	cd 40                	int    $0x40
  6d:	c3                   	ret    

0000006e <wait>:
SYSCALL(wait)
  6e:	b8 03 00 00 00       	mov    $0x3,%eax
  73:	cd 40                	int    $0x40
  75:	c3                   	ret    

00000076 <pipe>:
SYSCALL(pipe)
  76:	b8 04 00 00 00       	mov    $0x4,%eax
  7b:	cd 40                	int    $0x40
  7d:	c3                   	ret    

0000007e <read>:
SYSCALL(read)
  7e:	b8 05 00 00 00       	mov    $0x5,%eax
  83:	cd 40                	int    $0x40
  85:	c3                   	ret    

00000086 <write>:
SYSCALL(write)
  86:	b8 10 00 00 00       	mov    $0x10,%eax
  8b:	cd 40                	int    $0x40
  8d:	c3                   	ret    

0000008e <close>:
SYSCALL(close)
  8e:	b8 15 00 00 00       	mov    $0x15,%eax
  93:	cd 40                	int    $0x40
  95:	c3                   	ret    

00000096 <kill>:
SYSCALL(kill)
  96:	b8 06 00 00 00       	mov    $0x6,%eax
  9b:	cd 40                	int    $0x40
  9d:	c3                   	ret    

0000009e <exec>:
SYSCALL(exec)
  9e:	b8 07 00 00 00       	mov    $0x7,%eax
  a3:	cd 40                	int    $0x40
  a5:	c3                   	ret    

000000a6 <open>:
SYSCALL(open)
  a6:	b8 0f 00 00 00       	mov    $0xf,%eax
  ab:	cd 40                	int    $0x40
  ad:	c3                   	ret    

000000ae <mknod>:
SYSCALL(mknod)
  ae:	b8 11 00 00 00       	mov    $0x11,%eax
  b3:	cd 40                	int    $0x40
  b5:	c3                   	ret    

000000b6 <unlink>:
SYSCALL(unlink)
  b6:	b8 12 00 00 00       	mov    $0x12,%eax
  bb:	cd 40                	int    $0x40
  bd:	c3                   	ret    

000000be <fstat>:
SYSCALL(fstat)
  be:	b8 08 00 00 00       	mov    $0x8,%eax
  c3:	cd 40                	int    $0x40
  c5:	c3                   	ret    

000000c6 <link>:
SYSCALL(link)
  c6:	b8 13 00 00 00       	mov    $0x13,%eax
  cb:	cd 40                	int    $0x40
  cd:	c3                   	ret    

000000ce <mkdir>:
SYSCALL(mkdir)
  ce:	b8 14 00 00 00       	mov    $0x14,%eax
  d3:	cd 40                	int    $0x40
  d5:	c3                   	ret    

000000d6 <chdir>:
SYSCALL(chdir)
  d6:	b8 09 00 00 00       	mov    $0x9,%eax
  db:	cd 40                	int    $0x40
  dd:	c3                   	ret    

000000de <dup>:
SYSCALL(dup)
  de:	b8 0a 00 00 00       	mov    $0xa,%eax
  e3:	cd 40                	int    $0x40
  e5:	c3                   	ret    

000000e6 <getpid>:
SYSCALL(getpid)
  e6:	b8 0b 00 00 00       	mov    $0xb,%eax
  eb:	cd 40                	int    $0x40
  ed:	c3                   	ret    

000000ee <sbrk>:
SYSCALL(sbrk)
  ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  f3:	cd 40                	int    $0x40
  f5:	c3                   	ret    

000000f6 <sleep>:
SYSCALL(sleep)
  f6:	b8 0d 00 00 00       	mov    $0xd,%eax
  fb:	cd 40                	int    $0x40
  fd:	c3                   	ret    

000000fe <uptime>:
SYSCALL(uptime)
  fe:	b8 0e 00 00 00       	mov    $0xe,%eax
 103:	cd 40                	int    $0x40
 105:	c3                   	ret    

00000106 <date>:
SYSCALL(date)
 106:	b8 16 00 00 00       	mov    $0x16,%eax
 10b:	cd 40                	int    $0x40
 10d:	c3                   	ret    

0000010e <dup2>:
SYSCALL(dup2)
 10e:	b8 17 00 00 00       	mov    $0x17,%eax
 113:	cd 40                	int    $0x40
 115:	c3                   	ret    

00000116 <getprio>:
SYSCALL(getprio)
 116:	b8 18 00 00 00       	mov    $0x18,%eax
 11b:	cd 40                	int    $0x40
 11d:	c3                   	ret    

0000011e <setprio>:
SYSCALL(setprio)
 11e:	b8 19 00 00 00       	mov    $0x19,%eax
 123:	cd 40                	int    $0x40
 125:	c3                   	ret    

00000126 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 126:	55                   	push   %ebp
 127:	89 e5                	mov    %esp,%ebp
 129:	83 ec 1c             	sub    $0x1c,%esp
 12c:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 12f:	6a 01                	push   $0x1
 131:	8d 55 f4             	lea    -0xc(%ebp),%edx
 134:	52                   	push   %edx
 135:	50                   	push   %eax
 136:	e8 4b ff ff ff       	call   86 <write>
}
 13b:	83 c4 10             	add    $0x10,%esp
 13e:	c9                   	leave  
 13f:	c3                   	ret    

00000140 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	57                   	push   %edi
 144:	56                   	push   %esi
 145:	53                   	push   %ebx
 146:	83 ec 2c             	sub    $0x2c,%esp
 149:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 14c:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 14e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 152:	74 04                	je     158 <printint+0x18>
 154:	85 d2                	test   %edx,%edx
 156:	78 3c                	js     194 <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 158:	89 d1                	mov    %edx,%ecx
  neg = 0;
 15a:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 161:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 166:	89 c8                	mov    %ecx,%eax
 168:	ba 00 00 00 00       	mov    $0x0,%edx
 16d:	f7 f6                	div    %esi
 16f:	89 df                	mov    %ebx,%edi
 171:	43                   	inc    %ebx
 172:	8a 92 94 03 00 00    	mov    0x394(%edx),%dl
 178:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 17c:	89 ca                	mov    %ecx,%edx
 17e:	89 c1                	mov    %eax,%ecx
 180:	39 d6                	cmp    %edx,%esi
 182:	76 e2                	jbe    166 <printint+0x26>
  if(neg)
 184:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 188:	74 24                	je     1ae <printint+0x6e>
    buf[i++] = '-';
 18a:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 18f:	8d 5f 02             	lea    0x2(%edi),%ebx
 192:	eb 1a                	jmp    1ae <printint+0x6e>
    x = -xx;
 194:	89 d1                	mov    %edx,%ecx
 196:	f7 d9                	neg    %ecx
    neg = 1;
 198:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 19f:	eb c0                	jmp    161 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 1a1:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1a9:	e8 78 ff ff ff       	call   126 <putc>
  while(--i >= 0)
 1ae:	4b                   	dec    %ebx
 1af:	79 f0                	jns    1a1 <printint+0x61>
}
 1b1:	83 c4 2c             	add    $0x2c,%esp
 1b4:	5b                   	pop    %ebx
 1b5:	5e                   	pop    %esi
 1b6:	5f                   	pop    %edi
 1b7:	5d                   	pop    %ebp
 1b8:	c3                   	ret    

000001b9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1b9:	55                   	push   %ebp
 1ba:	89 e5                	mov    %esp,%ebp
 1bc:	57                   	push   %edi
 1bd:	56                   	push   %esi
 1be:	53                   	push   %ebx
 1bf:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1c2:	8d 45 10             	lea    0x10(%ebp),%eax
 1c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1c8:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1cd:	bb 00 00 00 00       	mov    $0x0,%ebx
 1d2:	eb 12                	jmp    1e6 <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1d4:	89 fa                	mov    %edi,%edx
 1d6:	8b 45 08             	mov    0x8(%ebp),%eax
 1d9:	e8 48 ff ff ff       	call   126 <putc>
 1de:	eb 05                	jmp    1e5 <printf+0x2c>
      }
    } else if(state == '%'){
 1e0:	83 fe 25             	cmp    $0x25,%esi
 1e3:	74 22                	je     207 <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 1e5:	43                   	inc    %ebx
 1e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e9:	8a 04 18             	mov    (%eax,%ebx,1),%al
 1ec:	84 c0                	test   %al,%al
 1ee:	0f 84 1d 01 00 00    	je     311 <printf+0x158>
    c = fmt[i] & 0xff;
 1f4:	0f be f8             	movsbl %al,%edi
 1f7:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 1fa:	85 f6                	test   %esi,%esi
 1fc:	75 e2                	jne    1e0 <printf+0x27>
      if(c == '%'){
 1fe:	83 f8 25             	cmp    $0x25,%eax
 201:	75 d1                	jne    1d4 <printf+0x1b>
        state = '%';
 203:	89 c6                	mov    %eax,%esi
 205:	eb de                	jmp    1e5 <printf+0x2c>
      if(c == 'd'){
 207:	83 f8 25             	cmp    $0x25,%eax
 20a:	0f 84 cc 00 00 00    	je     2dc <printf+0x123>
 210:	0f 8c da 00 00 00    	jl     2f0 <printf+0x137>
 216:	83 f8 78             	cmp    $0x78,%eax
 219:	0f 8f d1 00 00 00    	jg     2f0 <printf+0x137>
 21f:	83 f8 63             	cmp    $0x63,%eax
 222:	0f 8c c8 00 00 00    	jl     2f0 <printf+0x137>
 228:	83 e8 63             	sub    $0x63,%eax
 22b:	83 f8 15             	cmp    $0x15,%eax
 22e:	0f 87 bc 00 00 00    	ja     2f0 <printf+0x137>
 234:	ff 24 85 3c 03 00 00 	jmp    *0x33c(,%eax,4)
        printint(fd, *ap, 10, 1);
 23b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 23e:	8b 17                	mov    (%edi),%edx
 240:	83 ec 0c             	sub    $0xc,%esp
 243:	6a 01                	push   $0x1
 245:	b9 0a 00 00 00       	mov    $0xa,%ecx
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	e8 ee fe ff ff       	call   140 <printint>
        ap++;
 252:	83 c7 04             	add    $0x4,%edi
 255:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 258:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 25b:	be 00 00 00 00       	mov    $0x0,%esi
 260:	eb 83                	jmp    1e5 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 262:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 265:	8b 17                	mov    (%edi),%edx
 267:	83 ec 0c             	sub    $0xc,%esp
 26a:	6a 00                	push   $0x0
 26c:	b9 10 00 00 00       	mov    $0x10,%ecx
 271:	8b 45 08             	mov    0x8(%ebp),%eax
 274:	e8 c7 fe ff ff       	call   140 <printint>
        ap++;
 279:	83 c7 04             	add    $0x4,%edi
 27c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 27f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 282:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 287:	e9 59 ff ff ff       	jmp    1e5 <printf+0x2c>
        s = (char*)*ap;
 28c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 28f:	8b 30                	mov    (%eax),%esi
        ap++;
 291:	83 c0 04             	add    $0x4,%eax
 294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 297:	85 f6                	test   %esi,%esi
 299:	75 13                	jne    2ae <printf+0xf5>
          s = "(null)";
 29b:	be 33 03 00 00       	mov    $0x333,%esi
 2a0:	eb 0c                	jmp    2ae <printf+0xf5>
          putc(fd, *s);
 2a2:	0f be d2             	movsbl %dl,%edx
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	e8 79 fe ff ff       	call   126 <putc>
          s++;
 2ad:	46                   	inc    %esi
        while(*s != 0){
 2ae:	8a 16                	mov    (%esi),%dl
 2b0:	84 d2                	test   %dl,%dl
 2b2:	75 ee                	jne    2a2 <printf+0xe9>
      state = 0;
 2b4:	be 00 00 00 00       	mov    $0x0,%esi
 2b9:	e9 27 ff ff ff       	jmp    1e5 <printf+0x2c>
        putc(fd, *ap);
 2be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2c1:	0f be 17             	movsbl (%edi),%edx
 2c4:	8b 45 08             	mov    0x8(%ebp),%eax
 2c7:	e8 5a fe ff ff       	call   126 <putc>
        ap++;
 2cc:	83 c7 04             	add    $0x4,%edi
 2cf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2d2:	be 00 00 00 00       	mov    $0x0,%esi
 2d7:	e9 09 ff ff ff       	jmp    1e5 <printf+0x2c>
        putc(fd, c);
 2dc:	89 fa                	mov    %edi,%edx
 2de:	8b 45 08             	mov    0x8(%ebp),%eax
 2e1:	e8 40 fe ff ff       	call   126 <putc>
      state = 0;
 2e6:	be 00 00 00 00       	mov    $0x0,%esi
 2eb:	e9 f5 fe ff ff       	jmp    1e5 <printf+0x2c>
        putc(fd, '%');
 2f0:	ba 25 00 00 00       	mov    $0x25,%edx
 2f5:	8b 45 08             	mov    0x8(%ebp),%eax
 2f8:	e8 29 fe ff ff       	call   126 <putc>
        putc(fd, c);
 2fd:	89 fa                	mov    %edi,%edx
 2ff:	8b 45 08             	mov    0x8(%ebp),%eax
 302:	e8 1f fe ff ff       	call   126 <putc>
      state = 0;
 307:	be 00 00 00 00       	mov    $0x0,%esi
 30c:	e9 d4 fe ff ff       	jmp    1e5 <printf+0x2c>
    }
  }
}
 311:	8d 65 f4             	lea    -0xc(%ebp),%esp
 314:	5b                   	pop    %ebx
 315:	5e                   	pop    %esi
 316:	5f                   	pop    %edi
 317:	5d                   	pop    %ebp
 318:	c3                   	ret    
