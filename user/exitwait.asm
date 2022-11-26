
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
   7:	68 f4 03 00 00       	push   $0x3f4
   c:	6a 01                	push   $0x1
   e:	e8 80 02 00 00       	call   293 <printf>

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
  67:	68 64 04 00 00       	push   $0x464
  6c:	6a 01                	push   $0x1
  6e:	e8 20 02 00 00       	call   293 <printf>
    exit(N);
  73:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
  7a:	e8 d1 00 00 00       	call   150 <exit>

  for(; n > 0; n--)
  {
    if((pid = wait(&status)) < 0)
    {
      printf(1, "wait stopped early\n");
  7f:	83 ec 08             	sub    $0x8,%esp
  82:	68 10 04 00 00       	push   $0x410
  87:	6a 01                	push   $0x1
  89:	e8 05 02 00 00       	call   293 <printf>
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
  9d:	68 84 04 00 00       	push   $0x484
  a2:	6a 01                	push   $0x1
  a4:	e8 ea 01 00 00       	call   293 <printf>
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
  d3:	68 24 04 00 00       	push   $0x424
  d8:	6a 01                	push   $0x1
  da:	e8 b4 01 00 00       	call   293 <printf>
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
	printf(1,"fork test OK\n");
  f6:	83 ec 08             	sub    $0x8,%esp
  f9:	68 55 04 00 00       	push   $0x455
  fe:	6a 01                	push   $0x1
 100:	e8 8e 01 00 00       	call   293 <printf>
    if (WIFEXITED (status))
      printf (1, "Exited child %d, exitcode %d\n", pid, WEXITSTATUS (status));
    else if (WIFSIGNALED(status))
      printf (1, "Exited child (failure) %d, trap %d\n", pid, WEXITTRAP (status));
*/
}
 105:	83 c4 10             	add    $0x10,%esp
 108:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 10b:	c9                   	leave  
 10c:	c3                   	ret    
    printf(1, "wait got too many\n");
 10d:	83 ec 08             	sub    $0x8,%esp
 110:	68 42 04 00 00       	push   $0x442
 115:	6a 01                	push   $0x1
 117:	e8 77 01 00 00       	call   293 <printf>
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

00000200 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 200:	55                   	push   %ebp
 201:	89 e5                	mov    %esp,%ebp
 203:	83 ec 1c             	sub    $0x1c,%esp
 206:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 209:	6a 01                	push   $0x1
 20b:	8d 55 f4             	lea    -0xc(%ebp),%edx
 20e:	52                   	push   %edx
 20f:	50                   	push   %eax
 210:	e8 5b ff ff ff       	call   170 <write>
}
 215:	83 c4 10             	add    $0x10,%esp
 218:	c9                   	leave  
 219:	c3                   	ret    

0000021a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 21a:	55                   	push   %ebp
 21b:	89 e5                	mov    %esp,%ebp
 21d:	57                   	push   %edi
 21e:	56                   	push   %esi
 21f:	53                   	push   %ebx
 220:	83 ec 2c             	sub    $0x2c,%esp
 223:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 226:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 228:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 22c:	74 04                	je     232 <printint+0x18>
 22e:	85 d2                	test   %edx,%edx
 230:	78 3c                	js     26e <printint+0x54>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 232:	89 d1                	mov    %edx,%ecx
  neg = 0;
 234:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  }

  i = 0;
 23b:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 240:	89 c8                	mov    %ecx,%eax
 242:	ba 00 00 00 00       	mov    $0x0,%edx
 247:	f7 f6                	div    %esi
 249:	89 df                	mov    %ebx,%edi
 24b:	43                   	inc    %ebx
 24c:	8a 92 08 05 00 00    	mov    0x508(%edx),%dl
 252:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 256:	89 ca                	mov    %ecx,%edx
 258:	89 c1                	mov    %eax,%ecx
 25a:	39 d6                	cmp    %edx,%esi
 25c:	76 e2                	jbe    240 <printint+0x26>
  if(neg)
 25e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 262:	74 24                	je     288 <printint+0x6e>
    buf[i++] = '-';
 264:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 269:	8d 5f 02             	lea    0x2(%edi),%ebx
 26c:	eb 1a                	jmp    288 <printint+0x6e>
    x = -xx;
 26e:	89 d1                	mov    %edx,%ecx
 270:	f7 d9                	neg    %ecx
    neg = 1;
 272:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    x = -xx;
 279:	eb c0                	jmp    23b <printint+0x21>

  while(--i >= 0)
    putc(fd, buf[i]);
 27b:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 280:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 283:	e8 78 ff ff ff       	call   200 <putc>
  while(--i >= 0)
 288:	4b                   	dec    %ebx
 289:	79 f0                	jns    27b <printint+0x61>
}
 28b:	83 c4 2c             	add    $0x2c,%esp
 28e:	5b                   	pop    %ebx
 28f:	5e                   	pop    %esi
 290:	5f                   	pop    %edi
 291:	5d                   	pop    %ebp
 292:	c3                   	ret    

00000293 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 293:	55                   	push   %ebp
 294:	89 e5                	mov    %esp,%ebp
 296:	57                   	push   %edi
 297:	56                   	push   %esi
 298:	53                   	push   %ebx
 299:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 29c:	8d 45 10             	lea    0x10(%ebp),%eax
 29f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 2a2:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 2a7:	bb 00 00 00 00       	mov    $0x0,%ebx
 2ac:	eb 12                	jmp    2c0 <printf+0x2d>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 2ae:	89 fa                	mov    %edi,%edx
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
 2b3:	e8 48 ff ff ff       	call   200 <putc>
 2b8:	eb 05                	jmp    2bf <printf+0x2c>
      }
    } else if(state == '%'){
 2ba:	83 fe 25             	cmp    $0x25,%esi
 2bd:	74 22                	je     2e1 <printf+0x4e>
  for(i = 0; fmt[i]; i++){
 2bf:	43                   	inc    %ebx
 2c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c3:	8a 04 18             	mov    (%eax,%ebx,1),%al
 2c6:	84 c0                	test   %al,%al
 2c8:	0f 84 1d 01 00 00    	je     3eb <printf+0x158>
    c = fmt[i] & 0xff;
 2ce:	0f be f8             	movsbl %al,%edi
 2d1:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 2d4:	85 f6                	test   %esi,%esi
 2d6:	75 e2                	jne    2ba <printf+0x27>
      if(c == '%'){
 2d8:	83 f8 25             	cmp    $0x25,%eax
 2db:	75 d1                	jne    2ae <printf+0x1b>
        state = '%';
 2dd:	89 c6                	mov    %eax,%esi
 2df:	eb de                	jmp    2bf <printf+0x2c>
      if(c == 'd'){
 2e1:	83 f8 25             	cmp    $0x25,%eax
 2e4:	0f 84 cc 00 00 00    	je     3b6 <printf+0x123>
 2ea:	0f 8c da 00 00 00    	jl     3ca <printf+0x137>
 2f0:	83 f8 78             	cmp    $0x78,%eax
 2f3:	0f 8f d1 00 00 00    	jg     3ca <printf+0x137>
 2f9:	83 f8 63             	cmp    $0x63,%eax
 2fc:	0f 8c c8 00 00 00    	jl     3ca <printf+0x137>
 302:	83 e8 63             	sub    $0x63,%eax
 305:	83 f8 15             	cmp    $0x15,%eax
 308:	0f 87 bc 00 00 00    	ja     3ca <printf+0x137>
 30e:	ff 24 85 b0 04 00 00 	jmp    *0x4b0(,%eax,4)
        printint(fd, *ap, 10, 1);
 315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 318:	8b 17                	mov    (%edi),%edx
 31a:	83 ec 0c             	sub    $0xc,%esp
 31d:	6a 01                	push   $0x1
 31f:	b9 0a 00 00 00       	mov    $0xa,%ecx
 324:	8b 45 08             	mov    0x8(%ebp),%eax
 327:	e8 ee fe ff ff       	call   21a <printint>
        ap++;
 32c:	83 c7 04             	add    $0x4,%edi
 32f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 332:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 335:	be 00 00 00 00       	mov    $0x0,%esi
 33a:	eb 83                	jmp    2bf <printf+0x2c>
        printint(fd, *ap, 16, 0);
 33c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 33f:	8b 17                	mov    (%edi),%edx
 341:	83 ec 0c             	sub    $0xc,%esp
 344:	6a 00                	push   $0x0
 346:	b9 10 00 00 00       	mov    $0x10,%ecx
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	e8 c7 fe ff ff       	call   21a <printint>
        ap++;
 353:	83 c7 04             	add    $0x4,%edi
 356:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 359:	83 c4 10             	add    $0x10,%esp
      state = 0;
 35c:	be 00 00 00 00       	mov    $0x0,%esi
        ap++;
 361:	e9 59 ff ff ff       	jmp    2bf <printf+0x2c>
        s = (char*)*ap;
 366:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 369:	8b 30                	mov    (%eax),%esi
        ap++;
 36b:	83 c0 04             	add    $0x4,%eax
 36e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 371:	85 f6                	test   %esi,%esi
 373:	75 13                	jne    388 <printf+0xf5>
          s = "(null)";
 375:	be a8 04 00 00       	mov    $0x4a8,%esi
 37a:	eb 0c                	jmp    388 <printf+0xf5>
          putc(fd, *s);
 37c:	0f be d2             	movsbl %dl,%edx
 37f:	8b 45 08             	mov    0x8(%ebp),%eax
 382:	e8 79 fe ff ff       	call   200 <putc>
          s++;
 387:	46                   	inc    %esi
        while(*s != 0){
 388:	8a 16                	mov    (%esi),%dl
 38a:	84 d2                	test   %dl,%dl
 38c:	75 ee                	jne    37c <printf+0xe9>
      state = 0;
 38e:	be 00 00 00 00       	mov    $0x0,%esi
 393:	e9 27 ff ff ff       	jmp    2bf <printf+0x2c>
        putc(fd, *ap);
 398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 39b:	0f be 17             	movsbl (%edi),%edx
 39e:	8b 45 08             	mov    0x8(%ebp),%eax
 3a1:	e8 5a fe ff ff       	call   200 <putc>
        ap++;
 3a6:	83 c7 04             	add    $0x4,%edi
 3a9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 3ac:	be 00 00 00 00       	mov    $0x0,%esi
 3b1:	e9 09 ff ff ff       	jmp    2bf <printf+0x2c>
        putc(fd, c);
 3b6:	89 fa                	mov    %edi,%edx
 3b8:	8b 45 08             	mov    0x8(%ebp),%eax
 3bb:	e8 40 fe ff ff       	call   200 <putc>
      state = 0;
 3c0:	be 00 00 00 00       	mov    $0x0,%esi
 3c5:	e9 f5 fe ff ff       	jmp    2bf <printf+0x2c>
        putc(fd, '%');
 3ca:	ba 25 00 00 00       	mov    $0x25,%edx
 3cf:	8b 45 08             	mov    0x8(%ebp),%eax
 3d2:	e8 29 fe ff ff       	call   200 <putc>
        putc(fd, c);
 3d7:	89 fa                	mov    %edi,%edx
 3d9:	8b 45 08             	mov    0x8(%ebp),%eax
 3dc:	e8 1f fe ff ff       	call   200 <putc>
      state = 0;
 3e1:	be 00 00 00 00       	mov    $0x0,%esi
 3e6:	e9 d4 fe ff ff       	jmp    2bf <printf+0x2c>
    }
  }
}
 3eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3ee:	5b                   	pop    %ebx
 3ef:	5e                   	pop    %esi
 3f0:	5f                   	pop    %edi
 3f1:	5d                   	pop    %ebp
 3f2:	c3                   	ret    
