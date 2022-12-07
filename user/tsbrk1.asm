
tsbrk1:     file format elf32-i386


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
  10:	83 ec 18             	sub    $0x18,%esp
  char* a = sbrk (15000);
  13:	68 98 3a 00 00       	push   $0x3a98
  18:	e8 54 01 00 00       	call   171 <sbrk>
  1d:	89 c3                	mov    %eax,%ebx
  a[500] = 1;
  1f:	c6 80 f4 01 00 00 01 	movb   $0x1,0x1f4(%eax)
  if ((uint)a + 15000 != (uint) sbrk (-15000))
  26:	8d b0 98 3a 00 00    	lea    0x3a98(%eax),%esi
  2c:	c7 04 24 68 c5 ff ff 	movl   $0xffffc568,(%esp)
  33:	e8 39 01 00 00       	call   171 <sbrk>
  38:	83 c4 10             	add    $0x10,%esp
  3b:	39 c6                	cmp    %eax,%esi
  3d:	74 1b                	je     5a <main+0x5a>
  {
    printf (1, "sbrk() con número positivo falló.\n");
  3f:	83 ec 08             	sub    $0x8,%esp
  42:	68 8c 03 00 00       	push   $0x38c
  47:	6a 01                	push   $0x1
  49:	e8 de 01 00 00       	call   22c <printf>
    exit(1);
  4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  55:	e8 8f 00 00 00       	call   e9 <exit>
  }

  if (a != sbrk (0))
  5a:	83 ec 0c             	sub    $0xc,%esp
  5d:	6a 00                	push   $0x0
  5f:	e8 0d 01 00 00       	call   171 <sbrk>
  64:	83 c4 10             	add    $0x10,%esp
  67:	39 c3                	cmp    %eax,%ebx
  69:	74 1b                	je     86 <main+0x86>
  {
    printf (1, "sbrk() con cero falló.\n");
  6b:	83 ec 08             	sub    $0x8,%esp
  6e:	68 b1 03 00 00       	push   $0x3b1
  73:	6a 01                	push   $0x1
  75:	e8 b2 01 00 00       	call   22c <printf>
    exit(2);
  7a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  81:	e8 63 00 00 00       	call   e9 <exit>
  }

  if (a != sbrk (15000))
  86:	83 ec 0c             	sub    $0xc,%esp
  89:	68 98 3a 00 00       	push   $0x3a98
  8e:	e8 de 00 00 00       	call   171 <sbrk>
  93:	83 c4 10             	add    $0x10,%esp
  96:	39 c3                	cmp    %eax,%ebx
  98:	74 1b                	je     b5 <main+0xb5>
  {
    printf (1, "sbrk() negativo falló.\n");
  9a:	83 ec 08             	sub    $0x8,%esp
  9d:	68 ca 03 00 00       	push   $0x3ca
  a2:	6a 01                	push   $0x1
  a4:	e8 83 01 00 00       	call   22c <printf>
    exit(3);
  a9:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  b0:	e8 34 00 00 00       	call   e9 <exit>
  }

  printf (1, "Debe imprimir 1: %d.\n", ++a[500]); // el valor de a[500] debería ser 0 porque las páginas se entregan al usuario puestas a 0
  b5:	8a 83 f4 01 00 00    	mov    0x1f4(%ebx),%al
  bb:	40                   	inc    %eax
  bc:	88 83 f4 01 00 00    	mov    %al,0x1f4(%ebx)
  c2:	83 ec 04             	sub    $0x4,%esp
  c5:	0f be c0             	movsbl %al,%eax
  c8:	50                   	push   %eax
  c9:	68 e3 03 00 00       	push   $0x3e3
  ce:	6a 01                	push   $0x1
  d0:	e8 57 01 00 00       	call   22c <printf>
		a[i] = 0;
	}
	char *b = sbrk(500);
	printf(1,"b= 0x%x\n",b);
*/	
  exit(0);
  d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  dc:	e8 08 00 00 00       	call   e9 <exit>

000000e1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  e1:	b8 01 00 00 00       	mov    $0x1,%eax
  e6:	cd 40                	int    $0x40
  e8:	c3                   	ret    

000000e9 <exit>:
SYSCALL(exit)
  e9:	b8 02 00 00 00       	mov    $0x2,%eax
  ee:	cd 40                	int    $0x40
  f0:	c3                   	ret    

000000f1 <wait>:
SYSCALL(wait)
  f1:	b8 03 00 00 00       	mov    $0x3,%eax
  f6:	cd 40                	int    $0x40
  f8:	c3                   	ret    

000000f9 <pipe>:
SYSCALL(pipe)
  f9:	b8 04 00 00 00       	mov    $0x4,%eax
  fe:	cd 40                	int    $0x40
 100:	c3                   	ret    

00000101 <read>:
SYSCALL(read)
 101:	b8 05 00 00 00       	mov    $0x5,%eax
 106:	cd 40                	int    $0x40
 108:	c3                   	ret    

00000109 <write>:
SYSCALL(write)
 109:	b8 10 00 00 00       	mov    $0x10,%eax
 10e:	cd 40                	int    $0x40
 110:	c3                   	ret    

00000111 <close>:
SYSCALL(close)
 111:	b8 15 00 00 00       	mov    $0x15,%eax
 116:	cd 40                	int    $0x40
 118:	c3                   	ret    

00000119 <kill>:
SYSCALL(kill)
 119:	b8 06 00 00 00       	mov    $0x6,%eax
 11e:	cd 40                	int    $0x40
 120:	c3                   	ret    

00000121 <exec>:
SYSCALL(exec)
 121:	b8 07 00 00 00       	mov    $0x7,%eax
 126:	cd 40                	int    $0x40
 128:	c3                   	ret    

00000129 <open>:
SYSCALL(open)
 129:	b8 0f 00 00 00       	mov    $0xf,%eax
 12e:	cd 40                	int    $0x40
 130:	c3                   	ret    

00000131 <mknod>:
SYSCALL(mknod)
 131:	b8 11 00 00 00       	mov    $0x11,%eax
 136:	cd 40                	int    $0x40
 138:	c3                   	ret    

00000139 <unlink>:
SYSCALL(unlink)
 139:	b8 12 00 00 00       	mov    $0x12,%eax
 13e:	cd 40                	int    $0x40
 140:	c3                   	ret    

00000141 <fstat>:
SYSCALL(fstat)
 141:	b8 08 00 00 00       	mov    $0x8,%eax
 146:	cd 40                	int    $0x40
 148:	c3                   	ret    

00000149 <link>:
SYSCALL(link)
 149:	b8 13 00 00 00       	mov    $0x13,%eax
 14e:	cd 40                	int    $0x40
 150:	c3                   	ret    

00000151 <mkdir>:
SYSCALL(mkdir)
 151:	b8 14 00 00 00       	mov    $0x14,%eax
 156:	cd 40                	int    $0x40
 158:	c3                   	ret    

00000159 <chdir>:
SYSCALL(chdir)
 159:	b8 09 00 00 00       	mov    $0x9,%eax
 15e:	cd 40                	int    $0x40
 160:	c3                   	ret    

00000161 <dup>:
SYSCALL(dup)
 161:	b8 0a 00 00 00       	mov    $0xa,%eax
 166:	cd 40                	int    $0x40
 168:	c3                   	ret    

00000169 <getpid>:
SYSCALL(getpid)
 169:	b8 0b 00 00 00       	mov    $0xb,%eax
 16e:	cd 40                	int    $0x40
 170:	c3                   	ret    

00000171 <sbrk>:
SYSCALL(sbrk)
 171:	b8 0c 00 00 00       	mov    $0xc,%eax
 176:	cd 40                	int    $0x40
 178:	c3                   	ret    

00000179 <sleep>:
SYSCALL(sleep)
 179:	b8 0d 00 00 00       	mov    $0xd,%eax
 17e:	cd 40                	int    $0x40
 180:	c3                   	ret    

00000181 <uptime>:
SYSCALL(uptime)
 181:	b8 0e 00 00 00       	mov    $0xe,%eax
 186:	cd 40                	int    $0x40
 188:	c3                   	ret    

00000189 <date>:
SYSCALL(date)
 189:	b8 16 00 00 00       	mov    $0x16,%eax
 18e:	cd 40                	int    $0x40
 190:	c3                   	ret    

00000191 <dup2>:
SYSCALL(dup2)
 191:	b8 17 00 00 00       	mov    $0x17,%eax
 196:	cd 40                	int    $0x40
 198:	c3                   	ret    

00000199 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 199:	55                   	push   %ebp
 19a:	89 e5                	mov    %esp,%ebp
 19c:	83 ec 1c             	sub    $0x1c,%esp
 19f:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 1a2:	6a 01                	push   $0x1
 1a4:	8d 55 f4             	lea    -0xc(%ebp),%edx
 1a7:	52                   	push   %edx
 1a8:	50                   	push   %eax
 1a9:	e8 5b ff ff ff       	call   109 <write>
}
 1ae:	83 c4 10             	add    $0x10,%esp
 1b1:	c9                   	leave  
 1b2:	c3                   	ret    

000001b3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 1b3:	55                   	push   %ebp
 1b4:	89 e5                	mov    %esp,%ebp
 1b6:	57                   	push   %edi
 1b7:	56                   	push   %esi
 1b8:	53                   	push   %ebx
 1b9:	83 ec 2c             	sub    $0x2c,%esp
 1bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 1bf:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1c5:	74 04                	je     1cb <printint+0x18>
 1c7:	85 d2                	test   %edx,%edx
 1c9:	78 3c                	js     207 <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 1cb:	89 d1                	mov    %edx,%ecx
  neg = 0;
 1cd:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 1d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 1d9:	89 c8                	mov    %ecx,%eax
 1db:	ba 00 00 00 00       	mov    $0x0,%edx
 1e0:	f7 f6                	div    %esi
 1e2:	89 df                	mov    %ebx,%edi
 1e4:	43                   	inc    %ebx
 1e5:	8a 92 58 04 00 00    	mov    0x458(%edx),%dl
 1eb:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1ef:	89 ca                	mov    %ecx,%edx
 1f1:	89 c1                	mov    %eax,%ecx
 1f3:	39 d6                	cmp    %edx,%esi
 1f5:	76 e2                	jbe    1d9 <printint+0x26>
  if(neg)
 1f7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 1fb:	74 24                	je     221 <printint+0x6e>
    buf[i++] = '-';
 1fd:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 202:	8d 5f 02             	lea    0x2(%edi),%ebx
 205:	eb 1a                	jmp    221 <printint+0x6e>
    x = -xx;
 207:	89 d1                	mov    %edx,%ecx
 209:	f7 d9                	neg    %ecx
    neg = 1;
 20b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 212:	eb c0                	jmp    1d4 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 214:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 219:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 21c:	e8 78 ff ff ff       	call   199 <putc>
  while(--i >= 0)
 221:	4b                   	dec    %ebx
 222:	79 f0                	jns    214 <printint+0x61>
}
 224:	83 c4 2c             	add    $0x2c,%esp
 227:	5b                   	pop    %ebx
 228:	5e                   	pop    %esi
 229:	5f                   	pop    %edi
 22a:	5d                   	pop    %ebp
 22b:	c3                   	ret    

0000022c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 22c:	55                   	push   %ebp
 22d:	89 e5                	mov    %esp,%ebp
 22f:	57                   	push   %edi
 230:	56                   	push   %esi
 231:	53                   	push   %ebx
 232:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 235:	8d 45 10             	lea    0x10(%ebp),%eax
 238:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 23b:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 240:	bb 00 00 00 00       	mov    $0x0,%ebx
 245:	eb 12                	jmp    259 <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 247:	89 fa                	mov    %edi,%edx
 249:	8b 45 08             	mov    0x8(%ebp),%eax
 24c:	e8 48 ff ff ff       	call   199 <putc>
 251:	eb 05                	jmp    258 <printf+0x2c>
      }
    } else if(state == '%'){
 253:	83 fe 25             	cmp    $0x25,%esi
 256:	74 22                	je     27a <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 258:	43                   	inc    %ebx
 259:	8b 45 0c             	mov    0xc(%ebp),%eax
 25c:	8a 04 18             	mov    (%eax,%ebx,1),%al
 25f:	84 c0                	test   %al,%al
 261:	0f 84 1d 01 00 00    	je     384 <printf+0x158>
    c = fmt[i] & 0xff;
 267:	0f be f8             	movsbl %al,%edi
 26a:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 26d:	85 f6                	test   %esi,%esi
 26f:	75 e2                	jne    253 <printf+0x27>
      if(c == '%'){
 271:	83 f8 25             	cmp    $0x25,%eax
 274:	75 d1                	jne    247 <printf+0x1b>
        state = '%';
 276:	89 c6                	mov    %eax,%esi
 278:	eb de                	jmp    258 <printf+0x2c>
      if(c == 'd'){
 27a:	83 f8 25             	cmp    $0x25,%eax
 27d:	0f 84 cc 00 00 00    	je     34f <printf+0x123>
 283:	0f 8c da 00 00 00    	jl     363 <printf+0x137>
 289:	83 f8 78             	cmp    $0x78,%eax
 28c:	0f 8f d1 00 00 00    	jg     363 <printf+0x137>
 292:	83 f8 63             	cmp    $0x63,%eax
 295:	0f 8c c8 00 00 00    	jl     363 <printf+0x137>
 29b:	83 e8 63             	sub    $0x63,%eax
 29e:	83 f8 15             	cmp    $0x15,%eax
 2a1:	0f 87 bc 00 00 00    	ja     363 <printf+0x137>
 2a7:	ff 24 85 00 04 00 00 	jmp    *0x400(,%eax,4)
        printint(fd, *ap, 10, 1);
 2ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2b1:	8b 17                	mov    (%edi),%edx
 2b3:	83 ec 0c             	sub    $0xc,%esp
 2b6:	6a 01                	push   $0x1
 2b8:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2bd:	8b 45 08             	mov    0x8(%ebp),%eax
 2c0:	e8 ee fe ff ff       	call   1b3 <printint>
        ap++;
 2c5:	83 c7 04             	add    $0x4,%edi
 2c8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2cb:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2ce:	be 00 00 00 00       	mov    $0x0,%esi
 2d3:	eb 83                	jmp    258 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 2d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2d8:	8b 17                	mov    (%edi),%edx
 2da:	83 ec 0c             	sub    $0xc,%esp
 2dd:	6a 00                	push   $0x0
 2df:	b9 10 00 00 00       	mov    $0x10,%ecx
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	e8 c7 fe ff ff       	call   1b3 <printint>
        ap++;
 2ec:	83 c7 04             	add    $0x4,%edi
 2ef:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2f2:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2f5:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 2fa:	e9 59 ff ff ff       	jmp    258 <printf+0x2c>
        s = (char*)*ap;
 2ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 302:	8b 30                	mov    (%eax),%esi
        ap++;
 304:	83 c0 04             	add    $0x4,%eax
 307:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 30a:	85 f6                	test   %esi,%esi
 30c:	75 13                	jne    321 <printf+0xf5>
          s = "(null)";
 30e:	be f9 03 00 00       	mov    $0x3f9,%esi
 313:	eb 0c                	jmp    321 <printf+0xf5>
          putc(fd, *s);
 315:	0f be d2             	movsbl %dl,%edx
 318:	8b 45 08             	mov    0x8(%ebp),%eax
 31b:	e8 79 fe ff ff       	call   199 <putc>
          s++;
 320:	46                   	inc    %esi
        while(*s != 0){
 321:	8a 16                	mov    (%esi),%dl
 323:	84 d2                	test   %dl,%dl
 325:	75 ee                	jne    315 <printf+0xe9>
      state = 0;
 327:	be 00 00 00 00       	mov    $0x0,%esi
 32c:	e9 27 ff ff ff       	jmp    258 <printf+0x2c>
        putc(fd, *ap);
 331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 334:	0f be 17             	movsbl (%edi),%edx
 337:	8b 45 08             	mov    0x8(%ebp),%eax
 33a:	e8 5a fe ff ff       	call   199 <putc>
        ap++;
 33f:	83 c7 04             	add    $0x4,%edi
 342:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 345:	be 00 00 00 00       	mov    $0x0,%esi
 34a:	e9 09 ff ff ff       	jmp    258 <printf+0x2c>
        putc(fd, c);
 34f:	89 fa                	mov    %edi,%edx
 351:	8b 45 08             	mov    0x8(%ebp),%eax
 354:	e8 40 fe ff ff       	call   199 <putc>
      state = 0;
 359:	be 00 00 00 00       	mov    $0x0,%esi
 35e:	e9 f5 fe ff ff       	jmp    258 <printf+0x2c>
        putc(fd, '%');
 363:	ba 25 00 00 00       	mov    $0x25,%edx
 368:	8b 45 08             	mov    0x8(%ebp),%eax
 36b:	e8 29 fe ff ff       	call   199 <putc>
        putc(fd, c);
 370:	89 fa                	mov    %edi,%edx
 372:	8b 45 08             	mov    0x8(%ebp),%eax
 375:	e8 1f fe ff ff       	call   199 <putc>
      state = 0;
 37a:	be 00 00 00 00       	mov    $0x0,%esi
 37f:	e9 d4 fe ff ff       	jmp    258 <printf+0x2c>
    }
  }
}
 384:	8d 65 f4             	lea    -0xc(%ebp),%esp
 387:	5b                   	pop    %ebx
 388:	5e                   	pop    %esi
 389:	5f                   	pop    %edi
 38a:	5d                   	pop    %ebp
 38b:	c3                   	ret    
