
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
  24:	68 0c 03 00 00       	push   $0x30c
  29:	6a 02                	push   $0x2
  2b:	e8 79 01 00 00       	call   1a9 <printf>
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
  48:	68 19 03 00 00       	push   $0x319
  4d:	6a 01                	push   $0x1
  4f:	e8 55 01 00 00       	call   1a9 <printf>
	
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

00000116 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 116:	55                   	push   %ebp
 117:	89 e5                	mov    %esp,%ebp
 119:	83 ec 1c             	sub    $0x1c,%esp
 11c:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 11f:	6a 01                	push   $0x1
 121:	8d 55 f4             	lea    -0xc(%ebp),%edx
 124:	52                   	push   %edx
 125:	50                   	push   %eax
 126:	e8 5b ff ff ff       	call   86 <write>
}
 12b:	83 c4 10             	add    $0x10,%esp
 12e:	c9                   	leave  
 12f:	c3                   	ret    

00000130 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
 133:	57                   	push   %edi
 134:	56                   	push   %esi
 135:	53                   	push   %ebx
 136:	83 ec 2c             	sub    $0x2c,%esp
 139:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 13c:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 13e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 142:	74 04                	je     148 <printint+0x18>
 144:	85 d2                	test   %edx,%edx
 146:	78 3c                	js     184 <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 148:	89 d1                	mov    %edx,%ecx
  neg = 0;
 14a:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 151:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 156:	89 c8                	mov    %ecx,%eax
 158:	ba 00 00 00 00       	mov    $0x0,%edx
 15d:	f7 f6                	div    %esi
 15f:	89 df                	mov    %ebx,%edi
 161:	43                   	inc    %ebx
 162:	8a 92 84 03 00 00    	mov    0x384(%edx),%dl
 168:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 16c:	89 ca                	mov    %ecx,%edx
 16e:	89 c1                	mov    %eax,%ecx
 170:	39 d6                	cmp    %edx,%esi
 172:	76 e2                	jbe    156 <printint+0x26>
  if(neg)
 174:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 178:	74 24                	je     19e <printint+0x6e>
    buf[i++] = '-';
 17a:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 17f:	8d 5f 02             	lea    0x2(%edi),%ebx
 182:	eb 1a                	jmp    19e <printint+0x6e>
    x = -xx;
 184:	89 d1                	mov    %edx,%ecx
 186:	f7 d9                	neg    %ecx
    neg = 1;
 188:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 18f:	eb c0                	jmp    151 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 191:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 196:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 199:	e8 78 ff ff ff       	call   116 <putc>
  while(--i >= 0)
 19e:	4b                   	dec    %ebx
 19f:	79 f0                	jns    191 <printint+0x61>
}
 1a1:	83 c4 2c             	add    $0x2c,%esp
 1a4:	5b                   	pop    %ebx
 1a5:	5e                   	pop    %esi
 1a6:	5f                   	pop    %edi
 1a7:	5d                   	pop    %ebp
 1a8:	c3                   	ret    

000001a9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1a9:	55                   	push   %ebp
 1aa:	89 e5                	mov    %esp,%ebp
 1ac:	57                   	push   %edi
 1ad:	56                   	push   %esi
 1ae:	53                   	push   %ebx
 1af:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1b2:	8d 45 10             	lea    0x10(%ebp),%eax
 1b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1b8:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1bd:	bb 00 00 00 00       	mov    $0x0,%ebx
 1c2:	eb 12                	jmp    1d6 <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1c4:	89 fa                	mov    %edi,%edx
 1c6:	8b 45 08             	mov    0x8(%ebp),%eax
 1c9:	e8 48 ff ff ff       	call   116 <putc>
 1ce:	eb 05                	jmp    1d5 <printf+0x2c>
      }
    } else if(state == '%'){
 1d0:	83 fe 25             	cmp    $0x25,%esi
 1d3:	74 22                	je     1f7 <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 1d5:	43                   	inc    %ebx
 1d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d9:	8a 04 18             	mov    (%eax,%ebx,1),%al
 1dc:	84 c0                	test   %al,%al
 1de:	0f 84 1d 01 00 00    	je     301 <printf+0x158>
    c = fmt[i] & 0xff;
 1e4:	0f be f8             	movsbl %al,%edi
 1e7:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 1ea:	85 f6                	test   %esi,%esi
 1ec:	75 e2                	jne    1d0 <printf+0x27>
      if(c == '%'){
 1ee:	83 f8 25             	cmp    $0x25,%eax
 1f1:	75 d1                	jne    1c4 <printf+0x1b>
        state = '%';
 1f3:	89 c6                	mov    %eax,%esi
 1f5:	eb de                	jmp    1d5 <printf+0x2c>
      if(c == 'd'){
 1f7:	83 f8 25             	cmp    $0x25,%eax
 1fa:	0f 84 cc 00 00 00    	je     2cc <printf+0x123>
 200:	0f 8c da 00 00 00    	jl     2e0 <printf+0x137>
 206:	83 f8 78             	cmp    $0x78,%eax
 209:	0f 8f d1 00 00 00    	jg     2e0 <printf+0x137>
 20f:	83 f8 63             	cmp    $0x63,%eax
 212:	0f 8c c8 00 00 00    	jl     2e0 <printf+0x137>
 218:	83 e8 63             	sub    $0x63,%eax
 21b:	83 f8 15             	cmp    $0x15,%eax
 21e:	0f 87 bc 00 00 00    	ja     2e0 <printf+0x137>
 224:	ff 24 85 2c 03 00 00 	jmp    *0x32c(,%eax,4)
        printint(fd, *ap, 10, 1);
 22b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 22e:	8b 17                	mov    (%edi),%edx
 230:	83 ec 0c             	sub    $0xc,%esp
 233:	6a 01                	push   $0x1
 235:	b9 0a 00 00 00       	mov    $0xa,%ecx
 23a:	8b 45 08             	mov    0x8(%ebp),%eax
 23d:	e8 ee fe ff ff       	call   130 <printint>
        ap++;
 242:	83 c7 04             	add    $0x4,%edi
 245:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 248:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 24b:	be 00 00 00 00       	mov    $0x0,%esi
 250:	eb 83                	jmp    1d5 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 252:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 255:	8b 17                	mov    (%edi),%edx
 257:	83 ec 0c             	sub    $0xc,%esp
 25a:	6a 00                	push   $0x0
 25c:	b9 10 00 00 00       	mov    $0x10,%ecx
 261:	8b 45 08             	mov    0x8(%ebp),%eax
 264:	e8 c7 fe ff ff       	call   130 <printint>
        ap++;
 269:	83 c7 04             	add    $0x4,%edi
 26c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 26f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 272:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 277:	e9 59 ff ff ff       	jmp    1d5 <printf+0x2c>
        s = (char*)*ap;
 27c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 27f:	8b 30                	mov    (%eax),%esi
        ap++;
 281:	83 c0 04             	add    $0x4,%eax
 284:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 287:	85 f6                	test   %esi,%esi
 289:	75 13                	jne    29e <printf+0xf5>
          s = "(null)";
 28b:	be 23 03 00 00       	mov    $0x323,%esi
 290:	eb 0c                	jmp    29e <printf+0xf5>
          putc(fd, *s);
 292:	0f be d2             	movsbl %dl,%edx
 295:	8b 45 08             	mov    0x8(%ebp),%eax
 298:	e8 79 fe ff ff       	call   116 <putc>
          s++;
 29d:	46                   	inc    %esi
        while(*s != 0){
 29e:	8a 16                	mov    (%esi),%dl
 2a0:	84 d2                	test   %dl,%dl
 2a2:	75 ee                	jne    292 <printf+0xe9>
      state = 0;
 2a4:	be 00 00 00 00       	mov    $0x0,%esi
 2a9:	e9 27 ff ff ff       	jmp    1d5 <printf+0x2c>
        putc(fd, *ap);
 2ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2b1:	0f be 17             	movsbl (%edi),%edx
 2b4:	8b 45 08             	mov    0x8(%ebp),%eax
 2b7:	e8 5a fe ff ff       	call   116 <putc>
        ap++;
 2bc:	83 c7 04             	add    $0x4,%edi
 2bf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2c2:	be 00 00 00 00       	mov    $0x0,%esi
 2c7:	e9 09 ff ff ff       	jmp    1d5 <printf+0x2c>
        putc(fd, c);
 2cc:	89 fa                	mov    %edi,%edx
 2ce:	8b 45 08             	mov    0x8(%ebp),%eax
 2d1:	e8 40 fe ff ff       	call   116 <putc>
      state = 0;
 2d6:	be 00 00 00 00       	mov    $0x0,%esi
 2db:	e9 f5 fe ff ff       	jmp    1d5 <printf+0x2c>
        putc(fd, '%');
 2e0:	ba 25 00 00 00       	mov    $0x25,%edx
 2e5:	8b 45 08             	mov    0x8(%ebp),%eax
 2e8:	e8 29 fe ff ff       	call   116 <putc>
        putc(fd, c);
 2ed:	89 fa                	mov    %edi,%edx
 2ef:	8b 45 08             	mov    0x8(%ebp),%eax
 2f2:	e8 1f fe ff ff       	call   116 <putc>
      state = 0;
 2f7:	be 00 00 00 00       	mov    $0x0,%esi
 2fc:	e9 d4 fe ff ff       	jmp    1d5 <printf+0x2c>
    }
  }
}
 301:	8d 65 f4             	lea    -0xc(%ebp),%esp
 304:	5b                   	pop    %ebx
 305:	5e                   	pop    %esi
 306:	5f                   	pop    %edi
 307:	5d                   	pop    %ebp
 308:	c3                   	ret    
