
echo:     file format elf32-i386


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
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 08             	sub    $0x8,%esp
  14:	8b 31                	mov    (%ecx),%esi
  16:	8b 79 04             	mov    0x4(%ecx),%edi
  int i;

  for(i = 1; i < argc; i++)
  19:	b8 01 00 00 00       	mov    $0x1,%eax
  1e:	eb 1a                	jmp    3a <main+0x3a>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  20:	ba 16 03 00 00       	mov    $0x316,%edx
  25:	52                   	push   %edx
  26:	ff 34 87             	push   (%edi,%eax,4)
  29:	68 18 03 00 00       	push   $0x318
  2e:	6a 01                	push   $0x1
  30:	e8 7c 01 00 00       	call   1b1 <printf>
  35:	83 c4 10             	add    $0x10,%esp
  for(i = 1; i < argc; i++)
  38:	89 d8                	mov    %ebx,%eax
  3a:	39 f0                	cmp    %esi,%eax
  3c:	7d 0e                	jge    4c <main+0x4c>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  3e:	8d 58 01             	lea    0x1(%eax),%ebx
  41:	39 f3                	cmp    %esi,%ebx
  43:	7d db                	jge    20 <main+0x20>
  45:	ba 14 03 00 00       	mov    $0x314,%edx
  4a:	eb d9                	jmp    25 <main+0x25>
  exit(0);
  4c:	83 ec 0c             	sub    $0xc,%esp
  4f:	6a 00                	push   $0x0
  51:	e8 08 00 00 00       	call   5e <exit>

00000056 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  56:	b8 01 00 00 00       	mov    $0x1,%eax
  5b:	cd 40                	int    $0x40
  5d:	c3                   	ret    

0000005e <exit>:
SYSCALL(exit)
  5e:	b8 02 00 00 00       	mov    $0x2,%eax
  63:	cd 40                	int    $0x40
  65:	c3                   	ret    

00000066 <wait>:
SYSCALL(wait)
  66:	b8 03 00 00 00       	mov    $0x3,%eax
  6b:	cd 40                	int    $0x40
  6d:	c3                   	ret    

0000006e <pipe>:
SYSCALL(pipe)
  6e:	b8 04 00 00 00       	mov    $0x4,%eax
  73:	cd 40                	int    $0x40
  75:	c3                   	ret    

00000076 <read>:
SYSCALL(read)
  76:	b8 05 00 00 00       	mov    $0x5,%eax
  7b:	cd 40                	int    $0x40
  7d:	c3                   	ret    

0000007e <write>:
SYSCALL(write)
  7e:	b8 10 00 00 00       	mov    $0x10,%eax
  83:	cd 40                	int    $0x40
  85:	c3                   	ret    

00000086 <close>:
SYSCALL(close)
  86:	b8 15 00 00 00       	mov    $0x15,%eax
  8b:	cd 40                	int    $0x40
  8d:	c3                   	ret    

0000008e <kill>:
SYSCALL(kill)
  8e:	b8 06 00 00 00       	mov    $0x6,%eax
  93:	cd 40                	int    $0x40
  95:	c3                   	ret    

00000096 <exec>:
SYSCALL(exec)
  96:	b8 07 00 00 00       	mov    $0x7,%eax
  9b:	cd 40                	int    $0x40
  9d:	c3                   	ret    

0000009e <open>:
SYSCALL(open)
  9e:	b8 0f 00 00 00       	mov    $0xf,%eax
  a3:	cd 40                	int    $0x40
  a5:	c3                   	ret    

000000a6 <mknod>:
SYSCALL(mknod)
  a6:	b8 11 00 00 00       	mov    $0x11,%eax
  ab:	cd 40                	int    $0x40
  ad:	c3                   	ret    

000000ae <unlink>:
SYSCALL(unlink)
  ae:	b8 12 00 00 00       	mov    $0x12,%eax
  b3:	cd 40                	int    $0x40
  b5:	c3                   	ret    

000000b6 <fstat>:
SYSCALL(fstat)
  b6:	b8 08 00 00 00       	mov    $0x8,%eax
  bb:	cd 40                	int    $0x40
  bd:	c3                   	ret    

000000be <link>:
SYSCALL(link)
  be:	b8 13 00 00 00       	mov    $0x13,%eax
  c3:	cd 40                	int    $0x40
  c5:	c3                   	ret    

000000c6 <mkdir>:
SYSCALL(mkdir)
  c6:	b8 14 00 00 00       	mov    $0x14,%eax
  cb:	cd 40                	int    $0x40
  cd:	c3                   	ret    

000000ce <chdir>:
SYSCALL(chdir)
  ce:	b8 09 00 00 00       	mov    $0x9,%eax
  d3:	cd 40                	int    $0x40
  d5:	c3                   	ret    

000000d6 <dup>:
SYSCALL(dup)
  d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  db:	cd 40                	int    $0x40
  dd:	c3                   	ret    

000000de <getpid>:
SYSCALL(getpid)
  de:	b8 0b 00 00 00       	mov    $0xb,%eax
  e3:	cd 40                	int    $0x40
  e5:	c3                   	ret    

000000e6 <sbrk>:
SYSCALL(sbrk)
  e6:	b8 0c 00 00 00       	mov    $0xc,%eax
  eb:	cd 40                	int    $0x40
  ed:	c3                   	ret    

000000ee <sleep>:
SYSCALL(sleep)
  ee:	b8 0d 00 00 00       	mov    $0xd,%eax
  f3:	cd 40                	int    $0x40
  f5:	c3                   	ret    

000000f6 <uptime>:
SYSCALL(uptime)
  f6:	b8 0e 00 00 00       	mov    $0xe,%eax
  fb:	cd 40                	int    $0x40
  fd:	c3                   	ret    

000000fe <date>:
SYSCALL(date)
  fe:	b8 16 00 00 00       	mov    $0x16,%eax
 103:	cd 40                	int    $0x40
 105:	c3                   	ret    

00000106 <dup2>:
SYSCALL(dup2)
 106:	b8 17 00 00 00       	mov    $0x17,%eax
 10b:	cd 40                	int    $0x40
 10d:	c3                   	ret    

0000010e <getprio>:
SYSCALL(getprio)
 10e:	b8 18 00 00 00       	mov    $0x18,%eax
 113:	cd 40                	int    $0x40
 115:	c3                   	ret    

00000116 <setprio>:
SYSCALL(setprio)
 116:	b8 19 00 00 00       	mov    $0x19,%eax
 11b:	cd 40                	int    $0x40
 11d:	c3                   	ret    

0000011e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 11e:	55                   	push   %ebp
 11f:	89 e5                	mov    %esp,%ebp
 121:	83 ec 1c             	sub    $0x1c,%esp
 124:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 127:	6a 01                	push   $0x1
 129:	8d 55 f4             	lea    -0xc(%ebp),%edx
 12c:	52                   	push   %edx
 12d:	50                   	push   %eax
 12e:	e8 4b ff ff ff       	call   7e <write>
}
 133:	83 c4 10             	add    $0x10,%esp
 136:	c9                   	leave  
 137:	c3                   	ret    

00000138 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 138:	55                   	push   %ebp
 139:	89 e5                	mov    %esp,%ebp
 13b:	57                   	push   %edi
 13c:	56                   	push   %esi
 13d:	53                   	push   %ebx
 13e:	83 ec 2c             	sub    $0x2c,%esp
 141:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 144:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 146:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 14a:	74 04                	je     150 <printint+0x18>
 14c:	85 d2                	test   %edx,%edx
 14e:	78 3c                	js     18c <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 150:	89 d1                	mov    %edx,%ecx
  neg = 0;
 152:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 159:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 15e:	89 c8                	mov    %ecx,%eax
 160:	ba 00 00 00 00       	mov    $0x0,%edx
 165:	f7 f6                	div    %esi
 167:	89 df                	mov    %ebx,%edi
 169:	43                   	inc    %ebx
 16a:	8a 92 7c 03 00 00    	mov    0x37c(%edx),%dl
 170:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 174:	89 ca                	mov    %ecx,%edx
 176:	89 c1                	mov    %eax,%ecx
 178:	39 d6                	cmp    %edx,%esi
 17a:	76 e2                	jbe    15e <printint+0x26>
  if(neg)
 17c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 180:	74 24                	je     1a6 <printint+0x6e>
    buf[i++] = '-';
 182:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 187:	8d 5f 02             	lea    0x2(%edi),%ebx
 18a:	eb 1a                	jmp    1a6 <printint+0x6e>
    x = -xx;
 18c:	89 d1                	mov    %edx,%ecx
 18e:	f7 d9                	neg    %ecx
    neg = 1;
 190:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 197:	eb c0                	jmp    159 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 199:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 19e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1a1:	e8 78 ff ff ff       	call   11e <putc>
  while(--i >= 0)
 1a6:	4b                   	dec    %ebx
 1a7:	79 f0                	jns    199 <printint+0x61>
}
 1a9:	83 c4 2c             	add    $0x2c,%esp
 1ac:	5b                   	pop    %ebx
 1ad:	5e                   	pop    %esi
 1ae:	5f                   	pop    %edi
 1af:	5d                   	pop    %ebp
 1b0:	c3                   	ret    

000001b1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1b1:	55                   	push   %ebp
 1b2:	89 e5                	mov    %esp,%ebp
 1b4:	57                   	push   %edi
 1b5:	56                   	push   %esi
 1b6:	53                   	push   %ebx
 1b7:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1ba:	8d 45 10             	lea    0x10(%ebp),%eax
 1bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1c0:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1c5:	bb 00 00 00 00       	mov    $0x0,%ebx
 1ca:	eb 12                	jmp    1de <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1cc:	89 fa                	mov    %edi,%edx
 1ce:	8b 45 08             	mov    0x8(%ebp),%eax
 1d1:	e8 48 ff ff ff       	call   11e <putc>
 1d6:	eb 05                	jmp    1dd <printf+0x2c>
      }
    } else if(state == '%'){
 1d8:	83 fe 25             	cmp    $0x25,%esi
 1db:	74 22                	je     1ff <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 1dd:	43                   	inc    %ebx
 1de:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e1:	8a 04 18             	mov    (%eax,%ebx,1),%al
 1e4:	84 c0                	test   %al,%al
 1e6:	0f 84 1d 01 00 00    	je     309 <printf+0x158>
    c = fmt[i] & 0xff;
 1ec:	0f be f8             	movsbl %al,%edi
 1ef:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 1f2:	85 f6                	test   %esi,%esi
 1f4:	75 e2                	jne    1d8 <printf+0x27>
      if(c == '%'){
 1f6:	83 f8 25             	cmp    $0x25,%eax
 1f9:	75 d1                	jne    1cc <printf+0x1b>
        state = '%';
 1fb:	89 c6                	mov    %eax,%esi
 1fd:	eb de                	jmp    1dd <printf+0x2c>
      if(c == 'd'){
 1ff:	83 f8 25             	cmp    $0x25,%eax
 202:	0f 84 cc 00 00 00    	je     2d4 <printf+0x123>
 208:	0f 8c da 00 00 00    	jl     2e8 <printf+0x137>
 20e:	83 f8 78             	cmp    $0x78,%eax
 211:	0f 8f d1 00 00 00    	jg     2e8 <printf+0x137>
 217:	83 f8 63             	cmp    $0x63,%eax
 21a:	0f 8c c8 00 00 00    	jl     2e8 <printf+0x137>
 220:	83 e8 63             	sub    $0x63,%eax
 223:	83 f8 15             	cmp    $0x15,%eax
 226:	0f 87 bc 00 00 00    	ja     2e8 <printf+0x137>
 22c:	ff 24 85 24 03 00 00 	jmp    *0x324(,%eax,4)
        printint(fd, *ap, 10, 1);
 233:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 236:	8b 17                	mov    (%edi),%edx
 238:	83 ec 0c             	sub    $0xc,%esp
 23b:	6a 01                	push   $0x1
 23d:	b9 0a 00 00 00       	mov    $0xa,%ecx
 242:	8b 45 08             	mov    0x8(%ebp),%eax
 245:	e8 ee fe ff ff       	call   138 <printint>
        ap++;
 24a:	83 c7 04             	add    $0x4,%edi
 24d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 250:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 253:	be 00 00 00 00       	mov    $0x0,%esi
 258:	eb 83                	jmp    1dd <printf+0x2c>
        printint(fd, *ap, 16, 0);
 25a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 25d:	8b 17                	mov    (%edi),%edx
 25f:	83 ec 0c             	sub    $0xc,%esp
 262:	6a 00                	push   $0x0
 264:	b9 10 00 00 00       	mov    $0x10,%ecx
 269:	8b 45 08             	mov    0x8(%ebp),%eax
 26c:	e8 c7 fe ff ff       	call   138 <printint>
        ap++;
 271:	83 c7 04             	add    $0x4,%edi
 274:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 277:	83 c4 10             	add    $0x10,%esp
      state = 0;
 27a:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 27f:	e9 59 ff ff ff       	jmp    1dd <printf+0x2c>
        s = (char*)*ap;
 284:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 287:	8b 30                	mov    (%eax),%esi
        ap++;
 289:	83 c0 04             	add    $0x4,%eax
 28c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 28f:	85 f6                	test   %esi,%esi
 291:	75 13                	jne    2a6 <printf+0xf5>
          s = "(null)";
 293:	be 1d 03 00 00       	mov    $0x31d,%esi
 298:	eb 0c                	jmp    2a6 <printf+0xf5>
          putc(fd, *s);
 29a:	0f be d2             	movsbl %dl,%edx
 29d:	8b 45 08             	mov    0x8(%ebp),%eax
 2a0:	e8 79 fe ff ff       	call   11e <putc>
          s++;
 2a5:	46                   	inc    %esi
        while(*s != 0){
 2a6:	8a 16                	mov    (%esi),%dl
 2a8:	84 d2                	test   %dl,%dl
 2aa:	75 ee                	jne    29a <printf+0xe9>
      state = 0;
 2ac:	be 00 00 00 00       	mov    $0x0,%esi
 2b1:	e9 27 ff ff ff       	jmp    1dd <printf+0x2c>
        putc(fd, *ap);
 2b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2b9:	0f be 17             	movsbl (%edi),%edx
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
 2bf:	e8 5a fe ff ff       	call   11e <putc>
        ap++;
 2c4:	83 c7 04             	add    $0x4,%edi
 2c7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2ca:	be 00 00 00 00       	mov    $0x0,%esi
 2cf:	e9 09 ff ff ff       	jmp    1dd <printf+0x2c>
        putc(fd, c);
 2d4:	89 fa                	mov    %edi,%edx
 2d6:	8b 45 08             	mov    0x8(%ebp),%eax
 2d9:	e8 40 fe ff ff       	call   11e <putc>
      state = 0;
 2de:	be 00 00 00 00       	mov    $0x0,%esi
 2e3:	e9 f5 fe ff ff       	jmp    1dd <printf+0x2c>
        putc(fd, '%');
 2e8:	ba 25 00 00 00       	mov    $0x25,%edx
 2ed:	8b 45 08             	mov    0x8(%ebp),%eax
 2f0:	e8 29 fe ff ff       	call   11e <putc>
        putc(fd, c);
 2f5:	89 fa                	mov    %edi,%edx
 2f7:	8b 45 08             	mov    0x8(%ebp),%eax
 2fa:	e8 1f fe ff ff       	call   11e <putc>
      state = 0;
 2ff:	be 00 00 00 00       	mov    $0x0,%esi
 304:	e9 d4 fe ff ff       	jmp    1dd <printf+0x2c>
    }
  }
}
 309:	8d 65 f4             	lea    -0xc(%ebp),%esp
 30c:	5b                   	pop    %ebx
 30d:	5e                   	pop    %esi
 30e:	5f                   	pop    %edi
 30f:	5d                   	pop    %ebp
 310:	c3                   	ret    
