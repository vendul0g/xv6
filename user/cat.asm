
cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 75 08             	mov    0x8(%ebp),%esi
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
   8:	83 ec 04             	sub    $0x4,%esp
   b:	68 00 02 00 00       	push   $0x200
  10:	68 80 05 00 00       	push   $0x580
  15:	56                   	push   %esi
  16:	e8 1c 01 00 00       	call   137 <read>
  1b:	89 c3                	mov    %eax,%ebx
  1d:	83 c4 10             	add    $0x10,%esp
  20:	85 c0                	test   %eax,%eax
  22:	7e 32                	jle    56 <cat+0x56>
    if (write(1, buf, n) != n) {
  24:	83 ec 04             	sub    $0x4,%esp
  27:	53                   	push   %ebx
  28:	68 80 05 00 00       	push   $0x580
  2d:	6a 01                	push   $0x1
  2f:	e8 0b 01 00 00       	call   13f <write>
  34:	83 c4 10             	add    $0x10,%esp
  37:	39 d8                	cmp    %ebx,%eax
  39:	74 cd                	je     8 <cat+0x8>
      printf(1, "cat: write error\n");
  3b:	83 ec 08             	sub    $0x8,%esp
  3e:	68 d4 03 00 00       	push   $0x3d4
  43:	6a 01                	push   $0x1
  45:	e8 28 02 00 00       	call   272 <printf>
      exit(0);
  4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  51:	e8 c9 00 00 00       	call   11f <exit>
    }
  }
  if(n < 0){
  56:	78 07                	js     5f <cat+0x5f>
    printf(1, "cat: read error\n");
    exit(0);
  }
}
  58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  5b:	5b                   	pop    %ebx
  5c:	5e                   	pop    %esi
  5d:	5d                   	pop    %ebp
  5e:	c3                   	ret    
    printf(1, "cat: read error\n");
  5f:	83 ec 08             	sub    $0x8,%esp
  62:	68 e6 03 00 00       	push   $0x3e6
  67:	6a 01                	push   $0x1
  69:	e8 04 02 00 00       	call   272 <printf>
    exit(0);
  6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  75:	e8 a5 00 00 00       	call   11f <exit>

0000007a <main>:

int
main(int argc, char *argv[])
{
  7a:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  7e:	83 e4 f0             	and    $0xfffffff0,%esp
  81:	ff 71 fc             	push   -0x4(%ecx)
  84:	55                   	push   %ebp
  85:	89 e5                	mov    %esp,%ebp
  87:	57                   	push   %edi
  88:	56                   	push   %esi
  89:	53                   	push   %ebx
  8a:	51                   	push   %ecx
  8b:	83 ec 18             	sub    $0x18,%esp
  8e:	8b 01                	mov    (%ecx),%eax
  90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  93:	8b 51 04             	mov    0x4(%ecx),%edx
  96:	89 55 e0             	mov    %edx,-0x20(%ebp)
  int fd, i;

  if(argc <= 1){
  99:	83 f8 01             	cmp    $0x1,%eax
  9c:	7e 07                	jle    a5 <main+0x2b>
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
  9e:	be 01 00 00 00       	mov    $0x1,%esi
  a3:	eb 2b                	jmp    d0 <main+0x56>
    cat(0);
  a5:	83 ec 0c             	sub    $0xc,%esp
  a8:	6a 00                	push   $0x0
  aa:	e8 51 ff ff ff       	call   0 <cat>
    exit(0);
  af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  b6:	e8 64 00 00 00       	call   11f <exit>
    if((fd = open(argv[i], 0)) < 0){
      printf(1, "cat: cannot open %s\n", argv[i]);
      exit(0);
    }
    cat(fd);
  bb:	83 ec 0c             	sub    $0xc,%esp
  be:	50                   	push   %eax
  bf:	e8 3c ff ff ff       	call   0 <cat>
    close(fd);
  c4:	89 1c 24             	mov    %ebx,(%esp)
  c7:	e8 7b 00 00 00       	call   147 <close>
  for(i = 1; i < argc; i++){
  cc:	46                   	inc    %esi
  cd:	83 c4 10             	add    $0x10,%esp
  d0:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
  d3:	7d 38                	jge    10d <main+0x93>
    if((fd = open(argv[i], 0)) < 0){
  d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  d8:	8d 3c b0             	lea    (%eax,%esi,4),%edi
  db:	83 ec 08             	sub    $0x8,%esp
  de:	6a 00                	push   $0x0
  e0:	ff 37                	push   (%edi)
  e2:	e8 78 00 00 00       	call   15f <open>
  e7:	89 c3                	mov    %eax,%ebx
  e9:	83 c4 10             	add    $0x10,%esp
  ec:	85 c0                	test   %eax,%eax
  ee:	79 cb                	jns    bb <main+0x41>
      printf(1, "cat: cannot open %s\n", argv[i]);
  f0:	83 ec 04             	sub    $0x4,%esp
  f3:	ff 37                	push   (%edi)
  f5:	68 f7 03 00 00       	push   $0x3f7
  fa:	6a 01                	push   $0x1
  fc:	e8 71 01 00 00       	call   272 <printf>
      exit(0);
 101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 108:	e8 12 00 00 00       	call   11f <exit>
  }
  exit(0);
 10d:	83 ec 0c             	sub    $0xc,%esp
 110:	6a 00                	push   $0x0
 112:	e8 08 00 00 00       	call   11f <exit>

00000117 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 117:	b8 01 00 00 00       	mov    $0x1,%eax
 11c:	cd 40                	int    $0x40
 11e:	c3                   	ret    

0000011f <exit>:
SYSCALL(exit)
 11f:	b8 02 00 00 00       	mov    $0x2,%eax
 124:	cd 40                	int    $0x40
 126:	c3                   	ret    

00000127 <wait>:
SYSCALL(wait)
 127:	b8 03 00 00 00       	mov    $0x3,%eax
 12c:	cd 40                	int    $0x40
 12e:	c3                   	ret    

0000012f <pipe>:
SYSCALL(pipe)
 12f:	b8 04 00 00 00       	mov    $0x4,%eax
 134:	cd 40                	int    $0x40
 136:	c3                   	ret    

00000137 <read>:
SYSCALL(read)
 137:	b8 05 00 00 00       	mov    $0x5,%eax
 13c:	cd 40                	int    $0x40
 13e:	c3                   	ret    

0000013f <write>:
SYSCALL(write)
 13f:	b8 10 00 00 00       	mov    $0x10,%eax
 144:	cd 40                	int    $0x40
 146:	c3                   	ret    

00000147 <close>:
SYSCALL(close)
 147:	b8 15 00 00 00       	mov    $0x15,%eax
 14c:	cd 40                	int    $0x40
 14e:	c3                   	ret    

0000014f <kill>:
SYSCALL(kill)
 14f:	b8 06 00 00 00       	mov    $0x6,%eax
 154:	cd 40                	int    $0x40
 156:	c3                   	ret    

00000157 <exec>:
SYSCALL(exec)
 157:	b8 07 00 00 00       	mov    $0x7,%eax
 15c:	cd 40                	int    $0x40
 15e:	c3                   	ret    

0000015f <open>:
SYSCALL(open)
 15f:	b8 0f 00 00 00       	mov    $0xf,%eax
 164:	cd 40                	int    $0x40
 166:	c3                   	ret    

00000167 <mknod>:
SYSCALL(mknod)
 167:	b8 11 00 00 00       	mov    $0x11,%eax
 16c:	cd 40                	int    $0x40
 16e:	c3                   	ret    

0000016f <unlink>:
SYSCALL(unlink)
 16f:	b8 12 00 00 00       	mov    $0x12,%eax
 174:	cd 40                	int    $0x40
 176:	c3                   	ret    

00000177 <fstat>:
SYSCALL(fstat)
 177:	b8 08 00 00 00       	mov    $0x8,%eax
 17c:	cd 40                	int    $0x40
 17e:	c3                   	ret    

0000017f <link>:
SYSCALL(link)
 17f:	b8 13 00 00 00       	mov    $0x13,%eax
 184:	cd 40                	int    $0x40
 186:	c3                   	ret    

00000187 <mkdir>:
SYSCALL(mkdir)
 187:	b8 14 00 00 00       	mov    $0x14,%eax
 18c:	cd 40                	int    $0x40
 18e:	c3                   	ret    

0000018f <chdir>:
SYSCALL(chdir)
 18f:	b8 09 00 00 00       	mov    $0x9,%eax
 194:	cd 40                	int    $0x40
 196:	c3                   	ret    

00000197 <dup>:
SYSCALL(dup)
 197:	b8 0a 00 00 00       	mov    $0xa,%eax
 19c:	cd 40                	int    $0x40
 19e:	c3                   	ret    

0000019f <getpid>:
SYSCALL(getpid)
 19f:	b8 0b 00 00 00       	mov    $0xb,%eax
 1a4:	cd 40                	int    $0x40
 1a6:	c3                   	ret    

000001a7 <sbrk>:
SYSCALL(sbrk)
 1a7:	b8 0c 00 00 00       	mov    $0xc,%eax
 1ac:	cd 40                	int    $0x40
 1ae:	c3                   	ret    

000001af <sleep>:
SYSCALL(sleep)
 1af:	b8 0d 00 00 00       	mov    $0xd,%eax
 1b4:	cd 40                	int    $0x40
 1b6:	c3                   	ret    

000001b7 <uptime>:
SYSCALL(uptime)
 1b7:	b8 0e 00 00 00       	mov    $0xe,%eax
 1bc:	cd 40                	int    $0x40
 1be:	c3                   	ret    

000001bf <date>:
SYSCALL(date)
 1bf:	b8 16 00 00 00       	mov    $0x16,%eax
 1c4:	cd 40                	int    $0x40
 1c6:	c3                   	ret    

000001c7 <dup2>:
SYSCALL(dup2)
 1c7:	b8 17 00 00 00       	mov    $0x17,%eax
 1cc:	cd 40                	int    $0x40
 1ce:	c3                   	ret    

000001cf <getprio>:
SYSCALL(getprio)
 1cf:	b8 18 00 00 00       	mov    $0x18,%eax
 1d4:	cd 40                	int    $0x40
 1d6:	c3                   	ret    

000001d7 <setprio>:
SYSCALL(setprio)
 1d7:	b8 19 00 00 00       	mov    $0x19,%eax
 1dc:	cd 40                	int    $0x40
 1de:	c3                   	ret    

000001df <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 1df:	55                   	push   %ebp
 1e0:	89 e5                	mov    %esp,%ebp
 1e2:	83 ec 1c             	sub    $0x1c,%esp
 1e5:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 1e8:	6a 01                	push   $0x1
 1ea:	8d 55 f4             	lea    -0xc(%ebp),%edx
 1ed:	52                   	push   %edx
 1ee:	50                   	push   %eax
 1ef:	e8 4b ff ff ff       	call   13f <write>
}
 1f4:	83 c4 10             	add    $0x10,%esp
 1f7:	c9                   	leave  
 1f8:	c3                   	ret    

000001f9 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 1f9:	55                   	push   %ebp
 1fa:	89 e5                	mov    %esp,%ebp
 1fc:	57                   	push   %edi
 1fd:	56                   	push   %esi
 1fe:	53                   	push   %ebx
 1ff:	83 ec 2c             	sub    $0x2c,%esp
 202:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 205:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 207:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 20b:	74 04                	je     211 <printint+0x18>
 20d:	85 d2                	test   %edx,%edx
 20f:	78 3c                	js     24d <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 211:	89 d1                	mov    %edx,%ecx
  neg = 0;
 213:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 21a:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 21f:	89 c8                	mov    %ecx,%eax
 221:	ba 00 00 00 00       	mov    $0x0,%edx
 226:	f7 f6                	div    %esi
 228:	89 df                	mov    %ebx,%edi
 22a:	43                   	inc    %ebx
 22b:	8a 92 6c 04 00 00    	mov    0x46c(%edx),%dl
 231:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 235:	89 ca                	mov    %ecx,%edx
 237:	89 c1                	mov    %eax,%ecx
 239:	39 d6                	cmp    %edx,%esi
 23b:	76 e2                	jbe    21f <printint+0x26>
  if(neg)
 23d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 241:	74 24                	je     267 <printint+0x6e>
    buf[i++] = '-';
 243:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 248:	8d 5f 02             	lea    0x2(%edi),%ebx
 24b:	eb 1a                	jmp    267 <printint+0x6e>
    x = -xx;
 24d:	89 d1                	mov    %edx,%ecx
 24f:	f7 d9                	neg    %ecx
    neg = 1;
 251:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 258:	eb c0                	jmp    21a <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 25a:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 25f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 262:	e8 78 ff ff ff       	call   1df <putc>
  while(--i >= 0)
 267:	4b                   	dec    %ebx
 268:	79 f0                	jns    25a <printint+0x61>
}
 26a:	83 c4 2c             	add    $0x2c,%esp
 26d:	5b                   	pop    %ebx
 26e:	5e                   	pop    %esi
 26f:	5f                   	pop    %edi
 270:	5d                   	pop    %ebp
 271:	c3                   	ret    

00000272 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 272:	55                   	push   %ebp
 273:	89 e5                	mov    %esp,%ebp
 275:	57                   	push   %edi
 276:	56                   	push   %esi
 277:	53                   	push   %ebx
 278:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 27b:	8d 45 10             	lea    0x10(%ebp),%eax
 27e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 281:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 286:	bb 00 00 00 00       	mov    $0x0,%ebx
 28b:	eb 12                	jmp    29f <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 28d:	89 fa                	mov    %edi,%edx
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	e8 48 ff ff ff       	call   1df <putc>
 297:	eb 05                	jmp    29e <printf+0x2c>
      }
    } else if(state == '%'){
 299:	83 fe 25             	cmp    $0x25,%esi
 29c:	74 22                	je     2c0 <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 29e:	43                   	inc    %ebx
 29f:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a2:	8a 04 18             	mov    (%eax,%ebx,1),%al
 2a5:	84 c0                	test   %al,%al
 2a7:	0f 84 1d 01 00 00    	je     3ca <printf+0x158>
    c = fmt[i] & 0xff;
 2ad:	0f be f8             	movsbl %al,%edi
 2b0:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 2b3:	85 f6                	test   %esi,%esi
 2b5:	75 e2                	jne    299 <printf+0x27>
      if(c == '%'){
 2b7:	83 f8 25             	cmp    $0x25,%eax
 2ba:	75 d1                	jne    28d <printf+0x1b>
        state = '%';
 2bc:	89 c6                	mov    %eax,%esi
 2be:	eb de                	jmp    29e <printf+0x2c>
      if(c == 'd'){
 2c0:	83 f8 25             	cmp    $0x25,%eax
 2c3:	0f 84 cc 00 00 00    	je     395 <printf+0x123>
 2c9:	0f 8c da 00 00 00    	jl     3a9 <printf+0x137>
 2cf:	83 f8 78             	cmp    $0x78,%eax
 2d2:	0f 8f d1 00 00 00    	jg     3a9 <printf+0x137>
 2d8:	83 f8 63             	cmp    $0x63,%eax
 2db:	0f 8c c8 00 00 00    	jl     3a9 <printf+0x137>
 2e1:	83 e8 63             	sub    $0x63,%eax
 2e4:	83 f8 15             	cmp    $0x15,%eax
 2e7:	0f 87 bc 00 00 00    	ja     3a9 <printf+0x137>
 2ed:	ff 24 85 14 04 00 00 	jmp    *0x414(,%eax,4)
        printint(fd, *ap, 10, 1);
 2f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2f7:	8b 17                	mov    (%edi),%edx
 2f9:	83 ec 0c             	sub    $0xc,%esp
 2fc:	6a 01                	push   $0x1
 2fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
 303:	8b 45 08             	mov    0x8(%ebp),%eax
 306:	e8 ee fe ff ff       	call   1f9 <printint>
        ap++;
 30b:	83 c7 04             	add    $0x4,%edi
 30e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 311:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 314:	be 00 00 00 00       	mov    $0x0,%esi
 319:	eb 83                	jmp    29e <printf+0x2c>
        printint(fd, *ap, 16, 0);
 31b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 31e:	8b 17                	mov    (%edi),%edx
 320:	83 ec 0c             	sub    $0xc,%esp
 323:	6a 00                	push   $0x0
 325:	b9 10 00 00 00       	mov    $0x10,%ecx
 32a:	8b 45 08             	mov    0x8(%ebp),%eax
 32d:	e8 c7 fe ff ff       	call   1f9 <printint>
        ap++;
 332:	83 c7 04             	add    $0x4,%edi
 335:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 338:	83 c4 10             	add    $0x10,%esp
      state = 0;
 33b:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 340:	e9 59 ff ff ff       	jmp    29e <printf+0x2c>
        s = (char*)*ap;
 345:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 348:	8b 30                	mov    (%eax),%esi
        ap++;
 34a:	83 c0 04             	add    $0x4,%eax
 34d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 350:	85 f6                	test   %esi,%esi
 352:	75 13                	jne    367 <printf+0xf5>
          s = "(null)";
 354:	be 0c 04 00 00       	mov    $0x40c,%esi
 359:	eb 0c                	jmp    367 <printf+0xf5>
          putc(fd, *s);
 35b:	0f be d2             	movsbl %dl,%edx
 35e:	8b 45 08             	mov    0x8(%ebp),%eax
 361:	e8 79 fe ff ff       	call   1df <putc>
          s++;
 366:	46                   	inc    %esi
        while(*s != 0){
 367:	8a 16                	mov    (%esi),%dl
 369:	84 d2                	test   %dl,%dl
 36b:	75 ee                	jne    35b <printf+0xe9>
      state = 0;
 36d:	be 00 00 00 00       	mov    $0x0,%esi
 372:	e9 27 ff ff ff       	jmp    29e <printf+0x2c>
        putc(fd, *ap);
 377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 37a:	0f be 17             	movsbl (%edi),%edx
 37d:	8b 45 08             	mov    0x8(%ebp),%eax
 380:	e8 5a fe ff ff       	call   1df <putc>
        ap++;
 385:	83 c7 04             	add    $0x4,%edi
 388:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 38b:	be 00 00 00 00       	mov    $0x0,%esi
 390:	e9 09 ff ff ff       	jmp    29e <printf+0x2c>
        putc(fd, c);
 395:	89 fa                	mov    %edi,%edx
 397:	8b 45 08             	mov    0x8(%ebp),%eax
 39a:	e8 40 fe ff ff       	call   1df <putc>
      state = 0;
 39f:	be 00 00 00 00       	mov    $0x0,%esi
 3a4:	e9 f5 fe ff ff       	jmp    29e <printf+0x2c>
        putc(fd, '%');
 3a9:	ba 25 00 00 00       	mov    $0x25,%edx
 3ae:	8b 45 08             	mov    0x8(%ebp),%eax
 3b1:	e8 29 fe ff ff       	call   1df <putc>
        putc(fd, c);
 3b6:	89 fa                	mov    %edi,%edx
 3b8:	8b 45 08             	mov    0x8(%ebp),%eax
 3bb:	e8 1f fe ff ff       	call   1df <putc>
      state = 0;
 3c0:	be 00 00 00 00       	mov    $0x0,%esi
 3c5:	e9 d4 fe ff ff       	jmp    29e <printf+0x2c>
    }
  }
}
 3ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3cd:	5b                   	pop    %ebx
 3ce:	5e                   	pop    %esi
 3cf:	5f                   	pop    %edi
 3d0:	5d                   	pop    %ebp
 3d1:	c3                   	ret    
