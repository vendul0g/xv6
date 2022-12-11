
exitwait:     file format elf32-i386


Disassembly of section .text:

00000000 <forktest>:

#define N  1000

void
forktest(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 1c             	sub    $0x1c,%esp
  int n, pid;
  int status;

  printf(1, "exit/wait with status test\n");
   7:	68 04 04 00 00       	push   $0x404
   c:	6a 01                	push   $0x1
   e:	e8 90 02 00 00       	call   2a3 <printf>

  for(n=0; n<N; n++){
  13:	83 c4 10             	add    $0x10,%esp
  16:	bb 00 00 00 00       	mov    $0x0,%ebx
  1b:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  21:	7f 34                	jg     57 <forktest+0x57>
    pid = fork();
  23:	e8 20 01 00 00       	call   148 <fork>
    if(pid < 0)
  28:	85 c0                	test   %eax,%eax
  2a:	78 2b                	js     57 <forktest+0x57>
      break;
    if(pid == 0)
  2c:	74 03                	je     31 <forktest+0x31>
  for(n=0; n<N; n++){
  2e:	43                   	inc    %ebx
  2f:	eb ea                	jmp    1b <forktest+0x1b>
      exit(n - 1/(n/40));  // Some process will fail with divide by 0
  31:	b8 67 66 66 66       	mov    $0x66666667,%eax
  36:	f7 eb                	imul   %ebx
  38:	89 d1                	mov    %edx,%ecx
  3a:	c1 f9 04             	sar    $0x4,%ecx
  3d:	89 d8                	mov    %ebx,%eax
  3f:	c1 f8 1f             	sar    $0x1f,%eax
  42:	29 c1                	sub    %eax,%ecx
  44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  49:	99                   	cltd   
  4a:	f7 f9                	idiv   %ecx
  4c:	83 ec 0c             	sub    $0xc,%esp
  4f:	01 d8                	add    %ebx,%eax
  51:	50                   	push   %eax
  52:	e8 f9 00 00 00       	call   150 <exit>
  }

  if(n == N)
  57:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  5d:	75 4e                	jne    ad <forktest+0xad>
  {
    printf(1, "fork claimed to work %d times!\n", N);
  5f:	83 ec 04             	sub    $0x4,%esp
  62:	68 e8 03 00 00       	push   $0x3e8
  67:	68 74 04 00 00       	push   $0x474
  6c:	6a 01                	push   $0x1
  6e:	e8 30 02 00 00       	call   2a3 <printf>
    exit(N);
  73:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
  7a:	e8 d1 00 00 00       	call   150 <exit>

  for(; n > 0; n--)
  {
    if((pid = wait(&status)) < 0)
    {
      printf(1, "wait stopped early\n");
  7f:	83 ec 08             	sub    $0x8,%esp
  82:	68 20 04 00 00       	push   $0x420
  87:	6a 01                	push   $0x1
  89:	e8 15 02 00 00       	call   2a3 <printf>
      exit(-1);
  8e:	c7 04 24 ff ff ff ff 	movl   $0xffffffff,(%esp)
  95:	e8 b6 00 00 00       	call   150 <exit>
    }
    if (WIFEXITED (status))
      printf (1, "Exited child %d, exitcode %d\n", pid, WEXITSTATUS (status));
    else if (WIFSIGNALED(status))
      printf (1, "Exited child (failure) %d, trap %d\n", pid, WEXITTRAP (status));
  9a:	49                   	dec    %ecx
  9b:	51                   	push   %ecx
  9c:	50                   	push   %eax
  9d:	68 94 04 00 00       	push   $0x494
  a2:	6a 01                	push   $0x1
  a4:	e8 fa 01 00 00       	call   2a3 <printf>
  a9:	83 c4 10             	add    $0x10,%esp
  for(; n > 0; n--)
  ac:	4b                   	dec    %ebx
  ad:	85 db                	test   %ebx,%ebx
  af:	7e 33                	jle    e4 <forktest+0xe4>
    if((pid = wait(&status)) < 0)
  b1:	83 ec 0c             	sub    $0xc,%esp
  b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  b7:	50                   	push   %eax
  b8:	e8 9b 00 00 00       	call   158 <wait>
  bd:	83 c4 10             	add    $0x10,%esp
  c0:	85 c0                	test   %eax,%eax
  c2:	78 bb                	js     7f <forktest+0x7f>
    if (WIFEXITED (status))
  c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  c7:	89 d1                	mov    %edx,%ecx
  c9:	83 e1 7f             	and    $0x7f,%ecx
  cc:	75 cc                	jne    9a <forktest+0x9a>
      printf (1, "Exited child %d, exitcode %d\n", pid, WEXITSTATUS (status));
  ce:	0f b6 d6             	movzbl %dh,%edx
  d1:	52                   	push   %edx
  d2:	50                   	push   %eax
  d3:	68 34 04 00 00       	push   $0x434
  d8:	6a 01                	push   $0x1
  da:	e8 c4 01 00 00       	call   2a3 <printf>
  df:	83 c4 10             	add    $0x10,%esp
  e2:	eb c8                	jmp    ac <forktest+0xac>
  }

  if(wait(0) != -1){
  e4:	83 ec 0c             	sub    $0xc,%esp
  e7:	6a 00                	push   $0x0
  e9:	e8 6a 00 00 00       	call   158 <wait>
  ee:	83 c4 10             	add    $0x10,%esp
  f1:	83 f8 ff             	cmp    $0xffffffff,%eax
  f4:	75 17                	jne    10d <forktest+0x10d>
    printf(1, "wait got too many\n");
    exit(-1);
  }

  printf(1, "fork test OK\n");
  f6:	83 ec 08             	sub    $0x8,%esp
  f9:	68 65 04 00 00       	push   $0x465
  fe:	6a 01                	push   $0x1
 100:	e8 9e 01 00 00       	call   2a3 <printf>
}
 105:	83 c4 10             	add    $0x10,%esp
 108:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 10b:	c9                   	leave  
 10c:	c3                   	ret    
    printf(1, "wait got too many\n");
 10d:	83 ec 08             	sub    $0x8,%esp
 110:	68 52 04 00 00       	push   $0x452
 115:	6a 01                	push   $0x1
 117:	e8 87 01 00 00       	call   2a3 <printf>
    exit(-1);
 11c:	c7 04 24 ff ff ff ff 	movl   $0xffffffff,(%esp)
 123:	e8 28 00 00 00       	call   150 <exit>

00000128 <main>:

int
main(void)
{
 128:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 12c:	83 e4 f0             	and    $0xfffffff0,%esp
 12f:	ff 71 fc             	push   -0x4(%ecx)
 132:	55                   	push   %ebp
 133:	89 e5                	mov    %esp,%ebp
 135:	51                   	push   %ecx
 136:	83 ec 04             	sub    $0x4,%esp
  forktest();
 139:	e8 c2 fe ff ff       	call   0 <forktest>
  exit(0);
 13e:	83 ec 0c             	sub    $0xc,%esp
 141:	6a 00                	push   $0x0
 143:	e8 08 00 00 00       	call   150 <exit>

00000148 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 148:	b8 01 00 00 00       	mov    $0x1,%eax
 14d:	cd 40                	int    $0x40
 14f:	c3                   	ret    

00000150 <exit>:
SYSCALL(exit)
 150:	b8 02 00 00 00       	mov    $0x2,%eax
 155:	cd 40                	int    $0x40
 157:	c3                   	ret    

00000158 <wait>:
SYSCALL(wait)
 158:	b8 03 00 00 00       	mov    $0x3,%eax
 15d:	cd 40                	int    $0x40
 15f:	c3                   	ret    

00000160 <pipe>:
SYSCALL(pipe)
 160:	b8 04 00 00 00       	mov    $0x4,%eax
 165:	cd 40                	int    $0x40
 167:	c3                   	ret    

00000168 <read>:
SYSCALL(read)
 168:	b8 05 00 00 00       	mov    $0x5,%eax
 16d:	cd 40                	int    $0x40
 16f:	c3                   	ret    

00000170 <write>:
SYSCALL(write)
 170:	b8 10 00 00 00       	mov    $0x10,%eax
 175:	cd 40                	int    $0x40
 177:	c3                   	ret    

00000178 <close>:
SYSCALL(close)
 178:	b8 15 00 00 00       	mov    $0x15,%eax
 17d:	cd 40                	int    $0x40
 17f:	c3                   	ret    

00000180 <kill>:
SYSCALL(kill)
 180:	b8 06 00 00 00       	mov    $0x6,%eax
 185:	cd 40                	int    $0x40
 187:	c3                   	ret    

00000188 <exec>:
SYSCALL(exec)
 188:	b8 07 00 00 00       	mov    $0x7,%eax
 18d:	cd 40                	int    $0x40
 18f:	c3                   	ret    

00000190 <open>:
SYSCALL(open)
 190:	b8 0f 00 00 00       	mov    $0xf,%eax
 195:	cd 40                	int    $0x40
 197:	c3                   	ret    

00000198 <mknod>:
SYSCALL(mknod)
 198:	b8 11 00 00 00       	mov    $0x11,%eax
 19d:	cd 40                	int    $0x40
 19f:	c3                   	ret    

000001a0 <unlink>:
SYSCALL(unlink)
 1a0:	b8 12 00 00 00       	mov    $0x12,%eax
 1a5:	cd 40                	int    $0x40
 1a7:	c3                   	ret    

000001a8 <fstat>:
SYSCALL(fstat)
 1a8:	b8 08 00 00 00       	mov    $0x8,%eax
 1ad:	cd 40                	int    $0x40
 1af:	c3                   	ret    

000001b0 <link>:
SYSCALL(link)
 1b0:	b8 13 00 00 00       	mov    $0x13,%eax
 1b5:	cd 40                	int    $0x40
 1b7:	c3                   	ret    

000001b8 <mkdir>:
SYSCALL(mkdir)
 1b8:	b8 14 00 00 00       	mov    $0x14,%eax
 1bd:	cd 40                	int    $0x40
 1bf:	c3                   	ret    

000001c0 <chdir>:
SYSCALL(chdir)
 1c0:	b8 09 00 00 00       	mov    $0x9,%eax
 1c5:	cd 40                	int    $0x40
 1c7:	c3                   	ret    

000001c8 <dup>:
SYSCALL(dup)
 1c8:	b8 0a 00 00 00       	mov    $0xa,%eax
 1cd:	cd 40                	int    $0x40
 1cf:	c3                   	ret    

000001d0 <getpid>:
SYSCALL(getpid)
 1d0:	b8 0b 00 00 00       	mov    $0xb,%eax
 1d5:	cd 40                	int    $0x40
 1d7:	c3                   	ret    

000001d8 <sbrk>:
SYSCALL(sbrk)
 1d8:	b8 0c 00 00 00       	mov    $0xc,%eax
 1dd:	cd 40                	int    $0x40
 1df:	c3                   	ret    

000001e0 <sleep>:
SYSCALL(sleep)
 1e0:	b8 0d 00 00 00       	mov    $0xd,%eax
 1e5:	cd 40                	int    $0x40
 1e7:	c3                   	ret    

000001e8 <uptime>:
SYSCALL(uptime)
 1e8:	b8 0e 00 00 00       	mov    $0xe,%eax
 1ed:	cd 40                	int    $0x40
 1ef:	c3                   	ret    

000001f0 <date>:
SYSCALL(date)
 1f0:	b8 16 00 00 00       	mov    $0x16,%eax
 1f5:	cd 40                	int    $0x40
 1f7:	c3                   	ret    

000001f8 <dup2>:
SYSCALL(dup2)
 1f8:	b8 17 00 00 00       	mov    $0x17,%eax
 1fd:	cd 40                	int    $0x40
 1ff:	c3                   	ret    

00000200 <getprio>:
SYSCALL(getprio)
 200:	b8 18 00 00 00       	mov    $0x18,%eax
 205:	cd 40                	int    $0x40
 207:	c3                   	ret    

00000208 <setprio>:
SYSCALL(setprio)
 208:	b8 19 00 00 00       	mov    $0x19,%eax
 20d:	cd 40                	int    $0x40
 20f:	c3                   	ret    

00000210 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 210:	55                   	push   %ebp
 211:	89 e5                	mov    %esp,%ebp
 213:	83 ec 1c             	sub    $0x1c,%esp
 216:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 219:	6a 01                	push   $0x1
 21b:	8d 55 f4             	lea    -0xc(%ebp),%edx
 21e:	52                   	push   %edx
 21f:	50                   	push   %eax
 220:	e8 4b ff ff ff       	call   170 <write>
}
 225:	83 c4 10             	add    $0x10,%esp
 228:	c9                   	leave  
 229:	c3                   	ret    

0000022a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 22a:	55                   	push   %ebp
 22b:	89 e5                	mov    %esp,%ebp
 22d:	57                   	push   %edi
 22e:	56                   	push   %esi
 22f:	53                   	push   %ebx
 230:	83 ec 2c             	sub    $0x2c,%esp
 233:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 236:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 238:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 23c:	74 04                	je     242 <printint+0x18>
 23e:	85 d2                	test   %edx,%edx
 240:	78 3c                	js     27e <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 242:	89 d1                	mov    %edx,%ecx
  neg = 0;
 244:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 24b:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 250:	89 c8                	mov    %ecx,%eax
 252:	ba 00 00 00 00       	mov    $0x0,%edx
 257:	f7 f6                	div    %esi
 259:	89 df                	mov    %ebx,%edi
 25b:	43                   	inc    %ebx
 25c:	8a 92 18 05 00 00    	mov    0x518(%edx),%dl
 262:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 266:	89 ca                	mov    %ecx,%edx
 268:	89 c1                	mov    %eax,%ecx
 26a:	39 d6                	cmp    %edx,%esi
 26c:	76 e2                	jbe    250 <printint+0x26>
  if(neg)
 26e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 272:	74 24                	je     298 <printint+0x6e>
    buf[i++] = '-';
 274:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 279:	8d 5f 02             	lea    0x2(%edi),%ebx
 27c:	eb 1a                	jmp    298 <printint+0x6e>
    x = -xx;
 27e:	89 d1                	mov    %edx,%ecx
 280:	f7 d9                	neg    %ecx
    neg = 1;
 282:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 289:	eb c0                	jmp    24b <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 28b:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 290:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 293:	e8 78 ff ff ff       	call   210 <putc>
  while(--i >= 0)
 298:	4b                   	dec    %ebx
 299:	79 f0                	jns    28b <printint+0x61>
}
 29b:	83 c4 2c             	add    $0x2c,%esp
 29e:	5b                   	pop    %ebx
 29f:	5e                   	pop    %esi
 2a0:	5f                   	pop    %edi
 2a1:	5d                   	pop    %ebp
 2a2:	c3                   	ret    

000002a3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 2a3:	55                   	push   %ebp
 2a4:	89 e5                	mov    %esp,%ebp
 2a6:	57                   	push   %edi
 2a7:	56                   	push   %esi
 2a8:	53                   	push   %ebx
 2a9:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 2ac:	8d 45 10             	lea    0x10(%ebp),%eax
 2af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 2b2:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 2b7:	bb 00 00 00 00       	mov    $0x0,%ebx
 2bc:	eb 12                	jmp    2d0 <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 2be:	89 fa                	mov    %edi,%edx
 2c0:	8b 45 08             	mov    0x8(%ebp),%eax
 2c3:	e8 48 ff ff ff       	call   210 <putc>
 2c8:	eb 05                	jmp    2cf <printf+0x2c>
      }
    } else if(state == '%'){
 2ca:	83 fe 25             	cmp    $0x25,%esi
 2cd:	74 22                	je     2f1 <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 2cf:	43                   	inc    %ebx
 2d0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d3:	8a 04 18             	mov    (%eax,%ebx,1),%al
 2d6:	84 c0                	test   %al,%al
 2d8:	0f 84 1d 01 00 00    	je     3fb <printf+0x158>
    c = fmt[i] & 0xff;
 2de:	0f be f8             	movsbl %al,%edi
 2e1:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 2e4:	85 f6                	test   %esi,%esi
 2e6:	75 e2                	jne    2ca <printf+0x27>
      if(c == '%'){
 2e8:	83 f8 25             	cmp    $0x25,%eax
 2eb:	75 d1                	jne    2be <printf+0x1b>
        state = '%';
 2ed:	89 c6                	mov    %eax,%esi
 2ef:	eb de                	jmp    2cf <printf+0x2c>
      if(c == 'd'){
 2f1:	83 f8 25             	cmp    $0x25,%eax
 2f4:	0f 84 cc 00 00 00    	je     3c6 <printf+0x123>
 2fa:	0f 8c da 00 00 00    	jl     3da <printf+0x137>
 300:	83 f8 78             	cmp    $0x78,%eax
 303:	0f 8f d1 00 00 00    	jg     3da <printf+0x137>
 309:	83 f8 63             	cmp    $0x63,%eax
 30c:	0f 8c c8 00 00 00    	jl     3da <printf+0x137>
 312:	83 e8 63             	sub    $0x63,%eax
 315:	83 f8 15             	cmp    $0x15,%eax
 318:	0f 87 bc 00 00 00    	ja     3da <printf+0x137>
 31e:	ff 24 85 c0 04 00 00 	jmp    *0x4c0(,%eax,4)
        printint(fd, *ap, 10, 1);
 325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 328:	8b 17                	mov    (%edi),%edx
 32a:	83 ec 0c             	sub    $0xc,%esp
 32d:	6a 01                	push   $0x1
 32f:	b9 0a 00 00 00       	mov    $0xa,%ecx
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	e8 ee fe ff ff       	call   22a <printint>
        ap++;
 33c:	83 c7 04             	add    $0x4,%edi
 33f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 342:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 345:	be 00 00 00 00       	mov    $0x0,%esi
 34a:	eb 83                	jmp    2cf <printf+0x2c>
        printint(fd, *ap, 16, 0);
 34c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 34f:	8b 17                	mov    (%edi),%edx
 351:	83 ec 0c             	sub    $0xc,%esp
 354:	6a 00                	push   $0x0
 356:	b9 10 00 00 00       	mov    $0x10,%ecx
 35b:	8b 45 08             	mov    0x8(%ebp),%eax
 35e:	e8 c7 fe ff ff       	call   22a <printint>
        ap++;
 363:	83 c7 04             	add    $0x4,%edi
 366:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 369:	83 c4 10             	add    $0x10,%esp
      state = 0;
 36c:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 371:	e9 59 ff ff ff       	jmp    2cf <printf+0x2c>
        s = (char*)*ap;
 376:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 379:	8b 30                	mov    (%eax),%esi
        ap++;
 37b:	83 c0 04             	add    $0x4,%eax
 37e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 381:	85 f6                	test   %esi,%esi
 383:	75 13                	jne    398 <printf+0xf5>
          s = "(null)";
 385:	be b8 04 00 00       	mov    $0x4b8,%esi
 38a:	eb 0c                	jmp    398 <printf+0xf5>
          putc(fd, *s);
 38c:	0f be d2             	movsbl %dl,%edx
 38f:	8b 45 08             	mov    0x8(%ebp),%eax
 392:	e8 79 fe ff ff       	call   210 <putc>
          s++;
 397:	46                   	inc    %esi
        while(*s != 0){
 398:	8a 16                	mov    (%esi),%dl
 39a:	84 d2                	test   %dl,%dl
 39c:	75 ee                	jne    38c <printf+0xe9>
      state = 0;
 39e:	be 00 00 00 00       	mov    $0x0,%esi
 3a3:	e9 27 ff ff ff       	jmp    2cf <printf+0x2c>
        putc(fd, *ap);
 3a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3ab:	0f be 17             	movsbl (%edi),%edx
 3ae:	8b 45 08             	mov    0x8(%ebp),%eax
 3b1:	e8 5a fe ff ff       	call   210 <putc>
        ap++;
 3b6:	83 c7 04             	add    $0x4,%edi
 3b9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 3bc:	be 00 00 00 00       	mov    $0x0,%esi
 3c1:	e9 09 ff ff ff       	jmp    2cf <printf+0x2c>
        putc(fd, c);
 3c6:	89 fa                	mov    %edi,%edx
 3c8:	8b 45 08             	mov    0x8(%ebp),%eax
 3cb:	e8 40 fe ff ff       	call   210 <putc>
      state = 0;
 3d0:	be 00 00 00 00       	mov    $0x0,%esi
 3d5:	e9 f5 fe ff ff       	jmp    2cf <printf+0x2c>
        putc(fd, '%');
 3da:	ba 25 00 00 00       	mov    $0x25,%edx
 3df:	8b 45 08             	mov    0x8(%ebp),%eax
 3e2:	e8 29 fe ff ff       	call   210 <putc>
        putc(fd, c);
 3e7:	89 fa                	mov    %edi,%edx
 3e9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ec:	e8 1f fe ff ff       	call   210 <putc>
      state = 0;
 3f1:	be 00 00 00 00       	mov    $0x0,%esi
 3f6:	e9 d4 fe ff ff       	jmp    2cf <printf+0x2c>
    }
  }
}
 3fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3fe:	5b                   	pop    %ebx
 3ff:	5e                   	pop    %esi
 400:	5f                   	pop    %edi
 401:	5d                   	pop    %ebp
 402:	c3                   	ret    
