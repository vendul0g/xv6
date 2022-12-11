
init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   f:	83 ec 08             	sub    $0x8,%esp
  12:	6a 02                	push   $0x2
  14:	68 b0 03 00 00       	push   $0x3b0
  19:	e8 1d 01 00 00       	call   13b <open>
  1e:	83 c4 10             	add    $0x10,%esp
  21:	85 c0                	test   %eax,%eax
  23:	78 1b                	js     40 <main+0x40>
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  25:	83 ec 0c             	sub    $0xc,%esp
  28:	6a 00                	push   $0x0
  2a:	e8 44 01 00 00       	call   173 <dup>
  dup(0);  // stderr
  2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  36:	e8 38 01 00 00       	call   173 <dup>
  3b:	83 c4 10             	add    $0x10,%esp
  3e:	eb 67                	jmp    a7 <main+0xa7>
    mknod("console", 1, 1);
  40:	83 ec 04             	sub    $0x4,%esp
  43:	6a 01                	push   $0x1
  45:	6a 01                	push   $0x1
  47:	68 b0 03 00 00       	push   $0x3b0
  4c:	e8 f2 00 00 00       	call   143 <mknod>
    open("console", O_RDWR);
  51:	83 c4 08             	add    $0x8,%esp
  54:	6a 02                	push   $0x2
  56:	68 b0 03 00 00       	push   $0x3b0
  5b:	e8 db 00 00 00       	call   13b <open>
  60:	83 c4 10             	add    $0x10,%esp
  63:	eb c0                	jmp    25 <main+0x25>

  for(;;){
    printf(1, "init: starting sh\n");
    pid = fork();
    if(pid < 0){
      printf(1, "init: fork failed\n");
  65:	83 ec 08             	sub    $0x8,%esp
  68:	68 cb 03 00 00       	push   $0x3cb
  6d:	6a 01                	push   $0x1
  6f:	e8 da 01 00 00       	call   24e <printf>
      exit(0);
  74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  7b:	e8 7b 00 00 00       	call   fb <exit>
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit(0);
    }
    while((wpid=wait(NULL)) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  80:	83 ec 08             	sub    $0x8,%esp
  83:	68 f7 03 00 00       	push   $0x3f7
  88:	6a 01                	push   $0x1
  8a:	e8 bf 01 00 00       	call   24e <printf>
  8f:	83 c4 10             	add    $0x10,%esp
    while((wpid=wait(NULL)) >= 0 && wpid != pid)
  92:	83 ec 0c             	sub    $0xc,%esp
  95:	6a 00                	push   $0x0
  97:	e8 67 00 00 00       	call   103 <wait>
  9c:	83 c4 10             	add    $0x10,%esp
  9f:	85 c0                	test   %eax,%eax
  a1:	78 04                	js     a7 <main+0xa7>
  a3:	39 c3                	cmp    %eax,%ebx
  a5:	75 d9                	jne    80 <main+0x80>
    printf(1, "init: starting sh\n");
  a7:	83 ec 08             	sub    $0x8,%esp
  aa:	68 b8 03 00 00       	push   $0x3b8
  af:	6a 01                	push   $0x1
  b1:	e8 98 01 00 00       	call   24e <printf>
    pid = fork();
  b6:	e8 38 00 00 00       	call   f3 <fork>
  bb:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
  bd:	83 c4 10             	add    $0x10,%esp
  c0:	85 c0                	test   %eax,%eax
  c2:	78 a1                	js     65 <main+0x65>
    if(pid == 0){
  c4:	75 cc                	jne    92 <main+0x92>
      exec("sh", argv);
  c6:	83 ec 08             	sub    $0x8,%esp
  c9:	68 30 05 00 00       	push   $0x530
  ce:	68 de 03 00 00       	push   $0x3de
  d3:	e8 5b 00 00 00       	call   133 <exec>
      printf(1, "init: exec sh failed\n");
  d8:	83 c4 08             	add    $0x8,%esp
  db:	68 e1 03 00 00       	push   $0x3e1
  e0:	6a 01                	push   $0x1
  e2:	e8 67 01 00 00       	call   24e <printf>
      exit(0);
  e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  ee:	e8 08 00 00 00       	call   fb <exit>

000000f3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  f3:	b8 01 00 00 00       	mov    $0x1,%eax
  f8:	cd 40                	int    $0x40
  fa:	c3                   	ret    

000000fb <exit>:
SYSCALL(exit)
  fb:	b8 02 00 00 00       	mov    $0x2,%eax
 100:	cd 40                	int    $0x40
 102:	c3                   	ret    

00000103 <wait>:
SYSCALL(wait)
 103:	b8 03 00 00 00       	mov    $0x3,%eax
 108:	cd 40                	int    $0x40
 10a:	c3                   	ret    

0000010b <pipe>:
SYSCALL(pipe)
 10b:	b8 04 00 00 00       	mov    $0x4,%eax
 110:	cd 40                	int    $0x40
 112:	c3                   	ret    

00000113 <read>:
SYSCALL(read)
 113:	b8 05 00 00 00       	mov    $0x5,%eax
 118:	cd 40                	int    $0x40
 11a:	c3                   	ret    

0000011b <write>:
SYSCALL(write)
 11b:	b8 10 00 00 00       	mov    $0x10,%eax
 120:	cd 40                	int    $0x40
 122:	c3                   	ret    

00000123 <close>:
SYSCALL(close)
 123:	b8 15 00 00 00       	mov    $0x15,%eax
 128:	cd 40                	int    $0x40
 12a:	c3                   	ret    

0000012b <kill>:
SYSCALL(kill)
 12b:	b8 06 00 00 00       	mov    $0x6,%eax
 130:	cd 40                	int    $0x40
 132:	c3                   	ret    

00000133 <exec>:
SYSCALL(exec)
 133:	b8 07 00 00 00       	mov    $0x7,%eax
 138:	cd 40                	int    $0x40
 13a:	c3                   	ret    

0000013b <open>:
SYSCALL(open)
 13b:	b8 0f 00 00 00       	mov    $0xf,%eax
 140:	cd 40                	int    $0x40
 142:	c3                   	ret    

00000143 <mknod>:
SYSCALL(mknod)
 143:	b8 11 00 00 00       	mov    $0x11,%eax
 148:	cd 40                	int    $0x40
 14a:	c3                   	ret    

0000014b <unlink>:
SYSCALL(unlink)
 14b:	b8 12 00 00 00       	mov    $0x12,%eax
 150:	cd 40                	int    $0x40
 152:	c3                   	ret    

00000153 <fstat>:
SYSCALL(fstat)
 153:	b8 08 00 00 00       	mov    $0x8,%eax
 158:	cd 40                	int    $0x40
 15a:	c3                   	ret    

0000015b <link>:
SYSCALL(link)
 15b:	b8 13 00 00 00       	mov    $0x13,%eax
 160:	cd 40                	int    $0x40
 162:	c3                   	ret    

00000163 <mkdir>:
SYSCALL(mkdir)
 163:	b8 14 00 00 00       	mov    $0x14,%eax
 168:	cd 40                	int    $0x40
 16a:	c3                   	ret    

0000016b <chdir>:
SYSCALL(chdir)
 16b:	b8 09 00 00 00       	mov    $0x9,%eax
 170:	cd 40                	int    $0x40
 172:	c3                   	ret    

00000173 <dup>:
SYSCALL(dup)
 173:	b8 0a 00 00 00       	mov    $0xa,%eax
 178:	cd 40                	int    $0x40
 17a:	c3                   	ret    

0000017b <getpid>:
SYSCALL(getpid)
 17b:	b8 0b 00 00 00       	mov    $0xb,%eax
 180:	cd 40                	int    $0x40
 182:	c3                   	ret    

00000183 <sbrk>:
SYSCALL(sbrk)
 183:	b8 0c 00 00 00       	mov    $0xc,%eax
 188:	cd 40                	int    $0x40
 18a:	c3                   	ret    

0000018b <sleep>:
SYSCALL(sleep)
 18b:	b8 0d 00 00 00       	mov    $0xd,%eax
 190:	cd 40                	int    $0x40
 192:	c3                   	ret    

00000193 <uptime>:
SYSCALL(uptime)
 193:	b8 0e 00 00 00       	mov    $0xe,%eax
 198:	cd 40                	int    $0x40
 19a:	c3                   	ret    

0000019b <date>:
SYSCALL(date)
 19b:	b8 16 00 00 00       	mov    $0x16,%eax
 1a0:	cd 40                	int    $0x40
 1a2:	c3                   	ret    

000001a3 <dup2>:
SYSCALL(dup2)
 1a3:	b8 17 00 00 00       	mov    $0x17,%eax
 1a8:	cd 40                	int    $0x40
 1aa:	c3                   	ret    

000001ab <getprio>:
SYSCALL(getprio)
 1ab:	b8 18 00 00 00       	mov    $0x18,%eax
 1b0:	cd 40                	int    $0x40
 1b2:	c3                   	ret    

000001b3 <setprio>:
SYSCALL(setprio)
 1b3:	b8 19 00 00 00       	mov    $0x19,%eax
 1b8:	cd 40                	int    $0x40
 1ba:	c3                   	ret    

000001bb <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 1bb:	55                   	push   %ebp
 1bc:	89 e5                	mov    %esp,%ebp
 1be:	83 ec 1c             	sub    $0x1c,%esp
 1c1:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 1c4:	6a 01                	push   $0x1
 1c6:	8d 55 f4             	lea    -0xc(%ebp),%edx
 1c9:	52                   	push   %edx
 1ca:	50                   	push   %eax
 1cb:	e8 4b ff ff ff       	call   11b <write>
}
 1d0:	83 c4 10             	add    $0x10,%esp
 1d3:	c9                   	leave  
 1d4:	c3                   	ret    

000001d5 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 1d5:	55                   	push   %ebp
 1d6:	89 e5                	mov    %esp,%ebp
 1d8:	57                   	push   %edi
 1d9:	56                   	push   %esi
 1da:	53                   	push   %ebx
 1db:	83 ec 2c             	sub    $0x2c,%esp
 1de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 1e1:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1e7:	74 04                	je     1ed <printint+0x18>
 1e9:	85 d2                	test   %edx,%edx
 1eb:	78 3c                	js     229 <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 1ed:	89 d1                	mov    %edx,%ecx
  neg = 0;
 1ef:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 1f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 1fb:	89 c8                	mov    %ecx,%eax
 1fd:	ba 00 00 00 00       	mov    $0x0,%edx
 202:	f7 f6                	div    %esi
 204:	89 df                	mov    %ebx,%edi
 206:	43                   	inc    %ebx
 207:	8a 92 60 04 00 00    	mov    0x460(%edx),%dl
 20d:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 211:	89 ca                	mov    %ecx,%edx
 213:	89 c1                	mov    %eax,%ecx
 215:	39 d6                	cmp    %edx,%esi
 217:	76 e2                	jbe    1fb <printint+0x26>
  if(neg)
 219:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 21d:	74 24                	je     243 <printint+0x6e>
    buf[i++] = '-';
 21f:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 224:	8d 5f 02             	lea    0x2(%edi),%ebx
 227:	eb 1a                	jmp    243 <printint+0x6e>
    x = -xx;
 229:	89 d1                	mov    %edx,%ecx
 22b:	f7 d9                	neg    %ecx
    neg = 1;
 22d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 234:	eb c0                	jmp    1f6 <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 236:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 23b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 23e:	e8 78 ff ff ff       	call   1bb <putc>
  while(--i >= 0)
 243:	4b                   	dec    %ebx
 244:	79 f0                	jns    236 <printint+0x61>
}
 246:	83 c4 2c             	add    $0x2c,%esp
 249:	5b                   	pop    %ebx
 24a:	5e                   	pop    %esi
 24b:	5f                   	pop    %edi
 24c:	5d                   	pop    %ebp
 24d:	c3                   	ret    

0000024e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 24e:	55                   	push   %ebp
 24f:	89 e5                	mov    %esp,%ebp
 251:	57                   	push   %edi
 252:	56                   	push   %esi
 253:	53                   	push   %ebx
 254:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 257:	8d 45 10             	lea    0x10(%ebp),%eax
 25a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 25d:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 262:	bb 00 00 00 00       	mov    $0x0,%ebx
 267:	eb 12                	jmp    27b <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 269:	89 fa                	mov    %edi,%edx
 26b:	8b 45 08             	mov    0x8(%ebp),%eax
 26e:	e8 48 ff ff ff       	call   1bb <putc>
 273:	eb 05                	jmp    27a <printf+0x2c>
      }
    } else if(state == '%'){
 275:	83 fe 25             	cmp    $0x25,%esi
 278:	74 22                	je     29c <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 27a:	43                   	inc    %ebx
 27b:	8b 45 0c             	mov    0xc(%ebp),%eax
 27e:	8a 04 18             	mov    (%eax,%ebx,1),%al
 281:	84 c0                	test   %al,%al
 283:	0f 84 1d 01 00 00    	je     3a6 <printf+0x158>
    c = fmt[i] & 0xff;
 289:	0f be f8             	movsbl %al,%edi
 28c:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 28f:	85 f6                	test   %esi,%esi
 291:	75 e2                	jne    275 <printf+0x27>
      if(c == '%'){
 293:	83 f8 25             	cmp    $0x25,%eax
 296:	75 d1                	jne    269 <printf+0x1b>
        state = '%';
 298:	89 c6                	mov    %eax,%esi
 29a:	eb de                	jmp    27a <printf+0x2c>
      if(c == 'd'){
 29c:	83 f8 25             	cmp    $0x25,%eax
 29f:	0f 84 cc 00 00 00    	je     371 <printf+0x123>
 2a5:	0f 8c da 00 00 00    	jl     385 <printf+0x137>
 2ab:	83 f8 78             	cmp    $0x78,%eax
 2ae:	0f 8f d1 00 00 00    	jg     385 <printf+0x137>
 2b4:	83 f8 63             	cmp    $0x63,%eax
 2b7:	0f 8c c8 00 00 00    	jl     385 <printf+0x137>
 2bd:	83 e8 63             	sub    $0x63,%eax
 2c0:	83 f8 15             	cmp    $0x15,%eax
 2c3:	0f 87 bc 00 00 00    	ja     385 <printf+0x137>
 2c9:	ff 24 85 08 04 00 00 	jmp    *0x408(,%eax,4)
        printint(fd, *ap, 10, 1);
 2d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2d3:	8b 17                	mov    (%edi),%edx
 2d5:	83 ec 0c             	sub    $0xc,%esp
 2d8:	6a 01                	push   $0x1
 2da:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2df:	8b 45 08             	mov    0x8(%ebp),%eax
 2e2:	e8 ee fe ff ff       	call   1d5 <printint>
        ap++;
 2e7:	83 c7 04             	add    $0x4,%edi
 2ea:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2ed:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2f0:	be 00 00 00 00       	mov    $0x0,%esi
 2f5:	eb 83                	jmp    27a <printf+0x2c>
        printint(fd, *ap, 16, 0);
 2f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2fa:	8b 17                	mov    (%edi),%edx
 2fc:	83 ec 0c             	sub    $0xc,%esp
 2ff:	6a 00                	push   $0x0
 301:	b9 10 00 00 00       	mov    $0x10,%ecx
 306:	8b 45 08             	mov    0x8(%ebp),%eax
 309:	e8 c7 fe ff ff       	call   1d5 <printint>
        ap++;
 30e:	83 c7 04             	add    $0x4,%edi
 311:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 314:	83 c4 10             	add    $0x10,%esp
      state = 0;
 317:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 31c:	e9 59 ff ff ff       	jmp    27a <printf+0x2c>
        s = (char*)*ap;
 321:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 324:	8b 30                	mov    (%eax),%esi
        ap++;
 326:	83 c0 04             	add    $0x4,%eax
 329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 32c:	85 f6                	test   %esi,%esi
 32e:	75 13                	jne    343 <printf+0xf5>
          s = "(null)";
 330:	be 00 04 00 00       	mov    $0x400,%esi
 335:	eb 0c                	jmp    343 <printf+0xf5>
          putc(fd, *s);
 337:	0f be d2             	movsbl %dl,%edx
 33a:	8b 45 08             	mov    0x8(%ebp),%eax
 33d:	e8 79 fe ff ff       	call   1bb <putc>
          s++;
 342:	46                   	inc    %esi
        while(*s != 0){
 343:	8a 16                	mov    (%esi),%dl
 345:	84 d2                	test   %dl,%dl
 347:	75 ee                	jne    337 <printf+0xe9>
      state = 0;
 349:	be 00 00 00 00       	mov    $0x0,%esi
 34e:	e9 27 ff ff ff       	jmp    27a <printf+0x2c>
        putc(fd, *ap);
 353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 356:	0f be 17             	movsbl (%edi),%edx
 359:	8b 45 08             	mov    0x8(%ebp),%eax
 35c:	e8 5a fe ff ff       	call   1bb <putc>
        ap++;
 361:	83 c7 04             	add    $0x4,%edi
 364:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 367:	be 00 00 00 00       	mov    $0x0,%esi
 36c:	e9 09 ff ff ff       	jmp    27a <printf+0x2c>
        putc(fd, c);
 371:	89 fa                	mov    %edi,%edx
 373:	8b 45 08             	mov    0x8(%ebp),%eax
 376:	e8 40 fe ff ff       	call   1bb <putc>
      state = 0;
 37b:	be 00 00 00 00       	mov    $0x0,%esi
 380:	e9 f5 fe ff ff       	jmp    27a <printf+0x2c>
        putc(fd, '%');
 385:	ba 25 00 00 00       	mov    $0x25,%edx
 38a:	8b 45 08             	mov    0x8(%ebp),%eax
 38d:	e8 29 fe ff ff       	call   1bb <putc>
        putc(fd, c);
 392:	89 fa                	mov    %edi,%edx
 394:	8b 45 08             	mov    0x8(%ebp),%eax
 397:	e8 1f fe ff ff       	call   1bb <putc>
      state = 0;
 39c:	be 00 00 00 00       	mov    $0x0,%esi
 3a1:	e9 d4 fe ff ff       	jmp    27a <printf+0x2c>
    }
  }
}
 3a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3a9:	5b                   	pop    %ebx
 3aa:	5e                   	pop    %esi
 3ab:	5f                   	pop    %edi
 3ac:	5d                   	pop    %ebp
 3ad:	c3                   	ret    
