
tsbrk3:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fcntl.h"
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
  10:	83 ec 14             	sub    $0x14,%esp
  int fh = open ("README", O_RDONLY);
  13:	6a 00                	push   $0x0
  15:	68 20 03 00 00       	push   $0x320
  1a:	e8 9b 00 00 00       	call   ba <open>
  1f:	89 c3                	mov    %eax,%ebx

  char* a = sbrk (15000);
  21:	c7 04 24 98 3a 00 00 	movl   $0x3a98,(%esp)
  28:	e8 d5 00 00 00       	call   102 <sbrk>

  read (fh, a+8192, 50);
  2d:	8d b0 00 20 00 00    	lea    0x2000(%eax),%esi
  33:	83 c4 0c             	add    $0xc,%esp
  36:	6a 32                	push   $0x32
  38:	56                   	push   %esi
  39:	53                   	push   %ebx
  3a:	e8 53 00 00 00       	call   92 <read>

  // Debe imprimir los 50 primeros caracteres de README
  printf (1, "Debe imprimir los 50 primeros caracteres de README:\n");
  3f:	83 c4 08             	add    $0x8,%esp
  42:	68 2c 03 00 00       	push   $0x32c
  47:	6a 01                	push   $0x1
  49:	e8 6f 01 00 00       	call   1bd <printf>
  printf (1, "%s\n", a+8192);
  4e:	83 c4 0c             	add    $0xc,%esp
  51:	56                   	push   %esi
  52:	68 27 03 00 00       	push   $0x327
  57:	6a 01                	push   $0x1
  59:	e8 5f 01 00 00       	call   1bd <printf>

  close (fh);
  5e:	89 1c 24             	mov    %ebx,(%esp)
  61:	e8 3c 00 00 00       	call   a2 <close>

  exit(0);
  66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  6d:	e8 08 00 00 00       	call   7a <exit>

00000072 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  72:	b8 01 00 00 00       	mov    $0x1,%eax
  77:	cd 40                	int    $0x40
  79:	c3                   	ret    

0000007a <exit>:
SYSCALL(exit)
  7a:	b8 02 00 00 00       	mov    $0x2,%eax
  7f:	cd 40                	int    $0x40
  81:	c3                   	ret    

00000082 <wait>:
SYSCALL(wait)
  82:	b8 03 00 00 00       	mov    $0x3,%eax
  87:	cd 40                	int    $0x40
  89:	c3                   	ret    

0000008a <pipe>:
SYSCALL(pipe)
  8a:	b8 04 00 00 00       	mov    $0x4,%eax
  8f:	cd 40                	int    $0x40
  91:	c3                   	ret    

00000092 <read>:
SYSCALL(read)
  92:	b8 05 00 00 00       	mov    $0x5,%eax
  97:	cd 40                	int    $0x40
  99:	c3                   	ret    

0000009a <write>:
SYSCALL(write)
  9a:	b8 10 00 00 00       	mov    $0x10,%eax
  9f:	cd 40                	int    $0x40
  a1:	c3                   	ret    

000000a2 <close>:
SYSCALL(close)
  a2:	b8 15 00 00 00       	mov    $0x15,%eax
  a7:	cd 40                	int    $0x40
  a9:	c3                   	ret    

000000aa <kill>:
SYSCALL(kill)
  aa:	b8 06 00 00 00       	mov    $0x6,%eax
  af:	cd 40                	int    $0x40
  b1:	c3                   	ret    

000000b2 <exec>:
SYSCALL(exec)
  b2:	b8 07 00 00 00       	mov    $0x7,%eax
  b7:	cd 40                	int    $0x40
  b9:	c3                   	ret    

000000ba <open>:
SYSCALL(open)
  ba:	b8 0f 00 00 00       	mov    $0xf,%eax
  bf:	cd 40                	int    $0x40
  c1:	c3                   	ret    

000000c2 <mknod>:
SYSCALL(mknod)
  c2:	b8 11 00 00 00       	mov    $0x11,%eax
  c7:	cd 40                	int    $0x40
  c9:	c3                   	ret    

000000ca <unlink>:
SYSCALL(unlink)
  ca:	b8 12 00 00 00       	mov    $0x12,%eax
  cf:	cd 40                	int    $0x40
  d1:	c3                   	ret    

000000d2 <fstat>:
SYSCALL(fstat)
  d2:	b8 08 00 00 00       	mov    $0x8,%eax
  d7:	cd 40                	int    $0x40
  d9:	c3                   	ret    

000000da <link>:
SYSCALL(link)
  da:	b8 13 00 00 00       	mov    $0x13,%eax
  df:	cd 40                	int    $0x40
  e1:	c3                   	ret    

000000e2 <mkdir>:
SYSCALL(mkdir)
  e2:	b8 14 00 00 00       	mov    $0x14,%eax
  e7:	cd 40                	int    $0x40
  e9:	c3                   	ret    

000000ea <chdir>:
SYSCALL(chdir)
  ea:	b8 09 00 00 00       	mov    $0x9,%eax
  ef:	cd 40                	int    $0x40
  f1:	c3                   	ret    

000000f2 <dup>:
SYSCALL(dup)
  f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  f7:	cd 40                	int    $0x40
  f9:	c3                   	ret    

000000fa <getpid>:
SYSCALL(getpid)
  fa:	b8 0b 00 00 00       	mov    $0xb,%eax
  ff:	cd 40                	int    $0x40
 101:	c3                   	ret    

00000102 <sbrk>:
SYSCALL(sbrk)
 102:	b8 0c 00 00 00       	mov    $0xc,%eax
 107:	cd 40                	int    $0x40
 109:	c3                   	ret    

0000010a <sleep>:
SYSCALL(sleep)
 10a:	b8 0d 00 00 00       	mov    $0xd,%eax
 10f:	cd 40                	int    $0x40
 111:	c3                   	ret    

00000112 <uptime>:
SYSCALL(uptime)
 112:	b8 0e 00 00 00       	mov    $0xe,%eax
 117:	cd 40                	int    $0x40
 119:	c3                   	ret    

0000011a <date>:
SYSCALL(date)
 11a:	b8 16 00 00 00       	mov    $0x16,%eax
 11f:	cd 40                	int    $0x40
 121:	c3                   	ret    

00000122 <dup2>:
SYSCALL(dup2)
 122:	b8 17 00 00 00       	mov    $0x17,%eax
 127:	cd 40                	int    $0x40
 129:	c3                   	ret    

0000012a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 12a:	55                   	push   %ebp
 12b:	89 e5                	mov    %esp,%ebp
 12d:	83 ec 1c             	sub    $0x1c,%esp
 130:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 133:	6a 01                	push   $0x1
 135:	8d 55 f4             	lea    -0xc(%ebp),%edx
 138:	52                   	push   %edx
 139:	50                   	push   %eax
 13a:	e8 5b ff ff ff       	call   9a <write>
}
 13f:	83 c4 10             	add    $0x10,%esp
 142:	c9                   	leave  
 143:	c3                   	ret    

00000144 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 144:	55                   	push   %ebp
 145:	89 e5                	mov    %esp,%ebp
 147:	57                   	push   %edi
 148:	56                   	push   %esi
 149:	53                   	push   %ebx
 14a:	83 ec 2c             	sub    $0x2c,%esp
 14d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 150:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 152:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 156:	74 04                	je     15c <printint+0x18>
 158:	85 d2                	test   %edx,%edx
 15a:	78 3c                	js     198 <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 15c:	89 d1                	mov    %edx,%ecx
  neg = 0;
 15e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 165:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 16a:	89 c8                	mov    %ecx,%eax
 16c:	ba 00 00 00 00       	mov    $0x0,%edx
 171:	f7 f6                	div    %esi
 173:	89 df                	mov    %ebx,%edi
 175:	43                   	inc    %ebx
 176:	8a 92 c0 03 00 00    	mov    0x3c0(%edx),%dl
 17c:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 180:	89 ca                	mov    %ecx,%edx
 182:	89 c1                	mov    %eax,%ecx
 184:	39 d6                	cmp    %edx,%esi
 186:	76 e2                	jbe    16a <printint+0x26>
  if(neg)
 188:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 18c:	74 24                	je     1b2 <printint+0x6e>
    buf[i++] = '-';
 18e:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 193:	8d 5f 02             	lea    0x2(%edi),%ebx
 196:	eb 1a                	jmp    1b2 <printint+0x6e>
    x = -xx;
 198:	89 d1                	mov    %edx,%ecx
 19a:	f7 d9                	neg    %ecx
    neg = 1;
 19c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 1a3:	eb c0                	jmp    165 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 1a5:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1ad:	e8 78 ff ff ff       	call   12a <putc>
  while(--i >= 0)
 1b2:	4b                   	dec    %ebx
 1b3:	79 f0                	jns    1a5 <printint+0x61>
}
 1b5:	83 c4 2c             	add    $0x2c,%esp
 1b8:	5b                   	pop    %ebx
 1b9:	5e                   	pop    %esi
 1ba:	5f                   	pop    %edi
 1bb:	5d                   	pop    %ebp
 1bc:	c3                   	ret    

000001bd <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1bd:	55                   	push   %ebp
 1be:	89 e5                	mov    %esp,%ebp
 1c0:	57                   	push   %edi
 1c1:	56                   	push   %esi
 1c2:	53                   	push   %ebx
 1c3:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1c6:	8d 45 10             	lea    0x10(%ebp),%eax
 1c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1cc:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1d1:	bb 00 00 00 00       	mov    $0x0,%ebx
 1d6:	eb 12                	jmp    1ea <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1d8:	89 fa                	mov    %edi,%edx
 1da:	8b 45 08             	mov    0x8(%ebp),%eax
 1dd:	e8 48 ff ff ff       	call   12a <putc>
 1e2:	eb 05                	jmp    1e9 <printf+0x2c>
      }
    } else if(state == '%'){
 1e4:	83 fe 25             	cmp    $0x25,%esi
 1e7:	74 22                	je     20b <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 1e9:	43                   	inc    %ebx
 1ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ed:	8a 04 18             	mov    (%eax,%ebx,1),%al
 1f0:	84 c0                	test   %al,%al
 1f2:	0f 84 1d 01 00 00    	je     315 <printf+0x158>
    c = fmt[i] & 0xff;
 1f8:	0f be f8             	movsbl %al,%edi
 1fb:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 1fe:	85 f6                	test   %esi,%esi
 200:	75 e2                	jne    1e4 <printf+0x27>
      if(c == '%'){
 202:	83 f8 25             	cmp    $0x25,%eax
 205:	75 d1                	jne    1d8 <printf+0x1b>
        state = '%';
 207:	89 c6                	mov    %eax,%esi
 209:	eb de                	jmp    1e9 <printf+0x2c>
      if(c == 'd'){
 20b:	83 f8 25             	cmp    $0x25,%eax
 20e:	0f 84 cc 00 00 00    	je     2e0 <printf+0x123>
 214:	0f 8c da 00 00 00    	jl     2f4 <printf+0x137>
 21a:	83 f8 78             	cmp    $0x78,%eax
 21d:	0f 8f d1 00 00 00    	jg     2f4 <printf+0x137>
 223:	83 f8 63             	cmp    $0x63,%eax
 226:	0f 8c c8 00 00 00    	jl     2f4 <printf+0x137>
 22c:	83 e8 63             	sub    $0x63,%eax
 22f:	83 f8 15             	cmp    $0x15,%eax
 232:	0f 87 bc 00 00 00    	ja     2f4 <printf+0x137>
 238:	ff 24 85 68 03 00 00 	jmp    *0x368(,%eax,4)
        printint(fd, *ap, 10, 1);
 23f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 242:	8b 17                	mov    (%edi),%edx
 244:	83 ec 0c             	sub    $0xc,%esp
 247:	6a 01                	push   $0x1
 249:	b9 0a 00 00 00       	mov    $0xa,%ecx
 24e:	8b 45 08             	mov    0x8(%ebp),%eax
 251:	e8 ee fe ff ff       	call   144 <printint>
        ap++;
 256:	83 c7 04             	add    $0x4,%edi
 259:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 25c:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 25f:	be 00 00 00 00       	mov    $0x0,%esi
 264:	eb 83                	jmp    1e9 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 266:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 269:	8b 17                	mov    (%edi),%edx
 26b:	83 ec 0c             	sub    $0xc,%esp
 26e:	6a 00                	push   $0x0
 270:	b9 10 00 00 00       	mov    $0x10,%ecx
 275:	8b 45 08             	mov    0x8(%ebp),%eax
 278:	e8 c7 fe ff ff       	call   144 <printint>
        ap++;
 27d:	83 c7 04             	add    $0x4,%edi
 280:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 283:	83 c4 10             	add    $0x10,%esp
      state = 0;
 286:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 28b:	e9 59 ff ff ff       	jmp    1e9 <printf+0x2c>
        s = (char*)*ap;
 290:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 293:	8b 30                	mov    (%eax),%esi
        ap++;
 295:	83 c0 04             	add    $0x4,%eax
 298:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 29b:	85 f6                	test   %esi,%esi
 29d:	75 13                	jne    2b2 <printf+0xf5>
          s = "(null)";
 29f:	be 61 03 00 00       	mov    $0x361,%esi
 2a4:	eb 0c                	jmp    2b2 <printf+0xf5>
          putc(fd, *s);
 2a6:	0f be d2             	movsbl %dl,%edx
 2a9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ac:	e8 79 fe ff ff       	call   12a <putc>
          s++;
 2b1:	46                   	inc    %esi
        while(*s != 0){
 2b2:	8a 16                	mov    (%esi),%dl
 2b4:	84 d2                	test   %dl,%dl
 2b6:	75 ee                	jne    2a6 <printf+0xe9>
      state = 0;
 2b8:	be 00 00 00 00       	mov    $0x0,%esi
 2bd:	e9 27 ff ff ff       	jmp    1e9 <printf+0x2c>
        putc(fd, *ap);
 2c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2c5:	0f be 17             	movsbl (%edi),%edx
 2c8:	8b 45 08             	mov    0x8(%ebp),%eax
 2cb:	e8 5a fe ff ff       	call   12a <putc>
        ap++;
 2d0:	83 c7 04             	add    $0x4,%edi
 2d3:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2d6:	be 00 00 00 00       	mov    $0x0,%esi
 2db:	e9 09 ff ff ff       	jmp    1e9 <printf+0x2c>
        putc(fd, c);
 2e0:	89 fa                	mov    %edi,%edx
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
 2e5:	e8 40 fe ff ff       	call   12a <putc>
      state = 0;
 2ea:	be 00 00 00 00       	mov    $0x0,%esi
 2ef:	e9 f5 fe ff ff       	jmp    1e9 <printf+0x2c>
        putc(fd, '%');
 2f4:	ba 25 00 00 00       	mov    $0x25,%edx
 2f9:	8b 45 08             	mov    0x8(%ebp),%eax
 2fc:	e8 29 fe ff ff       	call   12a <putc>
        putc(fd, c);
 301:	89 fa                	mov    %edi,%edx
 303:	8b 45 08             	mov    0x8(%ebp),%eax
 306:	e8 1f fe ff ff       	call   12a <putc>
      state = 0;
 30b:	be 00 00 00 00       	mov    $0x0,%esi
 310:	e9 d4 fe ff ff       	jmp    1e9 <printf+0x2c>
    }
  }
}
 315:	8d 65 f4             	lea    -0xc(%ebp),%esp
 318:	5b                   	pop    %ebx
 319:	5e                   	pop    %esi
 31a:	5f                   	pop    %edi
 31b:	5d                   	pop    %ebp
 31c:	c3                   	ret    
