
tprio2:     file format elf32-i386


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
  10:	83 ec 0c             	sub    $0xc,%esp
  // Padre termina
  if (fork() != 0)
  13:	e8 5f 00 00 00       	call   77 <fork>
  18:	85 c0                	test   %eax,%eax
  1a:	74 0a                	je     26 <main+0x26>
    exit(1);
  1c:	83 ec 0c             	sub    $0xc,%esp
  1f:	6a 01                	push   $0x1
  21:	e8 59 00 00 00       	call   7f <exit>
  26:	89 c3                	mov    %eax,%ebx
  
  // Establecer prioridad normal. El shell aparecerá normalmente.
  setprio (getpid(), NORM_PRIO);
  28:	e8 d2 00 00 00       	call   ff <getpid>
  2d:	83 ec 08             	sub    $0x8,%esp
  30:	6a 00                	push   $0x0
  32:	50                   	push   %eax
  33:	e8 ff 00 00 00       	call   137 <setprio>

  int r = 0;
  
  for (int i = 0; i < 2000; ++i)
  38:	83 c4 10             	add    $0x10,%esp
  3b:	89 de                	mov    %ebx,%esi
  int r = 0;
  3d:	89 da                	mov    %ebx,%edx
  for (int i = 0; i < 2000; ++i)
  3f:	eb 0e                	jmp    4f <main+0x4f>
    for (int j = 0; j < 1000000; ++j)
      r += i + j;
  41:	8d 0c 06             	lea    (%esi,%eax,1),%ecx
  44:	01 ca                	add    %ecx,%edx
    for (int j = 0; j < 1000000; ++j)
  46:	40                   	inc    %eax
  47:	3d 3f 42 0f 00       	cmp    $0xf423f,%eax
  4c:	7e f3                	jle    41 <main+0x41>
  for (int i = 0; i < 2000; ++i)
  4e:	46                   	inc    %esi
  4f:	81 fe cf 07 00 00    	cmp    $0x7cf,%esi
  55:	7f 04                	jg     5b <main+0x5b>
    for (int j = 0; j < 1000000; ++j)
  57:	89 d8                	mov    %ebx,%eax
  59:	eb ec                	jmp    47 <main+0x47>

  // Imprime el resultado
  printf (1, "Resultado: %d\n", r);
  5b:	83 ec 04             	sub    $0x4,%esp
  5e:	52                   	push   %edx
  5f:	68 34 03 00 00       	push   $0x334
  64:	6a 01                	push   $0x1
  66:	e8 67 01 00 00       	call   1d2 <printf>
  
  exit(0);
  6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  72:	e8 08 00 00 00       	call   7f <exit>

00000077 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  77:	b8 01 00 00 00       	mov    $0x1,%eax
  7c:	cd 40                	int    $0x40
  7e:	c3                   	ret    

0000007f <exit>:
SYSCALL(exit)
  7f:	b8 02 00 00 00       	mov    $0x2,%eax
  84:	cd 40                	int    $0x40
  86:	c3                   	ret    

00000087 <wait>:
SYSCALL(wait)
  87:	b8 03 00 00 00       	mov    $0x3,%eax
  8c:	cd 40                	int    $0x40
  8e:	c3                   	ret    

0000008f <pipe>:
SYSCALL(pipe)
  8f:	b8 04 00 00 00       	mov    $0x4,%eax
  94:	cd 40                	int    $0x40
  96:	c3                   	ret    

00000097 <read>:
SYSCALL(read)
  97:	b8 05 00 00 00       	mov    $0x5,%eax
  9c:	cd 40                	int    $0x40
  9e:	c3                   	ret    

0000009f <write>:
SYSCALL(write)
  9f:	b8 10 00 00 00       	mov    $0x10,%eax
  a4:	cd 40                	int    $0x40
  a6:	c3                   	ret    

000000a7 <close>:
SYSCALL(close)
  a7:	b8 15 00 00 00       	mov    $0x15,%eax
  ac:	cd 40                	int    $0x40
  ae:	c3                   	ret    

000000af <kill>:
SYSCALL(kill)
  af:	b8 06 00 00 00       	mov    $0x6,%eax
  b4:	cd 40                	int    $0x40
  b6:	c3                   	ret    

000000b7 <exec>:
SYSCALL(exec)
  b7:	b8 07 00 00 00       	mov    $0x7,%eax
  bc:	cd 40                	int    $0x40
  be:	c3                   	ret    

000000bf <open>:
SYSCALL(open)
  bf:	b8 0f 00 00 00       	mov    $0xf,%eax
  c4:	cd 40                	int    $0x40
  c6:	c3                   	ret    

000000c7 <mknod>:
SYSCALL(mknod)
  c7:	b8 11 00 00 00       	mov    $0x11,%eax
  cc:	cd 40                	int    $0x40
  ce:	c3                   	ret    

000000cf <unlink>:
SYSCALL(unlink)
  cf:	b8 12 00 00 00       	mov    $0x12,%eax
  d4:	cd 40                	int    $0x40
  d6:	c3                   	ret    

000000d7 <fstat>:
SYSCALL(fstat)
  d7:	b8 08 00 00 00       	mov    $0x8,%eax
  dc:	cd 40                	int    $0x40
  de:	c3                   	ret    

000000df <link>:
SYSCALL(link)
  df:	b8 13 00 00 00       	mov    $0x13,%eax
  e4:	cd 40                	int    $0x40
  e6:	c3                   	ret    

000000e7 <mkdir>:
SYSCALL(mkdir)
  e7:	b8 14 00 00 00       	mov    $0x14,%eax
  ec:	cd 40                	int    $0x40
  ee:	c3                   	ret    

000000ef <chdir>:
SYSCALL(chdir)
  ef:	b8 09 00 00 00       	mov    $0x9,%eax
  f4:	cd 40                	int    $0x40
  f6:	c3                   	ret    

000000f7 <dup>:
SYSCALL(dup)
  f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  fc:	cd 40                	int    $0x40
  fe:	c3                   	ret    

000000ff <getpid>:
SYSCALL(getpid)
  ff:	b8 0b 00 00 00       	mov    $0xb,%eax
 104:	cd 40                	int    $0x40
 106:	c3                   	ret    

00000107 <sbrk>:
SYSCALL(sbrk)
 107:	b8 0c 00 00 00       	mov    $0xc,%eax
 10c:	cd 40                	int    $0x40
 10e:	c3                   	ret    

0000010f <sleep>:
SYSCALL(sleep)
 10f:	b8 0d 00 00 00       	mov    $0xd,%eax
 114:	cd 40                	int    $0x40
 116:	c3                   	ret    

00000117 <uptime>:
SYSCALL(uptime)
 117:	b8 0e 00 00 00       	mov    $0xe,%eax
 11c:	cd 40                	int    $0x40
 11e:	c3                   	ret    

0000011f <date>:
SYSCALL(date)
 11f:	b8 16 00 00 00       	mov    $0x16,%eax
 124:	cd 40                	int    $0x40
 126:	c3                   	ret    

00000127 <dup2>:
SYSCALL(dup2)
 127:	b8 17 00 00 00       	mov    $0x17,%eax
 12c:	cd 40                	int    $0x40
 12e:	c3                   	ret    

0000012f <getprio>:
SYSCALL(getprio)
 12f:	b8 18 00 00 00       	mov    $0x18,%eax
 134:	cd 40                	int    $0x40
 136:	c3                   	ret    

00000137 <setprio>:
SYSCALL(setprio)
 137:	b8 19 00 00 00       	mov    $0x19,%eax
 13c:	cd 40                	int    $0x40
 13e:	c3                   	ret    

0000013f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 13f:	55                   	push   %ebp
 140:	89 e5                	mov    %esp,%ebp
 142:	83 ec 1c             	sub    $0x1c,%esp
 145:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 148:	6a 01                	push   $0x1
 14a:	8d 55 f4             	lea    -0xc(%ebp),%edx
 14d:	52                   	push   %edx
 14e:	50                   	push   %eax
 14f:	e8 4b ff ff ff       	call   9f <write>
}
 154:	83 c4 10             	add    $0x10,%esp
 157:	c9                   	leave  
 158:	c3                   	ret    

00000159 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 159:	55                   	push   %ebp
 15a:	89 e5                	mov    %esp,%ebp
 15c:	57                   	push   %edi
 15d:	56                   	push   %esi
 15e:	53                   	push   %ebx
 15f:	83 ec 2c             	sub    $0x2c,%esp
 162:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 165:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 167:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 16b:	74 04                	je     171 <printint+0x18>
 16d:	85 d2                	test   %edx,%edx
 16f:	78 3c                	js     1ad <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 171:	89 d1                	mov    %edx,%ecx
  neg = 0;
 173:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 17a:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 17f:	89 c8                	mov    %ecx,%eax
 181:	ba 00 00 00 00       	mov    $0x0,%edx
 186:	f7 f6                	div    %esi
 188:	89 df                	mov    %ebx,%edi
 18a:	43                   	inc    %ebx
 18b:	8a 92 a4 03 00 00    	mov    0x3a4(%edx),%dl
 191:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 195:	89 ca                	mov    %ecx,%edx
 197:	89 c1                	mov    %eax,%ecx
 199:	39 d6                	cmp    %edx,%esi
 19b:	76 e2                	jbe    17f <printint+0x26>
  if(neg)
 19d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 1a1:	74 24                	je     1c7 <printint+0x6e>
    buf[i++] = '-';
 1a3:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1a8:	8d 5f 02             	lea    0x2(%edi),%ebx
 1ab:	eb 1a                	jmp    1c7 <printint+0x6e>
    x = -xx;
 1ad:	89 d1                	mov    %edx,%ecx
 1af:	f7 d9                	neg    %ecx
    neg = 1;
 1b1:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 1b8:	eb c0                	jmp    17a <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 1ba:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1c2:	e8 78 ff ff ff       	call   13f <putc>
  while(--i >= 0)
 1c7:	4b                   	dec    %ebx
 1c8:	79 f0                	jns    1ba <printint+0x61>
}
 1ca:	83 c4 2c             	add    $0x2c,%esp
 1cd:	5b                   	pop    %ebx
 1ce:	5e                   	pop    %esi
 1cf:	5f                   	pop    %edi
 1d0:	5d                   	pop    %ebp
 1d1:	c3                   	ret    

000001d2 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1d2:	55                   	push   %ebp
 1d3:	89 e5                	mov    %esp,%ebp
 1d5:	57                   	push   %edi
 1d6:	56                   	push   %esi
 1d7:	53                   	push   %ebx
 1d8:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1db:	8d 45 10             	lea    0x10(%ebp),%eax
 1de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1e1:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1e6:	bb 00 00 00 00       	mov    $0x0,%ebx
 1eb:	eb 12                	jmp    1ff <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1ed:	89 fa                	mov    %edi,%edx
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	e8 48 ff ff ff       	call   13f <putc>
 1f7:	eb 05                	jmp    1fe <printf+0x2c>
      }
    } else if(state == '%'){
 1f9:	83 fe 25             	cmp    $0x25,%esi
 1fc:	74 22                	je     220 <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 1fe:	43                   	inc    %ebx
 1ff:	8b 45 0c             	mov    0xc(%ebp),%eax
 202:	8a 04 18             	mov    (%eax,%ebx,1),%al
 205:	84 c0                	test   %al,%al
 207:	0f 84 1d 01 00 00    	je     32a <printf+0x158>
    c = fmt[i] & 0xff;
 20d:	0f be f8             	movsbl %al,%edi
 210:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 213:	85 f6                	test   %esi,%esi
 215:	75 e2                	jne    1f9 <printf+0x27>
      if(c == '%'){
 217:	83 f8 25             	cmp    $0x25,%eax
 21a:	75 d1                	jne    1ed <printf+0x1b>
        state = '%';
 21c:	89 c6                	mov    %eax,%esi
 21e:	eb de                	jmp    1fe <printf+0x2c>
      if(c == 'd'){
 220:	83 f8 25             	cmp    $0x25,%eax
 223:	0f 84 cc 00 00 00    	je     2f5 <printf+0x123>
 229:	0f 8c da 00 00 00    	jl     309 <printf+0x137>
 22f:	83 f8 78             	cmp    $0x78,%eax
 232:	0f 8f d1 00 00 00    	jg     309 <printf+0x137>
 238:	83 f8 63             	cmp    $0x63,%eax
 23b:	0f 8c c8 00 00 00    	jl     309 <printf+0x137>
 241:	83 e8 63             	sub    $0x63,%eax
 244:	83 f8 15             	cmp    $0x15,%eax
 247:	0f 87 bc 00 00 00    	ja     309 <printf+0x137>
 24d:	ff 24 85 4c 03 00 00 	jmp    *0x34c(,%eax,4)
        printint(fd, *ap, 10, 1);
 254:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 257:	8b 17                	mov    (%edi),%edx
 259:	83 ec 0c             	sub    $0xc,%esp
 25c:	6a 01                	push   $0x1
 25e:	b9 0a 00 00 00       	mov    $0xa,%ecx
 263:	8b 45 08             	mov    0x8(%ebp),%eax
 266:	e8 ee fe ff ff       	call   159 <printint>
        ap++;
 26b:	83 c7 04             	add    $0x4,%edi
 26e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 271:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 274:	be 00 00 00 00       	mov    $0x0,%esi
 279:	eb 83                	jmp    1fe <printf+0x2c>
        printint(fd, *ap, 16, 0);
 27b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 27e:	8b 17                	mov    (%edi),%edx
 280:	83 ec 0c             	sub    $0xc,%esp
 283:	6a 00                	push   $0x0
 285:	b9 10 00 00 00       	mov    $0x10,%ecx
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	e8 c7 fe ff ff       	call   159 <printint>
        ap++;
 292:	83 c7 04             	add    $0x4,%edi
 295:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 298:	83 c4 10             	add    $0x10,%esp
      state = 0;
 29b:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 2a0:	e9 59 ff ff ff       	jmp    1fe <printf+0x2c>
        s = (char*)*ap;
 2a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2a8:	8b 30                	mov    (%eax),%esi
        ap++;
 2aa:	83 c0 04             	add    $0x4,%eax
 2ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2b0:	85 f6                	test   %esi,%esi
 2b2:	75 13                	jne    2c7 <printf+0xf5>
          s = "(null)";
 2b4:	be 43 03 00 00       	mov    $0x343,%esi
 2b9:	eb 0c                	jmp    2c7 <printf+0xf5>
          putc(fd, *s);
 2bb:	0f be d2             	movsbl %dl,%edx
 2be:	8b 45 08             	mov    0x8(%ebp),%eax
 2c1:	e8 79 fe ff ff       	call   13f <putc>
          s++;
 2c6:	46                   	inc    %esi
        while(*s != 0){
 2c7:	8a 16                	mov    (%esi),%dl
 2c9:	84 d2                	test   %dl,%dl
 2cb:	75 ee                	jne    2bb <printf+0xe9>
      state = 0;
 2cd:	be 00 00 00 00       	mov    $0x0,%esi
 2d2:	e9 27 ff ff ff       	jmp    1fe <printf+0x2c>
        putc(fd, *ap);
 2d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2da:	0f be 17             	movsbl (%edi),%edx
 2dd:	8b 45 08             	mov    0x8(%ebp),%eax
 2e0:	e8 5a fe ff ff       	call   13f <putc>
        ap++;
 2e5:	83 c7 04             	add    $0x4,%edi
 2e8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2eb:	be 00 00 00 00       	mov    $0x0,%esi
 2f0:	e9 09 ff ff ff       	jmp    1fe <printf+0x2c>
        putc(fd, c);
 2f5:	89 fa                	mov    %edi,%edx
 2f7:	8b 45 08             	mov    0x8(%ebp),%eax
 2fa:	e8 40 fe ff ff       	call   13f <putc>
      state = 0;
 2ff:	be 00 00 00 00       	mov    $0x0,%esi
 304:	e9 f5 fe ff ff       	jmp    1fe <printf+0x2c>
        putc(fd, '%');
 309:	ba 25 00 00 00       	mov    $0x25,%edx
 30e:	8b 45 08             	mov    0x8(%ebp),%eax
 311:	e8 29 fe ff ff       	call   13f <putc>
        putc(fd, c);
 316:	89 fa                	mov    %edi,%edx
 318:	8b 45 08             	mov    0x8(%ebp),%eax
 31b:	e8 1f fe ff ff       	call   13f <putc>
      state = 0;
 320:	be 00 00 00 00       	mov    $0x0,%esi
 325:	e9 d4 fe ff ff       	jmp    1fe <printf+0x2c>
    }
  }
}
 32a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 32d:	5b                   	pop    %ebx
 32e:	5e                   	pop    %esi
 32f:	5f                   	pop    %edi
 330:	5d                   	pop    %ebp
 331:	c3                   	ret    
