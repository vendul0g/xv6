
tsbrk5:     file format elf32-i386


Disassembly of section .text:

00000000 <test1>:
#include "user.h"

int i = 1;

void test1()
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 10             	sub    $0x10,%esp
  char* a = sbrk (0);
   7:	6a 00                	push   $0x0
   9:	e8 35 01 00 00       	call   143 <sbrk>
   e:	89 c3                	mov    %eax,%ebx

  printf (1, "Debe fallar ahora:\n");
  10:	83 c4 08             	add    $0x8,%esp
  13:	68 60 03 00 00       	push   $0x360
  18:	6a 01                	push   $0x1
  1a:	e8 df 01 00 00       	call   1fe <printf>
  *(a+1) = 1;  // Debe fallar
  1f:	c6 43 01 01          	movb   $0x1,0x1(%ebx)
}
  23:	83 c4 10             	add    $0x10,%esp
  26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  29:	c9                   	leave  
  2a:	c3                   	ret    

0000002b <test2>:

void test2()
{
  2b:	55                   	push   %ebp
  2c:	89 e5                	mov    %esp,%ebp
  2e:	83 ec 10             	sub    $0x10,%esp
  // Página de guarda:
  printf (1, "Si no fallo antes (mal), ahora tambien debe fallar:\n");
  31:	68 78 03 00 00       	push   $0x378
  36:	6a 01                	push   $0x1
  38:	e8 c1 01 00 00       	call   1fe <printf>
  char* a = (char*)((int)&i + 4095);
  printf (1, "%d\n", a);
  3d:	83 c4 0c             	add    $0xc,%esp
  40:	68 77 15 00 00       	push   $0x1577
  45:	68 74 03 00 00       	push   $0x374
  4a:	6a 01                	push   $0x1
  4c:	e8 ad 01 00 00       	call   1fe <printf>
  *a = 1;
  51:	c6 05 77 15 00 00 01 	movb   $0x1,0x1577
}
  58:	83 c4 10             	add    $0x10,%esp
  5b:	c9                   	leave  
  5c:	c3                   	ret    

0000005d <test3>:

void test3()
{
  5d:	55                   	push   %ebp
  5e:	89 e5                	mov    %esp,%ebp
  60:	83 ec 10             	sub    $0x10,%esp
  // Acceder al núcleo
  printf (1, "Si no fallo antes (mal), ahora tambien debe fallar:\n");
  63:	68 78 03 00 00       	push   $0x378
  68:	6a 01                	push   $0x1
  6a:	e8 8f 01 00 00       	call   1fe <printf>
  char* a = (char*)0x80000001;
  *(a+1) = 1;  // Debe fallar (si lo anterior no ha fallado)
  6f:	c6 05 02 00 00 80 01 	movb   $0x1,0x80000002
}
  76:	83 c4 10             	add    $0x10,%esp
  79:	c9                   	leave  
  7a:	c3                   	ret    

0000007b <main>:


int
main(int argc, char *argv[])
{
  7b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  7f:	83 e4 f0             	and    $0xfffffff0,%esp
  82:	ff 71 fc             	push   -0x4(%ecx)
  85:	55                   	push   %ebp
  86:	89 e5                	mov    %esp,%ebp
  88:	51                   	push   %ecx
  89:	83 ec 0c             	sub    $0xc,%esp
  printf (1, "Este programa primero intenta acceder mas alla de sz.\n");
  8c:	68 b0 03 00 00       	push   $0x3b0
  91:	6a 01                	push   $0x1
  93:	e8 66 01 00 00       	call   1fe <printf>

  // Más allá de sz
  test1();
  98:	e8 63 ff ff ff       	call   0 <test1>

  // Guarda
  test2();
  9d:	e8 89 ff ff ff       	call   2b <test2>

  // Núcleo
  test3();
  a2:	e8 b6 ff ff ff       	call   5d <test3>

  exit (0);
  a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  ae:	e8 08 00 00 00       	call   bb <exit>

000000b3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  b3:	b8 01 00 00 00       	mov    $0x1,%eax
  b8:	cd 40                	int    $0x40
  ba:	c3                   	ret    

000000bb <exit>:
SYSCALL(exit)
  bb:	b8 02 00 00 00       	mov    $0x2,%eax
  c0:	cd 40                	int    $0x40
  c2:	c3                   	ret    

000000c3 <wait>:
SYSCALL(wait)
  c3:	b8 03 00 00 00       	mov    $0x3,%eax
  c8:	cd 40                	int    $0x40
  ca:	c3                   	ret    

000000cb <pipe>:
SYSCALL(pipe)
  cb:	b8 04 00 00 00       	mov    $0x4,%eax
  d0:	cd 40                	int    $0x40
  d2:	c3                   	ret    

000000d3 <read>:
SYSCALL(read)
  d3:	b8 05 00 00 00       	mov    $0x5,%eax
  d8:	cd 40                	int    $0x40
  da:	c3                   	ret    

000000db <write>:
SYSCALL(write)
  db:	b8 10 00 00 00       	mov    $0x10,%eax
  e0:	cd 40                	int    $0x40
  e2:	c3                   	ret    

000000e3 <close>:
SYSCALL(close)
  e3:	b8 15 00 00 00       	mov    $0x15,%eax
  e8:	cd 40                	int    $0x40
  ea:	c3                   	ret    

000000eb <kill>:
SYSCALL(kill)
  eb:	b8 06 00 00 00       	mov    $0x6,%eax
  f0:	cd 40                	int    $0x40
  f2:	c3                   	ret    

000000f3 <exec>:
SYSCALL(exec)
  f3:	b8 07 00 00 00       	mov    $0x7,%eax
  f8:	cd 40                	int    $0x40
  fa:	c3                   	ret    

000000fb <open>:
SYSCALL(open)
  fb:	b8 0f 00 00 00       	mov    $0xf,%eax
 100:	cd 40                	int    $0x40
 102:	c3                   	ret    

00000103 <mknod>:
SYSCALL(mknod)
 103:	b8 11 00 00 00       	mov    $0x11,%eax
 108:	cd 40                	int    $0x40
 10a:	c3                   	ret    

0000010b <unlink>:
SYSCALL(unlink)
 10b:	b8 12 00 00 00       	mov    $0x12,%eax
 110:	cd 40                	int    $0x40
 112:	c3                   	ret    

00000113 <fstat>:
SYSCALL(fstat)
 113:	b8 08 00 00 00       	mov    $0x8,%eax
 118:	cd 40                	int    $0x40
 11a:	c3                   	ret    

0000011b <link>:
SYSCALL(link)
 11b:	b8 13 00 00 00       	mov    $0x13,%eax
 120:	cd 40                	int    $0x40
 122:	c3                   	ret    

00000123 <mkdir>:
SYSCALL(mkdir)
 123:	b8 14 00 00 00       	mov    $0x14,%eax
 128:	cd 40                	int    $0x40
 12a:	c3                   	ret    

0000012b <chdir>:
SYSCALL(chdir)
 12b:	b8 09 00 00 00       	mov    $0x9,%eax
 130:	cd 40                	int    $0x40
 132:	c3                   	ret    

00000133 <dup>:
SYSCALL(dup)
 133:	b8 0a 00 00 00       	mov    $0xa,%eax
 138:	cd 40                	int    $0x40
 13a:	c3                   	ret    

0000013b <getpid>:
SYSCALL(getpid)
 13b:	b8 0b 00 00 00       	mov    $0xb,%eax
 140:	cd 40                	int    $0x40
 142:	c3                   	ret    

00000143 <sbrk>:
SYSCALL(sbrk)
 143:	b8 0c 00 00 00       	mov    $0xc,%eax
 148:	cd 40                	int    $0x40
 14a:	c3                   	ret    

0000014b <sleep>:
SYSCALL(sleep)
 14b:	b8 0d 00 00 00       	mov    $0xd,%eax
 150:	cd 40                	int    $0x40
 152:	c3                   	ret    

00000153 <uptime>:
SYSCALL(uptime)
 153:	b8 0e 00 00 00       	mov    $0xe,%eax
 158:	cd 40                	int    $0x40
 15a:	c3                   	ret    

0000015b <date>:
SYSCALL(date)
 15b:	b8 16 00 00 00       	mov    $0x16,%eax
 160:	cd 40                	int    $0x40
 162:	c3                   	ret    

00000163 <dup2>:
SYSCALL(dup2)
 163:	b8 17 00 00 00       	mov    $0x17,%eax
 168:	cd 40                	int    $0x40
 16a:	c3                   	ret    

0000016b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 16b:	55                   	push   %ebp
 16c:	89 e5                	mov    %esp,%ebp
 16e:	83 ec 1c             	sub    $0x1c,%esp
 171:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 174:	6a 01                	push   $0x1
 176:	8d 55 f4             	lea    -0xc(%ebp),%edx
 179:	52                   	push   %edx
 17a:	50                   	push   %eax
 17b:	e8 5b ff ff ff       	call   db <write>
}
 180:	83 c4 10             	add    $0x10,%esp
 183:	c9                   	leave  
 184:	c3                   	ret    

00000185 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 185:	55                   	push   %ebp
 186:	89 e5                	mov    %esp,%ebp
 188:	57                   	push   %edi
 189:	56                   	push   %esi
 18a:	53                   	push   %ebx
 18b:	83 ec 2c             	sub    $0x2c,%esp
 18e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 191:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 193:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 197:	74 04                	je     19d <printint+0x18>
 199:	85 d2                	test   %edx,%edx
 19b:	78 3c                	js     1d9 <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 19d:	89 d1                	mov    %edx,%ecx
  neg = 0;
 19f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 1a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 1ab:	89 c8                	mov    %ecx,%eax
 1ad:	ba 00 00 00 00       	mov    $0x0,%edx
 1b2:	f7 f6                	div    %esi
 1b4:	89 df                	mov    %ebx,%edi
 1b6:	43                   	inc    %ebx
 1b7:	8a 92 48 04 00 00    	mov    0x448(%edx),%dl
 1bd:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1c1:	89 ca                	mov    %ecx,%edx
 1c3:	89 c1                	mov    %eax,%ecx
 1c5:	39 d6                	cmp    %edx,%esi
 1c7:	76 e2                	jbe    1ab <printint+0x26>
  if(neg)
 1c9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 1cd:	74 24                	je     1f3 <printint+0x6e>
    buf[i++] = '-';
 1cf:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1d4:	8d 5f 02             	lea    0x2(%edi),%ebx
 1d7:	eb 1a                	jmp    1f3 <printint+0x6e>
    x = -xx;
 1d9:	89 d1                	mov    %edx,%ecx
 1db:	f7 d9                	neg    %ecx
    neg = 1;
 1dd:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 1e4:	eb c0                	jmp    1a6 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 1e6:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1ee:	e8 78 ff ff ff       	call   16b <putc>
  while(--i >= 0)
 1f3:	4b                   	dec    %ebx
 1f4:	79 f0                	jns    1e6 <printint+0x61>
}
 1f6:	83 c4 2c             	add    $0x2c,%esp
 1f9:	5b                   	pop    %ebx
 1fa:	5e                   	pop    %esi
 1fb:	5f                   	pop    %edi
 1fc:	5d                   	pop    %ebp
 1fd:	c3                   	ret    

000001fe <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1fe:	55                   	push   %ebp
 1ff:	89 e5                	mov    %esp,%ebp
 201:	57                   	push   %edi
 202:	56                   	push   %esi
 203:	53                   	push   %ebx
 204:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 207:	8d 45 10             	lea    0x10(%ebp),%eax
 20a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 20d:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 212:	bb 00 00 00 00       	mov    $0x0,%ebx
 217:	eb 12                	jmp    22b <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 219:	89 fa                	mov    %edi,%edx
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	e8 48 ff ff ff       	call   16b <putc>
 223:	eb 05                	jmp    22a <printf+0x2c>
      }
    } else if(state == '%'){
 225:	83 fe 25             	cmp    $0x25,%esi
 228:	74 22                	je     24c <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 22a:	43                   	inc    %ebx
 22b:	8b 45 0c             	mov    0xc(%ebp),%eax
 22e:	8a 04 18             	mov    (%eax,%ebx,1),%al
 231:	84 c0                	test   %al,%al
 233:	0f 84 1d 01 00 00    	je     356 <printf+0x158>
    c = fmt[i] & 0xff;
 239:	0f be f8             	movsbl %al,%edi
 23c:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 23f:	85 f6                	test   %esi,%esi
 241:	75 e2                	jne    225 <printf+0x27>
      if(c == '%'){
 243:	83 f8 25             	cmp    $0x25,%eax
 246:	75 d1                	jne    219 <printf+0x1b>
        state = '%';
 248:	89 c6                	mov    %eax,%esi
 24a:	eb de                	jmp    22a <printf+0x2c>
      if(c == 'd'){
 24c:	83 f8 25             	cmp    $0x25,%eax
 24f:	0f 84 cc 00 00 00    	je     321 <printf+0x123>
 255:	0f 8c da 00 00 00    	jl     335 <printf+0x137>
 25b:	83 f8 78             	cmp    $0x78,%eax
 25e:	0f 8f d1 00 00 00    	jg     335 <printf+0x137>
 264:	83 f8 63             	cmp    $0x63,%eax
 267:	0f 8c c8 00 00 00    	jl     335 <printf+0x137>
 26d:	83 e8 63             	sub    $0x63,%eax
 270:	83 f8 15             	cmp    $0x15,%eax
 273:	0f 87 bc 00 00 00    	ja     335 <printf+0x137>
 279:	ff 24 85 f0 03 00 00 	jmp    *0x3f0(,%eax,4)
        printint(fd, *ap, 10, 1);
 280:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 283:	8b 17                	mov    (%edi),%edx
 285:	83 ec 0c             	sub    $0xc,%esp
 288:	6a 01                	push   $0x1
 28a:	b9 0a 00 00 00       	mov    $0xa,%ecx
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	e8 ee fe ff ff       	call   185 <printint>
        ap++;
 297:	83 c7 04             	add    $0x4,%edi
 29a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 29d:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2a0:	be 00 00 00 00       	mov    $0x0,%esi
 2a5:	eb 83                	jmp    22a <printf+0x2c>
        printint(fd, *ap, 16, 0);
 2a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2aa:	8b 17                	mov    (%edi),%edx
 2ac:	83 ec 0c             	sub    $0xc,%esp
 2af:	6a 00                	push   $0x0
 2b1:	b9 10 00 00 00       	mov    $0x10,%ecx
 2b6:	8b 45 08             	mov    0x8(%ebp),%eax
 2b9:	e8 c7 fe ff ff       	call   185 <printint>
        ap++;
 2be:	83 c7 04             	add    $0x4,%edi
 2c1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2c4:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2c7:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 2cc:	e9 59 ff ff ff       	jmp    22a <printf+0x2c>
        s = (char*)*ap;
 2d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2d4:	8b 30                	mov    (%eax),%esi
        ap++;
 2d6:	83 c0 04             	add    $0x4,%eax
 2d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2dc:	85 f6                	test   %esi,%esi
 2de:	75 13                	jne    2f3 <printf+0xf5>
          s = "(null)";
 2e0:	be e7 03 00 00       	mov    $0x3e7,%esi
 2e5:	eb 0c                	jmp    2f3 <printf+0xf5>
          putc(fd, *s);
 2e7:	0f be d2             	movsbl %dl,%edx
 2ea:	8b 45 08             	mov    0x8(%ebp),%eax
 2ed:	e8 79 fe ff ff       	call   16b <putc>
          s++;
 2f2:	46                   	inc    %esi
        while(*s != 0){
 2f3:	8a 16                	mov    (%esi),%dl
 2f5:	84 d2                	test   %dl,%dl
 2f7:	75 ee                	jne    2e7 <printf+0xe9>
      state = 0;
 2f9:	be 00 00 00 00       	mov    $0x0,%esi
 2fe:	e9 27 ff ff ff       	jmp    22a <printf+0x2c>
        putc(fd, *ap);
 303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 306:	0f be 17             	movsbl (%edi),%edx
 309:	8b 45 08             	mov    0x8(%ebp),%eax
 30c:	e8 5a fe ff ff       	call   16b <putc>
        ap++;
 311:	83 c7 04             	add    $0x4,%edi
 314:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 317:	be 00 00 00 00       	mov    $0x0,%esi
 31c:	e9 09 ff ff ff       	jmp    22a <printf+0x2c>
        putc(fd, c);
 321:	89 fa                	mov    %edi,%edx
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	e8 40 fe ff ff       	call   16b <putc>
      state = 0;
 32b:	be 00 00 00 00       	mov    $0x0,%esi
 330:	e9 f5 fe ff ff       	jmp    22a <printf+0x2c>
        putc(fd, '%');
 335:	ba 25 00 00 00       	mov    $0x25,%edx
 33a:	8b 45 08             	mov    0x8(%ebp),%eax
 33d:	e8 29 fe ff ff       	call   16b <putc>
        putc(fd, c);
 342:	89 fa                	mov    %edi,%edx
 344:	8b 45 08             	mov    0x8(%ebp),%eax
 347:	e8 1f fe ff ff       	call   16b <putc>
      state = 0;
 34c:	be 00 00 00 00       	mov    $0x0,%esi
 351:	e9 d4 fe ff ff       	jmp    22a <printf+0x2c>
    }
  }
}
 356:	8d 65 f4             	lea    -0xc(%ebp),%esp
 359:	5b                   	pop    %ebx
 35a:	5e                   	pop    %esi
 35b:	5f                   	pop    %edi
 35c:	5d                   	pop    %ebp
 35d:	c3                   	ret    
