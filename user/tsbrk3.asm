
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
  15:	68 30 03 00 00       	push   $0x330
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
  42:	68 3c 03 00 00       	push   $0x33c
  47:	6a 01                	push   $0x1
  49:	e8 7f 01 00 00       	call   1cd <printf>
  printf (1, "%s\n", a+8192);
  4e:	83 c4 0c             	add    $0xc,%esp
  51:	56                   	push   %esi
  52:	68 37 03 00 00       	push   $0x337
  57:	6a 01                	push   $0x1
  59:	e8 6f 01 00 00       	call   1cd <printf>

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

0000012a <getprio>:
SYSCALL(getprio)
 12a:	b8 18 00 00 00       	mov    $0x18,%eax
 12f:	cd 40                	int    $0x40
 131:	c3                   	ret    

00000132 <setprio>:
SYSCALL(setprio)
 132:	b8 19 00 00 00       	mov    $0x19,%eax
 137:	cd 40                	int    $0x40
 139:	c3                   	ret    

0000013a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 13a:	55                   	push   %ebp
 13b:	89 e5                	mov    %esp,%ebp
 13d:	83 ec 1c             	sub    $0x1c,%esp
 140:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 143:	6a 01                	push   $0x1
 145:	8d 55 f4             	lea    -0xc(%ebp),%edx
 148:	52                   	push   %edx
 149:	50                   	push   %eax
 14a:	e8 4b ff ff ff       	call   9a <write>
}
 14f:	83 c4 10             	add    $0x10,%esp
 152:	c9                   	leave  
 153:	c3                   	ret    

00000154 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 154:	55                   	push   %ebp
 155:	89 e5                	mov    %esp,%ebp
 157:	57                   	push   %edi
 158:	56                   	push   %esi
 159:	53                   	push   %ebx
 15a:	83 ec 2c             	sub    $0x2c,%esp
 15d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 160:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 162:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 166:	74 04                	je     16c <printint+0x18>
 168:	85 d2                	test   %edx,%edx
 16a:	78 3c                	js     1a8 <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 16c:	89 d1                	mov    %edx,%ecx
  neg = 0;
 16e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 175:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 17a:	89 c8                	mov    %ecx,%eax
 17c:	ba 00 00 00 00       	mov    $0x0,%edx
 181:	f7 f6                	div    %esi
 183:	89 df                	mov    %ebx,%edi
 185:	43                   	inc    %ebx
 186:	8a 92 d0 03 00 00    	mov    0x3d0(%edx),%dl
 18c:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 190:	89 ca                	mov    %ecx,%edx
 192:	89 c1                	mov    %eax,%ecx
 194:	39 d6                	cmp    %edx,%esi
 196:	76 e2                	jbe    17a <printint+0x26>
  if(neg)
 198:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 19c:	74 24                	je     1c2 <printint+0x6e>
    buf[i++] = '-';
 19e:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1a3:	8d 5f 02             	lea    0x2(%edi),%ebx
 1a6:	eb 1a                	jmp    1c2 <printint+0x6e>
    x = -xx;
 1a8:	89 d1                	mov    %edx,%ecx
 1aa:	f7 d9                	neg    %ecx
    neg = 1;
 1ac:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 1b3:	eb c0                	jmp    175 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 1b5:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1bd:	e8 78 ff ff ff       	call   13a <putc>
  while(--i >= 0)
 1c2:	4b                   	dec    %ebx
 1c3:	79 f0                	jns    1b5 <printint+0x61>
}
 1c5:	83 c4 2c             	add    $0x2c,%esp
 1c8:	5b                   	pop    %ebx
 1c9:	5e                   	pop    %esi
 1ca:	5f                   	pop    %edi
 1cb:	5d                   	pop    %ebp
 1cc:	c3                   	ret    

000001cd <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1cd:	55                   	push   %ebp
 1ce:	89 e5                	mov    %esp,%ebp
 1d0:	57                   	push   %edi
 1d1:	56                   	push   %esi
 1d2:	53                   	push   %ebx
 1d3:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1d6:	8d 45 10             	lea    0x10(%ebp),%eax
 1d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1dc:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1e1:	bb 00 00 00 00       	mov    $0x0,%ebx
 1e6:	eb 12                	jmp    1fa <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1e8:	89 fa                	mov    %edi,%edx
 1ea:	8b 45 08             	mov    0x8(%ebp),%eax
 1ed:	e8 48 ff ff ff       	call   13a <putc>
 1f2:	eb 05                	jmp    1f9 <printf+0x2c>
      }
    } else if(state == '%'){
 1f4:	83 fe 25             	cmp    $0x25,%esi
 1f7:	74 22                	je     21b <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 1f9:	43                   	inc    %ebx
 1fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fd:	8a 04 18             	mov    (%eax,%ebx,1),%al
 200:	84 c0                	test   %al,%al
 202:	0f 84 1d 01 00 00    	je     325 <printf+0x158>
    c = fmt[i] & 0xff;
 208:	0f be f8             	movsbl %al,%edi
 20b:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 20e:	85 f6                	test   %esi,%esi
 210:	75 e2                	jne    1f4 <printf+0x27>
      if(c == '%'){
 212:	83 f8 25             	cmp    $0x25,%eax
 215:	75 d1                	jne    1e8 <printf+0x1b>
        state = '%';
 217:	89 c6                	mov    %eax,%esi
 219:	eb de                	jmp    1f9 <printf+0x2c>
      if(c == 'd'){
 21b:	83 f8 25             	cmp    $0x25,%eax
 21e:	0f 84 cc 00 00 00    	je     2f0 <printf+0x123>
 224:	0f 8c da 00 00 00    	jl     304 <printf+0x137>
 22a:	83 f8 78             	cmp    $0x78,%eax
 22d:	0f 8f d1 00 00 00    	jg     304 <printf+0x137>
 233:	83 f8 63             	cmp    $0x63,%eax
 236:	0f 8c c8 00 00 00    	jl     304 <printf+0x137>
 23c:	83 e8 63             	sub    $0x63,%eax
 23f:	83 f8 15             	cmp    $0x15,%eax
 242:	0f 87 bc 00 00 00    	ja     304 <printf+0x137>
 248:	ff 24 85 78 03 00 00 	jmp    *0x378(,%eax,4)
        printint(fd, *ap, 10, 1);
 24f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 252:	8b 17                	mov    (%edi),%edx
 254:	83 ec 0c             	sub    $0xc,%esp
 257:	6a 01                	push   $0x1
 259:	b9 0a 00 00 00       	mov    $0xa,%ecx
 25e:	8b 45 08             	mov    0x8(%ebp),%eax
 261:	e8 ee fe ff ff       	call   154 <printint>
        ap++;
 266:	83 c7 04             	add    $0x4,%edi
 269:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 26c:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 26f:	be 00 00 00 00       	mov    $0x0,%esi
 274:	eb 83                	jmp    1f9 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 276:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 279:	8b 17                	mov    (%edi),%edx
 27b:	83 ec 0c             	sub    $0xc,%esp
 27e:	6a 00                	push   $0x0
 280:	b9 10 00 00 00       	mov    $0x10,%ecx
 285:	8b 45 08             	mov    0x8(%ebp),%eax
 288:	e8 c7 fe ff ff       	call   154 <printint>
        ap++;
 28d:	83 c7 04             	add    $0x4,%edi
 290:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 293:	83 c4 10             	add    $0x10,%esp
      state = 0;
 296:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 29b:	e9 59 ff ff ff       	jmp    1f9 <printf+0x2c>
        s = (char*)*ap;
 2a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2a3:	8b 30                	mov    (%eax),%esi
        ap++;
 2a5:	83 c0 04             	add    $0x4,%eax
 2a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2ab:	85 f6                	test   %esi,%esi
 2ad:	75 13                	jne    2c2 <printf+0xf5>
          s = "(null)";
 2af:	be 71 03 00 00       	mov    $0x371,%esi
 2b4:	eb 0c                	jmp    2c2 <printf+0xf5>
          putc(fd, *s);
 2b6:	0f be d2             	movsbl %dl,%edx
 2b9:	8b 45 08             	mov    0x8(%ebp),%eax
 2bc:	e8 79 fe ff ff       	call   13a <putc>
          s++;
 2c1:	46                   	inc    %esi
        while(*s != 0){
 2c2:	8a 16                	mov    (%esi),%dl
 2c4:	84 d2                	test   %dl,%dl
 2c6:	75 ee                	jne    2b6 <printf+0xe9>
      state = 0;
 2c8:	be 00 00 00 00       	mov    $0x0,%esi
 2cd:	e9 27 ff ff ff       	jmp    1f9 <printf+0x2c>
        putc(fd, *ap);
 2d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2d5:	0f be 17             	movsbl (%edi),%edx
 2d8:	8b 45 08             	mov    0x8(%ebp),%eax
 2db:	e8 5a fe ff ff       	call   13a <putc>
        ap++;
 2e0:	83 c7 04             	add    $0x4,%edi
 2e3:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2e6:	be 00 00 00 00       	mov    $0x0,%esi
 2eb:	e9 09 ff ff ff       	jmp    1f9 <printf+0x2c>
        putc(fd, c);
 2f0:	89 fa                	mov    %edi,%edx
 2f2:	8b 45 08             	mov    0x8(%ebp),%eax
 2f5:	e8 40 fe ff ff       	call   13a <putc>
      state = 0;
 2fa:	be 00 00 00 00       	mov    $0x0,%esi
 2ff:	e9 f5 fe ff ff       	jmp    1f9 <printf+0x2c>
        putc(fd, '%');
 304:	ba 25 00 00 00       	mov    $0x25,%edx
 309:	8b 45 08             	mov    0x8(%ebp),%eax
 30c:	e8 29 fe ff ff       	call   13a <putc>
        putc(fd, c);
 311:	89 fa                	mov    %edi,%edx
 313:	8b 45 08             	mov    0x8(%ebp),%eax
 316:	e8 1f fe ff ff       	call   13a <putc>
      state = 0;
 31b:	be 00 00 00 00       	mov    $0x0,%esi
 320:	e9 d4 fe ff ff       	jmp    1f9 <printf+0x2c>
    }
  }
}
 325:	8d 65 f4             	lea    -0xc(%ebp),%esp
 328:	5b                   	pop    %ebx
 329:	5e                   	pop    %esi
 32a:	5f                   	pop    %edi
 32b:	5d                   	pop    %ebp
 32c:	c3                   	ret    
