
rm:     file format elf32-i386


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
  11:	83 ec 18             	sub    $0x18,%esp
  14:	8b 01                	mov    (%ecx),%eax
  16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  19:	8b 79 04             	mov    0x4(%ecx),%edi
  int i;

  if(argc < 2){
  1c:	83 f8 01             	cmp    $0x1,%eax
  1f:	7e 07                	jle    28 <main+0x28>
    printf(2, "Usage: rm files...\n");
    exit(0);
  }

  for(i = 1; i < argc; i++){
  21:	bb 01 00 00 00       	mov    $0x1,%ebx
  26:	eb 1c                	jmp    44 <main+0x44>
    printf(2, "Usage: rm files...\n");
  28:	83 ec 08             	sub    $0x8,%esp
  2b:	68 38 03 00 00       	push   $0x338
  30:	6a 02                	push   $0x2
  32:	e8 9f 01 00 00       	call   1d6 <printf>
    exit(0);
  37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  3e:	e8 40 00 00 00       	call   83 <exit>
  for(i = 1; i < argc; i++){
  43:	43                   	inc    %ebx
  44:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  47:	7d 28                	jge    71 <main+0x71>
    if(unlink(argv[i]) < 0){
  49:	8d 34 9f             	lea    (%edi,%ebx,4),%esi
  4c:	83 ec 0c             	sub    $0xc,%esp
  4f:	ff 36                	push   (%esi)
  51:	e8 7d 00 00 00       	call   d3 <unlink>
  56:	83 c4 10             	add    $0x10,%esp
  59:	85 c0                	test   %eax,%eax
  5b:	79 e6                	jns    43 <main+0x43>
      printf(2, "rm: %s failed to delete\n", argv[i]);
  5d:	83 ec 04             	sub    $0x4,%esp
  60:	ff 36                	push   (%esi)
  62:	68 4c 03 00 00       	push   $0x34c
  67:	6a 02                	push   $0x2
  69:	e8 68 01 00 00       	call   1d6 <printf>
      break;
  6e:	83 c4 10             	add    $0x10,%esp
    }
  }

  exit(0);
  71:	83 ec 0c             	sub    $0xc,%esp
  74:	6a 00                	push   $0x0
  76:	e8 08 00 00 00       	call   83 <exit>

0000007b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  7b:	b8 01 00 00 00       	mov    $0x1,%eax
  80:	cd 40                	int    $0x40
  82:	c3                   	ret    

00000083 <exit>:
SYSCALL(exit)
  83:	b8 02 00 00 00       	mov    $0x2,%eax
  88:	cd 40                	int    $0x40
  8a:	c3                   	ret    

0000008b <wait>:
SYSCALL(wait)
  8b:	b8 03 00 00 00       	mov    $0x3,%eax
  90:	cd 40                	int    $0x40
  92:	c3                   	ret    

00000093 <pipe>:
SYSCALL(pipe)
  93:	b8 04 00 00 00       	mov    $0x4,%eax
  98:	cd 40                	int    $0x40
  9a:	c3                   	ret    

0000009b <read>:
SYSCALL(read)
  9b:	b8 05 00 00 00       	mov    $0x5,%eax
  a0:	cd 40                	int    $0x40
  a2:	c3                   	ret    

000000a3 <write>:
SYSCALL(write)
  a3:	b8 10 00 00 00       	mov    $0x10,%eax
  a8:	cd 40                	int    $0x40
  aa:	c3                   	ret    

000000ab <close>:
SYSCALL(close)
  ab:	b8 15 00 00 00       	mov    $0x15,%eax
  b0:	cd 40                	int    $0x40
  b2:	c3                   	ret    

000000b3 <kill>:
SYSCALL(kill)
  b3:	b8 06 00 00 00       	mov    $0x6,%eax
  b8:	cd 40                	int    $0x40
  ba:	c3                   	ret    

000000bb <exec>:
SYSCALL(exec)
  bb:	b8 07 00 00 00       	mov    $0x7,%eax
  c0:	cd 40                	int    $0x40
  c2:	c3                   	ret    

000000c3 <open>:
SYSCALL(open)
  c3:	b8 0f 00 00 00       	mov    $0xf,%eax
  c8:	cd 40                	int    $0x40
  ca:	c3                   	ret    

000000cb <mknod>:
SYSCALL(mknod)
  cb:	b8 11 00 00 00       	mov    $0x11,%eax
  d0:	cd 40                	int    $0x40
  d2:	c3                   	ret    

000000d3 <unlink>:
SYSCALL(unlink)
  d3:	b8 12 00 00 00       	mov    $0x12,%eax
  d8:	cd 40                	int    $0x40
  da:	c3                   	ret    

000000db <fstat>:
SYSCALL(fstat)
  db:	b8 08 00 00 00       	mov    $0x8,%eax
  e0:	cd 40                	int    $0x40
  e2:	c3                   	ret    

000000e3 <link>:
SYSCALL(link)
  e3:	b8 13 00 00 00       	mov    $0x13,%eax
  e8:	cd 40                	int    $0x40
  ea:	c3                   	ret    

000000eb <mkdir>:
SYSCALL(mkdir)
  eb:	b8 14 00 00 00       	mov    $0x14,%eax
  f0:	cd 40                	int    $0x40
  f2:	c3                   	ret    

000000f3 <chdir>:
SYSCALL(chdir)
  f3:	b8 09 00 00 00       	mov    $0x9,%eax
  f8:	cd 40                	int    $0x40
  fa:	c3                   	ret    

000000fb <dup>:
SYSCALL(dup)
  fb:	b8 0a 00 00 00       	mov    $0xa,%eax
 100:	cd 40                	int    $0x40
 102:	c3                   	ret    

00000103 <getpid>:
SYSCALL(getpid)
 103:	b8 0b 00 00 00       	mov    $0xb,%eax
 108:	cd 40                	int    $0x40
 10a:	c3                   	ret    

0000010b <sbrk>:
SYSCALL(sbrk)
 10b:	b8 0c 00 00 00       	mov    $0xc,%eax
 110:	cd 40                	int    $0x40
 112:	c3                   	ret    

00000113 <sleep>:
SYSCALL(sleep)
 113:	b8 0d 00 00 00       	mov    $0xd,%eax
 118:	cd 40                	int    $0x40
 11a:	c3                   	ret    

0000011b <uptime>:
SYSCALL(uptime)
 11b:	b8 0e 00 00 00       	mov    $0xe,%eax
 120:	cd 40                	int    $0x40
 122:	c3                   	ret    

00000123 <date>:
SYSCALL(date)
 123:	b8 16 00 00 00       	mov    $0x16,%eax
 128:	cd 40                	int    $0x40
 12a:	c3                   	ret    

0000012b <dup2>:
SYSCALL(dup2)
 12b:	b8 17 00 00 00       	mov    $0x17,%eax
 130:	cd 40                	int    $0x40
 132:	c3                   	ret    

00000133 <getprio>:
SYSCALL(getprio)
 133:	b8 18 00 00 00       	mov    $0x18,%eax
 138:	cd 40                	int    $0x40
 13a:	c3                   	ret    

0000013b <setprio>:
SYSCALL(setprio)
 13b:	b8 19 00 00 00       	mov    $0x19,%eax
 140:	cd 40                	int    $0x40
 142:	c3                   	ret    

00000143 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 143:	55                   	push   %ebp
 144:	89 e5                	mov    %esp,%ebp
 146:	83 ec 1c             	sub    $0x1c,%esp
 149:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 14c:	6a 01                	push   $0x1
 14e:	8d 55 f4             	lea    -0xc(%ebp),%edx
 151:	52                   	push   %edx
 152:	50                   	push   %eax
 153:	e8 4b ff ff ff       	call   a3 <write>
}
 158:	83 c4 10             	add    $0x10,%esp
 15b:	c9                   	leave  
 15c:	c3                   	ret    

0000015d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 15d:	55                   	push   %ebp
 15e:	89 e5                	mov    %esp,%ebp
 160:	57                   	push   %edi
 161:	56                   	push   %esi
 162:	53                   	push   %ebx
 163:	83 ec 2c             	sub    $0x2c,%esp
 166:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 169:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 16b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 16f:	74 04                	je     175 <printint+0x18>
 171:	85 d2                	test   %edx,%edx
 173:	78 3c                	js     1b1 <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 175:	89 d1                	mov    %edx,%ecx
  neg = 0;
 177:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 17e:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 183:	89 c8                	mov    %ecx,%eax
 185:	ba 00 00 00 00       	mov    $0x0,%edx
 18a:	f7 f6                	div    %esi
 18c:	89 df                	mov    %ebx,%edi
 18e:	43                   	inc    %ebx
 18f:	8a 92 c4 03 00 00    	mov    0x3c4(%edx),%dl
 195:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 199:	89 ca                	mov    %ecx,%edx
 19b:	89 c1                	mov    %eax,%ecx
 19d:	39 d6                	cmp    %edx,%esi
 19f:	76 e2                	jbe    183 <printint+0x26>
  if(neg)
 1a1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 1a5:	74 24                	je     1cb <printint+0x6e>
    buf[i++] = '-';
 1a7:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1ac:	8d 5f 02             	lea    0x2(%edi),%ebx
 1af:	eb 1a                	jmp    1cb <printint+0x6e>
    x = -xx;
 1b1:	89 d1                	mov    %edx,%ecx
 1b3:	f7 d9                	neg    %ecx
    neg = 1;
 1b5:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 1bc:	eb c0                	jmp    17e <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 1be:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 1c6:	e8 78 ff ff ff       	call   143 <putc>
  while(--i >= 0)
 1cb:	4b                   	dec    %ebx
 1cc:	79 f0                	jns    1be <printint+0x61>
}
 1ce:	83 c4 2c             	add    $0x2c,%esp
 1d1:	5b                   	pop    %ebx
 1d2:	5e                   	pop    %esi
 1d3:	5f                   	pop    %edi
 1d4:	5d                   	pop    %ebp
 1d5:	c3                   	ret    

000001d6 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1d6:	55                   	push   %ebp
 1d7:	89 e5                	mov    %esp,%ebp
 1d9:	57                   	push   %edi
 1da:	56                   	push   %esi
 1db:	53                   	push   %ebx
 1dc:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1df:	8d 45 10             	lea    0x10(%ebp),%eax
 1e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1e5:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1ea:	bb 00 00 00 00       	mov    $0x0,%ebx
 1ef:	eb 12                	jmp    203 <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1f1:	89 fa                	mov    %edi,%edx
 1f3:	8b 45 08             	mov    0x8(%ebp),%eax
 1f6:	e8 48 ff ff ff       	call   143 <putc>
 1fb:	eb 05                	jmp    202 <printf+0x2c>
      }
    } else if(state == '%'){
 1fd:	83 fe 25             	cmp    $0x25,%esi
 200:	74 22                	je     224 <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 202:	43                   	inc    %ebx
 203:	8b 45 0c             	mov    0xc(%ebp),%eax
 206:	8a 04 18             	mov    (%eax,%ebx,1),%al
 209:	84 c0                	test   %al,%al
 20b:	0f 84 1d 01 00 00    	je     32e <printf+0x158>
    c = fmt[i] & 0xff;
 211:	0f be f8             	movsbl %al,%edi
 214:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 217:	85 f6                	test   %esi,%esi
 219:	75 e2                	jne    1fd <printf+0x27>
      if(c == '%'){
 21b:	83 f8 25             	cmp    $0x25,%eax
 21e:	75 d1                	jne    1f1 <printf+0x1b>
        state = '%';
 220:	89 c6                	mov    %eax,%esi
 222:	eb de                	jmp    202 <printf+0x2c>
      if(c == 'd'){
 224:	83 f8 25             	cmp    $0x25,%eax
 227:	0f 84 cc 00 00 00    	je     2f9 <printf+0x123>
 22d:	0f 8c da 00 00 00    	jl     30d <printf+0x137>
 233:	83 f8 78             	cmp    $0x78,%eax
 236:	0f 8f d1 00 00 00    	jg     30d <printf+0x137>
 23c:	83 f8 63             	cmp    $0x63,%eax
 23f:	0f 8c c8 00 00 00    	jl     30d <printf+0x137>
 245:	83 e8 63             	sub    $0x63,%eax
 248:	83 f8 15             	cmp    $0x15,%eax
 24b:	0f 87 bc 00 00 00    	ja     30d <printf+0x137>
 251:	ff 24 85 6c 03 00 00 	jmp    *0x36c(,%eax,4)
        printint(fd, *ap, 10, 1);
 258:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 25b:	8b 17                	mov    (%edi),%edx
 25d:	83 ec 0c             	sub    $0xc,%esp
 260:	6a 01                	push   $0x1
 262:	b9 0a 00 00 00       	mov    $0xa,%ecx
 267:	8b 45 08             	mov    0x8(%ebp),%eax
 26a:	e8 ee fe ff ff       	call   15d <printint>
        ap++;
 26f:	83 c7 04             	add    $0x4,%edi
 272:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 275:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 278:	be 00 00 00 00       	mov    $0x0,%esi
 27d:	eb 83                	jmp    202 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 27f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 282:	8b 17                	mov    (%edi),%edx
 284:	83 ec 0c             	sub    $0xc,%esp
 287:	6a 00                	push   $0x0
 289:	b9 10 00 00 00       	mov    $0x10,%ecx
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
 291:	e8 c7 fe ff ff       	call   15d <printint>
        ap++;
 296:	83 c7 04             	add    $0x4,%edi
 299:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 29c:	83 c4 10             	add    $0x10,%esp
      state = 0;
 29f:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 2a4:	e9 59 ff ff ff       	jmp    202 <printf+0x2c>
        s = (char*)*ap;
 2a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2ac:	8b 30                	mov    (%eax),%esi
        ap++;
 2ae:	83 c0 04             	add    $0x4,%eax
 2b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2b4:	85 f6                	test   %esi,%esi
 2b6:	75 13                	jne    2cb <printf+0xf5>
          s = "(null)";
 2b8:	be 65 03 00 00       	mov    $0x365,%esi
 2bd:	eb 0c                	jmp    2cb <printf+0xf5>
          putc(fd, *s);
 2bf:	0f be d2             	movsbl %dl,%edx
 2c2:	8b 45 08             	mov    0x8(%ebp),%eax
 2c5:	e8 79 fe ff ff       	call   143 <putc>
          s++;
 2ca:	46                   	inc    %esi
        while(*s != 0){
 2cb:	8a 16                	mov    (%esi),%dl
 2cd:	84 d2                	test   %dl,%dl
 2cf:	75 ee                	jne    2bf <printf+0xe9>
      state = 0;
 2d1:	be 00 00 00 00       	mov    $0x0,%esi
 2d6:	e9 27 ff ff ff       	jmp    202 <printf+0x2c>
        putc(fd, *ap);
 2db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2de:	0f be 17             	movsbl (%edi),%edx
 2e1:	8b 45 08             	mov    0x8(%ebp),%eax
 2e4:	e8 5a fe ff ff       	call   143 <putc>
        ap++;
 2e9:	83 c7 04             	add    $0x4,%edi
 2ec:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2ef:	be 00 00 00 00       	mov    $0x0,%esi
 2f4:	e9 09 ff ff ff       	jmp    202 <printf+0x2c>
        putc(fd, c);
 2f9:	89 fa                	mov    %edi,%edx
 2fb:	8b 45 08             	mov    0x8(%ebp),%eax
 2fe:	e8 40 fe ff ff       	call   143 <putc>
      state = 0;
 303:	be 00 00 00 00       	mov    $0x0,%esi
 308:	e9 f5 fe ff ff       	jmp    202 <printf+0x2c>
        putc(fd, '%');
 30d:	ba 25 00 00 00       	mov    $0x25,%edx
 312:	8b 45 08             	mov    0x8(%ebp),%eax
 315:	e8 29 fe ff ff       	call   143 <putc>
        putc(fd, c);
 31a:	89 fa                	mov    %edi,%edx
 31c:	8b 45 08             	mov    0x8(%ebp),%eax
 31f:	e8 1f fe ff ff       	call   143 <putc>
      state = 0;
 324:	be 00 00 00 00       	mov    $0x0,%esi
 329:	e9 d4 fe ff ff       	jmp    202 <printf+0x2c>
    }
  }
}
 32e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 331:	5b                   	pop    %ebx
 332:	5e                   	pop    %esi
 333:	5f                   	pop    %edi
 334:	5d                   	pop    %ebp
 335:	c3                   	ret    
