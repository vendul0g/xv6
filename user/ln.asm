
ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	8b 59 04             	mov    0x4(%ecx),%ebx
  if(argc != 3){
  12:	83 39 03             	cmpl   $0x3,(%ecx)
  15:	74 1b                	je     32 <main+0x32>
    printf(2, "Usage: ln old new\n");
  17:	83 ec 08             	sub    $0x8,%esp
  1a:	68 24 03 00 00       	push   $0x324
  1f:	6a 02                	push   $0x2
  21:	e8 9d 01 00 00       	call   1c3 <printf>
    exit(0);
  26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  2d:	e8 3e 00 00 00       	call   70 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  32:	83 ec 08             	sub    $0x8,%esp
  35:	ff 73 08             	push   0x8(%ebx)
  38:	ff 73 04             	push   0x4(%ebx)
  3b:	e8 90 00 00 00       	call   d0 <link>
  40:	83 c4 10             	add    $0x10,%esp
  43:	85 c0                	test   %eax,%eax
  45:	78 0a                	js     51 <main+0x51>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  47:	83 ec 0c             	sub    $0xc,%esp
  4a:	6a 00                	push   $0x0
  4c:	e8 1f 00 00 00       	call   70 <exit>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  51:	ff 73 08             	push   0x8(%ebx)
  54:	ff 73 04             	push   0x4(%ebx)
  57:	68 37 03 00 00       	push   $0x337
  5c:	6a 02                	push   $0x2
  5e:	e8 60 01 00 00       	call   1c3 <printf>
  63:	83 c4 10             	add    $0x10,%esp
  66:	eb df                	jmp    47 <main+0x47>

00000068 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  68:	b8 01 00 00 00       	mov    $0x1,%eax
  6d:	cd 40                	int    $0x40
  6f:	c3                   	ret    

00000070 <exit>:
SYSCALL(exit)
  70:	b8 02 00 00 00       	mov    $0x2,%eax
  75:	cd 40                	int    $0x40
  77:	c3                   	ret    

00000078 <wait>:
SYSCALL(wait)
  78:	b8 03 00 00 00       	mov    $0x3,%eax
  7d:	cd 40                	int    $0x40
  7f:	c3                   	ret    

00000080 <pipe>:
SYSCALL(pipe)
  80:	b8 04 00 00 00       	mov    $0x4,%eax
  85:	cd 40                	int    $0x40
  87:	c3                   	ret    

00000088 <read>:
SYSCALL(read)
  88:	b8 05 00 00 00       	mov    $0x5,%eax
  8d:	cd 40                	int    $0x40
  8f:	c3                   	ret    

00000090 <write>:
SYSCALL(write)
  90:	b8 10 00 00 00       	mov    $0x10,%eax
  95:	cd 40                	int    $0x40
  97:	c3                   	ret    

00000098 <close>:
SYSCALL(close)
  98:	b8 15 00 00 00       	mov    $0x15,%eax
  9d:	cd 40                	int    $0x40
  9f:	c3                   	ret    

000000a0 <kill>:
SYSCALL(kill)
  a0:	b8 06 00 00 00       	mov    $0x6,%eax
  a5:	cd 40                	int    $0x40
  a7:	c3                   	ret    

000000a8 <exec>:
SYSCALL(exec)
  a8:	b8 07 00 00 00       	mov    $0x7,%eax
  ad:	cd 40                	int    $0x40
  af:	c3                   	ret    

000000b0 <open>:
SYSCALL(open)
  b0:	b8 0f 00 00 00       	mov    $0xf,%eax
  b5:	cd 40                	int    $0x40
  b7:	c3                   	ret    

000000b8 <mknod>:
SYSCALL(mknod)
  b8:	b8 11 00 00 00       	mov    $0x11,%eax
  bd:	cd 40                	int    $0x40
  bf:	c3                   	ret    

000000c0 <unlink>:
SYSCALL(unlink)
  c0:	b8 12 00 00 00       	mov    $0x12,%eax
  c5:	cd 40                	int    $0x40
  c7:	c3                   	ret    

000000c8 <fstat>:
SYSCALL(fstat)
  c8:	b8 08 00 00 00       	mov    $0x8,%eax
  cd:	cd 40                	int    $0x40
  cf:	c3                   	ret    

000000d0 <link>:
SYSCALL(link)
  d0:	b8 13 00 00 00       	mov    $0x13,%eax
  d5:	cd 40                	int    $0x40
  d7:	c3                   	ret    

000000d8 <mkdir>:
SYSCALL(mkdir)
  d8:	b8 14 00 00 00       	mov    $0x14,%eax
  dd:	cd 40                	int    $0x40
  df:	c3                   	ret    

000000e0 <chdir>:
SYSCALL(chdir)
  e0:	b8 09 00 00 00       	mov    $0x9,%eax
  e5:	cd 40                	int    $0x40
  e7:	c3                   	ret    

000000e8 <dup>:
SYSCALL(dup)
  e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  ed:	cd 40                	int    $0x40
  ef:	c3                   	ret    

000000f0 <getpid>:
SYSCALL(getpid)
  f0:	b8 0b 00 00 00       	mov    $0xb,%eax
  f5:	cd 40                	int    $0x40
  f7:	c3                   	ret    

000000f8 <sbrk>:
SYSCALL(sbrk)
  f8:	b8 0c 00 00 00       	mov    $0xc,%eax
  fd:	cd 40                	int    $0x40
  ff:	c3                   	ret    

00000100 <sleep>:
SYSCALL(sleep)
 100:	b8 0d 00 00 00       	mov    $0xd,%eax
 105:	cd 40                	int    $0x40
 107:	c3                   	ret    

00000108 <uptime>:
SYSCALL(uptime)
 108:	b8 0e 00 00 00       	mov    $0xe,%eax
 10d:	cd 40                	int    $0x40
 10f:	c3                   	ret    

00000110 <date>:
SYSCALL(date)
 110:	b8 16 00 00 00       	mov    $0x16,%eax
 115:	cd 40                	int    $0x40
 117:	c3                   	ret    

00000118 <dup2>:
SYSCALL(dup2)
 118:	b8 17 00 00 00       	mov    $0x17,%eax
 11d:	cd 40                	int    $0x40
 11f:	c3                   	ret    

00000120 <getprio>:
SYSCALL(getprio)
 120:	b8 18 00 00 00       	mov    $0x18,%eax
 125:	cd 40                	int    $0x40
 127:	c3                   	ret    

00000128 <setprio>:
SYSCALL(setprio)
 128:	b8 19 00 00 00       	mov    $0x19,%eax
 12d:	cd 40                	int    $0x40
 12f:	c3                   	ret    

00000130 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
 133:	83 ec 1c             	sub    $0x1c,%esp
 136:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 139:	6a 01                	push   $0x1
 13b:	8d 55 f4             	lea    -0xc(%ebp),%edx
 13e:	52                   	push   %edx
 13f:	50                   	push   %eax
 140:	e8 4b ff ff ff       	call   90 <write>
}
 145:	83 c4 10             	add    $0x10,%esp
 148:	c9                   	leave  
 149:	c3                   	ret    

0000014a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 14a:	55                   	push   %ebp
 14b:	89 e5                	mov    %esp,%ebp
 14d:	57                   	push   %edi
 14e:	56                   	push   %esi
 14f:	53                   	push   %ebx
 150:	83 ec 2c             	sub    $0x2c,%esp
 153:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 156:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 158:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 15c:	74 04                	je     162 <printint+0x18>
 15e:	85 d2                	test   %edx,%edx
 160:	78 3c                	js     19e <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 162:	89 d1                	mov    %edx,%ecx
  neg = 0;
 164:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 16b:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 170:	89 c8                	mov    %ecx,%eax
 172:	ba 00 00 00 00       	mov    $0x0,%edx
 177:	f7 f6                	div    %esi
 179:	89 df                	mov    %ebx,%edi
 17b:	43                   	inc    %ebx
 17c:	8a 92 ac 03 00 00    	mov    0x3ac(%edx),%dl
 182:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 186:	89 ca                	mov    %ecx,%edx
 188:	89 c1                	mov    %eax,%ecx
 18a:	39 d6                	cmp    %edx,%esi
 18c:	76 e2                	jbe    170 <printint+0x26>
  if(neg)
 18e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 192:	74 24                	je     1b8 <printint+0x6e>
    buf[i++] = '-';
 194:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 199:	8d 5f 02             	lea    0x2(%edi),%ebx
 19c:	eb 1a                	jmp    1b8 <printint+0x6e>
    x = -xx;
 19e:	89 d1                	mov    %edx,%ecx
 1a0:	f7 d9                	neg    %ecx
    neg = 1;
 1a2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 1a9:	eb c0                	jmp    16b <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 1ab:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1b3:	e8 78 ff ff ff       	call   130 <putc>
  while(--i >= 0)
 1b8:	4b                   	dec    %ebx
 1b9:	79 f0                	jns    1ab <printint+0x61>
}
 1bb:	83 c4 2c             	add    $0x2c,%esp
 1be:	5b                   	pop    %ebx
 1bf:	5e                   	pop    %esi
 1c0:	5f                   	pop    %edi
 1c1:	5d                   	pop    %ebp
 1c2:	c3                   	ret    

000001c3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1c3:	55                   	push   %ebp
 1c4:	89 e5                	mov    %esp,%ebp
 1c6:	57                   	push   %edi
 1c7:	56                   	push   %esi
 1c8:	53                   	push   %ebx
 1c9:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1cc:	8d 45 10             	lea    0x10(%ebp),%eax
 1cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1d2:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1d7:	bb 00 00 00 00       	mov    $0x0,%ebx
 1dc:	eb 12                	jmp    1f0 <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1de:	89 fa                	mov    %edi,%edx
 1e0:	8b 45 08             	mov    0x8(%ebp),%eax
 1e3:	e8 48 ff ff ff       	call   130 <putc>
 1e8:	eb 05                	jmp    1ef <printf+0x2c>
      }
    } else if(state == '%'){
 1ea:	83 fe 25             	cmp    $0x25,%esi
 1ed:	74 22                	je     211 <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 1ef:	43                   	inc    %ebx
 1f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f3:	8a 04 18             	mov    (%eax,%ebx,1),%al
 1f6:	84 c0                	test   %al,%al
 1f8:	0f 84 1d 01 00 00    	je     31b <printf+0x158>
    c = fmt[i] & 0xff;
 1fe:	0f be f8             	movsbl %al,%edi
 201:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 204:	85 f6                	test   %esi,%esi
 206:	75 e2                	jne    1ea <printf+0x27>
      if(c == '%'){
 208:	83 f8 25             	cmp    $0x25,%eax
 20b:	75 d1                	jne    1de <printf+0x1b>
        state = '%';
 20d:	89 c6                	mov    %eax,%esi
 20f:	eb de                	jmp    1ef <printf+0x2c>
      if(c == 'd'){
 211:	83 f8 25             	cmp    $0x25,%eax
 214:	0f 84 cc 00 00 00    	je     2e6 <printf+0x123>
 21a:	0f 8c da 00 00 00    	jl     2fa <printf+0x137>
 220:	83 f8 78             	cmp    $0x78,%eax
 223:	0f 8f d1 00 00 00    	jg     2fa <printf+0x137>
 229:	83 f8 63             	cmp    $0x63,%eax
 22c:	0f 8c c8 00 00 00    	jl     2fa <printf+0x137>
 232:	83 e8 63             	sub    $0x63,%eax
 235:	83 f8 15             	cmp    $0x15,%eax
 238:	0f 87 bc 00 00 00    	ja     2fa <printf+0x137>
 23e:	ff 24 85 54 03 00 00 	jmp    *0x354(,%eax,4)
        printint(fd, *ap, 10, 1);
 245:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 248:	8b 17                	mov    (%edi),%edx
 24a:	83 ec 0c             	sub    $0xc,%esp
 24d:	6a 01                	push   $0x1
 24f:	b9 0a 00 00 00       	mov    $0xa,%ecx
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	e8 ee fe ff ff       	call   14a <printint>
        ap++;
 25c:	83 c7 04             	add    $0x4,%edi
 25f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 262:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 265:	be 00 00 00 00       	mov    $0x0,%esi
 26a:	eb 83                	jmp    1ef <printf+0x2c>
        printint(fd, *ap, 16, 0);
 26c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 26f:	8b 17                	mov    (%edi),%edx
 271:	83 ec 0c             	sub    $0xc,%esp
 274:	6a 00                	push   $0x0
 276:	b9 10 00 00 00       	mov    $0x10,%ecx
 27b:	8b 45 08             	mov    0x8(%ebp),%eax
 27e:	e8 c7 fe ff ff       	call   14a <printint>
        ap++;
 283:	83 c7 04             	add    $0x4,%edi
 286:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 289:	83 c4 10             	add    $0x10,%esp
      state = 0;
 28c:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 291:	e9 59 ff ff ff       	jmp    1ef <printf+0x2c>
        s = (char*)*ap;
 296:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 299:	8b 30                	mov    (%eax),%esi
        ap++;
 29b:	83 c0 04             	add    $0x4,%eax
 29e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2a1:	85 f6                	test   %esi,%esi
 2a3:	75 13                	jne    2b8 <printf+0xf5>
          s = "(null)";
 2a5:	be 4b 03 00 00       	mov    $0x34b,%esi
 2aa:	eb 0c                	jmp    2b8 <printf+0xf5>
          putc(fd, *s);
 2ac:	0f be d2             	movsbl %dl,%edx
 2af:	8b 45 08             	mov    0x8(%ebp),%eax
 2b2:	e8 79 fe ff ff       	call   130 <putc>
          s++;
 2b7:	46                   	inc    %esi
        while(*s != 0){
 2b8:	8a 16                	mov    (%esi),%dl
 2ba:	84 d2                	test   %dl,%dl
 2bc:	75 ee                	jne    2ac <printf+0xe9>
      state = 0;
 2be:	be 00 00 00 00       	mov    $0x0,%esi
 2c3:	e9 27 ff ff ff       	jmp    1ef <printf+0x2c>
        putc(fd, *ap);
 2c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2cb:	0f be 17             	movsbl (%edi),%edx
 2ce:	8b 45 08             	mov    0x8(%ebp),%eax
 2d1:	e8 5a fe ff ff       	call   130 <putc>
        ap++;
 2d6:	83 c7 04             	add    $0x4,%edi
 2d9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2dc:	be 00 00 00 00       	mov    $0x0,%esi
 2e1:	e9 09 ff ff ff       	jmp    1ef <printf+0x2c>
        putc(fd, c);
 2e6:	89 fa                	mov    %edi,%edx
 2e8:	8b 45 08             	mov    0x8(%ebp),%eax
 2eb:	e8 40 fe ff ff       	call   130 <putc>
      state = 0;
 2f0:	be 00 00 00 00       	mov    $0x0,%esi
 2f5:	e9 f5 fe ff ff       	jmp    1ef <printf+0x2c>
        putc(fd, '%');
 2fa:	ba 25 00 00 00       	mov    $0x25,%edx
 2ff:	8b 45 08             	mov    0x8(%ebp),%eax
 302:	e8 29 fe ff ff       	call   130 <putc>
        putc(fd, c);
 307:	89 fa                	mov    %edi,%edx
 309:	8b 45 08             	mov    0x8(%ebp),%eax
 30c:	e8 1f fe ff ff       	call   130 <putc>
      state = 0;
 311:	be 00 00 00 00       	mov    $0x0,%esi
 316:	e9 d4 fe ff ff       	jmp    1ef <printf+0x2c>
    }
  }
}
 31b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 31e:	5b                   	pop    %ebx
 31f:	5e                   	pop    %esi
 320:	5f                   	pop    %edi
 321:	5d                   	pop    %ebp
 322:	c3                   	ret    
